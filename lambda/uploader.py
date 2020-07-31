import json
import boto3
import logging

def upload(client, topic_arn,site):
    logging.info(f"Publishing {site} to SNS topic.\n")
    client.publish(TargetArn=topic_arn, Message=json.dumps({'default': json.dumps({'bucket': site}), 'sms':site, 'email':site}), Subject=f"New site to check",MessageStructure='json')
