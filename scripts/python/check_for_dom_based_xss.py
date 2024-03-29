"""write a python script to check if a website has any of these in its source code: [document.URL, document.documentURI, document.URLUnencoded, document.baseURI, location, document.cookie]
pass the url via command line args and use the logging library for debugging"""

import argparse
import logging
import ssl
import sys
import urllib
from urllib.request import urlopen

ssl._create_default_https_context = ssl._create_unverified_context
logging.basicConfig(filename="/RESULTS/dom_xss.log", level=logging.DEBUG)


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
# fetch the source code of the website
try:
    html = urllib.request.urlopen(args.url).read()
except Exception as e:
    logging.error("Error fetching the source code: %s" % str(e))
    sys.exit(1)

logging.info("checking %s", args.url)
# check if any of the strings are present in the source code
strings = [
    "document.URL",
    "document.documentURI",
    "document.URLUnencoded",
    "document.baseURI",
    "location",
    "document.cookie",
    "document.referrer",
    "window.name",
    "history.pushState",
    "history.replaceState",
    "localStorage",
    "sessionStorage",
    "IndexedDB",
    "mozIndexedDB",
    "webkitIndexedDB",
    "msIndexedDB",
    "Database",
]


for s in strings:
    if s in html.decode():
        logging.info('String "%s" found in source code!' % s)
