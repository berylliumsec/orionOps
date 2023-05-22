#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    while read -r ip; do
        iscsiadm --mode node --target "$2" --portal "$ip" --login
    done < <(grep . "/RESULTS/$1")
else
    iscsiadm --mode node --target "$2" --portal "$1" --login >/RESULTS/test_unauthenticated_iscsi_sessions
fi