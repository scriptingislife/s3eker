import requests
import logging
import boto3
import json

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)

def main(event, context):
    # Gather URLScan.io results for scans with a request to s3-website domains.
    req_results = requests.get("https://urlscan.io/api/v1/search/?q=domain:s3-website-us-east-1.amazonaws.com&size=20")
    if req_results.status_code != 200:
        logging.error("Bad request.")

    client = boto3.client('sns')
    sns_arn = "arn:aws:sns:us-east-1:358663747217:s3eker-upload"

    results = req_results.json()
    logging.info("Running through search results.")
    for result in results["results"]:
        logging.info(f"Getting info from scan {result['result']}")
        req_scan = requests.get(result["result"])
        if req_scan.status_code != 200:
            logging.error("Bad request.")

        scan = req_scan.json()
        domains = scan["lists"]["domains"]
        logging.debug(f"Got list of domains. {domains}")
        s3_sites = [domain for domain in domains if "s3-website" in domain]
        logging.info(f"Made list of s3 domains. {s3_sites}")
        for site in s3_sites:
            upload(client, sns_arn, site)

def upload(client, topic_arn,site):
    logging.info(f"Publishing {site} to SNS topic.\n")
    client.publish(TargetArn=topic_arn, Message=json.dumps({'default': json.dumps({'bucket': site}), 'sms':site, 'email':site}), Subject=f"New site to check",MessageStructure='json')

if __name__ == "__main__":
    main(None, None)