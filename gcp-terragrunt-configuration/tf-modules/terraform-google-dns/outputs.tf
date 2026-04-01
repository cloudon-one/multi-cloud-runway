output "type" {
  description = "The DNS zone type"
  value       = var.type
}

output "name" {
  description = "The DNS zone name"
  value       = module.dns.name
}

output "domain" {
  description = "The DNS zone domain"
  value       = module.dns.domain
}

output "name_servers" {
  description = "The DNS zone name servers"
  value       = module.dns.name_servers
}
