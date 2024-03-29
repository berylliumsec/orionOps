#!/bin/bash

# Function to run docker commands to keep things DRY (Don't Repeat Yourself)
run_docker() {
    local args=("$@")
    docker run --rm  -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest "${args[@]}"
}


# Execute commands
run_docker extract_info_dc 192.168.1.231
run_docker ssh_audit 192.168.1.231
run_docker nuclei https://192.168.1.231 -t templates/http/ 
run_docker masscan 192.168.1.231 -p80
run_docker zap_vuln_scan https://192.168.1.231
run_docker nmap_vuln_scan 192.168.1.231
run_docker run_web_app_tests https://192.168.1.231
run_docker resolve_fqdn network_targets
