resource "aws_cloudwatch_event_rule" "every-hour" {
  name = "s3eker-fetch-interval"
  description = "Time interval to trigger s3eker fetch Lambda."
  schedule_expression = "rate(1 hour)"
}
