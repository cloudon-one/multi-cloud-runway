# AWS VPN Gateway Terraform Module

This Terraform module creates and manages an AWS VPN Gateway and its associated resources using the `terraform-aws-modules/vpn-gateway/aws` module. It provides a flexible way to set up Site-to-Site VPN connections, with support for both VPC and Transit Gateway attachments.

## Features

- Create VPN Gateways and VPN Connections
- Support for connecting to Transit Gateways
- Configurable VPN tunnel options including IKE versions, encryption algorithms, and DPD settings
- IPv4 and IPv6 support
- Static route configuration
- Detailed tunnel configurations for both primary and secondary tunnels

## Usage

```hcl
module "vpn_gateway" {
  source  = "path/to/this/module"
  version = "3.7.2"

  customer_gateway_id = "cgw-1234567890abcdef0"
  vpc_id              = "vpc-1234567890abcdef0"

  vpn_gateway_id     = "vgw-1234567890abcdef0"
  connect_to_transit_gateway = false
  create_vpn_connection = true

  local_ipv4_network_cidr  = "10.0.0.0/16"
  remote_ipv4_network_cidr = "192.168.0.0/16"

  tunnel1_inside_cidr   = "169.254.100.0/30"
  tunnel2_inside_cidr   = "169.254.100.4/30"
  tunnel1_preshared_key = "abcdefghijklmnop"
  tunnel2_preshared_key = "qrstuvwxyz123456"

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## Inputs

This module supports a large number of input variables to allow for detailed configuration of the VPN connection. Here are some of the key inputs:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| customer_gateway_id | The ID of the Customer Gateway | `string` | n/a | yes |
| vpc_id | The ID of the VPC to attach to | `string` | n/a | yes |
| vpn_gateway_id | The ID of the VPN Gateway | `string` | `null` | no |
| connect_to_transit_gateway | Set to true to connect to a Transit Gateway | `bool` | `false` | no |
| transit_gateway_id | The ID of the Transit Gateway to connect to | `string` | `null` | no |
| create_vpn_connection | Set to false to prevent creating a VPN Connection | `bool` | `true` | no |
| local_ipv4_network_cidr | The local IPv4 network CIDR | `string` | `"0.0.0.0/0"` | no |
| remote_ipv4_network_cidr | The remote IPv4 network CIDR | `string` | `"0.0.0.0/0"` | no |
| tunnel1_inside_cidr | The CIDR block of the inside IP addresses for the first VPN tunnel | `string` | `null` | no |
| tunnel2_inside_cidr | The CIDR block of the inside IP addresses for the second VPN tunnel | `string` | `null` | no |
| tunnel1_preshared_key | The preshared key of the first VPN tunnel | `string` | `null` | no |
| tunnel2_preshared_key | The preshared key of the second VPN tunnel | `string` | `null` | no |

For a complete list of supported variables, please refer to the [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway/blob/master/variables.tf) file in the official module repository.

## Outputs

This module doesn't define any outputs directly. However, you can access all outputs from the underlying `terraform-aws-modules/vpn-gateway/aws` module. Refer to the [official module documentation](https://registry.terraform.io/modules/terraform-aws-modules/vpn-gateway/aws/latest?tab=outputs) for a list of available outputs.

## Notes

1. This module uses the `terraform-aws-modules/vpn-gateway/aws` module version 3.7.2. Make sure this version is compatible with your Terraform version.
2. The Customer Gateway must be created separately before using this module.
3. When connecting to a Transit Gateway, make sure to set `connect_to_transit_gateway = true` and provide the `transit_gateway_id`.
4. The module provides detailed configuration options for both VPN tunnels. Make sure to configure both tunnels for redundancy.

## Limitations

1. This module doesn't create the Customer Gateway. You need to create it separately and provide its ID.
2. The module doesn't support creating multiple VPN connections in a single invocation. For multiple connections, you'll need to use the module multiple times.
3. Some advanced VPN features might require direct use of the AWS provider resources instead of this module.

## License

This module is open-source software licensed under the Apache License 2.0. For more details, please see the [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway/blob/master/LICENSE) file in the official module repository.