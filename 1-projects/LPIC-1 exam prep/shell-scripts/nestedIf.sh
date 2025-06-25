#!/bin/bash
if ls /etc/S*.conf
 then 
  echo 
  echo "This command worked"
  echo
 else
  echo
  echo "This command failed"
  echo
  echo "Trying this instead: ls /etc/s*.conf"
  #
  if ls /etc/s*.conf
   then
    echo
    echo "Command worked"
   else
    echo
    echo "Command failed"
    echo "Check command syntax"
 fi
fi
echo
echo "End of script"
#
exit
