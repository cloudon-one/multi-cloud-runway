output "projects" {
  description = "Map of projects and their outputs from the project factory"
  value       = local.project_outputs
}

output "vpcs" {
  description = "Map of projects and their outputs from the network factory"
  value       = local.vpc_outputs
}

output "service_accounts" {
  description = "Map of projects and their service_accounts"
  value       = local.sa_outputs
}

output "active_apis" {
  description = "Map of projects and their active apis"
  value       = local.api_outputs
}

output "kms_rings" {
  description = "Map of projects and kms rings"
  value       = local.key_outputs
}