#!/bin/sh
export GITHUB_PACKAGES_READ=`echo "${GITHUB_USER}:${GITHUB_READ_PACKAGES_TOKEN}" | base64`
echo "$GITHUB_PACKAGES_READ"
cd $(dirname "$0")
pwd
envsubst < github-packages-read.yaml.envsubst > github-packages-read.yaml