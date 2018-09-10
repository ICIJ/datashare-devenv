#!/bin/bash

PROFILE_SHELL_WITH_PATH=$(ps -o command -p $PPID | grep -v COMMAND| sed 's/\-//g')
PROFILE_SHELL=$(basename $PROFILE_SHELL_WITH_PATH)

if [ -z "$PROFILE_SHELL" ]; then
  PROFILE_SHELL=bash
fi

if [ "$PROFILE_SHELL" == "zsh" ]; then
  if ! grep -q 'default-shell /bin/zsh' .tmux.conf ; then
    echo "set-option -g default-shell /bin/zsh" >> .tmux.conf
  fi
fi

docker exec -ti datashare_dsenv_1 script -q -c "/sbin/setuser dev /bin/$PROFILE_SHELL -c 'cd ~ && /bin/$PROFILE_SHELL'" /dev/null
