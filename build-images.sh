#!/bin/bash

# Terminate on error
set -e

# Prepare variables for later use
images=()
# The image will be pushed to GitHub container registry
repobase="${REPOBASE:-ghcr.io/nethserver}"
# Configure the image name
reponame="webserver"

# Function to build PHP FPM images
build_php_image() {
    local version=$1
    local php_image=$2
    
    podman build \
        --force-rm \
        --layers \
        --tag "${repobase}/php${version}-fpm" \
        --build-arg "PHP_VERSION_IMAGE=${php_image}" \
        container
    
    images+=("${repobase}/php${version}-fpm")
}

# Build all PHP FPM images
build_php_image "8.5" "docker.io/library/php:8.5.4-fpm-bookworm"
build_php_image "8.4" "docker.io/library/php:8.4.19-fpm-bookworm"
build_php_image "8.3" "docker.io/library/php:8.3.30-fpm-bookworm"
build_php_image "8.2" "docker.io/library/php:8.2.30-fpm-bookworm"
build_php_image "8.1" "docker.io/library/php:8.1.34-fpm-bookworm"
build_php_image "8.0" "docker.io/library/php:8.0.30-fpm-bullseye"
build_php_image "7.4" "docker.io/library/php:7.4.33-fpm-bullseye"

# Create a new empty container image
container=$(buildah from scratch)

# Reuse existing nodebuilder-webserver container, to speed up builds
if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-webserver; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-webserver -v "${PWD}:/usr/src:Z" docker.io/library/node:24-slim
fi

echo "Build static UI files with node..."
buildah run --env="NODE_OPTIONS=--openssl-legacy-provider" nodebuilder-webserver sh -c "cd /usr/src/ui && yarn install && yarn build"

# Add imageroot directory to the container image
buildah add "${container}" imageroot /imageroot
buildah add "${container}" ui/dist /ui
# Setup the entrypoint, ask to reserve one TCP port with the label and set a rootless container
buildah config --entrypoint=/ \
    --label="org.nethserver.authorizations=node:fwadm traefik@node:routeadm" \
    --label="org.nethserver.tcp-ports-demand=2" \
    --label="org.nethserver.rootfull=0" \
    --label="org.nethserver.images=docker.io/nginx:1.28.0-alpine docker.io/drakkan/sftpgo:v2.7.0-alpine" \
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
