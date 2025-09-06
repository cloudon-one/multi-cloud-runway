# GCP Landing Zone Infrastructure

## Overview

This directory contains the Google Cloud Platform landing zone implementation using Terragrunt and Terraform. The infrastructure follows Google Cloud Architecture Framework principles with enterprise-grade security, compliance standards (PCI/DSS, CIS Security Workbench), and operational excellence.

## Architecture

The GCP landing zone implements a hierarchical folder structure with resource isolation and comprehensive security controls:

### Organizational Hierarchy

```text
GCP Organization
├── admin/                      # Administrative resources
│   ├── Billing Account Management
│   ├── Organization Policies  
│   ├── IAM & Service Accounts
│   └── DNS Management
├── shrd/                      # Shared services
│   ├── dev/                   # Shared development services
│   └── prod/                  # Shared production services
├── dev/                       # Development environments  
│   └── eu/                    # EU development region
├── stg/                       # Staging environments
│   ├── eu/                    # EU staging region
│   └── us/                    # US staging region
└── prod/                      # Production environments
    ├── eu/                    # EU production region
    └── us/                    # US production region
```

### Regional Strategy

- **Primary Regions**: us-east1 (South Carolina), europe-west1 (Belgium)
- **Multi-Region**: Global services with regional distribution
- **Data Residency**: Region-specific data placement for compliance

## Services Implemented

### Core Infrastructure

- **VPC Networks**: Private Google Access enabled VPCs with custom subnets
- **Cloud NAT**: Managed NAT service for outbound internet connectivity
- **Cloud DNS**: Managed DNS service with private and public zones
- **Cloud Load Balancing**: Global and regional load balancers
- **Cloud Interconnect**: Dedicated connectivity for hybrid deployments

### Compute Services

- **GKE**: Private Kubernetes clusters with Workload Identity
- **Compute Engine**: VM instances with custom machine types
- **Cloud Run**: Serverless container platform
- **Cloud Functions**: Event-driven serverless compute

### Data Services

- **Cloud SQL**: Managed PostgreSQL and MySQL databases
- **Cloud Memorystore**: Managed Redis instances
- **Cloud Storage**: Object storage with lifecycle management
- **BigQuery**: Data warehouse and analytics platform
- **Cloud Spanner**: Globally distributed relational database

### Security Services

- **Cloud Security Command Center**: Centralized security management
- **Cloud KMS**: Key management and encryption
- **Cloud IAM**: Identity and access management
- **VPC Service Controls**: Data exfiltration protection
- **Cloud Armor**: DDoS protection and web application firewall

### Monitoring and Operations

- **Cloud Monitoring**: Infrastructure and application monitoring
- **Cloud Logging**: Centralized log management
- **Cloud Trace**: Distributed tracing
- **Cloud Profiler**: Application performance profiling
- **Error Reporting**: Real-time error tracking

## Directory Structure

```text
gcp-terragrunt-configuration/
├── envs/                       # Environment configurations
│   ├── global/                 # Global resources
│   │   ├── admin/              # Administrative setup
│   │   └── audit/              # Audit and compliance
│   ├── shrd/                   # Shared services
│   │   ├── dev/                # Shared development
│   │   └── prod/               # Shared production
│   ├── dev/eu/                 # Development EU
│   ├── stg/{eu,us}/           # Staging environments
│   └── prod/{eu,us}/          # Production environments
└── terragrunt/
    └── vars.yaml              # Centralized configuration
```

### Resource Organization

Each environment typically contains:

1. **Host Project (Network)**
   - VPC networks and subnets
   - Cloud NAT gateways
   - Firewall rules
   - DNS zones

2. **Service Project**
   - GKE clusters
   - Cloud SQL instances
   - Cloud Memorystore
   - Service accounts
   - Workload Identity bindings

## Configuration Management

### Centralized Configuration

The `terragrunt/vars.yaml` file contains hierarchical configuration with:

- **Global settings**: Organization-wide defaults
- **Environment-specific overrides**: Per-environment customizations
- **Service configurations**: Service-specific parameters
- **Network definitions**: CIDR blocks and connectivity

### Environment Characteristics

#### Shared Development (shrd/dev)
- **Region**: europe-west1
- **VPC CIDR**: 10.151.0.0/16
- **GKE**: Development-grade cluster with basic monitoring
- **Database**: PostgreSQL 11 with 7-day backup retention
- **Monitoring**: Basic Cloud Monitoring metrics

#### Shared Production (shrd/prod)
- **Region**: us-east1  
- **VPC CIDR**: 10.152.0.0/16
- **GKE**: Production-grade cluster with additional consul-vault pool
- **Database**: PostgreSQL 12 with 30-day backup retention
- **VPN**: Site-to-site connectivity for hybrid access
- **Monitoring**: Enhanced monitoring and alerting

#### Development EU (dev/eu)
- **Region**: europe-west1
- **VPC CIDR**: 10.153.0.0/16
- **Purpose**: Application development and testing
- **GKE**: Private cluster with CI/CD integration
- **Database**: PostgreSQL 11 with point-in-time recovery

#### Staging Environments (stg/eu, stg/us)
- **Regions**: europe-west1, us-east1
- **VPC CIDRs**: 10.154.0.0/16, 10.157.0.0/16
- **Purpose**: Pre-production validation
- **GKE**: Production-like configuration for testing
- **Database**: PostgreSQL 11 with enhanced monitoring

#### Production Environments (prod/eu, prod/us)
- **Regions**: europe-west1, us-east1
- **VPC CIDRs**: 10.155.0.0/16, 10.156.0.0/16
- **Purpose**: Production workloads
- **GKE**: High-availability clusters with auto-scaling
- **Database**: PostgreSQL 12 with deletion protection
- **Security**: Enhanced security controls and monitoring

## Security Implementation

### Network Security

- **Private GKE Clusters**: No public IP addresses for nodes
- **Authorized Networks**: Restricted API server access
- **Private Google Access**: Secure access to Google services
- **Cloud NAT**: Controlled outbound internet connectivity
- **VPC Service Controls**: Data exfiltration protection
- **Firewall Rules**: Principle of least privilege network access

### Identity and Access Management

- **Workload Identity**: Secure service-to-service authentication
- **Service Accounts**: Minimal privilege service accounts
- **IAM Hierarchy**: Organization, folder, and project-level permissions
- **Groups-based Access**: Role assignment through Google Groups
- **Regular Access Reviews**: Quarterly permission audits

### Data Protection

- **Encryption at Rest**: Google-managed or customer-managed keys
- **Encryption in Transit**: TLS 1.2+ for all communications
- **Cloud KMS**: Centralized key management
- **Backup Encryption**: Separate encryption for backup data
- **Data Classification**: Automated data discovery and classification

### Monitoring and Compliance

- **Audit Logging**: Comprehensive admin and data access logs
- **Security Command Center**: Centralized security findings
- **Policy Intelligence**: IAM policy analysis and recommendations
- **Compliance Monitoring**: CIS and PCI DSS benchmark monitoring
- **Real-time Alerting**: Security event notifications

## Network Architecture

### VPC Design

Each environment has dedicated VPC networks with:

- **GKE Subnet**: Container workloads with secondary IP ranges
- **General Subnet**: VM instances and other services  
- **Proxy Subnet**: Internal load balancer proxies (production only)

### IP Address Management

| Environment | VPC CIDR | GKE Subnet | Pods Range | Services Range |
|-------------|----------|------------|------------|----------------|
| Shared Dev | 10.151.0.0/16 | 10.151.128.0/20 | 10.151.0.0/17 | 10.151.144.0/20 |
| Shared Prod | 10.152.0.0/16 | 10.152.128.0/20 | 10.152.0.0/17 | 10.152.144.0/20 |
| Dev EU | 10.153.0.0/16 | 10.153.128.0/20 | 10.153.0.0/17 | 10.153.144.0/20 |
| Staging EU | 10.154.0.0/16 | 10.154.128.0/20 | 10.154.0.0/17 | 10.154.144.0/20 |
| Staging US | 10.157.0.0/16 | 10.157.128.0/20 | 10.157.0.0/17 | 10.157.144.0/20 |
| Prod EU | 10.155.0.0/16 | 10.155.128.0/20 | 10.155.0.0/17 | 10.155.144.0/20 |
| Prod US | 10.156.0.0/16 | 10.156.128.0/20 | 10.156.0.0/17 | 10.156.144.0/20 |

### Connectivity

- **VPC Peering**: Inter-environment communication where required
- **Cloud VPN**: Secure connectivity to on-premises networks
- **Private Service Connect**: Secure access to Google services
- **Cloud DNS**: Centralized DNS resolution across environments

## GKE Configuration

### Cluster Features

- **Private Clusters**: Nodes without external IP addresses
- **Workload Identity**: Secure pod-to-GCP service authentication
- **Network Policy**: Calico-based pod-to-pod communication control
- **Node Auto-provisioning**: Automatic node pool scaling
- **Release Channels**: Regular channel for stable updates
- **Binary Authorization**: Container image security verification

### Node Pool Configuration

#### Service Node Pool
- **Purpose**: General application workloads
- **Machine Types**: e2-medium (dev) to n2-standard-4 (prod)
- **Auto-scaling**: Environment-appropriate scaling limits
- **Disk**: 100GB SSD persistent disks
- **OS**: Container-Optimized OS (COS)

#### CI Pool  
- **Purpose**: Continuous integration workloads
- **Machine Types**: c2-standard-4 (dev) to n2-standard-2 (prod)
- **Auto-scaling**: Burst capacity for CI/CD pipelines
- **Preemptible**: Cost-optimized for non-critical workloads

#### Consul-Vault Pool (Production Only)
- **Purpose**: HashiCorp Consul and Vault services
- **Machine Type**: n2-standard-2
- **Scaling**: Fixed capacity for consistent performance
- **Security**: Enhanced security configuration

### Workload Identity

Secure authentication for Kubernetes workloads:

```yaml
ci-runner:
  k8s_sa_name: ci-runner
  namespace: ci-runner
  roles:
    - roles/container.developer
    - roles/storage.objectAdmin
```

## Database Configuration

### Cloud SQL Features

- **Private IP**: No public IP addresses
- **Regional Availability**: Multi-zone deployments
- **Automated Backups**: Point-in-time recovery enabled
- **SSL/TLS**: Required for all connections  
- **Database Flags**: Performance and security optimization
- **Read Replicas**: Cross-region disaster recovery

### Environment-Specific Settings

#### Development
- **Version**: PostgreSQL 11
- **Availability**: Zonal (cost-optimized)
- **Backup Retention**: 7 days
- **Deletion Protection**: Disabled for easy cleanup

#### Production  
- **Version**: PostgreSQL 12
- **Availability**: Regional (high availability)
- **Backup Retention**: 30 days
- **Deletion Protection**: Enabled
- **Read Replicas**: Cross-region for disaster recovery

### Redis Configuration

- **Memory Size**: 1GB standard allocation
- **Version**: Redis 5.0
- **Connectivity**: Private Service Access
- **High Availability**: Regional deployment in production
- **Security**: VPC-native with no public endpoints

## Deployment Guide

### Prerequisites

1. **Google Cloud SDK**: Latest version with authentication
2. **Terraform**: Version 1.5+
3. **Terragrunt**: Version 0.60+  
4. **Permissions**: Organization Admin, Billing Account User, Project Creator

### Initial Setup

1. **Authenticate with Google Cloud**:
   ```bash
   gcloud auth application-default login
   gcloud config set project PROJECT_ID
   ```

2. **Configure Billing and Organization**:
   ```bash
   # Update vars.yaml with your organization details
   vim gcp-terragrunt-configuration/terragrunt/vars.yaml
   ```

3. **Set Required Variables**:
   ```yaml
   common:
     billing_account: "YOUR_BILLING_ACCOUNT_ID"
     org_id: "YOUR_ORGANIZATION_ID"
     domain: "your-domain.com"
   ```

### Deployment Sequence

Deploy in the following order to respect dependencies:

#### Phase 1: Administrative Foundation
```bash
cd envs/global/admin
terragrunt init
terragrunt apply
```

#### Phase 2: Audit and Security
```bash
cd envs/global/audit
terragrunt init
terragrunt apply
```

#### Phase 3: Shared Services
```bash
# Shared production (has dependencies on admin)
cd envs/shrd/prod
terragrunt run-all init
terragrunt run-all apply

# Shared development
cd envs/shrd/dev
terragrunt run-all init
terragrunt run-all apply
```

#### Phase 4: Application Environments
```bash
# Development environment
cd envs/dev/eu
terragrunt run-all init
terragrunt run-all apply

# Staging environments
cd envs/stg/eu
terragrunt run-all init
terragrunt run-all apply

cd envs/stg/us
terragrunt run-all init
terragrunt run-all apply

# Production environments (requires careful planning)
cd envs/prod/eu
terragrunt run-all plan
terragrunt run-all apply

cd envs/prod/us  
terragrunt run-all plan
terragrunt run-all apply
```

### Service-Specific Deployment

Deploy individual services across environments:

```bash
# Deploy all VPC configurations
find . -path "*/net-vpc/terragrunt.hcl" -exec dirname {} \; | while read dir; do
  echo "Deploying VPC in $dir"
  (cd "$dir" && terragrunt apply)
done

# Deploy all GKE clusters
find . -path "*/svc-gke/terragrunt.hcl" -exec dirname {} \; | while read dir; do
  echo "Deploying GKE in $dir"  
  (cd "$dir" && terragrunt apply)
done
```

## Operational Procedures

### Daily Operations

1. **Resource Monitoring**: Review Cloud Monitoring dashboards
2. **Cost Analysis**: Monitor billing and budget alerts
3. **Security Review**: Check Security Command Center findings
4. **Backup Verification**: Verify automated backup completion
5. **Performance Check**: Review application performance metrics

### Weekly Operations

1. **Capacity Planning**: Analyze resource utilization trends
2. **Security Audit**: Review IAM changes and access patterns
3. **Performance Optimization**: Identify optimization opportunities  
4. **Compliance Status**: Verify regulatory compliance posture
5. **Documentation Updates**: Update operational procedures

### Monthly Operations

1. **Access Certification**: Review and certify user access
2. **Disaster Recovery Test**: Test backup and recovery procedures
3. **Cost Optimization**: Review and optimize resource usage
4. **Security Patching**: Apply security updates and patches
5. **Architecture Review**: Assess and improve system architecture

### Emergency Procedures

#### Security Incident Response

1. **Detection**: Security Command Center alerts and notifications
2. **Assessment**: Impact analysis and scope determination
3. **Containment**: Isolate affected resources using firewall rules
4. **Investigation**: Analyze audit logs and security findings
5. **Recovery**: Restore services and implement preventive measures

#### Service Outage Response

1. **Monitoring**: Cloud Monitoring alerts and health checks
2. **Escalation**: Follow escalation matrix based on severity
3. **Communication**: Stakeholder notifications via established channels
4. **Recovery**: Implement recovery procedures and validate restoration
5. **Post-Incident**: Conduct post-mortem and implement improvements

## Cost Optimization

### Development Environments

- **Machine Types**: Use e2-micro and e2-small instances  
- **Sustained Use Discounts**: Automatic discounts for consistent usage
- **Preemptible Instances**: Use for non-critical CI/CD workloads
- **Resource Scheduling**: Implement automated start/stop scheduling

### Production Environments

- **Committed Use Discounts**: Purchase CUDs for predictable workloads
- **Custom Machine Types**: Right-size instances for specific workloads
- **Storage Optimization**: Use appropriate storage classes
- **Network Optimization**: Minimize egress charges through architecture

### Cost Monitoring

- **Budget Alerts**: Proactive spending notifications
- **Cost Attribution**: Detailed cost allocation by project/team
- **Recommendation Engine**: Automated rightsizing recommendations
- **Usage Analytics**: Regular analysis of resource utilization

## Troubleshooting

### Common Issues

#### Terragrunt State Errors
```bash
# Clear Terragrunt cache
rm -rf .terragrunt-cache

# Re-initialize with backend refresh
terragrunt init -reconfigure
```

#### GKE Cluster Access Issues
```bash
# Update kubeconfig
gcloud container clusters get-credentials CLUSTER_NAME --region=REGION

# Verify Workload Identity configuration
kubectl get serviceaccount -n NAMESPACE
```

#### Networking Connectivity Problems
```bash
# Check firewall rules
gcloud compute firewall-rules list --filter="network:NETWORK_NAME"

# Verify Cloud NAT configuration
gcloud compute routers describe ROUTER_NAME --region=REGION
```

### Debugging Commands

```bash
# Terragrunt verbose logging
export TG_LOG=debug
terragrunt apply

# GCP resource inspection
gcloud compute instances list
gcloud container clusters describe CLUSTER_NAME

# Network debugging
gcloud compute networks subnets list --network=NETWORK_NAME
gcloud dns managed-zones list
```

## Compliance

### Standards Implementation

- **PCI DSS**: Payment card industry data security standard
- **CIS Benchmarks**: Center for Internet Security configuration standards  
- **ISO 27001**: Information security management system
- **SOC 2**: Service organization control 2 compliance

### Compliance Features

- **Data Encryption**: All data encrypted at rest and in transit
- **Access Logging**: Comprehensive audit trail of all access
- **Network Segmentation**: Isolated environments and workloads
- **Identity Management**: Strong authentication and authorization
- **Monitoring**: Continuous compliance monitoring and alerting

### Audit and Reporting

- **Compliance Dashboard**: Real-time compliance status monitoring
- **Automated Reporting**: Regular compliance reports generation
- **Risk Assessment**: Continuous risk evaluation and mitigation
- **Third-party Audits**: Annual compliance certification audits

## Support

### Documentation

- **Architecture Diagrams**: Detailed system architecture documentation
- **Runbooks**: Step-by-step operational procedures
- **API Documentation**: Service-specific API and configuration guides
- **Troubleshooting Guides**: Common issues and resolution procedures

### Support Channels

- **Primary**: gcp-infrastructure@cloudon.work
- **Emergency**: 24/7 on-call rotation for production issues
- **Slack**: #gcp-infrastructure for real-time collaboration
- **Documentation**: Internal wiki with detailed procedures

### Escalation Matrix

1. **L1 Support**: Development team (0-4 hours)
2. **L2 Support**: Senior engineers (4-8 hours)  
3. **L3 Support**: Google Cloud Premier Support (8+ hours)
4. **L4 Escalation**: Executive and vendor escalation (critical issues)

## Future Enhancements

### Planned Improvements

- **Multi-region Deployment**: Expand to additional regions
- **Service Mesh**: Implement Istio service mesh for microservices
- **GitOps Integration**: Implement ArgoCD for application deployment
- **Advanced Monitoring**: Integrate with third-party monitoring solutions
- **Cost Optimization**: Implement automated cost optimization tools

### Technology Roadmap

- **Anthos**: Multi-cloud and hybrid Kubernetes management
- **Cloud Build**: CI/CD pipeline standardization
- **Binary Authorization**: Enhanced container security
- **VPC-native GKE**: Migration to VPC-native clusters
- **Workload Identity**: Expand to all workloads

Last Updated: {{ current_date }}
Next Review: {{ next_review_date }}