#!/bin/bash
export PATH=$PATH:/APP
if [ "$1" = "zap_vuln_scan" ]; then
    printf "passing args to zap: %s" "$2"
    owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
        jq . /RESULTS/zap_raw_results.json >/RESULTS/zap_processed_results_.json

elif [ "$1" = "zap_vuln_scan_list" ]; then
    printf "passing args to zap: %s" "$2"
    # Check if the file is terminated with a newline, if not append it
    # If it is not terminated with a newline, the last url/ip will not be read
    if [ -z "$(tail -c 1 "/RESULTS/urls.txt")" ]; then
        echo >>"/RESULTS/urls.txt"
    fi
    counter=1
    while read -r url; do
        owasp-zap -cmd -quickurl "$url" -quickout "/RESULTS/zap_raw_results$counter.json" -silent -quickprogress &&
            jq . "/RESULTS/zap_raw_results$counter.json" >>/RESULTS/zap_processed_results_.json
        counter=$((counter + 1))
    done </RESULTS/urls.txt
elif [ "$1" = "nmap_vuln_scan" ]; then
    printf "passing args to nmap: %s" "$2"
    nmap -sV --script nmap-vulners/ "$2" >/RESULTS/nmap_raw_results

elif [ "$1" = "nmap_vuln_scan_list" ]; then
    # Check if the file is terminated with a newline, if not append it
    # If it is not terminated with a newline, the last url/ip will not be read
    if [ -z "$(tail -c 1 "/RESULTS/ips.txt")" ]; then
        echo >>"/RESULTS/ips.txt"
    fi
    while read -r ip; do
        nmap -sV --script nmap-vulners/ "$ip" >>/RESULTS/nmap_raw_results
    done </RESULTS/ips.txt

else
    printf "unrecognized command"
fi
