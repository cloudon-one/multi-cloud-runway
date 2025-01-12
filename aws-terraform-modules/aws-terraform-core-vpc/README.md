# AWS VPC Terraform Module

This Terraform module allows you to create multiple AWS VPCs with customizable configurations. It's built on top of the official AWS VPC module from the Terraform Registry.

## Features

- Create multiple VPCs in a single module call
- Configurable private and public subnets
- Optional NAT Gateway
- Customizable tags

## Example usage

To use this module, include the following code in your Terraform configuration:

```hcl
module "vpc" {
  source = "path/to/vpc/module"

  vpc_configs = [
    {
      vpc_name           = "outbound-vpc"
      vpc_cidr           = "192.168.200.0/24"
      private_subnets    = ["192.168.200.192/26", "192.168.200.128/26"]
      public_subnets     = ["192.168.200.64/26", "192.168.200.0/26"]
      azs                = ["us-east-2a", "us-east-2b"]
      enable_nat_gateway = true
      tags = {
        Owner = "Terraform"
        Name  = "outbound-vpc"
      }
    },
    {
      vpc_name           = "core-vpc"
      vpc_cidr           = "192.168.201.0/24"
      private_subnets    = ["192.168.201.192/26", "192.168.201.128/26"]
      azs                = ["us-east-2a", "us-east-2b"]
      enable_nat_gateway = false
      tags = {
        Owner = "Terraform"
        Name  = "core-vpc"
      }
    }
  ]
}
```

## Inputs

The module accepts the following input:

- `vpc_configs`: A list of objects, where each object represents a VPC configuration with the following attributes:
  - `vpc_name`: The name of the VPC
  - `vpc_cidr`: The CIDR block for the VPC
  - `private_subnets`: A list of CIDR blocks for private subnets
  - `public_subnets`: (Optional) A list of CIDR blocks for public subnets
  - `azs`: A list of Availability Zones
  - `enable_nat_gateway`: Boolean to enable/disable NAT Gateway
  - `tags`: A map of tags to apply to the VPC

## Outputs

The module provides the following outputs:

- `vpc_ids`: A map of VPC names to their respective IDs
- `private_subnet_ids`: A map of VPC names to their respective private subnet IDs
- `public_subnet_ids`: A map of VPC names to their respective public subnet IDs (if any)

## Requirements

- Terraform 0.13+
- AWS provider

## Notes

- This module uses the `for_each` meta-argument to create multiple VPCs based on the input list.
- If `enable_nat_gateway` is set to `true`, a single NAT Gateway will be created for all Availability Zones.
- Public subnets are optional. If not provided, only private subnets will be created.

## License

This module is released under the MIT License.