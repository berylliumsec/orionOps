# PETUSAWO

The purpose of the project is to make it easier to run Zap and NMAP scans
  
## Supported Open Source Applications

- OWASP Zap
  
## Getting Started

### Dependencies

- Docker

### Building the image

To build the image execute the following command at the root of the repo:

```bash
docker-compose build
```

### Executing the docker image

To run zap against a url, run the following command, replacing the url with the target url.
The results will be outputted to whatever directory you specify.

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan https://yourtarget.com/
```

Example of running NMAP's vulnerability scan against an IP address:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan 000.00.000.000
```

To run NMAP's vulnerability scan against a list of ip addresses, place
the list in a file named ips.txt with each IP address on a new line.
Run:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan_list
```

### Output Files

Zap generates a report file in JSON format. These files can be further processed by
other applications.

Nmap results are stored in regular txt file