# PETUSAWO

The purpose of the project is to remove clutter from vulnerability scans so that 
penetration testers can focus on severe vulnerabilities that can be easily used to
exploit a system or application.

## Supported Open Source Applications
- OWASP Zap
- NMAP
  
## Getting Started

### Dependencies

* Docker

### Configuration 

Both ZAP and NMAP can be configured from the command line. The following are the configuration
options:

- INCLUDE_NON_EXPLOIT : If this options is set to False, NMAP will not include a vulnerability that has not
  been exploited.
- CVSS_SCORE_THRESHOLD : The results will only contain vulnerabilities that thier CVSS score is greater than 
  this threshold.
- USE_ZAP_RISK: This option allows you to use the native ZAP risk rating as a threshold instead of the CVSS SCORE
- USE_CVSS_RISK: This option allows you to include the native ZAP risk rating instead of the CVSS SCORE
- ZAP_RISK_CODE_THRESHOLD: If USE_ZAP_RISK is set to True, results will only contain vulnerabilities whose ZAP RISK CODE score is greater than this value.

### Executing the docker image

To run zap against a url, run the following command, replacing the url with the target url.
The results will be outputted to whatever directory you specify (in this case)
```
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
zap_vuln_scan https://yourtarget.com/ --USE_CVSS_RISK --CVSS_SCORE_THRESHOLD=0
```

Example of running NMAP's vulnerability scan against an IP address:

```
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
nmap_vuln_scan 000.00.000.000 \
--INCULDE_NON_EXPLOIT --CVSS_SCORE_THRESHOLD=0
```
### Output Files
Both Zap and NMAP generate a report file in JSON format. These files can be further processed by
other applications. The python library pyjsonviewer can be used to quickly inspect results: For
example:
```
pyjsonviewer -f zap_results.json
```
