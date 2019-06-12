#!/bin/bash

PROFILE_SHELL_WITH_PATH=$SHELL

if [ -z "$PROFILE_SHELL_WITH_PATH" ]; then
  PROFILE_SHELL_WITH_PATH=$(ps -o command -p $PPID | grep -v COMMAND | sed 's/\-//g')
fi

PROFILE_SHELL=$(basename $PROFILE_SHELL_WITH_PATH)
DSENV_CONTAINER=$(docker ps | grep dsenv_dsenv_ | head -1 | awk '{print $NF}')

if [ -z "$PROFILE_SHELL" ]; then
  PROFILE_SHELL=bash
fi

if [ "$PROFILE_SHELL" == "zsh" ]; then
  if ! grep -q 'default-shell /bin/zsh' .tmux.conf ; then
    echo "set-option -g default-shell /bin/zsh" >> .tmux.conf
  fi
fi

docker exec -ti "$DSENV_CONTAINER" script -q -c "/sbin/setuser dev /bin/$PROFILE_SHELL -c 'cd ~ && bash /opt/hello.sh && /bin/$PROFILE_SHELL'" /dev/null
