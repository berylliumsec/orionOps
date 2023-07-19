#!/bin/bash

# if it is a file that contains a list of targets then use crackmap
if [ -f "/RESULTS/$1" ]; then
    crackmapexec smb target "$1"
else
    crackmapexec smb "$1"
fi