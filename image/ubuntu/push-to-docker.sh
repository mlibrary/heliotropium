#!/bin/sh
IMAGE_NAME_VERSION="ubuntu:latest"
echo $IMAGE_NAME_VERSION
DOCKER_IMAGE_NAME_VERSION="${DOCKER_USER}/${IMAGE_NAME_VERSION}"
echo $DOCKER_IMAGE_NAME_VERSION
docker tag $IMAGE_NAME_VERSION $DOCKER_IMAGE_NAME_VERSION
docker push $DOCKER_IMAGE_NAME_VERSION