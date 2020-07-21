import requests
import logging
import boto3
import json

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)

def main(event, context):
    client = boto3.client('sns')
    sns_arn = "arn:aws:sns:us-east-1:358663747217:s3eker-upload"

    site = "example.com.s3-website-us-east-1.amazonaws.com"
    upload(client, sns_arn, site)

def upload(client, topic_arn,site):
    logging.info(f"Publishing {site} to SNS topic.\n")
    client.publish(TargetArn=topic_arn, Message=json.dumps({'default': json.dumps({'bucket': site}), 'sms':site, 'email':site}), Subject=f"New site to check",MessageStructure='json')

if __name__ == "__main__":
    main(None, None)