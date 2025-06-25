#!/bin/bash
#
#
for loopVar in A B C D E F
 do
  echo "The letter is: "$loopVar
 done

# with sequence

for loopVar in $(seq 1 10)
 do
  echo "Looping over variable loopVar:"$loopVar
 done

exit
