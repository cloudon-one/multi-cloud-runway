# API Gateway resource
resource "aws_api_gateway_rest_api" "this" {
  for_each = local.api_gateways

  name        = each.value.name
  description = each.value.description

  endpoint_configuration {
    types = each.value.endpoint_configuration.type
  }

  tags = each.value.tags
}

# API Gateway resources
resource "aws_api_gateway_resource" "this" {
  for_each = { for idx, resource in flatten([
    for k, v in local.api_gateways : [
      for r in v.resources : {
        key = "${k}_${r.name}"
        value = r
        api_id = aws_api_gateway_rest_api.this[k].id
      }
    ]
  ]) : resource.key => resource.value }

  rest_api_id = each.value.api_id
  parent_id   = each.value.parent_id
  path_part   = each.value.name
}

# API Gateway methods
resource "aws_api_gateway_method" "this" {
  for_each = { for idx, method in flatten([
    for k, v in local.api_gateways : [
      for m in v.methods : {
        key = "${k}_${m.name}"
        value = m
        api_id = aws_api_gateway_rest_api.this[k].id
        resource_id = aws_api_gateway_resource.this["${k}_${trimprefix(m.resource, "/")}"].id
      }
    ]
  ]) : method.key => method.value }

  rest_api_id   = each.value.api_id
  resource_id   = each.value.resource_id
  http_method   = each.value.http_method
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this[split("_", each.key)[0]].id
}

# API Gateway authorizer
resource "aws_api_gateway_authorizer" "this" {
  for_each = local.api_gateways

  name                   = each.value.authorizer_name
  rest_api_id            = aws_api_gateway_rest_api.this[each.key].id
  authorizer_uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${each.value.authorizer_name}/invocations"
  authorizer_credentials = each.value.sqs_role_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "this" {
  for_each = local.api_gateways

  depends_on = [
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this
  ]

  rest_api_id = aws_api_gateway_rest_api.this[each.key].id
  stage_name  = each.value.stage
}

# API Gateway domain name
resource "aws_api_gateway_domain_name" "this" {
  for_each = local.api_gateways

  domain_name     = each.value.domain_name
  certificate_arn = each.value.endpoint_configuration.acm_certificate_arn
}

# API Gateway base path mapping
resource "aws_api_gateway_base_path_mapping" "this" {
  for_each = local.api_gateways

  api_id      = aws_api_gateway_rest_api.this[each.key].id
  stage_name  = aws_api_gateway_deployment.this[each.key].stage_name
  domain_name = aws_api_gateway_domain_name.this[each.key].domain_name
}

# API Gateway integration (assuming SQS integration)
resource "aws_api_gateway_integration" "this" {
  for_each = { for idx, method in flatten([
    for k, v in local.api_gateways : [
      for m in v.methods : {
        key = "${k}_${m.name}"
        value = m
        api_id = aws_api_gateway_rest_api.this[k].id
        resource_id = aws_api_gateway_resource.this["${k}_${trimprefix(m.resource, "/")}"].id
      }
    ]
  ]) : method.key => method.value }

  rest_api_id             = each.value.api_id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.sqs_queue_name}"
  credentials             = local.api_gateways[split("_", each.key)[0]].sqs_role_arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = each.value.request_template
  }
}
