import json
import requests
import logging
import boto3
import botocore

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)


def main(event, context):
    sns_event = event["Records"][0]["Sns"]
    bucket = json.loads(sns_event["Message"])["bucket"]

    s3 = boto3.client('s3')
    bucket_name = "s3eker-buckets"

    logging.info("Checking if domain exists in bucket.")
    # https://stackoverflow.com/questions/33842944/check-if-a-key-exists-in-a-bucket-in-s3-using-boto3
    
    logging.info(f"Loading object {bucket}")
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=bucket)
    found = False
    for obj in response.get('Contents', []):
        if obj['Key'] == bucket:
            found = True

    if not found:
        create_key(bucket_name, bucket)
                
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