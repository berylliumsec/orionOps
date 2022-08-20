import argparse
import json
import logging
import sys
from distutils.log import error

import xmltodict

import config

parser = argparse.ArgumentParser(description="Configure Nmap")

USE_ZAP_RISK = False
USE_CVSS_RISK = True
ZAP_RISK_CODE_THRESHOLD = 1


parser.add_argument(
    "--CVSS_SCORE_THRESHOLD",
    type=int,
    metavar="CTHR",
    help="The CVSS score threshold. (0-10)",
)
parser.add_argument(
    "--INCLUDE_NON_EXPLOIT",
    metavar="INE",
    action=argparse.BooleanOptionalAction,
    help="Include non-exploitable vulns?. (True or False)",
)

logging.basicConfig(level=logging.DEBUG)
TEXT = "#text"
SELECTED_CONFIG = []
NMAP_RAW_RESULTS_XML = "/RESULTS/nmap_raw_results.xml"
NMAP_RAW_RESULTS_JSON = "/RESULTS/nmap_raw_results.json"
NMAP_RESULTS = "/RESULTS/nmap_processed_results.json"


KEY = "@key"


class nmap:
    def __init__(self):
        self.cvss_score_threshold = None
        self.include_non_exploit = None
        self.results = []

    def load_config(self, args):
        """Load Configuration"""

        if len(sys.argv) < 1:
            self.cvss_score_threshold = config.CVSS_SCORE_THRESHOLD
            self.include_non_exploit = config.INCLUDE_NON_EXPLOIT
        else:
            self.cvss_score_threshold = args.CVSS_SCORE_THRESHOLD
            self.include_non_exploit = args.INCLUDE_NON_EXPLOIT
        logging.info("outputting configs: ")
        logging.info("self.cvss_score_threshold %s", self.cvss_score_threshold)
        logging.info("self.cvss_score_threshold %s", self.cvss_score_threshold)

    def convert_xml_to_dict(self, nmap_raw_results_xml, nmap_raw_results_json):
        """Convert nmap xml to JSON"""
        try:
            with open(nmap_raw_results_xml) as xml_file:
                data_dict = xmltodict.parse(xml_file.read())
                xml_file.close()
                json_data = json.dumps(data_dict)
                with open(nmap_raw_results_json, "w") as json_file:
                    json_file.write(json_data)
                    json_file.close()
        except FileNotFoundError as e:
            logging.debug(e)
            sys.exit(1)

    def extract_info_list(self, elements: list, port_info: dict):
        """Extract Important Info"""
        result = {"CVE": [], "TYPE": [], "CVSS SCORE": [], "PORT INFO": []}
        result["PORT INFO"].append(port_info)
        i = 0
        while i < 4:

            if elements[i][KEY] == "cvss":
                cvss = i
            if elements[i][KEY] == "type":
                type_ = i
            if elements[i][KEY] == "id":
                cve = i
            i += 1

        if float(elements[cvss]["#text"]) > self.cvss_score_threshold:
            result["CVE"].append(elements[cve][TEXT])
            result["TYPE"].append(elements[type_][TEXT])
            result["CVSS SCORE"].append(elements[cvss][TEXT])
            if result["CVE"]:
                self.results.append(result)

    def extract_info_dict(self, elements: dict, port_info: dict):
        """Extract Important Info"""
        result = {"CVE": [], "TYPE": [], "CVSS SCORE": [], "PORT INFO": []}
        result["PORT INFO"].append(port_info)
        i = 0
        while i < 4:
            print(elements[i][KEY])
            if elements[i][KEY] == "cvss":
                cvss = i
            if elements[i][KEY] == "type":
                type_ = i
            if elements[i][KEY] == "id":
                cve = i
            i += 1

        if float(elements[cvss]["#text"]) > self.cvss_score_threshold:
            result["CVE"].append(elements[cve][TEXT])
            result["TYPE"].append(elements[type_][TEXT])
            result["CVSS SCORE"].append(elements[cvss][TEXT])
        logging.info(result)
        if result["CVE"]:
            self.results.append(result)

    def process_results(self, nmap_raw_results_json, nmap_results) -> None:
        """Process the results"""

        f = open(nmap_raw_results_json)
        data = json.load(f)

        # get the ports, vulnerability results are attached to ports
        # 0 <elem key="is_exploit">false</elem>
        # 1 <elem key="cvss">7.5</elem>
        # 2 <elem key="type">cve</elem>
        # 3 <elem key="id">CVE-2022-31813</elem>

        for ports in data["nmaprun"]["host"]["ports"]["port"]:
            for elements in ports:
                if elements == "script":

                    if isinstance(ports[elements], list):
                        logging.debug("this is a list, handling like a list")
                        for element in ports[elements]:
                            if "table" in element:
                                for table in element["table"]["table"]:
                                    # if vulnerabilities which have no exploits should be included
                                    i = 0
                                    while i < 4:
                                        if table["elem"][i][KEY] != "is_exploit":
                                            logging.info("no vulnerabilities found")
                                            sys.exit(1)
                                        if table["elem"][i][KEY] == "is_exploit":
                                            if (
                                                self.include_non_exploit is False
                                                and table["elem"][i][TEXT] == "true"
                                            ):
                                                logging.info(
                                                    "including vulnerabilities that have no exploits"
                                                )
                                                # Check if vulnerabilities pass the threshold set in the config file
                                                self.extract_info_list(
                                                    table["elem"],
                                                    data["nmaprun"]["host"]["ports"][
                                                        "port"
                                                    ][0],
                                                )

                                            elif (
                                                self.include_non_exploit is True
                                                and table["elem"][i][TEXT] == "true"
                                            ):
                                                logging.info(
                                                    "excluding vulnerabilities that have no exploits"
                                                )
                                                # extract vulnerability data
                                                self.extract_info_list(
                                                    table["elem"],
                                                    data["nmaprun"]["host"]["ports"][
                                                        "port"
                                                    ][0],
                                                )
                                            else:
                                                logging.info(
                                                    "Could not determine whether to include vulnerabilities that have no exploits"
                                                )
                                                logging.info(
                                                    "The value for INCLUDE_NON_EXPLOIT is %s",
                                                    self.include_non_exploit,
                                                )
                                                logging.info(
                                                    'The value for elements["elem"][3][TEXT] is %s',
                                                    table["elem"][i][TEXT],
                                                )
                                            i += 1
                                        else:
                                            i += 1
                else:
                    try:
                        for elements in ports[elements]["table"]["table"]:
                            if type(elements) is dict:
                                logging.info("type is dict, treating it as such")
                                # if vulnerabilities which have no exploits should be included
                                i = 0
                                while i < 4:
                                    if elements["elem"][i][KEY] == "is_exploit":
                                        if (
                                            self.include_non_exploit is False
                                            and elements["elem"][i][TEXT] == "true"
                                        ):
                                            logging.info(
                                                "including vulnerabilities that have no exploits"
                                            )
                                            self.extract_info_dict(
                                                elements["elem"],
                                                data["nmaprun"]["host"]["ports"][
                                                    "port"
                                                ][0],
                                            )

                                        elif (
                                            self.include_non_exploit is True
                                            and elements["elem"][i][TEXT] == "false"
                                        ):
                                            logging.info(
                                                "excluding vulnerabilities that have no exploits"
                                            )

                                            self.extract_info_dict(
                                                elements["elem"],
                                                data["nmaprun"]["host"]["ports"][
                                                    "port"
                                                ][0],
                                            )
                                        else:
                                            logging.info(
                                                "Could not determine whether to include vulnerabilities that have no exploits"
                                            )
                                            logging.info(
                                                "The value for INCLUDE_NON_EXPLOIT is %s",
                                                self.include_non_exploit,
                                            )
                                            logging.info(
                                                'The value for elements["elem"][3][TEXT] is %s',
                                                elements["elem"][i][TEXT],
                                            )
                                        i += 1
                                    else:
                                        i += 1
                    except TypeError:
                        sys.exit(1)

        logging.info("printing out results......................................")
        logging.info(self.results)
        with open(nmap_results, "w") as json_file:
            json.dump(self.results, json_file)


if __name__ == "__main__":
    args = parser.parse_args()
    nmap_instance = nmap()
    nmap_instance.convert_xml_to_dict(NMAP_RAW_RESULTS_XML, NMAP_RAW_RESULTS_JSON)
    nmap_instance.load_config(args)
    nmap_instance.process_results(NMAP_RAW_RESULTS_JSON, NMAP_RESULTS)
