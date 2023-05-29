# AWS Audit and Hacking Playbook

## Auditing Tools

### Cloudformation Script / Dockerfile/ Docker Image / Git Repository Analysis

Analyzing docker images for vulnerabilities is important to determine if there are dependencies in the base or layered docker images that contain
vulnerabilities that could be exploited by an attacker.

Analyzing Cloud formation scripts is important to ensure practices are being followed and that IaC is deployed in a secure manner.

Git repositories that contain cloud resource configurations should also be analyzed to ensure that secrets are not being stored therein. 

[Checkov](https://github.com/bridgecrewio/checkov) is a static code analysis tool for infrastructure as code (IaC) and also a software composition
analysis (SCA) tool for images and open source packages. It can be used to analyze cloudformation scripts for best practices, secrets etc

[Trivy](https://github.com/aquasecurity/trivy) is a security tool that can be used to analyze docker images for vulnerabilities. 

[Git secrets](https://github.com/awslabs/git-secrets) can be used to analyze git repositories to ensure that they are not storing any secrets

### OSINT:

Open source intelligence can be a valuable when analyzing the attack surface area of a cloud environment. You can often find S3 buckets with public objects,

EC2 instances that can be accessed directly from the internet, misconfigured cloudfront, leaked secrets etc.

- If the AWS environment is hosting a domain, you can start by searching for the domain in the [Have I Been Pawned Website](https://haveibeenpwned.com/DomainSearch)

- Using [shodan](https://www.shodan.io), ensure that the AWS environment is not exposing any IoT device endpoints, you can make this easy by searching for the entire IP address range for the cloud account that is being audited.

### AWS Configuration Analysis

- Running Scout Suite

[Scout Suite](https://github.com/nccgroup/ScoutSuite) is an open source multi-cloud security-auditing tool, which enables security posture assessment of cloud environments. 
You can catch the majority of misconfigurations using scout suite.


## Manual Checks

- Instance Metadata

Instance metadata is a source of information about your running instances, consisting of categories such as host name, events, and security groups. You can also use this data to access user data that you provided when launching the instance. 

The instance metadata should be turned off if it is not being used, and if it is being used, ensure that it is IMDSv2 not IMDSv1. This is because it can be compromised
through a myriad of techniques, some of which are Server-Side Request Forgery, Proxies, DNS Rebinding etc

To check if an instance is running IMDSv1, simply run the following command from within the instance:

```bash
curl http://169.254.169.254/latest/user-data
```

If you received the error code `401` then it must be running IMDSv2



The rationale behind this is that if you have access to an instance, as well as any programs running on that instance, the data stored within
the instance is not safeguarded with authentication or encryption. Therefore, it is not a secure place to store sensitive information such as 
passwords or long-term encryption keys.

For example if the administrator's password was passed with userdata, and an attacker has
gained access to the instance, they can easily retrieve it by running the following command:

```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/
```

The results will look like:

```
[ec2-user@ip-172-xx-xx-xx ~]$ TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/user-data
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    56  100    56    0     0   8962      0 --:--:-- --:--:-- --:--:--  9333
*   Trying 169.254.169.254:80...
* Connected to 169.254.169.254 (169.254.169.254) port 80 (#0)
> GET /latest/user-data HTTP/1.1
> Host: 169.254.169.254
> User-Agent: curl/7.88.1
> Accept: */*
> X-aws-ec2-metadata-token: AQAAAPm_49V6IGWwyABYuQXrWfdP6yrb3-iy6UsOKg5zeol4pFOp_g==
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Accept-Ranges: bytes
< Content-Length: 64
< Content-Type: application/octet-stream
< Date: Sat, 27 May 2023 17:19:27 GMT
< Last-Modified: Sat, 27 May 2023 17:15:53 GMT
< X-Aws-Ec2-Metadata-Token-Ttl-Seconds: 21600
< Connection: close
< Server: EC2ws
< 
#!/bin/bash
* Closing connection 0
*echo "i know its silly but my password is: hahahaha"
```

You can do a complete enumeration using the following command:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest enumerate_aws_meta_data
```

The result will be written to a file named `aws_metadata.log` in the directory where you ran the above command.

Also it is possible to access metadata without direct instance access if an application running on the instance can be compromised


Mitigation

You can turn off access to your instance metadata by disabling the HTTP endpoint of the instance metadata service. If you do not 
specify a value, the default is to enable the HTTP endpoint.


Configure EC2 Instances to use IMDSv2:

Amazon Linux is configured by default to use IMDSv2 but other operating systems, so they will need to be
manually configured.

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html


 
- Cognito Pools: Ensure that AWS cognito pools do not support unauthenticated identities. You can find more information about how to
activate or deactivate guest access on [this page](https://docs.aws.amazon.com/cognito/latest/developerguide/identity-pools.html) in
the `Activate or deactivate guest access` section


