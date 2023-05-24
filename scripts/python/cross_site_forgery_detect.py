import argparse
import logging
import sys

import requests

logging.basicConfig(filename="/RESULTS/csrf.log", level=logging.DEBUG)


def detect_csrf(url):
    # Request the page to see if the web page has a CSRF token
    if args.proxy:
        logging.debug("using proxy %s", args.proxy)
        r = requests.get(
            url, verify=False, proxies={"http": args.proxy, "https": args.proxy}
        )
    else:
        r = requests.get(url, verify=False)

    # If the page has a CSRF token, it is not vulnerable to CSRF attacks
    if "csrf_token" in r.text:
        logging.info("CSRF token found")
    else:
        logging.warning("CSRF token not found")

    if r.headers.get("Referrer-Policy"):
        logging.info("Referrer-Policy found %s:", r.headers.get("Referrer-Policy"))
    else:
        logging.warning("Referrer-Policy not found")

    cookies = r.cookies

    # check if same-site cookie exists
    if "SameSite" in cookies.keys():
        logging.info("The website has SameSite cookie")
    else:
        logging.warning("The website has no SameSite cookie")


if __name__ == "__main__":
    # Set up logging
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
    url = args.url
    if not args.url:
        logging.debug("No URL supplied, exiting")
        sys.exit(1)
    else:
        logging.debug("Checking URL %s", args.url)
    detect_csrf(url)
