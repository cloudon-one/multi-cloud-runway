variable "acm_certificate_domain_validation_options" {
  description = "A list of domain_validation_options created by the ACM certificate to create required Route53 records from it (used when create_route53_records_only is set to true)"
  type        = any
  default     = {}
}

variable "certificate_transparency_logging_preference" {
  description = "Specifies whether certificate details should be added to a certificate transparency log"
  type = bool
  default = true
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "create_route53_records" {
  description = "When validation is set to DNS, define whether to create the DNS records internally via Route53 or externally using any DNS provider"
  type = bool
  default = true
}

variable "create_route53_records_only" {
  description = "Whether to create only Route53 records (e.g. using separate AWS provider)"
  type = bool
    default = false
}

variable "distinct_domain_names" {
  description = "A list of distinct domain names to use for the ACM certificate"
  type        = list(string)
  default = []
}

variable "dns_ttl" {
  description = "The TTL value for the DNS records"
  type        = number
    default     = 60
}

variable "domain_name" {
  description = "The domain name to use for the ACM certificate"
  type        = string
  default     = ""
}

variable "key_algorithm" {
  description = "The algorithm to use for the key"
  type        = string
  default     = null
}

variable "subject_alternative_names" {
  description = "A list of domain names that should be SANs in the ACM certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "value of tags to apply to the ACM certificate"
    type        = map(string)
    default     = {}
}

variable "validate_certificate" {
  description = "Whether to validate the ACM certificate"
  type        = bool
  default     = true
}

variable "validation_allow_overwrite_records" {
  description = "Whether to allow overwrite of Route53 records"
  type        = bool
  default     = true
}

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid. This parameter must not be set for certificates that were imported into ACM and then into Terraform"
  type        = string
  default     = "DNS"
}

variable "validation_option" {
  description = "The domain name that you want ACM to use to send you validation emails. This domain name is the suffix of the email addresses that you want ACM to use."
  type        = any
  default     = {}
}

variable "validation_record_fqdns" {
  description = "A list of FQDNs to use for the DNS validation"
  type        = list(string)
  default     = []   
}

variable "validation_timeout" {
  description = "The maximum time in seconds that you want ACM to wait for your domain validation"
  type        = number
  default     = null             
}

variable "wait_for_validation" {
  description = "Whether to wait for the ACM certificate to be validated"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record. Required when validating via Route53"
    type        = string
    default     = ""
}

variable "zones" {
  description = "value of zones to apply to the ACM certificate"
    type        = map(string)
    default     = {}
}