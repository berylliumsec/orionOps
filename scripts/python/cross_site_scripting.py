import logging
import sys
import requests
import argparse

logging.basicConfig(level=logging.INFO)
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
logging.basicConfig(filename="/RESULTS/xss.log", level=logging.DEBUG)
URL = args.url

# check for XSS vulnerability
payloads = [
    "<script>alert('XSS');</script>",
    "<script>alert(document.cookie);</script>",
    "<script>alert(window.location);</script>",
]

for payload in payloads:
    if args.proxy:
        logging.debug("using proxy %s", args.proxy)
        resp = requests.get(
            URL + payload,
            verify=False,
            proxies={"http": args.proxy, "https": args.proxy},
        )
    else:
        resp = requests.get(URL + payload, verify=False)
    if payload in resp.text:
        logging.warning("XSS Vulnerability found!")
    else:
        logging.info("No XSS Vulnerability found!")
