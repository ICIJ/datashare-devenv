#!/bin/bash

if test -n "$ZSH_VERSION"; then
  PROFILE_SHELL=zsh
elif test -n "$BASH_VERSION"; then
  PROFILE_SHELL=bash
else 
  echo "unknown shell type, using bash"
  PROFILE_SHELL=bash
fi

docker exec -ti datashare_dev_1 script -q -c "/sbin/setuser dev /bin/$PROFILE_SHELL -c 'cd ~ && /bin/$PROFILE_SHELL'" /dev/null
