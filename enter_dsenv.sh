#!/bin/bash
DEV_USER=dev

# When no DSENV_CONTAINER given, we use the first instance of `dsenv_workspace_`
if [ -z "$DSENV_CONTAINER" ]; then
  DSENV_CONTAINER=$(docker ps | grep dsenv_workspace_ | head -1 | awk '{print $NF}')
elif [ "discourse_dev" == "$DSENV_CONTAINER" ]; then
  DEV_USER=discourse
fi

# When DSENV_CONTAINER is different from `dsenv_workspace_`, we always use bash
if [[ $DSENV_CONTAINER != dsenv_workspace_* ]]; then
  PROFILE_SHELL_WITH_PATH=bash
else
  PROFILE_SHELL_WITH_PATH=$SHELL
  if [ -z "$PROFILE_SHELL_WITH_PATH" ]; then
    PROFILE_SHELL_WITH_PATH=$(ps -o command -p $PPID | grep -v COMMAND | sed 's/\-//g')
  fi
fi

PROFILE_SHELL=$(basename $PROFILE_SHELL_WITH_PATH)
if [ -z "$PROFILE_SHELL" ]; then
  PROFILE_SHELL=bash
fi

if [ "$PROFILE_SHELL" == "zsh" ]; then
  if ! grep -q 'default-shell /bin/zsh' .tmux.conf ; then
    echo "set-option -g default-shell /bin/zsh" >> .tmux.conf
  fi
fi

docker exec -ti "$DSENV_CONTAINER" script -q -c "/usr/bin/sudo HOME=/home/${DEV_USER} -E -u ${DEV_USER} /bin/$PROFILE_SHELL -c 'cd ~ && /bin/$PROFILE_SHELL'" /dev/null
