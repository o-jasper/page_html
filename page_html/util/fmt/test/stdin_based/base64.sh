#!/bin/bash

N=0

while true; do

    DATA=$(head -c "$(expr $RANDOM % 64)" /dev/random)

    ONE=$(echo -ne "$DATA" | lua base64.lua)
    # Apparently it puts control characters in there?
    TWO=$(echo -ne "$DATA" | base64 | tr -d "[:space:]" | tr -d '[:cntrl:]')

    if [ "$ONE" != "$TWO" ]; then
        echo WRONG
        echo $ONE
        echo $TWO
    else
        echo ok $ONE $N
        echo ..  $TWO
    fi
    N=$(expr $N + 1)

done
