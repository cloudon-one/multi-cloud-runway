# Contributing to Multi-Cloud Runway

Thank you for your interest in contributing to the Multi-Cloud Runway infrastructure project! This document provides guidelines for contributing to this enterprise-grade multi-cloud landing zone implementation.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Infrastructure Guidelines](#infrastructure-guidelines)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Security Considerations](#security-considerations)
- [Review Process](#review-process)

## Code of Conduct

This project adheres to a code of professional conduct. All contributors are expected to:

- Be respectful and inclusive
- Focus on constructive feedback
- Prioritize security and compliance
- Follow established conventions
- Document changes thoroughly

## Getting Started

### Prerequisites

Ensure you have the following tools installed and configured:

```bash
# Required tools
terraform --version  # >= 1.5.0
terragrunt --version  # >= 0.60.0
aws --version        # >= 2.0.0
gcloud version       # Latest SDK

# Development tools
git --version
make --version       # For build automation
pre-commit --version # For commit hooks
```

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/cloudon-one/multi-cloud-runway.git
   cd multi-cloud-runway
   ```

2. **Install pre-commit hooks:**
   ```bash
   pre-commit install
   ```

3. **Configure cloud credentials:**
   ```bash
   # AWS
   aws configure
   
   # GCP
   gcloud auth application-default login
   ```

4. **Set up development workspace:**
   ```bash
   # Create development branch
   git checkout -b feature/your-feature-name
   
   # Verify setup
   make verify-setup
   ```

## Development Workflow

### Branch Naming Convention

Use descriptive branch names following this pattern:

- `feature/add-new-service` - New features or services
- `fix/security-vulnerability` - Bug fixes and security patches  
- `docs/update-readme` - Documentation updates
- `refactor/vpc-configuration` - Code refactoring
- `compliance/pci-dss-updates` - Compliance-related changes

### Commit Message Guidelines

Follow conventional commit format:

```
type(scope): brief description

Detailed explanation of changes (if needed)

- Change 1
- Change 2

Closes #123
```

**Types:**
- `feat`: New feature or service
- `fix`: Bug fix or security patch
- `docs`: Documentation updates
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `sec`: Security improvements
- `compliance`: Compliance-related changes

**Examples:**
```
feat(aws): add GuardDuty configuration for security monitoring

- Enable GuardDuty in all AWS regions
- Configure threat intelligence integration
- Add automated response for high-severity findings

Closes #456
```

## Infrastructure Guidelines

### Terragrunt Best Practices

1. **Configuration Structure:**
   ```hcl
   # Always include common configuration
   include "common" {
     path = find_in_parent_folders("common.hcl")
   }
   
   # Use consistent module sourcing
   terraform {
     source = "git::https://github.com/cloudon-one/terraform-modules.git//module-name?ref=v1.0.0"
   }
   
   # Implement proper variable management
   locals {
     common_vars = yamldecode(file(find_in_parent_folders("vars.yaml")))
     environment = basename(get_terragrunt_dir())
     region      = basename(dirname(get_terragrunt_dir()))
   }
   ```

2. **Naming Conventions:**
   - Resources: `{organization}-{environment}-{service}-{resource}`
   - Variables: `snake_case` for all variable names
   - Modules: `kebab-case` for module names
   - Tags: Consistent tagging across all resources

3. **Security Requirements:**
   - All resources must use private subnets when applicable
   - Encryption at rest and in transit required
   - Network segmentation between environments
   - IAM roles following least privilege principle

### File Organization

```
service-name/
├── README.md                 # Service-specific documentation
├── region/
│   ├── environment/
│   │   ├── terragrunt.hcl   # Main configuration
│   │   └── variables.yaml   # Environment-specific variables
│   └── common.hcl           # Region-wide configuration
└── docs/
    ├── architecture.md      # Service architecture
    └── runbook.md          # Operational procedures
```

### Variable Management

1. **Hierarchy (lowest to highest precedence):**
   - Global defaults (`vars.yaml`)
   - Region-specific overrides
   - Environment-specific overrides
   - Service-specific configuration

2. **Sensitive Data:**
   - Never commit secrets to version control
   - Use cloud provider secret management services
   - Reference secrets using data sources
   - Document secret requirements in README

### Dependencies

1. **Explicit Dependencies:**
   ```hcl
   dependency "vpc" {
     config_path = "../../../vpc/us-east-2/dev"
     
     mock_outputs = {
       vpc_id = "vpc-12345678"
       private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
     }
     
     mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
   }
   ```

2. **Dependency Guidelines:**
   - Always provide mock outputs for planning
   - Use relative paths consistently
   - Document dependency relationships
   - Avoid circular dependencies

## Testing Requirements

### Pre-deployment Validation

1. **Syntax Validation:**
   ```bash
   # Validate Terraform syntax
   terragrunt validate
   
   # Check formatting
   terragrunt fmt -check
   
   # Validate against policies
   terragrunt run-all validate
   ```

2. **Security Scanning:**
   ```bash
   # Security policy validation
   tfsec .
   
   # Compliance checking
   checkov -d .
   
   # Infrastructure cost estimation
   infracost breakdown --path .
   ```

3. **Plan Review:**
   ```bash
   # Generate and review plan
   terragrunt plan
   
   # Cross-environment impact analysis
   terragrunt run-all plan
   ```

### Testing Environments

- **Development**: Full testing sandbox for experimentation
- **Staging**: Production-like environment for validation
- **Production**: Requires peer review and approval

### Automated Testing

All pull requests trigger automated testing including:

- Terraform syntax validation
- Security policy compliance
- Cost impact analysis  
- Documentation consistency checks
- Integration test execution

## Documentation Standards

### Required Documentation

1. **Service README.md:**
   ```markdown
   # Service Name
   
   ## Overview
   Brief description of the service
   
   ## Architecture
   High-level architecture diagram and explanation
   
   ## Configuration
   Key configuration parameters and their purpose
   
   ## Dependencies
   List of dependencies and their requirements
   
   ## Deployment
   Step-by-step deployment instructions
   
   ## Monitoring
   Monitoring and alerting configuration
   
   ## Troubleshooting
   Common issues and their resolution
   ```

2. **Architecture Decision Records (ADRs):**
   Document significant architectural decisions in `docs/adr/`

3. **Runbooks:**
   Operational procedures for common tasks and incident response

### Documentation Guidelines

- Use clear, concise language
- Include diagrams for complex architectures
- Provide working examples
- Keep documentation up-to-date with code changes
- Use standard markdown formatting

## Security Considerations

### Security Review Requirements

All contributions must undergo security review focusing on:

1. **Access Controls:**
   - IAM policies follow least privilege
   - Network access properly restricted
   - Administrative access properly secured

2. **Data Protection:**
   - Encryption configured appropriately
   - Backup and recovery procedures defined
   - Data classification and handling

3. **Monitoring and Logging:**
   - Adequate logging and monitoring
   - Security event detection and response
   - Audit trail completeness

4. **Compliance:**
   - PCI DSS requirements addressed
   - CIS benchmark compliance
   - Regulatory requirements met

### Security Testing

- Static analysis of infrastructure code
- Security policy validation
- Vulnerability scanning of deployed resources
- Compliance certification testing

## Review Process

### Pull Request Requirements

1. **Branch Protection:**
   - Branch must be up-to-date with main
   - All status checks must pass
   - At least one approved review required
   - No merge commits allowed

2. **Required Checks:**
   - Terraform validation ✅
   - Security policy compliance ✅
   - Documentation updates ✅
   - Integration tests ✅
   - Peer review approval ✅

3. **Review Criteria:**
   - Code follows established patterns
   - Security best practices implemented
   - Documentation is complete and accurate
   - Changes are well-tested
   - No breaking changes without justification

### Review Timeline

- **Initial Review**: Within 2 business days
- **Follow-up Reviews**: Within 1 business day
- **Security Reviews**: Within 3 business days for security-related changes
- **Emergency Changes**: Same-day review for critical security fixes

### Merge Process

1. **Automated Testing**: All CI/CD checks pass
2. **Peer Review**: Approved by at least one maintainer
3. **Security Approval**: Required for security-sensitive changes
4. **Merge Strategy**: Squash and merge for clean history

## Support and Communication

### Getting Help

- **General Questions**: Create a GitHub issue with the `question` label
- **Bug Reports**: Use the bug report template
- **Feature Requests**: Use the feature request template
- **Security Issues**: Email security@cloudon.work directly

### Communication Channels

- **GitHub Issues**: Primary communication channel
- **Pull Request Comments**: For change-specific discussions
- **Security Email**: For sensitive security matters
- **Team Chat**: For urgent operational issues

### Response Times

- **Bug Reports**: Acknowledged within 1 business day
- **Feature Requests**: Reviewed within 1 week
- **Security Issues**: Acknowledged within 24 hours
- **General Questions**: Responded to within 3 business days

## Recognition

Contributors will be recognized in the following ways:

- Listed in CONTRIBUTORS.md
- Mentioned in release notes for significant contributions
- Invited to join the core maintainer team for sustained contributions
- Recognition in team communications for outstanding work

Thank you for contributing to Multi-Cloud Runway! Your efforts help maintain a secure, scalable, and compliant multi-cloud infrastructure platform.