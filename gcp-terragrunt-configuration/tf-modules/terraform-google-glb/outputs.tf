output "backend-service" {
  description = "name of backend service that NEGs should attach to"
  value       = google_compute_backend_service.ingress.name
}

output "static-ip" {
  description = "static ip address"
  value       = google_compute_global_address.ingress.address
}

