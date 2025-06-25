#!/bin/bash
#
#########################
# Method #1 - echo & read
#
echo -n "What is your name? "
read userName
#
echo "Hello "$userName
#
#########################
# Method #2 - read -p
#
read -p "What is your favourite shell? " favouriteShell
#
echo "I also like" $favouriteShell
#
exit

