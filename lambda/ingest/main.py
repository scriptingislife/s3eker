import requests
import logging
from boto3 import client
from boto.s3.key import Key
import botocore

def main(event, context):
    # Gather URLScan.io results for scans with a request to s3-website domains.
    req_results = requests.get("https://urlscan.io/api/v1/search/?q=domain:s3-website-us-east-1.amazonaws.com&size=20")
    if req_results.status_code != 200:
        logging.error("Bad request.")

    s3 = client('s3')
    bucket_name = "s3eker-buckets"

    global_s3_sites = set()

    results = req_results.json()
    for result in results["results"]:
        req_scan = requests.get(result["result"])
        if req_scan.status_code != 200:
            logging.error("Bad request.")

        scan = req_scan.json()
        domains = scan["lists"]["domains"]
        s3_sites = [domain for domain in domains if "s3-website" in domain]
        for site in s3_sites:
            # https://stackoverflow.com/questions/33842944/check-if-a-key-exists-in-a-bucket-in-s3-using-boto3
            try:
                s3.Object("s3eker-buckets", site).load()
            except botocore.exceptions.ClientError as e:
                if e.response['Error']['Code'] == "404":
                    pass
                else:
                    logging.error("Error while getting object.")
                    # Something else has gone wrong
                    raise
            else:
                # The object does not exist
                create_key(bucket_name, site)
                
def create_key(bucket, key):
    s3 = boto3.client('s3')
    try:
        response = s3.upload_fileobj(bytearray(), bucket, key)
    except ClientError as e:
        logging.error(e)
        return False
    return True


if __name__ == "__main__":
    main(None, None)