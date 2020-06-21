resource "aws_lambda_function" "scan" {
    function_name   = "s3eker-scan"
    s3_bucket       = var.lambda_bucket_name
    s3_key          = "scan/scan.zip"

    memory_size     = 128
    timeout         = 15

    handler         = "main.main"
    runtime         = "python3.7"
    role            = aws_iam_role.exec_scan.arn
}

resource "aws_iam_role" "exec_scan" {
  name                = "s3eker-lambda-scan"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-scan-buckets-read" {
    role = aws_iam_role.exec_scan.name
    policy_arn = aws_iam_policy.buckets-read.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scan.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.buckets.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.buckets.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.scan.arn}"
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}