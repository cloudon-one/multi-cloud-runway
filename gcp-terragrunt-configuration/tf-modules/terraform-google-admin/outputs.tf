output "project_id" {
  description = "Admin Project ID"
  value       = module.admin_project.project_id
}

output "state_buckets" {
  description = "Mapping of the environment and bucket name"
  value       = { for bucket in google_storage_bucket.terraform_state_buckets : replace(bucket.name, "${module.admin_project.project_id}-", "") => bucket.name }
}

output "admin_terraform_state_bucket" {
  description = "Bucket where the state file for this module will be stored"
  value       = google_storage_bucket.this_admin_state_file.name
}

output "admin_folder" {
  description = "Admin Folder ID"
  value       = var.admin_folder ? google_folder.admin_folder.0.name : ""
}

output "folders" {
  description = "Folder objects"
  value = merge(
    google_folder.level_1,
    google_folder.level_2,
    google_folder.level_3,
    google_folder.level_4,
    google_folder.level_5,
  )
}

output "terraform_sa_accounts" {
  description = "Terraform Service Accounts"
  value       = google_service_account.terraform_sa_accounts
}