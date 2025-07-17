#!/bin/bash
echo "test command: Does the /etc/passwd file exist?"
#
if test -f /etc/passwd
 then echo "The file exists"
 else echo "Thee file does not exist"
fi
#
echo
echo "[ ] command: Does the /etc/passwd file exist?"
if [ -f /etc/passwd ]
 then echo "The file exists"
 else echo "Thee file does not exist"
fi
#
echo
echo "End of script"
#
exit
