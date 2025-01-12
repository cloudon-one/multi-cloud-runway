variable "name_prefix" {
  description = "Prefix to be added to each bucket name"
  type        = string
  default     = ""
}

variable "buckets" {
  description = "List of bucket configurations"
  type = list(object({
    bucket_name = string
    tags = object({
      Environment   = string
      Owner         = string
      Description   = string
      Terraform     = string
      Name          = string
    })
  }))
}

