#!/bin/bash
export PATH=$PATH:/APP
if [ "$1" = "zap_vuln_scan" ]; then
    printf "passing args to zap: %s %s %s %s" "$2" "$3" "$4" "$5"
    owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
        python3 parse_zap.py "$3" "$4" "$5" &&
        jq . /RESULTS/zap_processed_results.json >/RESULTS/zap_processed_results_.json &&
        rm /RESULTS/zap_processed_results.json
elif [ "$1" = "nmap_vuln_scan" ]; then
    printf "passing args to nmap: %s %s %s %s" "$2" "$3" "$4" "$5"
    nmap -oX /RESULTS/nmap_raw_results.xml -sV --script nmap-vulners/ "$2" &&
        python3 parse_nmap.py "$3" "$4" "$5" &&
        jq . /RESULTS/nmap_processed_results.json >/RESULTS/nmap_processed_results_.json &&
        rm /RESULTS/nmap_processed_results.json
elif [ "$1" = "parse_nmap" ]; then
    printf "passing args to nmap: %s %s " "$3" "$4"
    python3 parse_nmap.py "$2" "$3" &&
        jq . /RESULTS/nmap_processed_results.json >/RESULTS/nmap_processed_results_.json &&
        rm /RESULTS/nmap_processed_results.json
elif [ "$1" = "parse_zap" ]; then
    printf "passing args to zap: %s %s" "$3" "$4"
    python3 parse_zap.py "$2" "$3" &&
        jq . /RESULTS/zap_processed_results.json >/RESULTS/zap_processed_results_.json &&
        rm /RESULTS/zap_processed_results.json
elif [ "$1" = "zap_help" ]; then
    printf "printing zap help \n"
    python3 parse_zap.py --help
elif [ "$1" = "nmap_help" ]; then
    printf "printing nmap help \n"
    python3 parse_nmap.py --help
else
    printf "unrecognized command"
fi
