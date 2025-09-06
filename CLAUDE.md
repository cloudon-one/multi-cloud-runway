# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a multi-cloud infrastructure repository containing Terragrunt and Terraform configurations for deploying comprehensive cloud landing zones across AWS and GCP platforms. The repository implements enterprise-grade infrastructure with security controls, compliance standards (PCI/DSS, CIS Security Workbench), and best practices.

## Repository Structure

```text
multi-cloud-runway/
├── aws-terragrunt-configuration/    # AWS landing zone configuration
│   ├── aws/
│   │   ├── common.hcl              # Common Terragrunt configuration
│   │   ├── vars.yaml               # AWS environment variables
│   │   └── [service]/[region]/[env]/terragrunt.hcl
├── gcp-terragrunt-configuration/    # GCP landing zone configuration
│   ├── envs/
│   │   ├── global/                 # Global resources (admin, audit)
│   │   ├── shrd/                   # Shared environments (dev, prod)
│   │   ├── dev/eu/                 # Development environment
│   │   ├── stg/{eu,us}/            # Staging environments
│   │   └── prod/{eu,us}/           # Production environments
│   └── terragrunt/vars.yaml        # Centralized GCP configuration
└── README.md                       # Architecture documentation
```

## Common Development Commands

### AWS Infrastructure

Navigate to specific service directory: `cd aws-terragrunt-configuration/aws/[service]/[region]/[env]`

```bash
# Plan infrastructure changes
terragrunt plan

# Apply infrastructure changes
terragrunt apply

# Apply changes to all services in region/environment
terragrunt run-all plan
terragrunt run-all apply

# Destroy resources
terragrunt destroy
```

### GCP Infrastructure

Navigate to specific environment directory: `cd gcp-terragrunt-configuration/envs/[environment]/[region]`

```bash
# Initialize and apply (starting from global/admin)
cd envs/global/admin
terragrunt init
terragrunt apply

# Standard workflow for other environments
terragrunt plan
terragrunt apply

# State management
terragrunt state pull > backup.tfstate
```

### Prerequisites Verification

```bash
# Check tool versions
terraform version    # Requires 1.5.0+
terragrunt --version  # Requires 0.60.0+
aws --version        # AWS CLI 2.0.0+
gcloud version       # GCP SDK

# Authenticate with cloud providers
aws configure
gcloud auth application-default login
```

## Architecture Key Points

### AWS Landing Zone Structure

- **Management OU**: Organization management, IAM, billing
- **Network Account**: Core networking (VPCs, Transit Gateway, VPN)
- **Shared-Services Account**: Common services and EKS clusters
- **Security OU**: GuardDuty, Config, CloudTrail
- **Production/Development OUs**: Regional environments (US/EU)

Services included: ACM, API Gateway, Aurora, CloudTrail, DynamoDB, EC2, EKS, RDS, Redis, S3, SNS, Transit Gateway, VPC, VPN

### GCP Landing Zone Structure

- **Hierarchical folder structure**: Root → {admin, shrd, prod, dev, stg} → regional folders
- **Network isolation**: Dedicated VPCs per environment with specific CIDR ranges
- **GKE clusters**: Private clusters with multiple node pools (service, CI, consul-vault for prod)
- **Shared services**: Cloud SQL (PostgreSQL), Redis, DNS, IAM

### Configuration Management

- **AWS**: Uses `vars.yaml` in each configuration directory with environment-specific settings
- **GCP**: Centralized `terragrunt/vars.yaml` with hierarchical YAML structure containing all environment configurations
- **Remote state**: AWS uses S3 backends, GCP uses GCS buckets with regional distribution

## Security and Compliance Features

- **AWS**: GuardDuty, CloudTrail, AWS Config, IAM roles with principle of least privilege
- **GCP**: Private GKE clusters, VPC service controls, Cloud NAT, Workload Identity
- **Compliance**: PCI/DSS and CIS Security Workbench standards implementation
- **Network security**: Private subnets, firewall rules, VPN connections, authorized networks

## Important Notes

- Always run `terragrunt plan` before applying changes
- State files are stored remotely (S3 for AWS, GCS for GCP)
- Use consistent naming conventions following the established patterns
- Infrastructure modules are sourced from external repositories (cloudon-one GitHub organization)
- Production resources include deletion protection and enhanced security controls

## Debugging and Troubleshooting

- Check Terragrunt logs for module source resolution issues
- Verify cloud provider authentication and permissions
- Review remote state backend accessibility
- Ensure billing accounts and organization settings are properly configured

## Network CIDR Ranges (GCP)

- Shared Dev VPC: 10.151.0.0/16
- Shared Prod VPC: 10.152.0.0/16
- Dev EU VPC: 10.153.0.0/16
- Staging EU/US VPCs: 10.154.0.0/16, 10.157.0.0/16
- Prod EU/US VPCs: 10.155.0.0/16, 10.156.0.0/16
