#!/bin/sh

tiv_env_file="/etc/Tivoli/setup_env.sh"
if [ -f "$tiv_env_file" ]; then
  . $tiv_env_file
fi

echo x > /tmp/x
for rim in `wlookup -aLr RIM`
   do echo $rim
      wrimtest -l $rim </tmp/x
      echo
   done
rm /tmp/x

