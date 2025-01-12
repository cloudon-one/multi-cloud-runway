output "policy_attachments" {
  description = "List of policy attachments created"
  value       = aws_iam_policy_attachment.policy_attachments[*].name
}