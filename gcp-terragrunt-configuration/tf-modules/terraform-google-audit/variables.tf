variable "billing_account" {
  description = "Billing Account"
  type        = string
}

variable "domain" {
  description = "Organization domain"
  type        = string
}

variable "audit_folder" {
  description = "Wheater to create audit folder or not"
  type        = bool
  default     = true
}

variable "audit_folder_name" {
  description = "Name of the audit folder if audit_folder = true"
  type        = string
  default     = "audit"
}

variable "audit_project_name" {
  type = string
}

variable "audit_project_id" {
  type    = string
  default = ""
}

variable "audit_random_project_id" {
  type = bool
}

variable "org_parent_folder" {
  description = "Parent folder on organization level for all nested child folders"
  type        = string
  default     = ""
}

variable "log_sink_name" {
  description = "Log sink name"
  type        = string
  default     = "organization_sink"
}

variable "skip_gcloud_download" {
  description = "If set to false the gcloud binaries will be downloaded. Use for Terraform Cloud"
  type        = bool
  default     = true
}

variable "topic_name" {
  description = "The name of the pubsub topic to be created and used for log entries matching the filter."
  type        = string
  default     = "audit_logs"
}

variable "create_push_subscriber" {
  description = "Whether to add a push configuration to the subcription. If 'true', a push subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic."
  type        = bool
  default     = true
}

variable "create_subscriber" {
  description = "Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic."
  type        = bool
  default     = true
}

variable "push_endpoint" {
  description = "The URL locating the endpoint to which messages should be pushed."
  type        = string
  default     = ""
}

variable "org_id" {
  description = "Org ID"
  type        = string
  default     = ""
}
