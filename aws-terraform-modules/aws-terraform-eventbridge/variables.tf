variable "rules" {
  description = "List of EventBridge rules to create"
  type = list(object({
    name           = string
    description    = string
    event_pattern  = any
  }))
  default = []
}