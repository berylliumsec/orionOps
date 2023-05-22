#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    while read -r line; do
        python3 /scripts/python/resolve_fqdn.py --ip "$line"
    done  < <(grep . "/RESULTS/$1")
else
     python3 /scripts/python/resolve_fqdn.py --ip "$1"
fi