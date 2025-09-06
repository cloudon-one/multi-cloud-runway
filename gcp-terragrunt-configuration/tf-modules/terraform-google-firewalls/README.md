# Terraform Google Cloud Firewall Module

This module creates and manages Google Cloud firewall rules with support for both ingress and egress traffic control across VPC networks.

## Overview

This module provides comprehensive firewall management with:

- **Multiple Firewall Rules**: Create multiple rules with single module call
- **Allow and Deny Rules**: Support for both allow and deny traffic patterns
- **Flexible Targeting**: Target by tags, service accounts, or IP ranges
- **Logging Support**: Optional firewall log configuration
- **Priority Management**: Configurable rule priorities

## Usage

```hcl
module "firewall_rules" {
  source = "./tf-modules/terraform-google-firewalls"

  firewalls = {
    allow-ssh-from-iap = {
      project_id   = "my-project"
      network_name = "my-vpc-network"
      
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      
      source_ranges = ["35.235.240.0/20"]  # IAP CIDR
      target_tags   = ["ssh-enabled"]
      priority      = 1000
      
      log_config = [{
        metadata = "INCLUDE_ALL_METADATA"
      }]
      
      deny                    = []
      destination_ranges      = []
      target_service_accounts = []
    }
    
    allow-internal-communication = {
      project_id   = "my-project" 
      network_name = "my-vpc-network"
      
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
      
      source_ranges = ["10.0.0.0/8"]
      target_tags   = ["web-server"]
      priority      = 1100
      
      log_config = []
      deny                    = []
      destination_ranges      = []
      target_service_accounts = []
    }
  }
}
```

## Variables

### Firewalls Configuration

| Name | Description | Type |
|------|-------------|------|
| `firewalls` | Map of firewall rules to create | `map(object)` |

#### Firewall Rule Object Structure
```hcl
firewalls = {
  rule-name = {
    project_id              = string
    network_name           = string
    allow                  = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny                   = list(object({
      protocol = string  
      ports    = list(string)
    }))
    source_ranges          = list(string)
    destination_ranges     = list(string)
    target_tags            = list(string)
    target_service_accounts = list(string)
    priority               = number
    log_config            = list(object({
      metadata = string
    }))
  }
}
```

## Resources Created

- `google_compute_firewall`: Firewall rules for each entry in the firewalls map

## Features

- **Batch Creation**: Create multiple firewall rules in a single configuration
- **Dynamic Blocks**: Flexible allow/deny rules with dynamic configuration
- **Comprehensive Targeting**: Support for tags, service accounts, and IP ranges
- **Audit Logging**: Optional metadata logging for compliance and debugging

---

**⚠️ Security Critical**: Firewall rules control network access. Review all rules carefully before deployment.