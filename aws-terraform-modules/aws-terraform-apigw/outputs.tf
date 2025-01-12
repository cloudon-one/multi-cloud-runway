output "api_gateway_urls" {
  description = "Map of API Gateway URLs"
  value = { for k, v in aws_api_gateway_deployment.this :
    k => "https://${aws_api_gateway_domain_name.this[k].domain_name}/${v.stage_name}"
  }
}

output "api_gateway_ids" {
  description = "Map of API Gateway IDs"
  value = { for k, v in aws_api_gateway_rest_api.this : k => v.id }
}