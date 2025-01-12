variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Managed by Terraform"
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = number
  default     = 64532
}

variable "enable_auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = bool
  default     = true
}

variable "vpc_attachments" {
  description = "Maps of maps of VPC details to attach to TGW"
  type        = any
  default     = {}
}

variable "ram_allow_external_principals" {
  description = "Allow external principals to access the Transit Gateway"
  type        = bool
  default     = true
}

variable "ram_principals" {
  description = "A list of RAM principals to share TGW with"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}