pack: ## Package the code into zip archive, upload to the S3 bucket, and update the functions.
	cd lambda && ./pack.sh

remove: ## Remove the test bucket from the list of previously scanned buckets.
	aws s3 rm s3://s3eker-buckets/s3eker-open.s3-website-us-east-1.amazonaws.com

test: remove ## Publish a test open bucket to the SNS topic.
	aws sns publish --topic-arn 'arn:aws:sns:us-east-1:xxxxxxxxxxxx:s3eker-upload' --message '{"bucket": "s3eker-open.s3-website-us-east-1.amazonaws.com"}'