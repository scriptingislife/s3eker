import logging
import requests
import boto3
import json
from botocore.exceptions import ClientError
import base64

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)

def main(event, context):
    s3_event = event["Records"][0]["s3"]
    s3_object = s3_event["object"]["key"]

    target_bucket = s3_object.split('.')[0]

    s3 = boto3.client("s3")
    try:
        s3.list_objects(Bucket=target_bucket)
        logging.info(f"Bucket {target_bucket} is open!")
        
        webhook = get_secret()
        response = requests.post(webhook, headers={'Content-type': 'application/json'}, data=json.dumps({"text": f"Bucket `{target_bucket}` is open!"}))
        if response.status_code != 200:
            logging.error(f"Slack returned status code {response.status_code}.")

    except ClientError as e:
        if e.response['Error']['Code'] == "AccessDenied":
            logging.info(f"Permission denied for bucket {target_bucket}")
        else:
            raise

def get_secret():

    secret_name = "s3ekerSlackWebhook"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            return get_secret_value_response['SecretString']
        else:
            return base64.b64decode(get_secret_value_response['SecretBinary'])
            

if __name__ == "__main__":
    blah = {
        'Records': [
            {
                's3': {
                    'bucket': {
                        'name': 'bloopy'
                    },
                    'object': {
                        'key': 's3eker-open.s3-website-us-east-1.amazonaws.com'
                    }
                }
            }
        ]
    }
    main(blah, None)