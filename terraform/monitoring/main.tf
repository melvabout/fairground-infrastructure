terraform {
  backend "s3" {}
}

resource "aws_cloudwatch_event_rule" "fairground" {
  name        = "fairground-instance"
  description = "Capture when an Fiarground EC2 instance starts."

  event_pattern = jsonencode({
    "source" : ["aws.autoscaling"],
    "detail-type" : ["EC2 Instance Launch Successful"]
  })
}

resource "aws_cloudwatch_event_target" "fairground_instance" {
  rule      = aws_cloudwatch_event_rule.fairground.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.fairground_instance.arn
}

resource "aws_sns_topic" "fairground_instance" {
  name = "fairground-instance"
}

resource "aws_sns_topic_policy" "fairground_instance" {
  arn    = aws_sns_topic.fairground_instance.arn
  policy = data.aws_iam_policy_document.fairground_instance.json
}