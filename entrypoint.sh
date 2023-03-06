#!/bin/bash
export PATH=$PATH:/APP
if [ "$1" = "zap_vuln_scan" ]; then
    printf "passing args to zap: %s %s %s %s" "$2" "$3" "$4" "$5"
    owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
        jq . /RESULTS/zap_raw_results.json >/RESULTS/zap_processed_results_.json

else
    printf "unrecognized command"
fi
