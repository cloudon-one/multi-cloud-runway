# AWS CloudTrail Terraform Module

This Terraform module creates and manages an AWS CloudTrail and its associated S3 bucket for storing logs. It uses the `cloudposse/cloudtrail/aws` module for CloudTrail configuration and the `cloudposse/cloudtrail-s3-bucket/aws` module for creating the S3 bucket.

## Features

- Create and configure AWS CloudTrail
- Set up S3 bucket for CloudTrail logs with access logging
- Configurable event selectors and insight selectors
- Support for multi-region and organization-wide trails
- CloudWatch Logs integration
- KMS encryption support
- SNS topic integration

## Usage

```hcl
module "cloudtrail" {
  source  = "cloudposse/cloudtrail/aws"
  version = "0.24.0"

  s3_bucket_name                 = module.cloudtrail_s3_bucket.bucket_id
  enable_log_file_validation     = true
  include_global_service_events  = true
  is_multi_region_trail          = true
  enable_logging                 = true
  
  # Add other variables as needed

  context = module.this.context
}

module "cloudtrail_s3_bucket" {
  source  = "cloudposse/cloudtrail-s3-bucket/aws"
  version = "0.20.0"

  force_destroy            = true
  create_access_log_bucket = true

  context = module.this.context
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| s3_bucket_name | Name of the S3 bucket to store CloudTrail logs | `string` | n/a | yes |
| additional_tag_map | Additional tags for appending to tags_as_list_of_maps | `map(string)` | `{}` | no |
| advanced_event_selector | Specifies an advanced event selector for enabling data event logging | `any` | `[]` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| cloud_watch_logs_group_arn | Specifies a log group name using an Amazon Resource Name (ARN) | `string` | `""` | no |
| cloud_watch_logs_role_arn | Specifies the role for the CloudWatch Logs endpoint to assume to write to a user's log group | `string` | `""` | no |
| context | Single object for setting entire context at once | `any` | `{}` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| descriptor_formats | Describe additional descriptors to be output in the `descriptors` output map | `map` | `{}` | no |
| enable_log_file_validation | Specifies whether log file integrity validation is enabled | `bool` | `true` | no |
| enable_logging | Enable logging for the trail | `bool` | `true` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `""` | no |
| event_selector | Specifies an event selector for enabling data event logging | `any` | `[]` | no |
| include_global_service_events | Specifies whether the trail is publishing events from global services such as IAM to the log files | `bool` | `true` | no |
| insight_selector | Specifies an insight selector for identifying unusual operational activity | `any` | `[]` | no |
| is_multi_region_trail | Specifies whether the trail is created in the current region or in all regions | `bool` | `true` | no |
| is_organization_trail | Specifies whether the trail is an AWS Organizations trail | `bool` | `false` | no |
| kms_key_arn | Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail | `string` | `""` | no |
| s3_key_prefix | Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery | `string` | `""` | no |
| sns_topic_name | Specifies the name of the Amazon SNS topic defined for notification of log file delivery | `string` | `null` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

This module doesn't specify any outputs directly. However, you can refer to the [official module documentation](https://registry.terraform.io/modules/cloudposse/cloudtrail/aws/latest) for potential outputs that can be used.

## Notes

- The S3 bucket created by the `cloudtrail_s3_bucket` module is configured with `force_destroy = true`, which means all objects will be deleted from the bucket when you destroy the Terraform resources. Be cautious with this setting in production environments.
- The S3 bucket is configured to create an access log bucket. Make sure you have appropriate permissions to create additional S3 buckets.
- Remember to configure appropriate IAM permissions for CloudTrail to write to the S3 bucket and CloudWatch Logs (if enabled).
- If you're using organization-wide trail (`is_organization_trail = true`), ensure you have the necessary permissions in the AWS Organizations management account.

## License

This module uses modules from Cloud Posse, which are released under the Apache 2.0 License.