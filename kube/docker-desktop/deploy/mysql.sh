#!/bin/sh
cd $(dirname "$0")
pwd
envsubst < mysql.yaml.envsubst > mysql.yaml