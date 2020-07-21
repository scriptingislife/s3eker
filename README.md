# s3eker <img src="res/icon.png" alt="icon" width="32"/>
Find open S3 buckets by searching website source code. s3eker searches [urlscan.io](https://urlscan.io) for websites that reach out to a `s3-website-us-east-1.amazonaws.com` subdomain. It will then attempt to list the contents of the bucket. If an open bucket is found it will alert via Slack. The theory being if a bucket is being used as a static site, it may have more relaxed permissions. Additional criteria and inputs may be added later.

<img src="res/notif.png" alt="notification" width="200"/>

s3eker runs on AWS and can be spun up using Terraform with the exception of a Secrets Manager entry for the Slack webhook. No API key is needed for urlscan.io. Ingestion functions are run periodically using Cloudwatch events. They publish all found buckets to an SNS topic. This notifies the upload function which will check if the bucket has already been scanned. If it has not been scanned, the bucket name is uploaded to an S3 bucket, triggering the scan function.

<img src="res/s3eker.png" alt="diagram"/>