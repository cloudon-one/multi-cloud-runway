variable "policies" {
  description = "List of policies with their ARNs and members"
  type = list(object({
    name    = string
    arn     = string
    members = list(string)
  }))
}