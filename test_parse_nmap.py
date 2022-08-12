import logging

import pytest

from parse_nmap import nmap

logging.basicConfig(level=logging.DEBUG)
TEXT = "#text"
SELECTED_CONFIG = []
KEY = "@key"
NMAP_RAW_RESULTS_XML_TEST = "test_results/nmap_raw_results_test.xml"
NMAP_RAW_RESULTS_JSON_TEST = "test_results/nmap_raw_results.json"
NMAP_RESULTS = "test_results/nmap_processed_test_results"
results = []

nmap_instance = nmap()
nmap_instance.convert_xml_to_dict(
    NMAP_RAW_RESULTS_XML_TEST,
    NMAP_RAW_RESULTS_JSON_TEST,
)
