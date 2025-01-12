# AWS Transit Gateway Terraform Module

This Terraform module deploys an AWS Transit Gateway and its associated resources, including VPC attachments and Resource Access Manager (RAM) sharing configuration.

## Features

- Creates an AWS Transit Gateway
- Supports multiple VPC attachments
- Configures Resource Access Manager (RAM) for sharing the Transit Gateway
- Customizable route configurations for VPC attachments

## Usage

```hcl
module "tgw" {
  source = "path/to/module"

  name        = "my-transit-gateway"
  description = "Transit Gateway for my network"

  amazon_side_asn = 64532

  vpc_attachments = {
    vpc1 = {
      vpc_id     = "vpc-1234567890abcdef0"
      subnet_ids = ["subnet-1234567890abcdef0", "subnet-0987654321fedcba0"]
      
      tgw_routes = [
        {
          destination_cidr_block = "10.0.0.0/16"
        },
        {
          blackhole = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }
  }

  ram_allow_external_principals = true
  ram_principals                = ["123456789012"]

  tags = {
    Environment = "production"
    Project     = "MyProject"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.1 |
| aws | >= 3.63 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.63 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on all the resources as identifier | `string` | n/a | yes |
| description | Description of the Transit Gateway | `string` | `"My TGW shared with several other AWS accounts"` | no |
| amazon_side_asn | The Autonomous System Number (ASN) for the Amazon side of the gateway | `number` | `64532` | no |
| enable_auto_accept_shared_attachments | Whether resource attachment requests are automatically accepted | `bool` | `true` | no |
| vpc_attachments | Maps of maps of VPC details to attach to TGW | `any` | `{}` | no |
| ram_allow_external_principals | Allow external principals to access the Transit Gateway | `bool` | `true` | no |
| ram_principals | A list of RAM principals to share TGW with | `list(string)` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| tgw_id | EC2 Transit Gateway identifier |
| tgw_arn | EC2 Transit Gateway Amazon Resource Name (ARN) |
| tgw_route_table_id | EC2 Transit Gateway Route Table identifier |
| vpc_attachments | Map of VPC attachments |
| ram_resource_share_id | The ID of the resource share of TGW |

## Notes

- This module uses the AWS Transit Gateway module from the Terraform Registry. Make sure you have the necessary permissions to create these resources in your AWS account.
- The `vpc_attachments` variable allows for complex configurations. Refer to the AWS provider documentation for all available options.
- When `ram_allow_external_principals` is set to `true`, ensure that the `ram_principals` list contains only trusted AWS account IDs.

## Contributing

Contributions to this module are welcome. Please ensure that you update tests and documentation as appropriate.

## License

This module is released under the MIT License. See the LICENSE file for more details.