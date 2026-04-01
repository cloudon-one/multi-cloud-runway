output "shared_vpc_attachments" {
  description = "Map of shared VPC service project attachments"
  value       = google_compute_shared_vpc_service_project.shared_vpc_attachments
}

output "workload_identity_service_accounts" {
  description = "Map of workload identity service account emails"
  value       = { for k, v in module.workload_identity_iam : k => v.service_account_email }
}

output "workload_identity_service_account_names" {
  description = "Map of workload identity service account fully qualified names"
  value       = { for k, v in module.workload_identity_iam : k => v.service_account_name }
}

output "organization_iam_bindings" {
  description = "Map of IAM bindings applied at organization level"
  value       = { for k, v in module.organization_iam : k => v }
}

output "folder_iam_bindings" {
  description = "Map of IAM bindings applied at folder level"
  value       = { for k, v in module.folder_iam : k => v }
}

output "project_iam_bindings" {
  description = "Map of IAM bindings applied at project level"
  value       = { for k, v in module.project_iam : k => v }
}

output "subnet_iam_bindings" {
  description = "Map of IAM bindings applied to subnets"
  value       = { for k, v in module.subnet_iam : k => v }
}

output "storage_bucket_iam_bindings" {
  description = "Map of IAM bindings applied to storage buckets"
  value       = { for k, v in module.storage_buckets_iam : k => v }
}

output "service_account_iam_bindings" {
  description = "Map of IAM bindings applied to service accounts"
  value       = { for k, v in module.service_account_iam : k => v }
}
