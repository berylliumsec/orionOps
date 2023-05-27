Running Scout Suite

OSINT

Dumping metadata

Instance metadata is a source of information about your running instances, consisting of categories such as host name, events, and security groups. You can also use this data to access user data that you provided when launching the instance. 


If you have access to an instance, as well as any programs running on that instance, the data stored within the instance is not safeguarded with authentication or encryption. Therefore, it is not a secure place to store sensitive information such as passwords or long-term encryption keys.

For example if the adminsitrator's password was passed with userdata, and an attacker has
gained access to the instance, they can easily restrieve it by running the following command:

```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/
```

The results will look like:

```
[ec2-user@ip-172-31-30-47 ~]$ TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") \
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
echo "i know its silly but my password is: hahahaha"
```
Also it is possible to access metadata without direct instance access if an application running on the instance can be compromised


Mitigations

You can turn off access to your instance metadata by disabling the HTTP endpoint of the instance metadata service. If you do not specify a value, the default is to enable the HTTP endpoint.


Configure EC2 Instances to use IMDSv2:

Amazon Linux is configured by default to use IMDSv2 but other operating systems, so they will need to be
manually configured.

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html


To check if an instance is running IMDSv1, simply run the following command from within the instance:

```bash
curl http://169.254.169.254/latest/user-data
```

If you recieved the error code `401` then it must be running IMDSv2

Ensure Docker containers are not running as root users

