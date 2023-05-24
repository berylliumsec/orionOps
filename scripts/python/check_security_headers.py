import argparse
import logging
import sys

import requests

logging.basicConfig(filename="/RESULTS/security_headers.log", level=logging.DEBUG)


def check_security_headers(url):
    headers = {
        "X-Frame-Options": "deny",
        "Content-Security-Policy": "default-src https:",
        "Referrer-Policy": "strict-origin",
        "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
        "X-XSS-Protection": "1; mode=block",
        "X-Content-Type-Options": "nosniff",
    }
    if args.proxy:
        logging.debug("using proxy %s", args.proxy)
        response = requests.get(
            url, verify=False, proxies={"http": args.proxy, "https": args.proxy}
        )
    else:
        response = requests.get(url, verify=False)
    for header_name, header_value in headers.items():
        if header_name in response.headers:
            if response.headers[header_name] == header_value:
                logging.info(f"{header_name}: {header_value}")
            else:
                logging.error(f"{header_name}: {response.headers[header_name]}")
        else:
            logging.error(f"{header_name}: NOT PRESENT")


if __name__ == "__main__":
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
    check_security_headers(args.url)
