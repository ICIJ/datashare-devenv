#!/bin/bash

PROFILE_SHELL_WITH_PATH=$SHELL
DEV_USER=dev

if [ -z "$PROFILE_SHELL_WITH_PATH" ]; then
  PROFILE_SHELL_WITH_PATH=$(ps -o command -p $PPID | grep -v COMMAND | sed 's/\-//g')
fi

PROFILE_SHELL=$(basename $PROFILE_SHELL_WITH_PATH)
if [ -z "$DSENV_CONTAINER" ]; then
  DSENV_CONTAINER=$(docker ps | grep dsenv_dsenv_ | head -1 | awk '{print $NF}')
elif [ "discourse_dev" == "$DSENV_CONTAINER" ]; then
  DEV_USER=discourse
fi

if [ -z "$PROFILE_SHELL" ]; then
  PROFILE_SHELL=bash
fi

if [ "$PROFILE_SHELL" == "zsh" ]; then
  if ! grep -q 'default-shell /bin/zsh' .tmux.conf ; then
    echo "set-option -g default-shell /bin/zsh" >> .tmux.conf
  fi
fi

docker exec -ti "$DSENV_CONTAINER" script -q -c "/usr/bin/sudo HOME=/home/${DEV_USER} -E -u ${DEV_USER} /bin/$PROFILE_SHELL -c 'cd ~ && /bin/$PROFILE_SHELL'" /dev/null

