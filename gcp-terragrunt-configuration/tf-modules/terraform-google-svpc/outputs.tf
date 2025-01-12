// Project factory outputs
output "project_name" {
  value = module.host_project.project_name
}

output "project_number" {
  value = module.host_project.project_number
}

output "domain" {
  value       = module.host_project.domain
  description = "The organization's domain"
}

output "group_email" {
  value       = module.host_project.group_email
  description = "The email of the G Suite group with group_name"
}

output "service_account_id" {
  value       = module.host_project.service_account_id
  description = "The id of the default service account"
}

output "service_account_display_name" {
  value       = module.host_project.service_account_display_name
  description = "The display name of the default service account"
}

output "service_account_email" {
  value       = module.host_project.service_account_email
  description = "The email of the default service account"
}

output "service_account_name" {
  value       = module.host_project.service_account_name
  description = "The fully-qualified name of the default service account"
}

output "service_account_unique_id" {
  value       = module.host_project.service_account_unique_id
  description = "The unique id of the default service account"
}

output "project_bucket_self_link" {
  value       = module.host_project.project_bucket_self_link
  description = "Project's bucket selfLink"
}

output "project_bucket_url" {
  value       = module.host_project.project_bucket_url
  description = "Project's bucket url"
}

output "budget_name" {
  value       = module.host_project.budget_name
  description = "The name of the budget if created"
}

// Network factory outputs
output "network" {
  value       = module.vpc
  description = "The created network"
}

output "subnets" {
  value       = module.vpc.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "proxy_subnets" {
  value       = module.subnets_beta.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding proxy subnets."
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "project_id" {
  value       = module.vpc.project_id
  description = "VPC project id"
}

output "subnets_names" {
  value       = module.vpc.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.vpc.subnets_regions
  description = "The region where the subnets will be created"
}

output "subnets_private_access" {
  value       = module.vpc.subnets_private_access
  description = "Whether the subnets will have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = module.vpc.subnets_flow_logs
  description = "Whether the subnets will have VPC flow logs enabled"
}

output "subnets_secondary_ranges" {
  value       = module.vpc.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

output "route_names" {
  value       = module.vpc.route_names
  description = "The route names associated with this VPC"
}