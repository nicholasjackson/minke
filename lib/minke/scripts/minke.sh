#!/bin/bash
DOCKER_SOCK="/var/run/docker.sock:/var/run/docker.sock"
RVM_COMMAND="source /usr/local/rvm/scripts/rvm"
ERROR="Please specify a command e.g. ./minke.sh rake app:test"
COMMAND=""
NEW_UUID=$(base64 /dev/urandom | tr -d '/+' | head -c 32 | tr '[:upper:]' '[:lower:]')
GEMSET='minkegems'
GEMSETFOLDER="/usr/local/rvm/gems/ruby-2.3.1@${GEMSET}"

if [ "$1" == '' ]; then
  echo $ERROR;
  exit 1;
fi

COMMAND=$*
DIR=$(dirname `pwd`)

echo "Running command: ${COMMAND}"
DOCKER_RUN="docker run --rm --net=minke_${NEW_UUID} -v ${DOCKER_SOCK} -v ${DIR}:${DIR} -v ${DIR}/_build/vendor/gems:${GEMSETFOLDER} -e DOCKER_NETWORK=minke_${NEW_UUID} -w ${DIR}/_build nicholasjackson/minke /bin/bash -c '${RVM_COMMAND} && ${COMMAND}'"
echo $DOCKER_RUN
