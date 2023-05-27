#!/bin/bash

# if it is a file that contains a list of targets then use crackmap
if [ -f "$1" ]; then
    crackmapexec smb targets "$1" > /RESULTS/results
else
    crackmapexec smb "$1" > /RESULTS/results
fi