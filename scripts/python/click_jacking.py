import requests
import logging
import argparse

logger = logging.getLogger(__name__)

logging.basicConfig(filename="/RESULTS/click_jacking.log", level=logging.DEBUG)


def is_clickjacking_protected(url):
    if args.proxy:
        logging.debug("using proxy %s", args.proxy)
        response = requests.get(
            url, verify=False, proxies={"http": args.proxy, "https": args.proxy}
        )
    else:
        response = requests.get(url, verify=False)
    if response.headers.get("X-Frame-Options"):
        logging.info(
            "X-Frame-Options Detected: %s", response.headers.get("X-Frame-Options")
        )
    else:
        logging.info(
            "X-Frame options not detected, this site may not be protected against clickjacking"
        )

    if response.headers.get("Content-Security-Policy"):
        logging.info(
            "Content-Security-Policy Detected: %s",
            response.headers.get("Content-Security-Policy"),
        )
    else:
        logging.info(
            "Content-Security-Policy not detected, this site may not be protected against clickjacking"
        )
        return False


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
    is_clickjacking_protected(args.url)
