#!/bin/bash

# Terminate on error
set -e

# Prepare variables for later use
images=()
# The image will be pushed to GitHub container registry
repobase="${REPOBASE:-ghcr.io/nethserver}"
# Configure the image name
reponame="webserver"

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php8.4-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:8.4.14-fpm-trixie" \
    container

images+=("${repobase}/php8.4-fpm")

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php8.3-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:8.3.27-fpm-trixie" \
    container

images+=("${repobase}/php8.3-fpm")

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php8.2-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:8.2.29-fpm-trixie" \
    container

images+=("${repobase}/php8.2-fpm")

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php8.1-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:8.1.33-fpm-trixie" \
    container

images+=("${repobase}/php8.1-fpm")

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php8.0-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:8.0.30-fpm-bullseye" \
    container

images+=("${repobase}/php8.0-fpm")

podman build \
    --force-rm \
    --layers \
    --tag "${repobase}/php7.4-fpm" \
    --build-arg "PHP_VERSION_IMAGE=docker.io/library/php:7.4.33-fpm-bullseye" \
    container

images+=("${repobase}/php7.4-fpm")

# Create a new empty container image
container=$(buildah from scratch)

# Reuse existing nodebuilder-webserver container, to speed up builds
if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-webserver; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-webserver -v "${PWD}:/usr/src:Z" docker.io/library/node:18-slim
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
    --label="org.nethserver.images=docker.io/nginx:1.28.0-alpine docker.io/drakkan/sftpgo:v2.6.6-alpine" \
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
