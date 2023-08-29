#!/bin/bash
enum4linux -a -u "" -p "" "$1" && enum4linux -a -u "guest" -p ""  "$1"
smbclient -U '%' -L  "$1" && smbclient -U 'guest%' -L //
nmap -n -sV --script "ldap* and not brute" -p 389  "$1"