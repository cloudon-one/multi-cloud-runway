locals {
  # Process all API Gateway configs
  api_gateways = { for config in var.inputs :
    config.name => merge(config, {
      sqs_role_arn    = var.sqs_role_arn
      authorizer_name = var.authorizer_name
    })
  }
}