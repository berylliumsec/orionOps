#!/bin/bash
screen -S responder -d -m sudo responder -I "$1" -b -w -F -v -P
if [ -f "$2" ]; then
    screen -S relay -d -m sudo python3 relay.py -tf "$2" -smb2support
else
    screen -S relay -m sudo python3 relay.py -t "$2" -smb2support
fi