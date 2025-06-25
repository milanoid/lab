#!/bin/bash
loopVar=1
until [ $loopVar -eq 100000 ]
 do
  echo "The number is: "$loopVar
  loopVar=$[ $loopVar * 10 ]
 done
exit
