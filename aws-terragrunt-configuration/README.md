# AWS Landing Zone Infrastructure

[![AWS](https://img.shields.io/badge/cloud-AWS-orange.svg)](https://aws.amazon.com)
[![Terragrunt](https://img.shields.io/badge/IaC-Terragrunt-blue.svg)](https://terragrunt.gruntwork.io)

Multi-account, multi-region AWS landing zone following the Well-Architected Framework.

---

## Table of Contents

- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Services](#services)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Security](#security)
- [Operations](#operations)

---

## Architecture

```text
AWS Organization Root
├── Management OU
│   └── Management Account (billing, organizations, IAM)
├── Security OU
│   ├── Audit Account (CloudTrail, Config, GuardDuty)
│   └── Log Archive Account (centralized logging)
├── Network OU
│   └── Network Account (Transit Gateway, VPC, VPN)
├── Shared Services OU
│   └── Shared Services Account (EKS, ECR, SSM)
├── Production OU
│   ├── US Production (us-east-2)
│   └── EU Production (eu-west-2)
└── Development OU
    ├── US Development (us-east-2)
    └── US/EU Staging (us-east-2 / eu-west-2)
```

| Region | ID | Environments |
|--------|----|-------------|
| **US (Primary)** | us-east-2 | dev, stg, prod |
| **EU (Secondary)** | eu-west-2 | stg, prod |

The provider region is **auto-selected** based on directory path — EU configs (`eu/*`) get `eu-west-2`, all others get `us-east-2`.

---

## Directory Structure

```text
aws/
├── _env.hcl                  # Shared locals for all {service}/{region}/{env}/ configs
├── _module_version.hcl       # Centralized module version ref (v1.0.0)
├── common.hcl               # Root: S3+DynamoDB backend, provider with default_tags, version constraints
├── vars.yaml                # All environment/service configuration
├── terragrunt.hcl           # Root include
│
├── {service}/{region}/{env}/  # Per-service deployments (12 services x regions x envs)
│   └── terragrunt.hcl        # Includes _env.hcl, sets module source + inputs
│
├── accounts/                  # AWS Organization + account provisioning
├── cloudtrail/                # Centralized API audit logging
├── network/
│   ├── vpc/                   # Core networking VPC
│   └── tgw/                   # Transit Gateway (connects all VPCs)
├── security/
│   ├── scp/                   # Service Control Policies
│   ├── eventbridge/           # Security event routing
│   └── sns/                   # Security notifications
└── iam/
    ├── roles/                 # IAM roles
    ├── groups/                # IAM groups
    ├── policies/              # IAM policies
    └── users/                 # IAM users
```

---

## Services

| Service | Module | Regions | Environments | Dependencies |
|---------|--------|---------|--------------|-------------|
| **vpc** | aws-terraform-vpc | us, eu | dev, stg, prod | - |
| **eks** | aws-terraform-eks | us, eu | dev, stg, prod | vpc |
| **ec2** | aws-terraform-ec2 | us, eu | dev, stg, prod | vpc |
| **rds** | aws-terraform-rds | us, eu | dev, stg, prod | - |
| **aurora** | aws-terraform-rds-aurora | us, eu | dev, stg, prod | - |
| **dynamodb** | aws-terraform-dynamodb | us, eu | dev, stg, prod | - |
| **redis** | aws-terraform-redis | us, eu | dev, stg, prod | vpc (dev) |
| **s3** | aws-terraform-s3 | us, eu | dev, stg, prod | - |
| **sns** | aws-terraform-sns | us, eu | dev, stg, prod | - |
| **acm** | aws-terraform-acm | us, eu | dev, stg, prod | - |
| **api-gw** | aws-terraform-apigw | us, eu | dev, stg, prod | - |
| **vpn** | aws-terraform-vpn | us, eu | dev, stg, prod | - |

All modules sourced from `git::https://github.com/cloudon-one/aws-terraform-modules.git` with centralized version ref.

---

## Configuration

### Variable Hierarchy

```text
vars.yaml
└── Environments
    └── {region}-{env}         # e.g., "us-prod", "eu-stg"
        └── Resources
            └── {service}      # e.g., "vpc", "eks"
                └── inputs     # Service-specific config
```

### Shared Configuration Files

| File | Purpose | Scope |
|------|---------|-------|
| `common.hcl` | S3 backend, DynamoDB locking, AWS provider with `default_tags`, version constraints | All configs |
| `_env.hcl` | Shared locals (`common_vars`, `environment`, `location`, `resource`, `resource_vars`, `module_ref`) | 55 service configs |
| `_module_version.hcl` | `module_ref = "v1.0.0"` | 11 non-env configs |
| `vars.yaml` | All environment and service parameters | All configs |

### Changing Module Version

Update `module_ref` in both `_env.hcl` and `_module_version.hcl` — all 66 module source refs update automatically.

### Environment Settings

| Setting | Dev | Staging | Production |
|---------|-----|---------|------------|
| Instance types | t3.micro/small | t3.medium/large | m5.large+ |
| Backup retention | 7 days | 14 days | 30 days |
| Deletion protection | Off | DB only | All stateful |
| Multi-AZ | Off | DB only | All services |
| Monitoring | Basic | Enhanced | Full stack |

---

## Deployment

### Initial Setup

```bash
aws configure
aws sts get-caller-identity    # Verify access
vim aws/vars.yaml              # Set org-specific values
```

### Deployment Order

```bash
# Phase 1 — Foundation
cd aws/accounts && terragrunt apply
cd aws/cloudtrail && terragrunt apply
cd aws/security/scp && terragrunt apply

# Phase 2 — Networking
cd aws/vpc/us/prod && terragrunt apply
cd aws/network/tgw && terragrunt apply

# Phase 3 — Compute & Data
cd aws/eks/us/prod && terragrunt apply
cd aws/rds/us/prod && terragrunt apply

# Bulk operations
make aws-plan     # Plan all
make aws-apply    # Apply all
```

---

## Security

| Control | Implementation |
|---------|---------------|
| **Network** | Private subnets, NACLs, security groups, VPC Flow Logs |
| **Identity** | Cross-account IAM roles, MFA enforcement, instance profiles |
| **Encryption** | KMS at rest, TLS 1.2+ in transit, auto-rotation |
| **Audit** | CloudTrail (all regions), Config, GuardDuty |
| **Policy** | SCPs on OUs, EventBridge security rules |
| **State** | S3 encrypted + DynamoDB locking |
| **Tags** | Auto-applied via provider `default_tags` (owner, terraform) |

---

## Operations

### Common Commands

```bash
make aws-validate              # Validate all configs
make health-check              # Check AWS credentials
make backup-state              # Backup state files
make clean                     # Clear caches

# Debugging
export TG_LOG=debug && terragrunt plan
terragrunt state list
terragrunt state show <resource>
```

### Troubleshooting

| Issue | Solution |
|-------|---------|
| Dependency errors | `rm -rf .terragrunt-cache && terragrunt apply` |
| API rate limiting | `terragrunt apply --terragrunt-parallelism=1` |
| State lock stuck | `terragrunt force-unlock <lock-id>` |
