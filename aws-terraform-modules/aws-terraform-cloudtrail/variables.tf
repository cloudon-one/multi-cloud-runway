variable "enable_log_file_validation" {
  type        = bool
  default     = true
  description = "Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs"
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is created in the current region or in all regions"
}

variable "include_global_service_events" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Enable logging for the trail"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudTrail logs"
}

variable "cloud_watch_logs_role_arn" {
  type        = string
  description = "Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group"
  default     = ""
}

variable "cloud_watch_logs_group_arn" {
  type        = string
  description = "Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered"
  default     = ""
}

variable "insight_selector" {
  type = list(object({
    insight_type = string
  }))

  description = "Specifies an insight selector for type of insights to log on a trail"
  default     = []
}

variable "event_selector" {
  type = list(object({
    include_management_events        = bool
    read_write_type                  = string
    exclude_management_event_sources = optional(set(string))

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  default     = []
}

variable "advanced_event_selector" {
  type = list(object({
    name = optional(string)
    field_selector = list(object({
      field           = string
      ends_with       = optional(list(string))
      not_ends_with   = optional(list(string))
      equals          = optional(list(string))
      not_equals      = optional(list(string))
      starts_with     = optional(list(string))
      not_starts_with = optional(list(string))
    }))
  }))
  description = "Specifies an advanced event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail"
  default     = ""
}

variable "is_organization_trail" {
  type        = bool
  default     = true
  description = "The trail is an AWS Organizations trail"
}

variable "sns_topic_name" {
  type        = string
  description = "Specifies the name of the Amazon SNS topic defined for notification of log file delivery"
  default     = null
}

variable "s3_key_prefix" {
  type        = string
  description = "Prefix for S3 bucket used by Cloudtrail to store logs"
  default     = null
}

variable "additional_tag_map" {
  type        = map(string)
  description = "Additional tags for the CloudTrail"
  default     = {}
  
}

variable "attributes" {
  type = list(string)
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`, in the order they appear in the list. New attributes are appended to the end of the list. The elements of the list are joined by the `delimiter` and treated as a single ID element."
  default = []
}

variable "context" {
  type = any
  description = "Single object for setting entire context at once. See description of individual variables for details. Leave string and numeric variables as `null` to use default value. Individual variable settings (non-null) override settings in context object, except for attributes, tags, and additional_tag_map, which are merged"
  default = {
    "additional_tag_map": {}, 
    "attributes": [], 
    "delimiter": null, 
    "descriptor_formats": {}, 
    "enabled": true, 
    "environment": null, 
    "id_length_limit": null, 
    "label_key_case": null, 
    "label_order": [], 
    "label_value_case": null, 
    "labels_as_tags": [ "unset" ], 
    "name": null, "namespace": null, 
    "regex_replace_chars": null, 
    "stage": null, "tags": {}, 
    "tenant": null}
}

variable "delimiter" {
  type = string
  description = "Delimiter to be used between ID elements. Defaults to `-` (hyphen). Set to  to use no delimiter at all"
  default = null  
}

variable "enabled" {
  type = bool
  description = "Set to false to prevent the module from creating any resources"
  default = true
}

variable "environment" {
  type = string
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  default = ""
}

variable "tags" {
  type = map(string)
  description = "A map of tags to add to all resources"
  default = {}
}