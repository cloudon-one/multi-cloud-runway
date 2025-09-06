# Terraform Google Cloud Memorystore Module

This module creates and manages Google Cloud Memorystore for Redis instances with high availability, security, and monitoring configuration.

## Overview

- **Redis Instances**: Fully managed Redis with automatic patching
- **High Availability**: Multi-zone deployment with automatic failover
- **VPC Integration**: Private IP connectivity within VPC networks
- **Security**: Transit encryption, authentication, and network isolation
- **Monitoring**: Built-in monitoring and alerting capabilities

## Usage

```hcl
module "redis" {
  source = "./tf-modules/terraform-google-memorystore"

  project_id = "my-project"
  region     = "us-central1"

  # Instance Configuration
  instance_id    = "app-cache"
  memory_size_gb = 5
  redis_version  = "REDIS_6_X"

  # Network Configuration
  authorized_network = "projects/my-project/global/networks/vpc-network"
  
  # High Availability
  tier               = "STANDARD_HA"
  availability_zones = ["us-central1-a", "us-central1-b"]

  # Security
  auth_enabled           = true
  transit_encryption_mode = "SERVER_CLIENT_ONLY"
  
  # Backup Configuration
  persistence_config = {
    persistence_mode = "RDB"
    rdb_snapshot_period = "TWENTY_FOUR_HOURS"
  }
}
```

## Features

- **Managed Service**: No infrastructure management required
- **Auto-scaling**: Configurable memory scaling based on usage
- **Backup and Recovery**: Automated backups with point-in-time recovery
- **Security**: VPC-native networking with optional authentication
- **Monitoring**: Integration with Cloud Monitoring and logging

---

**⚠️ Production Cache**: Memorystore instances store application data in memory. Ensure proper backup and security configuration.