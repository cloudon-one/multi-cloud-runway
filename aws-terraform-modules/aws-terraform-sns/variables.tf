variable "topics" {
  description = "List of SNS topics to create"
  type = list(object({
    name = string
  }))
}

variable "subscriptions" {
  description = "List of SNS subscriptions to create"
  type = list(object({
    id       = string
    protocol = string
    topic    = string
  }))
}