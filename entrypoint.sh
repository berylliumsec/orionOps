#!/bin/bash
export PATH=$PATH:/APP
if [ "$1" = "zap_vuln_scan" ]; then
    printf "passing args to zap: %s" "$2" 
    owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
        jq . /RESULTS/zap_raw_results.json >/RESULTS/zap_processed_results_.json

elif [ "$1" = "nmap_vuln_scan" ]; then
    printf "passing args to nmap: %s" "$2" 
    nmap -sV --script nmap-vulners/ "$2" > /RESULTS/nmap_raw_results

elif [ "$1" = "nmap_vuln_scan_list" ]; then
    while read -r ip
    do
        nmap -sV --script nmap-vulners/ "$ip" >> /RESULTS/nmap_raw_results
    done < /RESULTS/ips.txt

else
    printf "unrecognized command"
fi
