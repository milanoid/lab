#!/bin/bash
#
cat $HOME/scripts/colors.txt | while read fileLine
do
 echo "Color in this line is: "$fileLine
done
#
exit
