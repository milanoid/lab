#!/bin/bash
loopVar=1

while [ $loopVar -ne 10 ]
 do
  echo  "The number is: "$loopVar
  loopVar=$[ $loopVar +1 ]
 done
exit
