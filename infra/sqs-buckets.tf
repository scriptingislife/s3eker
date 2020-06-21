resource "aws_sqs_queue" "buckets" {
    name = "s3eker-buckets"
    max_message_size            = 2048
    message_retention_seconds   = 86400
    receive_wait_time_seconds   = 10
}