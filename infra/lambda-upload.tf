resource "aws_lambda_function" "upload" {
    function_name   = "s3eker-upload"
    s3_bucket       = var.lambda_bucket_name
    s3_key          = "upload/upload.zip"

    memory_size     = 128
    timeout         = 240

    handler         = "main.main"
    runtime         = "python3.7"
    role            = aws_iam_role.exec_upload.arn
}

resource "aws_iam_role" "exec_upload" {
  name                = "s3eker-lambda-upload"
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

resource "aws_iam_role_policy_attachment" "attach-upload-lambda-execute" {
  role = aws_iam_role.exec_upload.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach-upload-buckets-read" {
    role = aws_iam_role.exec_upload.name
    policy_arn = aws_iam_policy.buckets-read.arn
}

resource "aws_iam_role_policy_attachment" "attach-upload-buckets-write" {
    role = aws_iam_role.exec_upload.name
    policy_arn = aws_iam_policy.buckets-write.arn
}
