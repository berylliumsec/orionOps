#!/bin/bash

# Check if the input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-ip-file>"
    exit 1
fi

# Check if the input file exists
if [[ ! -f "$1" ]]; then
    echo "Error: File $1 does not exist."
    exit 1
fi

# Sort the IP addresses
sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 "$1"
