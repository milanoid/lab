#/bin/bash
#
# Demonstration script showing 
# the use of built commands
#
echo "Method 1: \$()"
#
file $(ls /etc/s*.conf)
#
echo
echo "Method 2: backticks"
#
file `ls /etc/s*.conf`
#
echo
echo "Method 3: xargs"
#
ls /etc/s*.conf | xargs file
#
echo
echo "Method 4a: Command substitution"
#
commandSubA="file /etc/s*.conf"
echo $commandSubA
$commandSubA
#
echo
echo "Method 4b: True Command substitution"
#
commandSubB=$(file /etc/s*.conf)
echo $commandSubB
#
exit
