#!/bin/bash
iscsiadm --mode discovery --type sendtargets --portal "$1"

#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    while read -r ip; do
        iscsiadm --mode discovery --type sendtargets --portal "$ip"
    done < <(grep . "/RESULTS/$1")
else
    iscsiadm --mode discovery --type sendtargets --portal "$1" >/RESULTS/test_unauthenticated_iscsi_sessions
fi