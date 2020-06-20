import requests
import logging
from boto3 import client

def main():
    req_results = requests.get("https://urlscan.io/api/v1/search/?q=domain:s3-website-us-east-1.amazonaws.com&size=20")
    if req_results.status_code != 200:
        logging.error("Bad request.")

    s3 = client('s3')

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
            if site not in global_s3_sites:
                print(site)
            global_s3_sites.add(site)

if __name__ == "__main__":
    main()