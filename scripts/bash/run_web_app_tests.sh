#!/bin/bash
if [ -f "/RESULTS/$1" ]; then
    while read -r line; do
        python3 "/scripts/python/check_for_dom_based_xss.py" --url "$line" --proxy "$2"
        python3 "/scripts/python/check_security_headers.py" --url "$line" --proxy "$2"
        python3 "/scripts/python/click_jacking.py" --url "$line" --proxy "$2"
        python3 "/scripts/python/cross_site_forgery_detect.py" --url "$line" --proxy "$2"
        python3 "/scripts/python/os_finger_printing.py" --url "$line" --proxy "$2"
    done  < <(grep . "/RESULTS/$1")
else
        python3 "/scripts/python/check_for_dom_based_xss.py" --url "$1" --proxy "$2"
        python3 "/scripts/python/check_security_headers.py" --url "$1" --proxy "$2"
        python3 "/scripts/python/click_jacking.py" --url "$1" --proxy "$2"
        python3 "/scripts/python/cross_site_forgery_detect.py" --url "$1" --proxy "$2"
        python3 "/scripts/python/os_finger_printing.py" --url "$1" --proxy "$2"
fi