resource "aws_sns_topic" "upload" {
    name = "s3eker-upload"
}

resource "aws_iam_policy" "upload-write" {
    name = "s3eker-sns-upload-write"
    description = "Allow ingestion Lambdas to write to SNS topic."
    policy = <<EOF
{
  "Id": "Policy1595299188603",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1595299187036",
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.upload.arn}",
      "Principal": "*"
    }
  ]
}
    EOF
}