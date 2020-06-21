resource "aws_s3_bucket" "buckets" {
    bucket  = "s3eker-buckets"
    acl     = "private"
}

resource "aws_iam_policy" "buckets-write" {
    name = "s3eker-s3-buckets-write"
    description = "Allows writing to S3 bucket used for storing bucket domains."
    policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Sid": "VisualEditor0",
    "Action": [
        "s3:PutObject"
    ],
    "Effect": "Allow",
    "Resource": "${aws_s3_bucket.buckets.arn}/*"
    }
]
}
    EOF
}

resource "aws_iam_policy" "buckets-read" {
    name = "s3eker-s3-buckets-read"
    description = "Allows reading S3 bucket used for storing bucket domains."
    policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Sid": "VisualEditor0",
    "Action": [
        "s3:GetObject",
        "s3:ListBucket"
    ],
    "Effect": "Allow",
    "Resource": "${aws_s3_bucket.buckets.arn}/*"
    }
]
}
    EOF
}