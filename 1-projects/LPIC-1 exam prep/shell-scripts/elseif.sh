#!/bin/bash
echo "Trying command: ls /etc/S*.conf"
echo
#
if ls /etc/S*.conf
 then
  echo
  echo "This command works"
  echo
 elif ls /etc/s*.conf
  then
   echo
   echo "Use this command instead: ls /etc/s*.conf"
fi
echo
echo "End of script"
#
exit
