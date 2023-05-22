#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    while read -r line; do
        printf "checking for DOM based XSS"
        python3 "/scripts/python/check_for_dom_based_xss.py" --url "$line" --proxy "$2" 
        printf "checking security headers"
        python3 "/scripts/python/check_security_headers.py" --url "$line" --proxy "$2" 
        printf "checking for clickjacking protection"
        python3 "/scripts/python/click_jacking.py" --url "$line" --proxy "$2" 
        printf "checking for cross site forgery protection"
        python3 "/scripts/python/cross_site_forgery_detect.py" --url "$line" --proxy "$2" 
        printf "trying OS fingerprinting"
        python3 "/scripts/python/os_finger_printing.py" --url "$line" --proxy "$2" 
    done  < <(grep . "/RESULTS/$1")
else
        printf "checking for DOM based XSS"
        python3 "/scripts/python/check_for_dom_based_xss.py" --url "$1" --proxy "$2" 
        printf "checking security headers"
        python3 "/scripts/python/check_security_headers.py" --url "$1" --proxy "$2" 
        printf "checking for clickjacking protection"
        python3 "/scripts/python/click_jacking.py" --url "$1" --proxy "$2" 
        printf "checking for cross site forgery protection"
        python3 "/scripts/python/cross_site_forgery_detect.py" --url "$1" --proxy "$2" 
        printf "trying OS fingerprinting"
        python3 "/scripts/python/os_finger_printing.py" --url "$1" --proxy "$2"
fi