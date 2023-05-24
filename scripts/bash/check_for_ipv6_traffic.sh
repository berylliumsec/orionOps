#!/bin/bash
tshark -i "$1" -f "ip6" 