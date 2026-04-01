output "service_account_email" {
  description = "Email of the GCP service account bound to the Kubernetes service account"
  value       = google_service_account.cluster_service_account.email
}

output "service_account_name" {
  description = "Fully qualified name of the GCP service account"
  value       = google_service_account.cluster_service_account.name
}
