#!/bin/bash

while IFS= read -r line
do
    if ! ping -c 1 "$line" &> /dev/null
    then
        echo "$line">> non_responsive.txt
    fi
done < "$1"
