output "db_instance_ids" {
  description = "The IDs of the RDS instances"
  value       = { for k, v in aws_db_instance.this : k => v.id }
}

output "db_instance_arns" {
  description = "The ARNs of the RDS instances"
  value       = { for k, v in aws_db_instance.this : k => v.arn }
}

output "db_instance_endpoints" {
  description = "The connection endpoints of the RDS instances"
  value       = { for k, v in aws_db_instance.this : k => v.endpoint }
}