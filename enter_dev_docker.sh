#!/bin/bash

docker exec -ti $1 script -q -c "/sbin/setuser dev /bin/bash -c 'cd ~ && /bin/bash'" /dev/null
