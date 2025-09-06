# Terraform Google Cloud Load Balancer Module

This module creates and manages Google Cloud HTTP(S) Load Balancers with SSL certificates, backend services, and URL routing capabilities.

## Overview

- **Global Load Balancing**: HTTP(S) load balancer with global anycast IPs
- **SSL/TLS Termination**: Managed SSL certificates and custom certificate support  
- **Backend Services**: Integration with compute instances, instance groups, and NEGs
- **URL Routing**: Path and host-based traffic routing
- **Health Checks**: Configurable health checking for backends

## Usage

```hcl
module "load_balancer" {
  source = "./tf-modules/terraform-google-glb"

  project_id = "my-project"
  name      = "web-app-lb"

  # SSL Configuration
  ssl_certificates = ["web-app-ssl-cert"]
  
  # Backend Configuration  
  backends = {
    web-backend = {
      port                    = 80
      protocol               = "HTTP"
      port_name              = "http"
      timeout_sec            = 30
      enable_cdn             = false
      health_check          = {
        request_path = "/health"
        port         = 80
      }
      groups = [
        {
          group = "projects/my-project/zones/us-central1-a/instanceGroups/web-instances"
        }
      ]
    }
  }

  # URL Routing
  url_map = [{
    host_rule = {
      hosts        = ["example.com"]
      path_matcher = "web-matcher"
    }
    path_rule = {
      paths   = ["/*"]
      service = "web-backend"
    }
  }]
}
```

## Features

- **High Availability**: Global load balancing with automatic failover
- **SSL Management**: Automatic SSL certificate provisioning and renewal
- **Traffic Distribution**: Configurable load balancing algorithms
- **CDN Integration**: Built-in Cloud CDN support for static content
- **Security**: DDoS protection and Google Cloud Armor integration

---

**⚠️ Production Load Balancer**: This module creates internet-facing load balancers. Ensure proper security configuration.