output "fairground_instance_aws_sns_topic_arn" {
  description = "The arn of the fairground instances SNS Topic"
  value       = aws_sns_topic.fairground_instance.arn
}