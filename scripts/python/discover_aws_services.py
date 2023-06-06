import argparse
import logging
import os

import boto3

logging.basicConfig(level=logging.DEBUG)

parser = argparse.ArgumentParser(description="Configure")

parser.add_argument(
    "--Serial_number",
    type=str,
    metavar="Serial_number",
    help="Serial_number",
)
parser.add_argument(
    "--Token",
    type=str,
    metavar="Token",
    help="Token",
)
parser.add_argument(
    "--Region",
    type=str,
    metavar="Region",
    help="Region",
)


def get_services() -> None:
    """Retrieve all deployed AWS Services"""
    resources = []
    client = boto3.client("resourcegroupstaggingapi", region_name=args.Region)
    resources = client.get_resources()
    print(resources.keys())
    if "ResourcetagMappingList" in resources:
        for resource in resources["ResourcetagMappingList"]:
            if resource:
                split_resource = resource["ResourceARN"].split(":")
                resources.append(split_resource)

    with open("/RESULTS/aws_resources.json", "w") as f:
        f.write(resources)



if __name__ == "__main__":
    args = parser.parse_args()
    get_services()