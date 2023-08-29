#!/bin/bash
terminate() {
    echo "Caught SIGINT signal!"
    # Kill any child processes
    pkill -P $$
    exit 1
}

trap 'terminate' SIGINT
export PATH=$PATH:/APP:/usr/local/go/bin:"$HOME"/go/bin

print_help() {
    echo "Available commands and their descriptions:"
    echo "  shell                           : Start a new shell session"
    echo "  zap_vuln_scan                   : Run a vulnerability scan using ZAP"
    echo "  nmap_vuln_scan                  : Execute a vulnerability scan using nmap"
    echo "  nmap                            : Run a standard nmap scan"
    echo "  masscan                         : Execute a scan using masscan"
    echo "  ssh_audit                       : Audit SSH for potential vulnerabilities"
    echo "  extract_info_dc                 : Extract information from domain controllers"
    echo "  nuclei                          : Scan using the Nuclei tool"
    echo "  rpc_dump                        : Dump RPC information"
    echo "  check_for_ipv6_traffic          : Check for IPv6 traffic in the network"
    echo "  start_mitm6                     : Start a man-in-the-middle attack on IPv6"
    echo "  start_ntlm_relay_ipv6           : Start an NTLM relay attack on IPv6"
    echo "  check_if_smb_signing_is_required: Check if SMB signing is enforced"
    echo "  start_responder                 : Start the Responder tool for LLMNR, NBT-NS and MDNS poisoning"
    echo "  start_nltm_relay_ipv4           : Start an NTLM relay attack on IPv4"
    echo "  check_and_exploit_null_smb_sessions: Check and exploit null SMB sessions"
    echo "  run_web_app_tests               : Run a series of web application tests"
    echo "  list_iscsi_targets              : List available iSCSI targets"
    echo "  test_unauthenticated_iscsi_sessions: Test for unauthenticated iSCSI sessions"
    echo "  resolve_fqdn                    : Resolve a Fully Qualified Domain Name"
    echo "  sort_ips                        : Sort IP addresses"
    echo "  enumerate_aws_meta_data         : Enumerate AWS meta-data"
    echo "  dump_creds                      : Dump credentials using Impacket's secretsdump"
    echo "  list_smb_shares                 : List available SMB shares"
    echo "  access_smb                      : Access an SMB share"
    echo "  pass_hashes_wmi_exec            : Execute commands using passed hashes with WMI"
    echo "  discover_aws_services           : Discover AWS services for a specified region"
    echo "  enumerate_supported_ciphers     : Enumerate supported ciphers on a target port"
    echo "  check_rdp                       : Check the security of an RDP connection"
    echo "  help                            : Display this help message"
}



case "$1" in
    shell)
        /bin/bash
    ;;
    zap_vuln_scan)
        printf "passing args to zap: %s" "$2"
        output_file="zap_processed_results_.json"
        urls_file="/RESULTS/$2"
        if [ -f "$urls_file" ]; then
            counter=1
            while read -r url; do
                printf "running scans, results will be written to %s\n" $output_file
                owasp-zap -cmd -quickurl "$url" -quickout "/RESULTS/zap_raw_results$counter.json" -silent -quickprogress &&
                jq . "/RESULTS/zap_raw_results$counter.json" >> "/RESULTS/$output_file"
                counter=$((counter + 1))
            done < <(grep . "$urls_file")
        else
            printf "running scans, results will be written to %s\n" $output_file
            owasp-zap -cmd -quickurl "$2" -quickout /RESULTS/zap_raw_results.json -silent -quickprogress &&
            jq . /RESULTS/zap_raw_results.json > "/RESULTS/$output_file"
        fi
    ;;
    nmap_vuln_scan)
        printf "passing args to nmap: %s" "$2"
        output_file="nmap_raw_results"
        ips_file="/RESULTS/$2"
        if [ -f "$ips_file" ]; then
            printf "running scans, output will be written to %s in your current working folder\n" $output_file
            while read -r ip; do
                nmap --script nmap-vulners/ -O -Pn -sV "$ip" 2>&1 | tee -a "/RESULTS/$output_file"
            done < <(grep . "/RESULTS/$2")
        else
            printf "running scans, output will be written to %s in your current working folder\n" $output_file
            nmap -O -Pn -sV --script nmap-vulners/ "$2" 2>&1 | tee -a "/RESULTS/$output_file"
        fi
    ;;
    nmap)
        
        if [ -f "/RESULTS/$2" ]; then
            printf "passing args to nmap: %s" "$2"
            while read -r ip; do
                printf "%s\n" "running scans, output will be written to nmap_raw_results in your current working folder"
                nmap "$ip" 2>&1 | tee -a /RESULTS/nmap_raw_results
            done < <(grep . "/RESULTS/$2")
        else
            printf "%s\n" "running scans, output will be written to nmap_raw_results in your current working folder"
            nmap "${@:2}" 2>&1 | tee -a /RESULTS/nmap_raw_results
        fi
    ;;
    masscan)
        if [ -f "/RESULTS/$2" ]; then
            while read -r ip; do
                printf "%s\n" "running mass scans, output will be written to masscan_raw_results in your current working folder"
                masscan "$3" "$ip" 2>&1 | tee -a /RESULTS/masscan_raw_results
            done < <(grep . "/RESULTS/$2")
        else
            printf "%s\n" "running scans, output will be written to masscan_raw_results in your current working folder"
            masscan "$3" "$2" 2>&1 | tee -a /RESULTS/masscan_raw_results
        fi
    ;;
    ssh_audit)
        if [ -f "/RESULTS/$2" ]; then
            
            while read -r ip; do
                printf "%s\n" "running scans, output will be written to ssh_audit_results in your current working folder"
                ssh-audit "$ip" 2>&1 | tee -a /RESULTS/ssh_audit_results
            done < <(grep . "/RESULTS/$2")
        else
            ssh-audit "$2" 2>&1 | tee -a /RESULTS/ssh_audit_results
        fi
    ;;
    extract_info_dc)
        
        if [ -f "/RESULTS/$2" ]; then
            
            while read -r ip; do
                printf "%s\n" "running scans, output will be written to dc_anonymous_enumeration_results in your current working folder"
                /scripts/bash/extract_info_dc.sh "$ip" 2>&1 | tee -a /RESULTS/dc_anonymous_enumeration_temp
                
            done < <(grep . "/RESULTS/$2")
            # Remove ANSI escape codes from input.txt and save the clean content to output.txt
            sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g" /RESULTS/dc_anonymous_enumeration_temp > /RESULTS/dc_anonymous_enumeration_results
            rm /RESULTS/dc_anonymous_enumeration_temp
        else
            printf "%s\n" "running scans, output will be written to dc_anonymous_enumeration_results in your current working folder"
            /scripts/bash/extract_info_dc.sh "$2" 2>&1 | tee -a /RESULTS/dc_anonymous_enumeration_results_temp
            sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g" /RESULTS/dc_anonymous_enumeration_results_temp > /RESULTS/dc_anonymous_enumeration_results
            rm /RESULTS/dc_anonymous_enumeration_results_temp
        fi
    ;;
    nuclei)
        if [ -f "/RESULTS/$2" ]; then
            
            printf "%s\n" "running scans, output will be written to nuclei_results in your current working folder"
            nuclei -list "/RESULTS/$2" "${@:2}"  2>&1 | tee -a /RESULTS/nuclei_results
        else
            nuclei "$2" "${@:2}" 2>&1 | tee -a /RESULTS/nuclei_results
        fi
    ;;
    rpc_dump)
        if [ -f "/RESULTS/$2" ]; then
            
            while read -r ip; do
                printf "%s\n" "running scans, output will be written to rpc_dump_results in your current working folder"
                impacket-rpcdump "$ip" 2>&1 | tee -a /RESULTS/rpc_dump_results
            done < <(grep . "/RESULTS/$2")
        else
            impacket-rpcdump "$2" 2>&1 | tee -a /RESULTS/rpc_dump_results
        fi
    ;;
    check_for_ipv6_traffic)
        /scripts/bash/check_for_ipv6_traffic.sh "$2"
    ;;
    start_mitm6)
        /scripts/bash/start_mitm6.sh "$2" "$3"
    ;;
    start_ntlm_relay_ipv6)
        /scripts/bash/start_nltm_relay_ipv6.sh "$2"
    ;;
    check_if_smb_signing_is_required)
        /scripts/bash/check_if_smb_signing_is_required.sh "$2"
    ;;
    start_responder)
        /scripts/bash/start_responder.sh "$2"
    ;;
    
    start_nltm_relay_ipv4)
        /scripts/bash/start_nltm_relay_ipv4.sh "$2"
    ;;
    
    check_and_exploit_null_smb_sessions)
        /scripts/bash/check_and_exploit_null_smb_sessions.sh "$2" >>/RESULTS/smb_null_session_results
    ;;
    run_web_app_tests)
        /scripts/bash/run_web_app_tests.sh "$2" "$3"
    ;;
    list_iscsi_targets)
        /scripts/bash/list_iscsi_targets.sh "$2" "$3"
    ;;
    test_unauthenticated_iscsi_sessions)
        /scripts/bash/test_unauthenticated_iscsi_sessions.sh "$2" "$3"
    ;;
    resolve_fqdn)
        /scripts/bash/resolve_fqdn.sh "$2"
    ;;
    sort_ips)
        /scripts/bash/sort_ips.sh "$2"
    ;;
    enumerate_aws_meta_data)
        python3 /scripts/python/enumerate_ec2_metadata_userdata.py
    ;;
    dump_creds)
        proxychains impacket-secretsdump -no-pass "$2"
    ;;
    list_smb_shares)
        proxychains smbclient -L "$2" -U "$3"
    ;;
    access_smb)
        proxychains smbclient "$2" -U "$3"
    ;;
    pass_hashes_wmi_exec)
        impacket-wmiexec -hashes "$2" "$3"
    ;;
    discover_aws_services)
        python3 /scripts/python/discover_aws_services.py --Region "$2"
    ;;
    enumerate_supported_ciphers)
        nmap --script ssl-enum-ciphers -p "$2" "$3" >>"/RESULTS/$3-supported_ciphers"
    ;;
    check_rdp)
        /APP/rdp-sec-check/rdp-sec-check.pl "$2" >>"/RESULTS/$2-rdp-check-results"
    ;;
    help)
    print_help
    ;;
    *)
        echo "Unknown command: $1"
        print_help
        exit 1
    ;;
esac
