resource "aws_lambda_function" "ingest" {
    function_name   = "s3eker-ingest"
    s3_bucket       = var.lambda_bucket_name
    s3_key          = "ingest/ingest.zip"

    memory_size     = 128
    timeout         = 240

    handler         = "main"
    runtime         = "python3.7"
    role            = aws_iam_role.exec_ingest.arn
}

resource "aws_iam_role" "exec_ingest" {
  name                = "s3eker-lambda-ingest"
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

resource "aws_iam_role_policy_attachment" "attach-ingest-buckets-read" {
    role = aws_iam_role.exec_ingest.name
    policy_arn = aws_iam_policy.buckets-read.arn
}

resource "aws_iam_role_policy_attachment" "attach-ingest-buckets-write" {
    role = aws_iam_role.exec_ingest.name
    policy_arn = aws_iam_policy.buckets-write.arn
}

resource "aws_cloudwatch_event_rule" "fetch-interval" {
  name = "s3eker-fetch-interval"
  description = "Time interval to trigger s3eker fetch Lambda."
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "fetch-interval" {
  rule = aws_cloudwatch_event_rule.fetch-interval.name
  target_id = "s3eker-ingest"
  arn = aws_lambda_function.ingest.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_s3eker_ingest" {
  statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ingest.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.fetch-interval.arn}"
}
