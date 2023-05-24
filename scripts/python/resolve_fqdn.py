import argparse
import logging
import socket
import sys

logging.basicConfig(filename="/RESULTS/dns_resolution.log", level=logging.DEBUG)
parser = argparse.ArgumentParser(description="Configure args")
parser.add_argument(
    "--ip",
    type=str,
    help="url of the target",
)
args = parser.parse_args()
if not args.ip:
    logging.debug("No IP supplied, exiting")
    sys.exit(1)
else:
    logging.debug("Checking IP %s", args.ip)
fqdn = socket.getfqdn(args.ip)

logging.debug("IP Address: %s, FQDN: %s", args.ip, fqdn)
