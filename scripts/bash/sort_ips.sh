#!/bin/bash

# Check if the input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-ip-file>"
    exit 1
fi

# Check if the input file exists
if [[ ! -f "/RESULTS/$1" ]]; then
    echo "Error: File $1 does not exist."
    exit 1
fi

# Strip leading and trailing whitespace, sort the IP addresses and remove duplicates
sed 's/^[ \t]*//;s/[ \t]*$//' "/RESULTS/$1" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | uniq
