# Terraform Google Cloud VPC Peering Module

This module creates and manages VPC network peering connections between Google Cloud VPC networks for secure cross-network communication.

## Overview

- **VPC Peering**: Connect VPC networks across projects and organizations
- **Bidirectional Connectivity**: Automatic bidirectional peering setup
- **Route Management**: Custom route advertisement and import controls
- **Cross-Project**: Support for peering across different GCP projects
- **Security**: Network-level isolation with controlled connectivity

## Usage

```hcl
module "vpc_peering" {
  source = "./tf-modules/terraform-google-peering"

  # Local Network
  local_network_name    = "vpc-network-1"
  local_project_id      = "project-1"
  
  # Peer Network  
  peer_network_name     = "vpc-network-2"
  peer_project_id       = "project-2"
  
  # Peering Configuration
  peering_name         = "vpc1-to-vpc2"
  auto_create_routes   = true
  
  # Route Advertisement
  export_custom_routes = true
  import_custom_routes = true
}
```

## Features

- **Cross-Project Peering**: Connect VPC networks in different projects
- **Route Control**: Granular control over route advertisement
- **Automatic Configuration**: Bidirectional peering setup
- **Network Isolation**: Secure communication without internet transit
- **Cost Effective**: No additional charges for VPC peering traffic

---

**⚠️ Network Connectivity**: VPC peering creates direct network paths between VPCs. Ensure proper security controls are in place.