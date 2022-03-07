#!/bin/sh
cd $(dirname "$0")
pwd
envsubst < ubuntu.yaml.envsubst > ubuntu.yaml