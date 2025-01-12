output "rule_arns" {
  description = "ARNs of the created EventBridge rules"
  value       = aws_cloudwatch_event_rule.this[*].arn
}