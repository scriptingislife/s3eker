# s3eker <img src="res/icon.png" alt="icon" width="32"/>
Find open S3 buckets by searching website source code. s3eker searches [urlscan.io](https://urlscan.io) for websites that reach out to a `s3-website-us-east-1.amazonaws.com` subdomain. It will then attempt to list the contents of the bucket. The theory being if a bucket is being used as a static site, it may have more relaxed permissions. Additional criteria and inputs may be added later. If an open bucket is found it will alert via Slack.

<img src="res/notif.png" alt="notification" width="200"/>

s3eker runs on AWS and can be spun up using Terraform with the exception of a Secrets Manager entry for the Slack webhook. No API key is needed for urlscan.io. There are two serverless Lambda functions to run the searching and listing operations. A S3 bucket used to track previously seen buckets and to trigger the second Lambda. 

<img src="res/s3eker.png" alt="diagram"/>