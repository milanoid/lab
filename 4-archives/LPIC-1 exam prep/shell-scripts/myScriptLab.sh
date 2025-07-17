#!/bin/bash
# Section-1 Lab
#
# My practice shell script
#
echo "This is my practice shell script"
echo
echo -n "My current working directory is: "
pwd
#
echo
if [ -n "$1" ]
 then echo "I passed this parameter to the script: "$1
else echo "I did not pass a parameter to this script "$0
fi
#
userName="0"
#
while [ $userName = "0" ]
do
 read -p "Enter your username: " userName
done
exit
