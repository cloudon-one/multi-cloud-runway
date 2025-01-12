variable "dynamodb_tables" {
  description = "Configuration for DynamoDB tables"
  type = list(object({
    name                 = string
    billing_mode         = string
    read_capacity        = optional(string)
    write_capacity       = optional(string)
    autoscaling_enabled  = optional(bool)
    autoscaling_read     = optional(map(string))
    autoscaling_write    = optional(map(string))
  }))
}