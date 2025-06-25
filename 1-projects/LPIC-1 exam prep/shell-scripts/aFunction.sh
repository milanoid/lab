#!/bin/bash
#
# method 1 of declaring a function
#
function sayHello {
 echo "Hello "$1
}


# mathod 2 of declaring a function
sayHelloName() {
 echo "Hello "$1
}

sayHello "Adam"
#
sayHelloName "Milan"
