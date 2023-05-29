import argparse
import logging
import requests

parser = argparse.ArgumentParser(description="Configure proxy")
parser.add_argument(
    "--url",
    type=str,
    help="url of the target",
    default="http://169.254.169.254/latest/meta-data"
)

parser.add_argument(
    "--user_data_url",
    type=str,
    help="url of the target",
    default="http://169.254.169.254/latest/user-data"
)
parser.add_argument(
    "--proxy",
    type=str,
    help="IP and Port of proxy",
)
args = parser.parse_args()
logging.basicConfig(filename="aws_metadata.log", level=logging.DEBUG)

URL = args.url

resp = requests.get(URL, verify=False)
metadata = resp.text.split() 
for data in metadata:

    fetch_data = requests.get(URL+"/"+data, verify=False)
    if fetch_data.status_code == 200:
        logging.debug("Metadata found, %s: %s", data, fetch_data.text)
    else:
        logging.debug("metadata for endpoint %s not found", data)

fetch_user_data = requests.get(args.user_data_url, verify=False)

if fetch_user_data.status_code == 200:
        logging.debug("Userdata found, %s:" ,fetch_data.text)
else:
    logging.debug("userdata for endpoint %s not found", data)

