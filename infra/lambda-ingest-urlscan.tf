resource "aws_lambda_function" "ingest-urlscan" {
    function_name   = "s3eker-ingest-urlscan"
    s3_bucket       = var.lambda_bucket_name
    s3_key          = "ingest-urlscan-urlscan/ingest-urlscan.zip"

    memory_size     = 128
    timeout         = 240

    handler         = "main.main"
    runtime         = "python3.7"
    role            = aws_iam_role.exec_ingest-urlscan.arn
}

resource "aws_iam_role" "exec_ingest-urlscan" { 
  name                = "s3eker-lambda-ingest-urlscan"
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

resource "aws_iam_role_policy_attachment" "attach-ingest-urlscan-lambda-execute" {
  role = aws_iam_role.exec_ingest-urlscan.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach-ingest-urlscan-buckets-read" {
    role = aws_iam_role.exec_ingest-urlscan.name
    policy_arn = aws_iam_policy.buckets-read.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_s3eker_ingest-urlscan" {
  statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ingest-urlscan.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every-hour.arn
}

resource "aws_cloudwatch_event_target" "ingest-urlscan" {
  rule = aws_cloudwatch_event_rule.every-hour.name
  target_id = "s3eker-ingest-urlscan"
  arn = aws_lambda_function.ingest-urlscan.arn
}
