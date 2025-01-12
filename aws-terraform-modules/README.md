# AWS Terraform Modules Collection

This repository contains a comprehensive collection of reusable Terraform modules for AWS infrastructure provisioning. Each module is designed to be modular, maintainable, and follows AWS best practices.

## Available Modules

### Networking
- **aws-terraform-core-vpc**: Core VPC infrastructure setup
- **aws-terraform-vpc**: Standard VPC configuration
- **aws-terraform-peering**: VPC peering connections
- **aws-terraform-tgw**: Transit Gateway configuration
- **aws-terraform-vpn**: VPN connection setup

### Computing
- **aws-terraform-ec2**: EC2 instance provisioning
- **aws-terraform-eks**: Elastic Kubernetes Service cluster setup

### Storage & Databases
- **aws-terraform-s3**: S3 bucket configuration
- **aws-terraform-dynamodb**: DynamoDB tables
- **aws-terraform-rds**: Relational Database Service
- **aws-terraform-rds-aurora**: Amazon Aurora cluster setup
- **aws-terraform-redis**: ElastiCache Redis configuration

### Security & Identity
- **aws-terraform-accounts**: AWS account management
- **aws-terraform-acm**: AWS Certificate Manager
- **aws-terraform-cloudtrail**: CloudTrail logging
- **aws-terraform-iam**: IAM resource management
  - account: Account-level IAM settings
  - assumable-role: Cross-account role assumption
  - groups: IAM group management
  - policies: Custom IAM policies
  - roles: IAM roles
  - service-accounts: Service account configuration
  - users: IAM user management

### Application Services
- **aws-terraform-apigw**: API Gateway setup
- **aws-terraform-eventbridge**: EventBridge/CloudWatch Events
- **aws-terraform-sns**: Simple Notification Service

## Module Structure
Each module follows a consistent structure:
```
module-name/
├── README.md        # Module documentation
├── main.tf          # Main module logic
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── versions.tf      # (optional) Provider version constraints
```

## Usage

Each module can be used by referencing it in your Terraform configuration:

```hcl
module "example" {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-<service>?ref=main"
  
  # Module specific variables
  # ...
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider
- Valid AWS credentials configured

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.


## Support

For issues, feature requests, or support:
1. Check the module's README for specific documentation
2. Open an issue in the repository
3. Submit a pull request with proposed changes

---

For detailed documentation on each module, please refer to the respective README files within each module directory.