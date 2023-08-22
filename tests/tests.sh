#!/bin/bash

# Function to run docker commands to keep things DRY (Don't Repeat Yourself)
run_docker() {
    local args=("$@")
    docker run --rm --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest "${args[@]}"
}

# AWS environment vars
aws_env_vars=<(env | grep -E '^AWS_')

# Execute commands
run_docker ssh_audit 192.168.1.250
run_docker nuclei https://192.168.1.1
run_docker masscan 192.168.1.250 -p80
run_docker zap_vuln_scan https://192.168.1.1
run_docker nmap_vuln_scan 192.168.1.1
run_docker run_web_app_tests https://192.168.1.1
run_docker check_and_exploit_null_smb_sessions 192.168.1.155
docker run --network host --env-file "$aws_env_vars" -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest discover_aws_services us-east-1
docker run --network host --env-file "$aws_env_vars" -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest enumerate_supported_ciphers 443 192.168.1.1
run_docker check_rdp
run_docker resolve_fqdn network_targets
