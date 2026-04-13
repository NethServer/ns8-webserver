#!/bin/bash

# Terminate on error
set -e
# Enable job control so each background job gets its own process group (needed for kill_all_builds)
set -m

# Prepare variables for later use
images=()
# The image will be pushed to GitHub container registry
repobase="${REPOBASE:-ghcr.io/nethserver}"
# Configure the image name
reponame="webserver"

# PHP versions to build: "version" "base-image" (pairs)
declare -a PHP_VERSIONS=(
    "8.5" "docker.io/library/php:8.5.4-fpm-bookworm"
    "8.4" "docker.io/library/php:8.4.19-fpm-bookworm"
    "8.3" "docker.io/library/php:8.3.30-fpm-bookworm"
    "8.2" "docker.io/library/php:8.2.30-fpm-bookworm"
    "8.1" "docker.io/library/php:8.1.34-fpm-bookworm"
    "8.0" "docker.io/library/php:8.0.30-fpm-bullseye"
    "7.4" "docker.io/library/php:7.4.33-fpm-bullseye"
)

# Secure temp dir for FIFO (avoids TOCTOU race of mktemp -u)
tmpdir=$(mktemp -d)
# Early trap: ensure tmpdir is cleaned even if mkfifo or exec below fails
trap 'rm -rf "${tmpdir}"' EXIT
result_fifo="${tmpdir}/result.fifo"
mkfifo "${result_fifo}"
# Open FIFO read-write to avoid blocking on open (no writer needed yet)
exec 3<> "${result_fifo}"

declare -a pids=()

kill_all_builds() {
    for pid in "${pids[@]}"; do
        # With set -m each wrapper runs in its own process group (PGID=pid);
        # kill -- -pid sends SIGTERM to the whole group (wrapper + nested subshell + podman + sed)
        kill -- -"${pid}" 2>/dev/null || true
    done
}
# Full trap replaces the early one: also kill builds and close FD 3 on exit
trap 'kill_all_builds; exec 3<&-; exec 3>&-; rm -rf "${tmpdir}"' EXIT
trap 'kill_all_builds; exit 130' INT
trap 'kill_all_builds; exit 143' TERM

# Create a new empty container image and add static assets that don't depend on builds
container=$(buildah from scratch)
buildah add "${container}" imageroot /imageroot

# Limit parallel builds to available CPU cores to avoid contention on CI runners
max_parallel=$(nproc)
active_jobs=0

# Launch PHP FPM builds in parallel (throttled to max_parallel)
for (( i=0; i<${#PHP_VERSIONS[@]}; i+=2 )); do
    version="${PHP_VERSIONS[$i]}"
    php_image="${PHP_VERSIONS[$((i+1))]}"
    echo "Starting build php${version}-fpm (${php_image})..."
    (
        set +e
        # Nested build subshell: set +e so PIPESTATUS is always reachable;
        # exit with podman's status only — sed log-prefix failures are ignored.
        (
            set +e
            podman build \
                --force-rm \
                --layers \
                --cache-from "${repobase}/php${version}-fpm" \
                --tag "${repobase}/php${version}-fpm" \
                --build-arg "PHP_VERSION_IMAGE=${php_image}" \
                container 2>&1 | sed -u "s/^/[php${version}] /"
            exit "${PIPESTATUS[0]}"
        ) &
        build_pid=$!
        # wait is valid here: build_pid is a direct child of this wrapper subshell.
        # This captures the exit code even if build_pid is SIGKILLed — the kernel still provides it.
        wait "${build_pid}"
        printf "%s %d\n" "${version}" "$?" > "${result_fifo}" 2>/dev/null || true
    ) &
    pids+=("$!")
    active_jobs=$(( active_jobs + 1 ))
    if (( active_jobs >= max_parallel )); then
        wait -n 2>/dev/null || true
        active_jobs=$(( active_jobs - 1 ))
    fi
done

# Launch Node UI build in parallel with PHP builds
echo "Starting UI build with Node..."
(
    set +e
    (
        set +e
        # Reuse existing nodebuilder-webserver container, to speed up builds
        if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-webserver; then
            echo "[node] Pulling NodeJS runtime..."
            buildah from --name nodebuilder-webserver -v "${PWD}:/usr/src:Z" docker.io/library/node:24-slim
        fi
        buildah run --env="NODE_OPTIONS=--openssl-legacy-provider" nodebuilder-webserver \
            sh -c "cd /usr/src/ui && yarn install && yarn build" 2>&1 | sed -u "s/^/[node] /"
        exit "${PIPESTATUS[0]}"
    ) &
    build_pid=$!
    wait "${build_pid}"
    printf "%s %d\n" "node" "$?" > "${result_fifo}" 2>/dev/null || true
) &
pids+=("$!")

# Read results in completion order; stop everything on first failure
total=${#pids[@]}
for (( completed=0; completed<total; completed++ )); do
    if ! read -r done_version done_result <&3; then
        echo "[main] Failed to read build result from result FIFO"
        exit 1
    fi
    if [[ -z "${done_version}" || -z "${done_result}" || ! "${done_result}" =~ ^-?[0-9]+$ ]]; then
        echo "[main] Malformed build result from result FIFO: version='${done_version}' result='${done_result}'"
        exit 1
    fi
    if [[ "${done_result}" -ne 0 ]]; then
        echo "[${done_version}] BUILD FAILED - killing remaining builds..."
        exit 1
    fi
    echo "[${done_version}] BUILD OK"
done

# Reap all background build jobs to avoid zombies
wait "${pids[@]}"

for (( i=0; i<${#PHP_VERSIONS[@]}; i+=2 )); do
    images+=("${repobase}/php${PHP_VERSIONS[$i]}-fpm")
done

# Add UI dist produced by the Node build (must be after all builds complete)
buildah add "${container}" ui/dist /ui
# Setup the entrypoint, ask to reserve one TCP port with the label and set a rootless container
buildah config --entrypoint=/ \
    --label="org.nethserver.authorizations=node:fwadm traefik@node:routeadm" \
    --label="org.nethserver.tcp-ports-demand=2" \
    --label="org.nethserver.rootfull=0" \
    --label="org.nethserver.images=docker.io/nginx:1.28.0-alpine docker.io/drakkan/sftpgo:v2.7.1-alpine" \
    "${container}"
# Commit the image
buildah commit "${container}" "${repobase}/${reponame}"

# Append the image URL to the images array
images+=("${repobase}/${reponame}")

#
# NOTICE:
#
# It is possible to build and publish multiple images.
#
# 1. create another buildah container
# 2. add things to it and commit it
# 3. append the image url to the images array
#

#
# Setup CI when pushing to Github. 
# Warning! docker::// protocol expects lowercase letters (,,)
if [[ -n "${CI}" ]]; then
    # Set output value for Github Actions
    printf "::set-output name=images::%s\n" "${images[*],,}"
else
    # Just print info for manual push
    printf "Publish the images with:\n\n"
    for image in "${images[@],,}"; do printf "  buildah push %s docker://%s:%s\n" "${image}" "${image}" "${IMAGETAG:-latest}" ; done
    printf "\n"
fi
