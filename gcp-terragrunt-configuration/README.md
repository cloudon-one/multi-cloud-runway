# GCP Landing Zone with Terragrunt and YAML 

This repository contains the Infrastructure as Code (IaC) implementation of a Google Cloud Platform (GCP) landing zone using Terragrunt and YAML configuration. The infrastructure is designed to support multiple environments with a hierarchical structure.

Current GCP Landing Zone Architecture compilant with PCI/DCC and CIS Security Workbench Standards.

## Architecture Overview

[![](https://mermaid.ink/img/pako:eNqVVnlvmzAU_yoWU6VNokdWrdKiaVITaBYtTRkOmzSSPxwwCRvYyJh2V7_7nrGTcDQ7kKw8eL93-B0_5acV8ZhaQ2sjSLFFi9GSIXhOTtCd2BCW_iAy5QzN6D3NtOrOn4RN3Zu1OH8bZbyKOTt74OLrCp2evkU3dzPH9bG22Tu9JSlDNzyLqSibTstqrRMwZuEOg6WoIlkJutJA9Vw7t9N5eB3ne18NJX7nOyHeEkFj5NOSVyKiZZ1jD-q4H0NH5cCLnDL5NAgvJiGWZJOyzdMAz79zQk_wGPLclaMFoizuVAHQX2gkS0RYI0mUcIHqW2lgfc26lrXkmRsb41UD5NWoX2POJNS3_KW_-sZgH2DVqfUfUeqJU0Ej3X__8HV6fRvCQR7P0ihtGThzHMJBnzlrfR9NZ7PpfBKO0iyDQiJMZVUcLU-3e4ch0BDV4vrGSoAeGjy0cvUEoO6Pgag2rTrRGhOAXHafCs6UrPXgvnYEv26ghgW5ASS2gZp0q9mCNBw9Wc_dnukYwUdvHMJBg4uzwavLs4uzi_PBVWtSg8l7N4SDxllVys4YB_jDLByrFUQgtVW-60xx6NM4LY8XXM93__ow_LqOiwncbQ8LVj11gPfqAK_68262ox9Ctad2ogQIorCHCC0txKi1_QDuN5IXGUU8QTGFHcig1_QQCT03di86PWt7_a-ueQFude2q3zWAHO_aQTpkE-C5uwjnVCoaRWOeF7BHTDY3ST3z64XpNkgd3c2n8AbyfSBZ1jXDwUi5x9Wa0ZbP_UAczwu7PuwZFfdpmyFqv83hq-nP46XcCAqvaPCyg27MIxqTaEs7ei8YGW9etT6HZP-eqG6FHpO6hMdU6hbHd-C7oib9HmWkLB2aACUrIkcJ8NbwWfI6sUsp-Fc6fHZ5eWnk04c0ltvhy-Jbx7bQRG2M1-s_GA96xsKQn7GOk_gfrBs-NLnbigBtYCYbVtSul0nfqIf0bE1DtqmYSb6J0yRka7qxd9RiqxctQev2eVu2lVORkzSG_xY_lZulJbc0p0trCGJME1Jlcmkt2SNASSU5_s4iawhMT21L8GqztYYJyUp4q4qYSOqkBMYx30EKwj5znhvQ42-OTqIc?type=png)](https://mermaid.live/edit#pako:eNqVVnlvmzAU_yoWU6VNokdWrdKiaVITaBYtTRkOmzSSPxwwCRvYyJh2V7_7nrGTcDQ7kKw8eL93-B0_5acV8ZhaQ2sjSLFFi9GSIXhOTtCd2BCW_iAy5QzN6D3NtOrOn4RN3Zu1OH8bZbyKOTt74OLrCp2evkU3dzPH9bG22Tu9JSlDNzyLqSibTstqrRMwZuEOg6WoIlkJutJA9Vw7t9N5eB3ne18NJX7nOyHeEkFj5NOSVyKiZZ1jD-q4H0NH5cCLnDL5NAgvJiGWZJOyzdMAz79zQk_wGPLclaMFoizuVAHQX2gkS0RYI0mUcIHqW2lgfc26lrXkmRsb41UD5NWoX2POJNS3_KW_-sZgH2DVqfUfUeqJU0Ej3X__8HV6fRvCQR7P0ihtGThzHMJBnzlrfR9NZ7PpfBKO0iyDQiJMZVUcLU-3e4ch0BDV4vrGSoAeGjy0cvUEoO6Pgag2rTrRGhOAXHafCs6UrPXgvnYEv26ghgW5ASS2gZp0q9mCNBw9Wc_dnukYwUdvHMJBg4uzwavLs4uzi_PBVWtSg8l7N4SDxllVys4YB_jDLByrFUQgtVW-60xx6NM4LY8XXM93__ow_LqOiwncbQ8LVj11gPfqAK_68262ox9Ctad2ogQIorCHCC0txKi1_QDuN5IXGUU8QTGFHcig1_QQCT03di86PWt7_a-ueQFude2q3zWAHO_aQTpkE-C5uwjnVCoaRWOeF7BHTDY3ST3z64XpNkgd3c2n8AbyfSBZ1jXDwUi5x9Wa0ZbP_UAczwu7PuwZFfdpmyFqv83hq-nP46XcCAqvaPCyg27MIxqTaEs7ei8YGW9etT6HZP-eqG6FHpO6hMdU6hbHd-C7oib9HmWkLB2aACUrIkcJ8NbwWfI6sUsp-Fc6fHZ5eWnk04c0ltvhy-Jbx7bQRG2M1-s_GA96xsKQn7GOk_gfrBs-NLnbigBtYCYbVtSul0nfqIf0bE1DtqmYSb6J0yRka7qxd9RiqxctQev2eVu2lVORkzSG_xY_lZulJbc0p0trCGJME1Jlcmkt2SNASSU5_s4iawhMT21L8GqztYYJyUp4q4qYSOqkBMYx30EKwj5znhvQ42-OTqIc)

The landing zone implements a hierarchical structure with the following components:

### Folder Structure
- Root
  - admin
  - shrd (Shared environment)
    - prod
    - dev
  - prod (Production)
    - eu
    - us
  - dev (Developmement)
    - eu
  - stg (Staging)
    - eu
    - us

### Network Design

Each environment has its own dedicated VPC with the following CIDR ranges as examples:
- Shared Dev VPC: 10.151.0.0/16
- Shared Prod VPC: 10.152.0.0/16
- Dev EU VPC: 10.153.0.0/16
- Staging EU VPC: 10.154.0.0/16
- Prod EU VPC: 10.155.0.0/16
- Prod US VPC: 10.156.0.0/16
- Staging US VPC: 10.157.0.0/16

Each VPC includes:
- Private subnet for GKE
- General purpose subnet
- Cloud NAT configuration
- Internal load balancer subnet (in production)
- Firewall rules for proxy access

### Kubernetes Clusters (GKE)

Each environment has a GKE cluster with the following configurations:
- Private clusters with VPC-native networking
- Multiple node pools:
  - Service node pool
  - CI pool
  - Additional consul-vault pool in production
- Workload Identity enabled
- Network Policy with Calico
- Regular release channel

### Database Infrastructure

Each environment includes:
- Cloud SQL (PostgreSQL):
  - Development: PostgreSQL 11
  - Production: PostgreSQL 12
  - Regional availability
  - Private IP configuration
  - Automated backups

- Redis:
  - Memory size: 1GB
  - Redis 5.0
  - Private service access
  - Regional deployment

## Prerequisites

- [GCP SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform 1.5+](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- [Terragrunt 0.60+](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## Required GCP Permissions to Deploy Landing Zone

- Billing Account User
- Organization Viewer
- Folder Admin
- Compute Storage Admin
- Project Creator
- Project IAM Admin
- Folder Admin
- XPN Admin

## Getting Started

1. Clone the repository:
   ```bash
   git clone git@github.com:cloudon-one/gcp-terragrunt-lz.git
   ```

## Start

Authenticate with GCP SDK

```bash
gcloud auth application-default login
cd envs/global/admin
terragrunt init
terragrunt apply
```

## Directory Structure

```
├── envs/
│   ├── global/
│   │   ├── admin/
│   │   └── audit/
│   ├── shrd/
│   │   ├── dev/
│   │   └── prod/
│   ├── dev/
│   │   └── eu/
│   ├── stg/
│   │   ├── eu/
│   │   └── us/
│   └── prod/
│       ├── eu/
│       └── us/
└── vars.yaml
```

## Configuration Management

The infrastructure is configured through a centralized `vars.yaml` file that contains all environment-specific settings. Key configuration areas include:

- Network configurations
- GKE cluster settings
- IAM permissions
- Service account definitions
- Database configurations
- DNS settings

## IAM & Security

The landing zone implements a comprehensive IAM structure with predefined roles:
- Network Admins: Network and security management
- DevOps: Deployment and operational access
- Organization Admins: High-level organizational management

## Terraform State Management

Terraform state files are stored in GCS buckets with the following regional distribution:
- US East1: Admin, Audit, Shared Prod, Prod US
- Europe West1: Shared Dev, Dev EU, Staging EU, Prod EU

## Resources Per Environment

Each environment typically contains:
1. Host Project (Network)
   - VPC
   - Subnets
   - Cloud NAT
   - Firewall Rules
   - DNS Zones

2. Service Project
   - GKE Cluster
   - Cloud SQL
   - Redis Instance
   - Service Accounts
   - Workload Identity Bindings

## Contributing

When contributing to this infrastructure:
1. Always test changes in development first
2. Follow the established naming conventions
3. Use the provided folder structure
4. Update the vars.yaml file for new configurations

## Documentation

For more detailed information about specific components:
- [GKE Configuration Guide](docs/gke.md)
- [Network Architecture](docs/network.md)
- [Security Controls](docs/security.md)
- [Database Setup](docs/database.md)

## Support

For support and questions, contact:
- DevOps Team: gcp-devops@cloudon.work
- Network Team: gcp-network-admins@cloudon.work
- Organization Admins: gcp-org-admins@cloudon.work