# AWS VPC Peering Multi-Account Terraform Module

This Terraform module creates and manages VPC peering connections between VPCs in different AWS accounts.

## Features

- Create VPC peering connections across different AWS accounts
- Configure both requester and accepter sides of the peering connection
- Manage route table entries for peered VPCs
- Support for cross-region peering
- Flexible configuration options for AWS credentials and assume role capabilities

## Usage

```hcl
module "vpc-peering-multi-account" {
  source  = "cloudposse/vpc-peering-multi-account/aws"
  version = "0.20.0"

  namespace = "eg"
  stage     = "prod"
  name      = "vpc-peering"

  requester_vpc_id = "vpc-XXXXXXXXXXXXXXXXX"
  accepter_vpc_id  = "vpc-YYYYYYYYYYYYYYYYY"

  requester_aws_assume_role_arn = "arn:aws:iam::1111111111:role/OrganizationAccountAccessRole"
  accepter_aws_assume_role_arn  = "arn:aws:iam::2222222222:role/OrganizationAccountAccessRole"

  requester_region = "us-west-2"
  accepter_region  = "us-east-1"

  auto_accept = true

  # Optionally, enable DNS resolution from accepter VPC to requester VPC
  accepter_allow_remote_vpc_dns_resolution = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| requester_vpc_id | Requester VPC ID | `string` | n/a | yes |
| accepter_vpc_id | Accepter VPC ID | `string` | n/a | yes |
| requester_aws_assume_role_arn | Requester AWS assume role ARN | `string` | n/a | yes |
| accepter_aws_assume_role_arn | Accepter AWS assume role ARN | `string` | n/a | yes |
| requester_region | Requester AWS region | `string` | n/a | yes |
| accepter_region | Accepter AWS region | `string` | n/a | yes |
| auto_accept | Automatically accept the peering (both VPCs need to be in the same AWS account) | `bool` | `true` | no |
| accepter_allow_remote_vpc_dns_resolution | Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC | `bool` | `false` | no |
| requester_allow_remote_vpc_dns_resolution | Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC | `bool` | `false` | no |

For a complete list of input variables, please refer to the `variables.tf` file in the module's repository.

## Outputs

| Name | Description |
|------|-------------|
| connection_id | VPC peering connection ID |
| accept_status | The status of the VPC peering connection request |
| requester_vpc_cidr | Requester VPC CIDR |
| accepter_vpc_cidr | Accepter VPC CIDR |
| requester_vpc_peering_connection_options | Requester VPC peering connection options |
| accepter_vpc_peering_connection_options | Accepter VPC peering connection options |

For a complete list of outputs, please refer to the `outputs.tf` file in the module's repository.

## Notes

1. This module requires appropriate IAM permissions to create and manage VPC peering connections in both the requester and accepter accounts.
2. Cross-region peering is supported, but make sure both regions are specified correctly.
3. When using `auto_accept = true`, both VPCs must be in the same AWS account.
4. The module uses the AWS provider's assume role functionality. Ensure that the provided role ARNs have the necessary permissions.

## Limitations

1. This module does not create the VPCs. You need to provide existing VPC IDs.
2. The module assumes a certain level of network architecture. Customize route table management if your setup differs significantly from standard patterns.
3. DNS resolution settings only apply to AWS provided DNS, not custom DNS servers.

## License

This module is released under the Apache 2.0 License. For more information, please see the [LICENSE](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account/blob/master/LICENSE) file in the official module repository.