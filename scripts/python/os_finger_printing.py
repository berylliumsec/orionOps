import argparse
import logging
import platform
import sys
import urllib.request

logging.basicConfig(filename="/RESULTS/os_fingerprinting.log", level=logging.DEBUG)
parser = argparse.ArgumentParser(description="Configure proxy")
parser.add_argument(
    "--url",
    type=str,
    help="url of the target",
)
parser.add_argument(
    "--proxy",
    type=str,
    help="IP and Port of proxy",
)

args = parser.parse_args()
if not args.url:
    logging.debug("No URL supplied, exiting")
    sys.exit(1)
else:
    logging.debug("Checking URL %s", args.url)
if args.proxy:
    logging.debug("using proxy %s", args.proxy)
    proxy_support = urllib.request.ProxyHandler(
        {"http": args.proxy, "https": args.proxy}
    )
    opener = urllib.request.build_opener(proxy_support)
    urllib.request.install_opener(opener)

# Check if command line args were passed

# Check the OS of the web server
try:
    # Get the system info from the header
    with urllib.request.urlopen(args.url) as response:
        info = response.info()
        system = info.get("Server")

    # Log the system info
    logging.info(f"Server OS for {args.url} is {system}")

    # Log the local system info
    logging.info(f"Local OS is {platform.system()}")

except Exception as err:
    logging.error(err)
    exit(1)
