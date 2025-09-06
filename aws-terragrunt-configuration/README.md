# AWS Landing Zone Infrastructure

## Overview

This directory contains the AWS landing zone implementation using Terragrunt and Terraform. The infrastructure follows AWS Well-Architected Framework principles with enterprise-grade security, compliance, and operational excellence.

## Architecture

The AWS landing zone implements a multi-account, multi-region architecture with the following organizational structure:

### Organizational Units (OUs)

```text
AWS Organization Root
├── Management OU
│   └── Management Account (Billing, Organizations, IAM)
├── Security OU
│   ├── Audit Account (CloudTrail, Config, GuardDuty)
│   └── Log Archive Account (Centralized logging)
├── Network OU
│   └── Network Account (Transit Gateway, VPC, VPN)
├── Shared Services OU
│   └── Shared Services Account (EKS, ECR, SSM)
├── Production OU
│   ├── Production US Account
│   └── Production EU Account
└── Development OU
    ├── Development Account
    └── Staging Account
```

### Regional Deployment

- **Primary Region**: us-east-2 (Ohio)
- **Secondary Region**: eu-west-2 (London)
- **Disaster Recovery**: Cross-region backup and replication

## Services Implemented

### Core Infrastructure

- **VPC**: Multi-AZ virtual private clouds with public/private subnets
- **Transit Gateway**: Centralized connectivity hub for VPC-to-VPC communication
- **Direct Connect**: Dedicated network connection to on-premises
- **Route 53**: DNS management and health checks

### Compute Services

- **EKS**: Managed Kubernetes clusters with multiple node groups
- **EC2**: Auto Scaling Groups with mixed instance types
- **Lambda**: Serverless compute for automation
- **ECS**: Containerized applications with Fargate

### Data Services

- **RDS**: Multi-AZ PostgreSQL and MySQL databases
- **Aurora**: Serverless and provisioned clusters
- **DynamoDB**: NoSQL databases with global tables
- **ElastiCache**: Redis and Memcached clusters
- **S3**: Object storage with lifecycle policies

### Security Services

- **GuardDuty**: Threat detection and monitoring
- **CloudTrail**: API logging and audit trails
- **Config**: Configuration compliance monitoring
- **IAM**: Identity and access management
- **KMS**: Key management and encryption
- **Secrets Manager**: Secure secrets storage
- **WAF**: Web application firewall

### Monitoring and Logging

- **CloudWatch**: Metrics, logs, and alarms
- **X-Ray**: Distributed tracing
- **Systems Manager**: Patch management and automation
- **SNS**: Notification services

## Directory Structure

```text
aws/
├── common.hcl              # Common Terragrunt configuration
├── vars.yaml              # Environment variables and configuration
├── [service]/             # Service-specific configurations
│   └── [region]/          # Regional deployments
│       ├── dev/           # Development environment
│       ├── stg/           # Staging environment
│       └── prod/          # Production environment
└── security/
    └── scp/               # Service Control Policies
        └── policies/      # JSON policy files
```

### Supported Services

| Service | Description | Regions | Environments |
|---------|-------------|---------|--------------|
| vpc | Virtual Private Cloud | us, eu | dev, stg, prod |
| eks | Elastic Kubernetes Service | us, eu | dev, stg, prod |
| rds | Relational Database Service | us, eu | dev, stg, prod |
| aurora | Aurora Database Clusters | us, eu | stg, prod |
| s3 | Simple Storage Service | us, eu | dev, stg, prod |
| dynamodb | NoSQL Database | us, eu | dev, stg, prod |
| redis | ElastiCache Redis | us, eu | dev, stg, prod |
| cloudtrail | API Audit Logging | us, eu | all |
| tgw | Transit Gateway | us, eu | shared |
| vpn | Site-to-Site VPN | us, eu | prod |
| sns | Simple Notification Service | us, eu | all |
| api-gw | API Gateway | us, eu | dev, stg, prod |
| acm | Certificate Manager | us, eu | dev, stg, prod |
| ec2 | Elastic Compute Cloud | us, eu | dev, stg, prod |

## Configuration Management

### Variable Hierarchy

Variables are resolved in the following precedence order:

1. **Service-specific inputs** (highest precedence)
2. **Environment-specific configuration**
3. **Regional defaults**
4. **Global defaults** (lowest precedence)

### Environment Configuration

Each environment has specific characteristics:

#### Development Environment
- **Purpose**: Development and testing
- **Instance Types**: t3.micro, t3.small
- **Backup Retention**: 7 days
- **Deletion Protection**: Disabled
- **Multi-AZ**: Disabled for cost optimization
- **Monitoring**: Basic CloudWatch metrics

#### Staging Environment
- **Purpose**: Pre-production validation
- **Instance Types**: t3.medium, t3.large
- **Backup Retention**: 14 days
- **Deletion Protection**: Enabled for databases
- **Multi-AZ**: Enabled for databases
- **Monitoring**: Enhanced monitoring enabled

#### Production Environment
- **Purpose**: Production workloads
- **Instance Types**: m5.large, m5.xlarge, c5.large+
- **Backup Retention**: 30 days
- **Deletion Protection**: Enabled for all stateful resources
- **Multi-AZ**: Enabled for all services
- **Monitoring**: Full observability stack

## Security Implementation

### Network Security

- **Private Subnets**: All application workloads deployed in private subnets
- **NAT Gateways**: High-availability NAT gateways for outbound internet access
- **Security Groups**: Principle of least privilege access controls
- **NACLs**: Additional network-level security controls
- **VPC Flow Logs**: Network traffic monitoring and analysis

### Identity and Access Management

- **Cross-Account Roles**: Secure cross-account access using IAM roles
- **Service-Linked Roles**: AWS service-specific roles with minimal permissions
- **Instance Profiles**: EC2 instances use IAM roles instead of access keys
- **MFA Enforcement**: Multi-factor authentication required for sensitive operations

### Data Protection

- **Encryption at Rest**: All data encrypted using AWS KMS
- **Encryption in Transit**: TLS 1.2+ for all data transmission
- **Key Rotation**: Automatic key rotation enabled for all KMS keys
- **Backup Encryption**: All backups encrypted with separate keys

### Monitoring and Alerting

- **CloudTrail**: All API calls logged to S3 with integrity validation
- **GuardDuty**: Machine learning-based threat detection
- **Config**: Configuration compliance monitoring and remediation
- **CloudWatch Alarms**: Proactive monitoring and alerting

## Deployment Guide

### Prerequisites

1. **AWS CLI**: Version 2.0+ with appropriate credentials
2. **Terraform**: Version 1.5+
3. **Terragrunt**: Version 0.60+
4. **Permissions**: Administrative access to AWS Organization

### Initial Setup

1. **Configure AWS CLI**:
   ```bash
   aws configure
   # Verify access
   aws sts get-caller-identity
   ```

2. **Clone Repository**:
   ```bash
   git clone https://github.com/cloudon-one/multi-cloud-runway.git
   cd multi-cloud-runway/aws-terragrunt-configuration
   ```

3. **Update Configuration**:
   ```bash
   # Edit vars.yaml with your organization-specific values
   vim aws/vars.yaml
   ```

### Deployment Sequence

Deploy services in the following order to respect dependencies:

#### Phase 1: Foundation (Management and Security)
```bash
# Organization and account setup
cd aws/organizations/management
terragrunt apply

# Security account setup
cd aws/security/audit
terragrunt apply

# CloudTrail setup
cd aws/cloudtrail/us/management
terragrunt apply
```

#### Phase 2: Network Infrastructure
```bash
# VPC in each region
cd aws/vpc/us/prod
terragrunt apply

cd aws/vpc/eu/prod
terragrunt apply

# Transit Gateway
cd aws/tgw/us/shared
terragrunt apply

# VPN connections
cd aws/vpn/us/prod
terragrunt apply
```

#### Phase 3: Compute and Storage
```bash
# EKS clusters
cd aws/eks/us/prod
terragrunt apply

# RDS databases
cd aws/rds/us/prod
terragrunt apply

# S3 buckets
cd aws/s3/us/prod
terragrunt apply
```

#### Phase 4: Applications and Services
```bash
# Application-specific services
cd aws/api-gw/us/prod
terragrunt apply

cd aws/redis/us/prod
terragrunt apply
```

### Bulk Deployment

For deploying entire environments:

```bash
# Deploy all services in production US
cd aws
terragrunt run-all plan --terragrunt-include-dir="*/us/prod"
terragrunt run-all apply --terragrunt-include-dir="*/us/prod"

# Deploy specific service across all environments
terragrunt run-all plan --terragrunt-include-dir="vpc/*/*"
terragrunt run-all apply --terragrunt-include-dir="vpc/*/*"
```

## Operational Procedures

### Daily Operations

1. **Monitoring Dashboard**: Check CloudWatch dashboards for system health
2. **Security Alerts**: Review GuardDuty findings and security notifications
3. **Cost Monitoring**: Monitor AWS Cost Explorer for budget adherence
4. **Backup Verification**: Verify automated backup completion

### Weekly Operations

1. **Security Review**: Review CloudTrail logs for unusual activity
2. **Performance Analysis**: Analyze CloudWatch metrics for optimization opportunities
3. **Cost Optimization**: Review resource utilization and rightsizing opportunities
4. **Compliance Check**: Verify Config compliance status

### Monthly Operations

1. **Security Patch Review**: Review and apply security patches
2. **Access Review**: Audit IAM users, roles, and permissions
3. **Disaster Recovery Test**: Test backup and recovery procedures
4. **Capacity Planning**: Review growth trends and capacity requirements

### Emergency Procedures

#### Security Incident Response

1. **Isolation**: Use Security Groups to isolate affected resources
2. **Investigation**: Use CloudTrail and VPC Flow Logs for forensic analysis
3. **Communication**: Use SNS for incident notifications
4. **Recovery**: Follow documented recovery procedures

#### Service Outage Response

1. **Assessment**: Check CloudWatch dashboards and AWS Service Health
2. **Escalation**: Follow escalation procedures based on impact
3. **Communication**: Update stakeholders via established channels
4. **Recovery**: Implement recovery procedures and validate restoration

## Troubleshooting

### Common Issues

#### Terragrunt Dependency Errors
```bash
# Clear cache and retry
terragrunt destroy-all --terragrunt-non-interactive
rm -rf .terragrunt-cache
terragrunt apply
```

#### AWS API Rate Limiting
```bash
# Use exponential backoff and reduce parallelism
terragrunt apply --terragrunt-parallelism=1
```

#### State Lock Issues
```bash
# Force unlock (use carefully)
terragrunt force-unlock <lock-id>
```

### Debugging Commands

```bash
# Verbose logging
export TG_LOG=debug
terragrunt apply

# Plan with detailed output
terragrunt plan -detailed-exitcode

# State inspection
terragrunt state list
terragrunt state show <resource>
```

## Cost Optimization

### Development Environment
- **Instance Types**: Use t3.micro and t3.small
- **Auto Scaling**: Aggressive scale-down policies
- **Scheduled Shutdown**: Automatic shutdown during non-business hours
- **Spot Instances**: Use for non-critical workloads

### Production Environment
- **Reserved Instances**: Purchase RIs for predictable workloads
- **Savings Plans**: Use for consistent compute usage
- **Storage Optimization**: Use appropriate storage classes for S3
- **Monitoring**: Set up billing alerts and cost anomaly detection

## Compliance

### Frameworks Supported
- **SOC 2 Type II**: System and organization controls
- **ISO 27001**: Information security management
- **PCI DSS**: Payment card industry data security
- **HIPAA**: Health insurance portability and accountability
- **FedRAMP**: Federal risk and authorization management

### Compliance Features
- **Encryption**: All data encrypted at rest and in transit
- **Audit Logging**: Comprehensive audit trail via CloudTrail
- **Access Controls**: Role-based access with principle of least privilege
- **Network Segmentation**: Isolated environments and workloads
- **Monitoring**: Continuous compliance monitoring via Config

## Support

### Documentation
- **Architecture Diagrams**: Available in `docs/architecture/`
- **Runbooks**: Operational procedures in `docs/runbooks/`
- **API Documentation**: Service-specific API docs

### Support Channels
- **Internal Wiki**: Detailed operational procedures
- **Slack Channel**: #aws-infrastructure for real-time support
- **Email**: aws-team@cloudon.work for formal requests
- **On-Call**: 24/7 on-call rotation for production issues

### Escalation Procedures
1. **Level 1**: Development team (0-4 hours)
2. **Level 2**: Senior engineers (4-8 hours)
3. **Level 3**: AWS Enterprise Support (8+ hours)
4. **Level 4**: Executive escalation (critical issues)

Last Updated: {{ current_date }}
Next Review: {{ next_review_date }}