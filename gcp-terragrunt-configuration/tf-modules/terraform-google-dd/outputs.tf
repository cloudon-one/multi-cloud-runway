output "host_filters" {
  value       = datadog_integration_gcp.project.host_filters
  description = "Datadog monitoring host filters"
}

output "service_account_email" {
  value       = module.service_account.email
  description = "Datadog IAM service account email"
}