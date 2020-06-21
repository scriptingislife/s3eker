from botocore.vendored import requests
import logging
import boto3
import botocore

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)


def main(event, context):
    # Gather URLScan.io results for scans with a request to s3-website domains.
    req_results = requests.get("https://urlscan.io/api/v1/search/?q=domain:s3-website-us-east-1.amazonaws.com&size=20")
    if req_results.status_code != 200:
        logging.error("Bad request.")

    s3 = boto3.client('s3')
    bucket_name = "s3eker-buckets"

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
            logging.info("Checking if domain exists in bucket.")
            # https://stackoverflow.com/questions/33842944/check-if-a-key-exists-in-a-bucket-in-s3-using-boto3
            
            logging.info(f"Loading object {site}")
            response = s3.list_objects_v2(Bucket=bucket_name, Prefix=site)
            found = False
            for obj in response.get('Contents', []):
                if obj['Key'] == site:
                    found = True

            if not found:
                create_key(bucket_name, site)

            logging.info("\tBloopy bloop.")
                
def create_key(bucket, key):
    logging.info(f"Creating key {key} in bucket {bucket}.\n")
    s3 = boto3.client('s3')
    try:
        s3.put_object(Bucket=bucket, Key=key)
    except botocore.exceptions.ClientError as e:
        logging.error(e)
        return False
    return True


if __name__ == "__main__":
    main(None, None)