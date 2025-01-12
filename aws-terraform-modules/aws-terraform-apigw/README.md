# API Gateway Terraform Module

This Terraform module creates and manages AWS API Gateway resources, including REST APIs, resources, methods, authorizers, deployments, domain names, and integrations.

## Features

- Create multiple API Gateways
- Define API resources and methods
- Set up custom authorizers
- Configure SQS integrations
- Manage deployments and stages
- Set up custom domain names with SSL/TLS certificates
- Create base path mappings

## Usage

```hcl
module "api_gateway" {
  source = "./path/to/this/module"

  region         = "us-west-2"
  sqs_queue_name = "my-sqs-queue"

  api_gateways = {
    my_api = {
      name        = "My API"
      description = "My API Gateway"
      endpoint_configuration = {
        type                  = ["REGIONAL"]
        acm_certificate_arn   = "arn:aws:acm:us-west-2:123456789012:certificate/abcdef12-3456-7890-abcd-ef1234567890"
      }
      domain_name     = "api.example.com"
      authorizer_name = "my-custom-authorizer"
      sqs_role_arn    = "arn:aws:iam::123456789012:role/api-gateway-sqs-role"
      stage           = "prod"
      resources = [
        {
          name      = "resource1"
          parent_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
        }
      ]
      methods = [
        {
          name             = "POST"
          resource         = "/resource1"
          http_method      = "POST"
          request_template = <<EOF
Action=SendMessage&MessageBody={
  "method": "$context.httpMethod",
  "body" : $input.json('$'),
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))" #if($foreach.hasNext),#end
    #end
  }
}
EOF
        }
      ]
      tags = {
        Environment = "Production"
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | The AWS region where resources will be created | `string` | n/a | yes |
| sqs_queue_name | The name of the SQS queue for API Gateway integration | `string` | n/a | yes |
| api_gateways | A map of API Gateway configurations | `map(object)` | n/a | yes |

The `api_gateways` object should contain the following structure for each API:

```hcl
{
  name        = string
  description = string
  endpoint_configuration = object({
    type                = list(string)
    acm_certificate_arn = string
  })
  domain_name     = string
  authorizer_name = string
  sqs_role_arn    = string
  stage           = string
  resources       = list(object({
    name      = string
    parent_id = string
  }))
  methods = list(object({
    name             = string
    resource         = string
    http_method      = string
    request_template = string
  }))
  tags = map(string)
}
```

## Resources Created

- `aws_api_gateway_rest_api`: The main API Gateway resource
- `aws_api_gateway_resource`: API Gateway resources (endpoints)
- `aws_api_gateway_method`: HTTP methods for the resources
- `aws_api_gateway_authorizer`: Custom authorizer for the API
- `aws_api_gateway_deployment`: Deployment of the API
- `aws_api_gateway_domain_name`: Custom domain name for the API
- `aws_api_gateway_base_path_mapping`: Base path mapping for the custom domain
- `aws_api_gateway_integration`: Integration with SQS for each method

## Notes

- This module assumes a custom authorizer and SQS integration for all methods. Modify the module if you need different configurations.
- Ensure that the SQS queue and the IAM role for SQS integration exist before applying this module.
- The module uses a `for_each` loop to create multiple API Gateways, resources, and methods based on the input configuration.
- Remember to manage your API Gateway stages separately if you need more control over stage settings.

## Outputs

This module doesn't define any outputs. Consider adding outputs for important resource IDs or ARNs if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).