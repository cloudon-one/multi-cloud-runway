output "current_location_id" {
  value       = module.memorystore.current_location_id
  description = "The current zone where the Redis endpoint is placed."
}

output "host" {
  value       = module.memorystore.host
  description = "The IP address of the instance."
}

output "id" {
  value       = module.memorystore.id
  description = "The memorystore instance ID."
}

output "persistence_iam_identity" {
  value       = module.memorystore.persistence_iam_identity
  description = "Cloud IAM identity used by import/export operations. Format is 'serviceAccount:'. May change over time"
}

output "region" {
  value       = module.memorystore.region
  description = "The region the instance lives in."
}
