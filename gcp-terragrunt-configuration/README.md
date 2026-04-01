# GCP Landing Zone Infrastructure

[![GCP](https://img.shields.io/badge/cloud-GCP-blue.svg)](https://cloud.google.com)
[![Terragrunt](https://img.shields.io/badge/IaC-Terragrunt-blue.svg)](https://terragrunt.gruntwork.io)

Hierarchical GCP landing zone with Shared VPC, private GKE clusters, and enterprise security controls.

---

## Table of Contents

- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Terraform Modules](#terraform-modules)
- [Configuration](#configuration)
- [Network Architecture](#network-architecture)
- [GKE Configuration](#gke-configuration)
- [Database Configuration](#database-configuration)
- [Deployment](#deployment)
- [Security](#security)
- [Operations](#operations)

---

## Architecture

```text
GCP Organization (cloudon-one.com)
├── admin/                        # Org admin, billing, terraform state buckets
├── shrd/                         # Shared services (Shared VPC hosts)
│   ├── dev/  [europe-west1]      # Shared dev VPC, GKE, Datadog
│   └── prod/ [us-east1]          # Shared prod VPC, GKE, VPN, Datadog
├── dev/                          # Development
│   └── eu/   [europe-west1]      # Dev VPC, GKE, SQL, Redis
├── stg/                          # Staging
│   └── eu/   [europe-west1]      # Stg VPC, GKE, SQL, Redis
│   └── us/   [us-east1]          # Stg VPC
└── prod/                         # Production
    ├── eu/   [europe-west1]      # Prod VPC, GKE, SQL, Redis, GLB
    └── us/   [us-east1]          # Prod VPC, GKE, SQL, Redis, GLB
```

### Shared VPC Model

Each environment uses a **host/service project** pattern:
- **Host project** (`net-vpc`): Owns the VPC, subnets, firewalls, Cloud NAT
- **Service project** (`svc-projects`): Runs workloads (GKE, SQL, Redis) attached to host VPC
- **VPC attachments** (`net-vpc-attachments`): IAM bindings connecting service projects to host subnets

VPC **peering** connects shared environments to their downstream environments (shrd/dev <-> dev/eu + stg/eu, shrd/prod <-> prod/us + prod/eu).

---

## Directory Structure

```text
gcp-terragrunt-configuration/
├── terragrunt/
│   ├── terragrunt.hcl              # Root config: GCS backend, shared locals
│   ├── vars.yaml                   # All environment configuration
│   ├── common-dependencies.hcl     # Global admin dependency
│   └── envs/
│       ├── global/                 # admin, audit, iam, net-dns
│       ├── shrd/{dev,prod}/        # Shared VPC hosts + services
│       ├── dev/eu/                 # Development
│       ├── stg/eu/                 # Staging EU
│       └── prod/{eu,us}/           # Production
│           ├── net-vpc/            # VPC + subnets + Cloud NAT
│           ├── net-firewalls/      # Firewall rules
│           ├── net-dns/            # DNS zones
│           ├── net-vpn/            # VPN gateways
│           ├── net-glb/            # Global Load Balancer
│           ├── net-vpc-attachments/ # Shared VPC IAM bindings
│           ├── net-peering/        # VPC peering (shrd only)
│           ├── svc-projects/       # Service project provisioning
│           ├── svc-gke/            # GKE cluster
│           ├── svc-sql/            # Cloud SQL
│           ├── svc-redis/          # Memorystore Redis
│           └── svc-datadog/        # Datadog integration
└── tf-modules/                     # Local Terraform modules (14)
```

---

## Terraform Modules

| Module | Purpose | Key Upstream Dependency |
|--------|---------|----------------------|
| `terraform-google-admin` | Org folders, admin project, state buckets, service accounts | project-factory |
| `terraform-google-audit` | Audit project, org log sink, Pub/Sub | project-factory, log-export |
| `terraform-google-svpc` | Shared VPC host project + network + Cloud NAT | project-factory, network, cloud-nat |
| `terraform-google-projects` | Service projects, API enablement, KMS | project-factory, network, kms |
| `terraform-google-gke` | Private GKE cluster, KMS encryption, IAM | kubernetes-engine, iam |
| `terraform-google-sql` | Cloud SQL PostgreSQL with private networking | sql-db |
| `terraform-google-memorystore` | Redis with private service access | memorystore |
| `terraform-google-dns` | Cloud DNS zones (public/private) | cloud-dns |
| `terraform-google-firewalls` | Compute firewall rules | - (native resource) |
| `terraform-google-glb` | Global HTTP(S) Load Balancer | lb-http |
| `terraform-google-vpn` | Classic VPN with optional BGP | vpn |
| `terraform-google-peering` | Dynamic VPC peering (for_each) | network//network-peering |
| `terraform-google-iam-permissions` | Org/folder/project/subnet IAM, Workload Identity, Shared VPC attachments | iam |
| `terraform-google-dd` | Datadog GCP integration | iam-service-account |

Audit all upstream module versions: `./scripts/check-module-versions.sh`

---

## Configuration

### vars.yaml Structure

```text
vars.yaml
├── common:                    # org_id, domain, billing_account, suffix
└── envs:
    ├── global:
    │   └── resources: {admin, audit, iam, net-dns}
    ├── shrd:
    │   ├── dev:
    │   │   ├── region: europe-west1
    │   │   └── resources: {net-vpc, net-firewalls, net-peering, svc-projects, svc-gke, ...}
    │   └── prod: ...
    ├── dev: {eu: ...}
    ├── stg: {eu: ..., us: ...}
    └── prod: {eu: ..., us: ...}
```

### Locals Derivation

Terragrunt derives config path from directory structure:

```hcl
folder    = basename(dirname(dirname(get_terragrunt_dir())))   # e.g., "prod"
environment = basename(dirname(get_terragrunt_dir()))           # e.g., "us"
resource    = basename(get_terragrunt_dir())                    # e.g., "svc-gke"
resource_vars = vars["envs"][folder][environment]["resources"][resource]
```

### Resource Naming Convention

- `net-*` = networking resources (vpc, firewalls, dns, vpn, glb, peering, vpc-attachments)
- `svc-*` = service resources (projects, gke, sql, redis, datadog)

---

## Network Architecture

| Environment | VPC CIDR | GKE Subnet | Pods | Services | Region |
|-------------|----------|------------|------|----------|--------|
| Shared Dev | 10.151.0.0/16 | 10.151.128.0/20 | 10.151.0.0/17 | 10.151.144.0/20 | europe-west1 |
| Shared Prod | 10.152.0.0/16 | 10.152.128.0/20 | 10.152.0.0/17 | 10.152.144.0/20 | us-east1 |
| Dev EU | 10.153.0.0/16 | 10.153.128.0/20 | 10.153.0.0/17 | 10.153.144.0/20 | europe-west1 |
| Staging EU | 10.154.0.0/16 | 10.154.128.0/20 | 10.154.0.0/17 | 10.154.144.0/20 | europe-west1 |
| Prod EU | 10.155.0.0/16 | 10.155.128.0/20 | 10.155.0.0/17 | 10.155.144.0/20 | europe-west1 |
| Prod US | 10.156.0.0/16 | 10.156.128.0/20 | 10.156.0.0/17 | 10.156.144.0/20 | us-east1 |

### Connectivity

- **VPC Peering**: shrd/dev <-> dev/eu + stg/eu; shrd/prod <-> prod/us + prod/eu
- **Cloud VPN**: Site-to-site in shrd/prod for hybrid access
- **Cloud NAT**: Per-region outbound with `ALL_SUBNETWORKS_ALL_IP_RANGES`
- **Cloud DNS**: Public zones per environment + global root zone

---

## GKE Configuration

| Feature | Setting |
|---------|---------|
| Cluster type | Private (no public node IPs) |
| Authentication | Workload Identity |
| Network policy | Calico |
| Encryption | Cloud KMS (application-layer) |
| Logging | Cloud Logging + Cloud Monitoring |
| Node OS | Container-Optimized OS |

### Node Pools

| Pool | Purpose | Machine Type (prod) | Autoscaling |
|------|---------|-------------------|-------------|
| service-node-pool | Application workloads | n2-standard-4 | Yes |
| ci-pool | CI/CD runners | n2-standard-2 | Yes (preemptible) |
| consul-vault | HashiCorp services (prod only) | n2-standard-2 | Fixed |

---

## Database Configuration

### Cloud SQL (PostgreSQL)

| Setting | Dev/Stg | Production |
|---------|---------|------------|
| Version | PostgreSQL 11 | PostgreSQL 12 |
| Availability | Zonal | Regional (HA) |
| Backup retention | 7 days | 30 days |
| Deletion protection | Off | On |
| Networking | Private IP only | Private IP only |
| Point-in-time recovery | Enabled | Enabled |

### Cloud Memorystore (Redis)

| Setting | Value |
|---------|-------|
| Version | Redis 5.0 |
| Memory | 1 GB |
| Connect mode | Private Service Access |
| HA | Regional in production |

---

## Deployment

### Initial Setup

```bash
gcloud auth application-default login
vim gcp-terragrunt-configuration/terragrunt/vars.yaml   # Set org details
```

### Deployment Order

```bash
# Phase 1 — Foundation
cd terragrunt/envs/global/admin && terragrunt apply

# Phase 2 — Audit
cd terragrunt/envs/global/audit && terragrunt apply

# Phase 3 — Shared services (respects internal dependency order)
cd terragrunt/envs/shrd/prod && terragrunt run-all apply
cd terragrunt/envs/shrd/dev && terragrunt run-all apply

# Phase 4 — Environments
cd terragrunt/envs/prod/us && terragrunt run-all apply
cd terragrunt/envs/prod/eu && terragrunt run-all apply

# Bulk operations
make gcp-plan     # Plan all
make gcp-apply    # Apply all
```

### Dependency Chain (per environment)

```text
net-vpc → net-firewalls → net-vpc-attachments
net-vpc → net-dns
net-vpc → net-vpn
net-vpc → svc-projects → svc-gke
net-vpc → svc-projects → svc-sql
net-vpc → svc-projects → svc-redis
net-vpc → svc-projects → svc-datadog
net-vpc → svc-projects → net-glb
```

---

## Security

| Control | Implementation |
|---------|---------------|
| **Network** | Private GKE, Private Google Access, Cloud NAT, firewall rules |
| **Identity** | Workload Identity, groups-based IAM, folder-level permissions |
| **Encryption** | Cloud KMS for GKE secrets, CMEK for SQL, managed keys for GCS |
| **Audit** | Org-level audit logging, Pub/Sub sink, Security Command Center |
| **Secrets** | Sensitive variables marked (`datadog_api_key`, `shared_secret`) |
| **State** | GCS with versioning, encryption, no `force_destroy` on state buckets |

---

## Operations

### Common Commands

```bash
make gcp-validate                # Validate all configs
make health-check                # Check GCP credentials
./scripts/check-module-versions.sh  # Audit upstream module versions

# Debugging
export TG_LOG=debug && terragrunt plan
gcloud compute firewall-rules list --filter="network:NETWORK"
gcloud container clusters describe CLUSTER --region=REGION
```

### Troubleshooting

| Issue | Solution |
|-------|---------|
| State errors | `rm -rf .terragrunt-cache && terragrunt init -reconfigure` |
| GKE access | `gcloud container clusters get-credentials CLUSTER --region=REGION` |
| Network issues | `gcloud compute firewall-rules list`, `gcloud compute routers describe` |

### Support

- **Primary**: gcp-infrastructure@cloudon-one.com
- **Emergency**: 24/7 on-call rotation
