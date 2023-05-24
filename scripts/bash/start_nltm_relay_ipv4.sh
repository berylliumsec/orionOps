#!/bin/bash
if [ -f "$2" ]; then
    python3 relay.py -tf "$2" -smb2support
else
    python3 relay.py -t "$2" -smb2support
fi