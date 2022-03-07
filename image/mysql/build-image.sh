#!/bin/sh
OPT_TAG="-t mysql:latest"
echo "${OPT_TAG}"
ARG_PATH=$(dirname "$0")
echo "${ARG_PATH}"
docker build ${OPT_TAG} ${ARG_PATH}