#!/bin/sh
tiv_env_file="/etc/Tivoli/setup_env.sh"
if [ -f "$tiv_env_file" ]; then
  . $tiv_env_file
fi
unset CHILD_OF_OSERV
eval $*
