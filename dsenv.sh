#!/bin/bash
if [[ "$1" != "stop" && "$1" != "start" ]]; then 
  echo "usage : $0 start or stop"
  exit 1
fi

CURRENT_DIR=$(pwd)
DSENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export DS_HOME=${DS_HOME:-$CURRENT_DIR}
export DS_IMAGE=${DS_IMAGE:-dsenv}


if [[ $1 == "start" ]]; then 
  for file in $DSENV_DIR/rcfiles/*; do
    cp -n $file $CURRENT_DIR/.`basename $file`
  done
  if [ ! -f $CURRENT_DIR/.profile ]; then
    ln -s $CURRENT_DIR/.bashrc $CURRENT_DIR/.profile 
  fi
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p datashare up -d
elif [[ "$1" == "stop" ]]; then 
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p datashare stop
fi
