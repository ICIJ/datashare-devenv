#!/bin/bash

USER_UID=$(id -u)
USER_GID=$(id -g)

docker build --build-arg user_uid=$USER_UID --build-arg user_gid=$USER_GID -t dsenv .
