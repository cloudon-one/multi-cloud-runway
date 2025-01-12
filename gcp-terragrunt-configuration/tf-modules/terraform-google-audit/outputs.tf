output "project_id" {
  description = "Audit Project ID"
  value       = module.audit_project.project_id
}

output "log_sink_sa" {
  description = "Service account name of the log sink"
  value       = module.log_export.writer_identity
}

output "log_filter" {
  description = "Log filter expression"
  value       = module.log_export.filter
}

output "destination_uri" {
  description = "PubSub topic URI"
  value       = module.destination.destination_uri
}

output "console_link" {
  description = "The console link to the destination pubsub topic"
  value       = module.destination.console_link
}

output "topic_resource_name" {
  description = "The resource name for the destination pubsub topic"
  value       = module.destination.resource_name
}

output "topic_resource_id" {
  description = "The resource id for the destination pubsub topic"
  value       = module.destination.resource_id
}
