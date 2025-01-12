# AWS RDS (Relational Database Service) Terraform Module

This Terraform module creates and manages AWS RDS instances and their associated role associations for S3 import and export features.

## Features

- Create multiple RDS instances with customizable configurations
- Support for various database engines
- Configure storage options including encryption and auto-scaling
- Set up multi-AZ deployments
- Manage S3 import and export role associations

## Usage

```hcl
module "rds_instances" {
  source = "./path/to/this/module"

  rds_instances = [
    {
      identifier            = "my-database-1"
      availability_zone     = "us-west-2a"
      engine                = "mysql"
      engine_version        = "8.0"
      instance_class        = "db.t3.micro"
      allocated_storage     = 20
      max_allocated_storage = 100
      storage_encrypted     = true
      auto_minor_version_upgrade = true
      multi_az              = false
      tags = {
        Environment = "Production"
      }
      db_instance_role_associations = [
        {
          s3import = {
            ingestion_role = "arn:aws:iam::123456789012:role/rds-s3-import-role"
          }
        },
        {
          s3export = {
            ingestion_role = "arn:aws:iam::123456789012:role/rds-s3-export-role"
          }
        }
      ]
    },
    # Add more RDS instances as needed
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| rds_instances | List of RDS instance configurations | `list(object)` | `[]` | yes |

Each object in the `rds_instances` list should have the following structure:

```hcl
{
  identifier                 = string
  availability_zone          = string
  engine                     = string
  engine_version             = string
  instance_class             = string
  allocated_storage          = number
  max_allocated_storage      = number
  storage_encrypted          = bool
  auto_minor_version_upgrade = bool
  multi_az                   = bool
  tags                       = map(string)
  db_instance_role_associations = list(object({
    s3import = optional(object({
      ingestion_role = string
    }))
    s3export = optional(object({
      ingestion_role = string
    }))
  }))
}
```

## Resources Created

- `aws_db_instance`: RDS instances
- `aws_db_instance_role_association`: Role associations for S3 import and export features

## Notes

1. This module creates RDS instances and manages their S3 import/export role associations.
2. The `storage_encrypted` parameter should be set to `true` for production environments to ensure data at rest is encrypted.
3. When `multi_az` is set to `true`, AWS will create a primary instance and a standby instance in a different Availability Zone for high availability.
4. The `max_allocated_storage` parameter enables storage autoscaling. Set it higher than `allocated_storage` to allow the storage to grow automatically.
5. S3 import and export features require appropriate IAM roles to be created separately and referenced in the `db_instance_role_associations` configuration.

## Limitations

1. This module doesn't manage the creation of the S3 buckets or IAM roles used for import/export. These need to be created separately.
2. Database credentials and connection details are not managed by this module. Consider using AWS Secrets Manager or another secure method to manage these.
3. The module doesn't handle subnet groups, parameter groups, or option groups. These would need to be managed separately or the module would need to be extended to include these resources.

## Outputs

This module doesn't define any outputs. Consider adding outputs for the RDS instance IDs, endpoints, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).