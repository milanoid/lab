#!/bin/bash
#
# Demonstrates handling
# input via passed parameters
#
if [ -n "$1" ]
 then echo "The first passed parameter is: "$1
 else
  echo "No parameters passed to this script: "$0
  exit
fi
#
if [ -n "$2" ]
 then echo "The second passed parameter is $2"
fi
#
if [ -n "$3" ]
 then echo "The third passed parameter is $3"
fi
#
exit
