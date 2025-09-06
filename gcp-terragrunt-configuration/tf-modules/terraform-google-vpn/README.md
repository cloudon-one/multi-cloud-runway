# Terraform Google Cloud VPN Module

This module creates and manages Google Cloud VPN connections for secure hybrid cloud connectivity between GCP and on-premises networks.

## Overview

- **Site-to-Site VPN**: Secure IPSec tunnels to on-premises networks
- **High Availability**: Multiple tunnel configuration for redundancy
- **Dynamic Routing**: BGP support for automatic route advertisement
- **Static Routes**: Manual route configuration for simple setups
- **Cloud Router Integration**: Integration with Cloud Router for dynamic routing

## Usage

```hcl
module "vpn" {
  source = "./tf-modules/terraform-google-vpn"

  project_id = "my-project"
  region     = "us-central1"
  network    = "my-vpc-network"

  # VPN Gateway
  gateway_name = "on-premises-vpn"
  
  # Tunnels Configuration
  tunnels = [
    {
      name               = "tunnel-1"
      peer_ip           = "203.0.113.1"
      shared_secret     = var.vpn_shared_secret
      target_vpn_gateway = "on-premises-vpn"
      ike_version       = 2
      local_traffic_selector  = ["10.0.0.0/16"]
      remote_traffic_selector = ["192.168.0.0/16"]
    }
  ]

  # Static Routes
  routes = [
    {
      name        = "on-premises-route"
      destination = "192.168.0.0/16"
      next_hop_vpn_tunnel = "tunnel-1"
      priority    = 1000
    }
  ]
}
```

## Features

- **Enterprise Connectivity**: Secure connection to corporate networks
- **Multiple Protocols**: Support for IKEv1 and IKEv2
- **Route Management**: Static and dynamic routing options
- **High Throughput**: Up to 3 Gbps per tunnel
- **Monitoring**: Built-in tunnel monitoring and alerting

---

**⚠️ Network Security**: VPN connections provide direct access between networks. Ensure proper firewall rules and security policies are in place.