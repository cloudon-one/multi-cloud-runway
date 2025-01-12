output "cluster_identifiers" {
  description = "The identifiers of the Aurora clusters"
  value       = { for k, v in aws_rds_cluster.this : k => v.cluster_identifier }
}

output "cluster_endpoints" {
  description = "The endpoints of the Aurora clusters"
  value       = { for k, v in aws_rds_cluster.this : k => v.endpoint }
}

output "cluster_reader_endpoints" {
  description = "The reader endpoints of the Aurora clusters"
  value       = { for k, v in aws_rds_cluster.this : k => v.reader_endpoint }
}