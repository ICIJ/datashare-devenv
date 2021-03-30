#!/bin/bash

CURRENT_DIR=$(pwd)
DSENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export DS_HOME=${DS_HOME:-$CURRENT_DIR}
export DS_IMAGE=${DS_IMAGE:-dsenv}
export DS_DNS=${DS_DNS:-172.20.0.2}
export TMUX=${TMUX}

if [ -f /.dockerenv ]; then
  echo -e "\e[0;31mYou're trying to run this script from inside the devenv 😵\e[0m"
  exit
fi

if [[ "$(docker images -q ${DS_IMAGE} 2> /dev/null)" == "" ]]; then
  # do something
  echo "Devenv image doesn't existing yet. We need to build it!"
  docker build -t dsenv ${DSENV_DIR}
fi

if [[ $DS_HOME != $HOME ]] ; then
  echo -e "\e[0;33mYou're about to start the devenv from a directory different from your homedir.\e[0m"
  while true; do
    read -p "Do you want use your homedir instead? [Y/n/c]" yn
    case $yn in
      "" ) export DS_HOME=${HOME}; break;;
      [Yy]* ) export DS_HOME=${HOME}; break;;
      [Nn]* ) break;;
      [Cc]* ) exit;;
      * ) echo -e "\e[0;31mPlease answer yes, no or cancel.\e[0m";;
    esac
  done
fi

if [[ $1 == "start"  ]] || [[ $1 == "up"  ]] || [[ $1 == "enter" ]]; then
  for file in $DSENV_DIR/rcfiles/*; do
    cp -n $file $DS_HOME/.`basename $file`
  done
  if [ ! -f $DS_HOME/.profile ]; then
    ln -s $DS_HOME/.bashrc $DS_HOME/.profile
  fi

  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv up -d ${@:2}

  if [ $1 == ${@: -1} ] || [[ ${@: -1} == "workspace" ]]; then
    DSENV_BACKEND_HOST="http://$(docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv port workspace 8080)"
    DSENV_FRONTEND_HOST="http://$(docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv port workspace 9009)"
    echo -e "\e[2mBackend interface is exposed on: \e[0m$DSENV_BACKEND_HOST"
    echo -e "\e[2mFrontend interface is exposed on: \e[0m$DSENV_FRONTEND_HOST"
  fi

  if [[ $1 == "enter" ]]; then
    ${DSENV_DIR}/enter_dsenv.sh
  fi

elif [[ "$1" == "stop" ]]; then
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv stop
elif [[ "$1" == "destroy" ]]; then
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv down
else
  docker-compose -f ${DSENV_DIR}/docker-compose.yml -p dsenv $@
fi
