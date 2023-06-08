#!/bin/bash
export PATH=$PATH:/APP

if [ "$1" = "zap_vuln_scan" ]; then
    printf "passing args to zap: %s" "$2"
    if [ -f "/RESULTS/$2" ]; then
        counter=1
        while read -r url; do
            owasp-zap -cmd -quickurl "$url" -quickout "/RESULTS/zap_raw_results$counter.json" -silent -quickprogress &&
            jq . "/RESULTS/zap_raw_results$counter.json" >>/RESULTS/zap_processed_results_.json
            counter=$((counter + 1))
        done < <(grep . "/RESULTS/$2")
    else
        owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
        jq . /RESULTS/zap_raw_results.json >/RESULTS/zap_processed_results_.json
    fi
    
    elif [ "$1" = "nmap_vuln_scan" ]; then
    printf "passing args to nmap: %s" "$2"
    if [ -f "/RESULTS/$2" ]; then
        while read -r ip; do
            nmap -sV --script nmap-vulners/ "$ip" >>/RESULTS/nmap_raw_results
        done < <(grep . "/RESULTS/$2")
    else
        nmap -sV --script nmap-vulners/ "$2" >/RESULTS/nmap_raw_results
    fi
    
    elif [ "$1" = "nmap" ]; then
    if [ -f "/RESULTS/$2" ]; then
        while read -r ip; do
            nmap "$ip" >>/RESULTS/nmap_raw_results
        done < <(grep . "/RESULTS/$2")
    else
        nmap -sV --script nmap-vulners/ "$2" >/RESULTS/nmap_raw_results
    fi
    nmap "$2" >>/RESULTS/nmap_raw_results
    
    elif [ "$1" = "os_finger_printing" ]; then
    if [ -f "/RESULTS/$2" ]; then
        
        while read -r ip; do
            nmap -O "$ip" >>/RESULTS/nmap_fingerprinting_raw_results
        done < <(grep . "/RESULTS/$2")
    else
        nmap -O "$2" >/RESULTS/nmap_fingerprinting_raw_results
    fi
    
    elif [ "$1" = "check_for_ipv6_traffic" ]; then
    /scripts/bash/check_for_ipv6_traffic.sh "$2"
    
    elif [ "$1" = "start_mitm6" ]; then
    /scripts/bash/start_mitm6.sh "$2" "$3"
    
    elif [ "$1" = "start_nltm_relay_ipv6" ]; then
    /scripts/bash/start_nltm_relay_ipv6.sh "$2"

    elif [ "$1" = "check_if_smb_signing_is_required" ]; then
    /scripts/bash/check_if_smb_signing_is_required.sh "/RESULTS/$2"
    
    elif [ "$1" = "start_responder" ]; then
    /scripts/bash/start_responder.sh "$2"
    
    elif [ "$1" = "start_nltm_relay_ipv4" ]; then
    /scripts/bash/start_nltm_relay_ipv4.sh "$2"
    
    elif [ "$1" = "check_and_exploit_null_smb_sessions" ]; then
    /scripts/bash/check_and_exploit_null_smb_sessions.sh "$2" >>/RESULTS/smb_null_session_results
    
    elif [ "$1" = "run_web_app_tests" ]; then
    /scripts/bash/run_web_app_tests.sh "$2" "$3"
    
    elif [ "$1" = "list_iscsi_targets" ]; then
    /scripts/bash/list_iscsi_targets.sh "$2" "$3"
    
    elif [ "$1" = "test_unauthenticated_iscsi_sessions" ]; then
    /scripts/bash/test_unauthenticated_iscsi_sessions.sh "$2" "$3"
    
    elif [ "$1" = "resolve_fqdn" ]; then
    /scripts/bash/resolve_fqdn.sh "$2"

    elif [ "$1" = "enumerate_aws_meta_data" ]; then
    python3 /scripts/python/enumerate_ec2_metadata_userdata.py

    elif [ "$1" = "dump_creds" ]; then
    proxychains impacket-secretsdump -no-pass "$2"

    elif [ "$1" = "list_smb_shares" ]; then
    proxychains smbclient -L "$2" -U "$3"

    elif [ "$1" = "access_smb" ]; then
    proxychains smbclient "$2" -U "$3"

    elif [ "$1" = "pass_hashes_wmi_exec" ]; then
    impacket-wmiexec -hashes "$2" "$3"
    
    elif [ "$1" == "discover_aws_services" ]; then
    python3 /scripts/python/discover_aws_services.py --Region "$2"

    elif [ "$1" == "enumerate_supported_ciphers" ]; then
    nmap --script ssl-enum-ciphers -p "$2" "$3" >> "/RESULTS/$3-supported_ciphers"

    elif [ "$1" = "help" ]; then
    printf "\n"
    printf "zap_vuln_scan"
    printf "\n"
    printf "nmap_vuln_scan"
    printf "\n"
    printf "nmap"
    printf "\n"
    printf "check_and_exploit_null_smb_sessions"
    printf "\n"
    printf "os_finger_printing"
    printf "\n"
    printf "enumerate_aws_meta_data"
    
else
    printf "command not found, spawning a shell"
    /bin/bash
fi
