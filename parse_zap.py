import argparse
import json
import logging
import re
import sys
from ast import arg

import logging_loki
import pandas as pd
import requests

import config

logging.basicConfig(level=logging.DEBUG)
TEXT = "#text"
SELECTED_CONFIG = []
KEY = "@key"
CVE_PATTERN = "\w\w\w-\d\d\d\d-\d\d\d\d\d"
REQUESTS_SESSION = requests.Session()
ZAP_RAW_RESULTS = "/RESULTS/zap_raw_results.json"
ZAP_PROCESSED_RESULTS = "/RESULTS/zap_processed_results.json"
ZAP_PROCESSED_RESULTS_CSV = "/RESULTS/zap_processed_results.csv"


parser = argparse.ArgumentParser(description="Configure Zap")

parser.add_argument(
    "--USE_ZAP_RISK",
    metavar="ZR",
    action=argparse.BooleanOptionalAction,
    help="Use ZAP risk rating instead of CVSS score? (True or False)",
)
parser.add_argument(
    "--USE_CVSS_RISK",
    metavar="CR",
    action=argparse.BooleanOptionalAction,
    help="Use CVSS score instead of ZAP risk rating? (True or False)",
)
parser.add_argument(
    "--CVSS_SCORE_THRESHOLD",
    metavar="CVTH",
    type=int,
    help="CVSS threshold score 0-9",
)

parser.add_argument(
    "--ZAP_RISK_CODE_THRESHOLD",
    metavar="ZRCT",
    type=int,
    help="ZAP risk score 0-9",
)

parser.add_argument(
    "--LOKI_URL",
    metavar="LOKI",
    default="http://localhost:3100/loki/api/v1/push",
    type=str,
    help="LOKI's url E.G: http://192.168.1.1",
)


class zap:
    def __init__(self):
        self.use_zap_risk = None
        self.use_cvss_risk = None
        self.zap_risk_code_threshold = None
        self.cvss_score_threshold = None
        self.results = []
        self.logger = logging.getLogger("zap-petusawo-logger")

    def load_config(self, args: argparse):
        """Load Configuration"""

        logging.debug("loading args")
        logging.debug(args)
        if len(sys.argv) < 1:
            logging.debug("using config")
            self.use_zap_risk = config.USE_ZAP_RISK
            self.use_cvss_risk = config.USE_CVSS_RISK
            self.zap_risk_code_threshold = config.ZAP_RISK_CODE_THRESHOLD
            self.cvss_score_threshold = config.CVSS_SCORE_THRESHOLD
            self.handler = logging_loki.LokiHandler(
                url=args.LOKI_URL,
                tags={"application": "zap"},
                version="1",
            )
            self.logger.addHandler(self.handler)

        else:
            logging.debug("using args")
            logging.debug(args.USE_ZAP_RISK)
            logging.debug(args.USE_CVSS_RISK)
            logging.debug(args.ZAP_RISK_CODE_THRESHOLD)
            logging.debug(args.LOKI_URL)
            self.handler = logging_loki.LokiHandler(
                url=args.LOKI_URL,
                tags={"application": "zap"},
                version="1",
            )
            self.logger.addHandler(self.handler)

            self.use_zap_risk = args.USE_ZAP_RISK
            self.use_cvss_risk = args.USE_CVSS_RISK
            self.zap_risk_code_threshold = args.ZAP_RISK_CODE_THRESHOLD
            self.cvss_score_threshold = args.CVSS_SCORE_THRESHOLD
        if config.USE_CVSS_RISK is True and config.USE_ZAP_RISK is True:
            logging.WARN("Select either config.USE_CVSS_RISK or config.USE_ZAP_RISK")
            sys.exit(1)
        if config.USE_CVSS_RISK is False and config.USE_ZAP_RISK is False:
            logging.WARN(
                "You must set either config.USE_CVSS_RISK or config.USE_ZAP_RISK to true, exiting"
            )
            sys.exit(1)

    def extract_info_zap(self, elements: dict):
        """extract information from Zap results"""
        result = {
            "NAME": [],
            "RISKCODE": [],
            "DESCRIPTION": [],
            "INSTANCES": [],
        }
        result["NAME"].append(elements["name"])
        result["RISKCODE"].append(elements["riskcode"])
        result["DESCRIPTION"].append(elements["desc"])
        result["INSTANCES"].append(elements["instances"])
        if result["NAME"]:
            self.results.append(result)
            self.logger.info(
                result,
                extra={"tags": {"service": "zap"}},
            )

    def extract_info_cve(self, elements: dict, cves_list: list):
        """extract information from CVE results"""
        logging.info("extracting info from cve")
        for cve in cves_list:
            try:
                logging.info("iterating and downloading cves")
                url = "https://cve.circl.lu/api/cve/" + cve
                req_results = REQUESTS_SESSION.get(url)
                results_json = req_results.json()
                logging.info(results_json.keys())

                if int(results_json["cvss"]) > self.cvss_score_threshold:
                    logging.debug("cvss score is %s", results_json["cvss"])
                    result = {
                        "NAME": [],
                        "PREREQUISITES": [],
                        "DESCRIPTION": [],
                        "CVSS SCORE": [],
                        "INSTANCES": [],
                        "CVE ID": [],
                    }
                    logging.info("printing individual results:")
                    logging.info(result)

                    if len(results_json["capec"]) > 0:
                        logging.info("capec found")
                        result["NAME"].append(results_json["capec"][0]["name"])
                        result["PREREQUISITES"].append(
                            results_json["capec"][0]["prerequisites"]
                        )
                    else:
                        logging.info("capec not found")
                    result["INSTANCES"].append(elements["instances"])
                    result["DESCRIPTION"].append(elements["desc"])
                    result["CVE ID"].append(results_json["id"])
                    result["CVSS SCORE"].append(results_json["cvss"])
                    logging.info("printing individual results")
                    logging.info(result)
                    if result["NAME"]:
                        self.results.append(result)
                        self.logger.info(
                            result,
                            extra={"tags": {"service": "zap"}},
                        )
                else:
                    logging.debug("cvss score is %s", results_json["cvss"])
            except:
                logging.error("unable to retrieve url")
                raise

    def process_results(
        self,
        zap_raw_results: json,
        zap_processed_results: json,
        zap_processed_results_csv: pd,
    ) -> None:
        """Process the results"""
        logging.debug("processing results")
        f = open(zap_raw_results)
        data = json.load(f)
        i = 0
        logging.debug("checking which risk scoring systems should be used")
        logging.debug("begin outputting variables")
        logging.debug(self.use_zap_risk)
        logging.debug(self.use_cvss_risk)
        logging.debug(self.zap_risk_code_threshold)
        logging.debug(self.cvss_score_threshold)
        logging.debug("done outputting variables")
        while i < len(data["site"]):
            for alert in data["site"][i]["alerts"]:
                # check if Zap's scoring system should be used
                if self.use_zap_risk is True:
                    logging.debug("Using ZAP Score")
                    logging.debug("Printing Keys: ")
                    logging.debug(alert.keys())

                    if int(alert["riskcode"]) >= self.zap_risk_code_threshold:
                        self.extract_info_zap(alert)
                # check if CVSS score should be used
                elif self.use_cvss_risk is True:
                    # get the cve id using a regex pattern
                    logging.debug("Using CVSS Score")
                    cves = re.compile(CVE_PATTERN)
                    cves_list = cves.findall(alert["otherinfo"])

                    self.extract_info_cve(alert, cves_list)

            i += 1
        logging.info("printing results ..................")
        logging.info(self.results)

        df = pd.DataFrame(self.results)
        df.to_csv(zap_processed_results_csv)
        with open(zap_processed_results, "w") as json_file:
            json.dump(self.results, json_file)


if __name__ == "__main__":
    args = parser.parse_args()
    zap_instance = zap()
    zap_instance.load_config(args)
    zap_instance.process_results(
        ZAP_RAW_RESULTS, ZAP_PROCESSED_RESULTS, ZAP_PROCESSED_RESULTS_CSV
    )
