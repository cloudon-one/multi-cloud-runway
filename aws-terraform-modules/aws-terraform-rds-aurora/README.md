# AWS Aurora RDS Terraform Module

This Terraform module creates and manages AWS Aurora RDS clusters and instances, along with their associated role associations for S3 import and export features.

## Features

- Create multiple Aurora RDS clusters and instances
- Support for various Aurora database engines
- Configure storage encryption
- Manage instance class and engine versions
- Set up S3 import and export role associations

## Usage

```hcl
module "aurora_clusters" {
  source = "./path/to/this/module"

  aurora_clusters = [
    {
      identifier            = "my-aurora-cluster"
      availability_zone     = "us-west-2a"
      engine                = "aurora-mysql"
      engine_version        = "5.7.mysql_aurora.2.10.2"
      instance_class        = "db.r5.large"
      storage_encrypted     = true
      auto_minor_version_upgrade = true
      tags = {
        Environment = "Production"
      }
      db_instance_role_associations = [
        {
          s3import = {
            ingestion_role = "arn:aws:iam::123456789012:role/aurora-s3-import-role"
          }
        },
        {
          s3export = {
            ingestion_role = "arn:aws:iam::123456789012:role/aurora-s3-export-role"
          }
        }
      ]
    },
    # Add more Aurora clusters as needed
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aurora_clusters | List of Aurora RDS cluster configurations | `list(object)` | `[]` | yes |

Each object in the `aurora_clusters` list should have the following structure:

```hcl
{
  identifier                 = string
  availability_zone          = string
  engine                     = string
  engine_version             = string
  instance_class             = string
  storage_encrypted          = bool
  auto_minor_version_upgrade = bool
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

- `aws_rds_cluster`: Aurora RDS clusters
- `aws_rds_cluster_instance`: Aurora RDS instances
- `aws_db_instance_role_association`: Role associations for S3 import and export features

## Notes

1. This module creates Aurora RDS clusters and instances, and manages their S3 import/export role associations.
2. The `storage_encrypted` parameter should be set to `true` for production environments to ensure data at rest is encrypted.
3. Each Aurora cluster created by this module will have one associated instance. For multi-instance clusters, you may need to modify the module.
4. The instance identifier is automatically generated based on the cluster identifier.
5. S3 import and export features require appropriate IAM roles to be created separately and referenced in the `db_instance_role_associations` configuration.

## Limitations

1. This module creates a single instance per Aurora cluster. For multi-instance clusters, the module would need to be extended.
2. The module doesn't manage the creation of the S3 buckets or IAM roles used for import/export. These need to be created separately.
3. Database credentials and connection details are not managed by this module. Consider using AWS Secrets Manager or another secure method to manage these.
4. The module doesn't handle subnet groups, parameter groups, or cluster parameter groups. These would need to be managed separately or the module would need to be extended to include these resources.

## Outputs

This module doesn't define any outputs. Consider adding outputs for the Aurora cluster endpoints, reader endpoints, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).