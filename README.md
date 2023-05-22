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

### ZAP

To run zap against a url, run the following command, replacing the url with the target url.
The results will be outputted to whatever directory you specify.

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan https://yourtarget.com/
```

To run Zap against a list of URLs, place the urls in file named urls.txt in the `PWD`with each url
on a new line (the last line must be terminated with a new line). Run:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan your_list.txt
```

### NMAP

Example of running NMAP's vulnerability scan against an IP address:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan 000.00.000.000
```

To run NMAP's vulnerability scan against a list of ip addresses, place
the list in a file named ips.txt in the `PWD` with each IP address on a new line
(the last line must be terminated with a new line).
Run:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan your_list.txt
```

### General WEB Application Scans

All web application scans can be run through an optional proxy server such as burpsuite.
If no proxy is being used, the option can be ignored.

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
run_web_app_tests target_ip_address_or_list_of_ips optional_proxy_address
```

### Checking for SMB signing not required

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_if_smb_is_required target_ip_address_or_list_of_ips
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
### Output Files

All log files will be placed in the directory from which you run the docker container.
