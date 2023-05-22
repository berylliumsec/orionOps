import socket
import sys
import contextlib
import logging

import sys
import logging
import argparse
logging.basicConfig(filename="/RESULTS/dns_resolution.log", level=logging.DEBUG)
parser = argparse.ArgumentParser(description="Configure args")
parser.add_argument(
    "--ip",
    type=str,
    help="url of the target",
)
args = parser.parse_args()
fqdn = socket.getfqdn(args.ip)

logging.debug("IP Address: %s, FQDN: %s", args.ip, fqdn)