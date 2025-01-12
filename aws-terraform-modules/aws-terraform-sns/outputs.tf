output "topic_arns" {
  description = "ARNs of the created SNS topics"
  value       = { for k, v in aws_sns_topic.this : k => v.arn }
}

output "subscription_arns" {
  description = "ARNs of the created SNS subscriptions"
  value       = aws_sns_topic_subscription.this[*].arn
}