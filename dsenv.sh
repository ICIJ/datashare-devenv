#!/bin/bash

CURRENT_DIR=$(pwd)
DSENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export DS_HOME=${DS_HOME:-$CURRENT_DIR}
export DS_IMAGE=${DS_IMAGE:-dsenv}
export DS_DNS=${DS_DNS:-172.20.0.2}
export TMUX=${TMUX}

if [[ "$(docker images -q ${DS_IMAGE} 2> /dev/null)" == "" ]]; then
  # do something
  echo "Devenv image doesn't existing yet. We need to build it!"
  docker build -t dsenv ${DSENV_DIR}
fi

if [[ $1 == "start"  ]] || [[ $1 == "up"  ]] || [[ $1 == "enter" ]]; then
  for file in $DSENV_DIR/rcfiles/*; do
    cp -n $file $CURRENT_DIR/.`basename $file`
  done
  if [ ! -f $CURRENT_DIR/.profile ]; then
    ln -s $CURRENT_DIR/.bashrc $CURRENT_DIR/.profile
  fi
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv up -d
  DSENV_BACKEND_HOST="http://$(docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv port dsenv 8080)"
  DSENV_FRONTEND_HOST="http://$(docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv port dsenv 9009)"

  if [[ $1 == "enter" ]]; then
    echo -e "\e[2mBackend interface is exposed on: \e[0m$DSENV_BACKEND_HOST"
    echo -e "\e[2mFrontend interface is exposed on: \e[0m$DSENV_FRONTEND_HOST"
    ${DSENV_DIR}/enter_dsenv.sh
  fi

elif [[ "$1" == "stop" ]]; then
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv stop
elif [[ "$1" == "destroy" ]]; then
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv down
else
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv $@
fi
