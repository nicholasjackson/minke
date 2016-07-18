#!/bin/bash
DOCKER_SOCK="/var/run/docker.sock:/var/run/docker.sock"
RVM_COMMAND="source /usr/local/rvm/scripts/rvm"
ERROR="Please specify a command e.g. ./minke.sh rake app:test"
COMMAND=""
NEW_UUID=$(base64 /dev/urandom | tr -d '/+' | head -c 32 | tr '[:upper:]' '[:lower:]')
NETWORK
GEMSET='minkegems'
GEMSETFOLDER="/usr/local/rvm/gems/ruby-2.3.1@${GEMSET}"

if [ "$1" == '' ]; then
  echo $ERROR;
  exit 1;
fi

COMMAND=$*

if [[ $1 == \ -g* ]]; then
  echo "Generating new template"
  DIR=${PWD}
  DOCKER_RUN="docker run --rm -v ${DOCKER_SOCK} -v ${DIR}:${DIR} -v ${DIR}/_build/vendor/gems:${GEMSETFOLDER} -e DOCKER_NETWORK=minke_${NEW_UUID} -w ${DIR} nicholasjackson/minke /bin/bash -c '${RVM_COMMAND} && bundle install && minke ${COMMAND}'"
  eval "${DOCKER_RUN}"
fi

if [[ $1 != \ -g* ]]; then
  DIR=$(dirname `pwd`)
  DOCKER_RUN="docker run --rm --net=minke_${NEW_UUID} -v ${DOCKER_SOCK} -v ${DIR}:${DIR} -v ${DIR}/_build/vendor/gems:${GEMSETFOLDER} -e DOCKER_NETWORK=minke_${NEW_UUID} -w ${DIR}/_build nicholasjackson/minke /bin/bash -c '${RVM_COMMAND} && ${COMMAND}'"

  echo "Running command: ${COMMAND}"

  eval "docker network create minke_${NEW_UUID}"
  eval "${DOCKER_RUN}"
fi
