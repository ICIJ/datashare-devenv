#!/bin/bash
PROFILE_SHELL_WITH_PATH=$(ps -o command -p $PPID | grep -v COMMAND| sed 's/\-//g')
PROFILE_SHELL=$(basename $PROFILE_SHELL_WITH_PATH)
if test -n "$PROFILE_VERSION"; then
  PROFILE_SHELL=bash
fi

docker exec -ti datashare_dev_1 script -q -c "/sbin/setuser dev /bin/$PROFILE_SHELL -c 'cd ~ && /bin/$PROFILE_SHELL'" /dev/null
