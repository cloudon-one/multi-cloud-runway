# AWS S3 Bucket Terraform Module

This Terraform module creates and manages AWS S3 buckets with consistent naming conventions and public access blocks.

## Features

- Create multiple S3 buckets with a single module
- Apply a consistent prefix to all bucket names
- Automatically block public access for all created buckets
- Apply standardized tags to buckets

## Usage

```hcl
module "s3_buckets" {
  source = "./path/to/this/module"

  name_prefix = "mycompany-"
  
  buckets = [
    {
      bucket_name = "logs"
      tags = {
        Environment = "Production"
        Owner       = "DevOps"
        Department  = "IT"
        Description = "Logs bucket"
        Terraform   = "true"
        Name        = "logs"
      }
    },
    {
      bucket_name = "backups"
      tags = {
        Environment = "Production"
        Owner       = "DataTeam"
        Department  = "Data"
        Description = "Backups bucket"
        Terraform   = "true"
        Name        = "backups"
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix to be applied to all bucket names | `string` | n/a | yes |
| buckets | List of bucket configurations | `list(object)` | `[]` | yes |

Each object in the `buckets` list should have the following structure:

```hcl
{
  bucket_name = string
  tags = object({
    Environment = string
    Owner       = string
    Department  = string
    Description = string
    Terraform   = string
    Name        = string
  })
}
```

## Resources Created

- `aws_s3_bucket`: S3 buckets
- `aws_s3_bucket_public_access_block`: Public access block for each S3 bucket

## Notes

1. This module applies a consistent naming convention by prefixing all bucket names with the provided `name_prefix`.
2. Public access is blocked for all buckets created by this module.
3. Tags are applied consistently across all buckets, with the "Name" tag being prefixed with the `name_prefix`.
4. The actual bucket names in AWS will be `${name_prefix}${bucket_name}`.

## Limitations

1. This module doesn't manage bucket policies, CORS configurations, or versioning. These would need to be added separately or the module would need to be extended.
2. The module doesn't handle encryption settings. If you need server-side encryption, you'll need to modify the module.
3. All buckets created by this module will have the same public access block settings. If you need different settings for different buckets, you'll need to modify the module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for the bucket ARNs, names, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).