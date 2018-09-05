#!/bin/bash

if [[ "$1" != "stop" && "$1" != "start" ]]; then 
  echo "usage : $0 start or stop"
  exit 1
fi

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export DS_HOME=${DS_HOME:-`pwd`}
export DS_IMAGE=${DS_IMAGE:-dsdev}

if [[ $1 == "start" ]]; then 
  docker-compose -f ${CURDIR}/docker-compose.yml -p datashare up -d
elif [[ "$1" == "stop" ]]; then 
  docker-compose -f ${CURDIR}/docker-compose.yml -p datashare stop
fi
