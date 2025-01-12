output "acm_certificate_arn" {
  value = module.acm.acm_certificate_arn
}

output "acm_certificate_domain_validation_options" {
  value = module.acm.acm_certificate_domain_validation_options
}

output "acm_certificate_status" {
  value = module.acm.acm_certificate_status
}

output "acm_certificate_validation_emails" {
  value = module.acm.acm_certificate_validation_emails
}

output "distinct_domain_names" {
  value = module.acm.distinct_domain_names
}

output "validation_domains" {
  value = module.acm.validation_domains
}

output "validation_route53_record_fqdns" {
  value = module.acm.validation_route53_record_fqdns
}