variable "region" {
  description = "AWS region"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "sqs_role_arn" {
  description = "ARN of the IAM role for SQS"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "authorizer_name" {
  description = "Name of the Lambda authorizer"
  type        = string
}

variable "inputs" {
  description = "List of API Gateway configurations"
  type = list(object({
    name                   = string
    description            = string
    stage                  = string
    domain_name            = string
    endpoint_configuration = object({
      type                 = list(string)
      acm_certificate_arn  = string
    })
    tags                   = map(string)
    resources = list(object({
      name                 = string
      parent_id            = string
    }))
    methods = list(object({
      name                 = string
      resource             = string
      http_method          = string
      request_template     = string
    }))
  }))
}