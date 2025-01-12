# AWS Organization Terraform Module

This Terraform module manages AWS Organizations, including the creation of Organizational Units (OUs) and accounts.

## Features

- Creates an AWS Organization
- Creates Organizational Units (OUs)
- Creates AWS accounts and assigns them to OUs

## Prerequisites

- Terraform v0.12+
- AWS provider configured
- Appropriate AWS permissions to manage Organizations, OUs, and accounts

## Usage

```hcl
module "aws_organization" {
  source = "path/to/this/module"

  organization = {
    feature_set = "ALL"  # or "CONSOLIDATED_BILLING"
  }

  org_units = [
    {
      name      = "Production"
      parent_id = "r-abc1"  # Root ID
    },
    {
      name      = "Development"
      parent_id = "r-abc1"  # Root ID
    }
  ]

  accounts = {
    prod_account = {
      account_name  = "Production Account"
      account_email = "prod@example.com"
      ou            = "ou-1234-production"
    },
    dev_account = {
      account_name  = "Development Account"
      account_email = "dev@example.com"
      ou            = "ou-5678-development"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization | Configuration for the AWS Organization | `object` | n/a | yes |
| org_units | List of Organizational Units to create | `list(object)` | `[]` | no |
| accounts | Map of AWS accounts to create | `map(object)` | `{}` | no |

## Outputs

This module doesn't define any outputs. You may want to add outputs based on your specific needs.

## Notes

- The `prevent_destroy` lifecycle rule is set for accounts to prevent accidental deletion.
- Ensure that you have the necessary permissions to create and manage AWS Organizations, OUs, and accounts.
- Be cautious when modifying existing organizations and accounts, as it may impact your AWS infrastructure.

## License

MIT Licence.