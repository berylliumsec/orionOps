#!/bin/bash

# if it is a file that contains a list of targets then use crackmap
if [ -f "$1" ]; then
    crackmapexec smb targets "$1" 1>&2 > /RESULTS/smb_signing_results
else
    crackmapexec smb "$1" 1>&2> /RESULTS/smb_signing_results
fi