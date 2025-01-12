# AWS Certificate Manager (ACM) Terraform Module

This Terraform module creates and manages SSL/TLS certificates using AWS Certificate Manager (ACM). It's based on the `terraform-aws-modules/acm/aws` module version 5.1.0.

## Features

- Create and manage ACM certificates
- Support for domain validation
- Route 53 integration for DNS validation
- Customizable certificate options

## Usage

```hcl
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.0"

  domain_name = "example.com"
  zone_id     = "Z2FDTNDATAQYW2"

  subject_alternative_names = [
    "*.example.com",
    "app.sub.example.com",
  ]

  wait_for_validation = true

  tags = {
    Name = "example.com"
    Environment = "Production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm_certificate_domain_validation_options | Domain validation options for the certificate | `any` | `null` | no |
| certificate_transparency_logging_preference | Specifies whether certificate details should be added to a certificate transparency log | `string` | `"ENABLED"` | no |
| create_certificate | Whether to create an ACM certificate | `bool` | `true` | no |
| create_route53_records | Whether to create Route 53 records for validation | `bool` | `true` | no |
| create_route53_records_only | Whether to create only Route 53 records (no certificate) | `bool` | `false` | no |
| distinct_domain_names | Distinct domain names for the certificate | `list(string)` | `[]` | no |
| dns_ttl | The TTL of DNS recursive resolvers to cache information about this record | `number` | `60` | no |
| domain_name | Domain name for the ACM certificate | `string` | `""` | yes |
| key_algorithm | Algorithm of the public and private key pair | `string` | `"RSA_2048"` | no |
| subject_alternative_names | Subject alternative names for the ACM certificate | `list(string)` | `[]` | no |
| tags | Tags to apply to the ACM certificate | `map(string)` | `{}` | no |
| validate_certificate | Whether to validate the certificate | `bool` | `true` | no |
| validation_allow_overwrite_records | Whether to allow overwrite of Route 53 records | `bool` | `true` | no |
| validation_method | Which method to use for validation, DNS or EMAIL | `string` | `"DNS"` | no |
| validation_option | The domain name that you want ACM to use to send you validation emails | `any` | `{}` | no |
| validation_record_fqdns | List of FQDNs that implement the validation | `list(string)` | `[]` | no |
| validation_timeout | Duration to wait for validation to complete | `string` | `"45m"` | no |
| wait_for_validation | Whether to wait for the validation to complete | `bool` | `true` | no |
| zone_id | The ID of the hosted zone to contain the validationrecords | `string` | `""` | no |
| zones | List of route53 zone objects | `any` | `{}` | no |

## Outputs

This module doesn't specify any outputs. However, you can refer to the [official module documentation](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest) for potential outputs that can be used.

## Notes

- Ensure that you have the necessary permissions to create and manage ACM certificates and Route 53 records.
- The module uses DNS validation by default. If you prefer email validation, change the `validation_method` to "EMAIL".
- When using Route 53 for DNS validation, make sure the specified `zone_id` corresponds to the correct hosted zone for your domain.

## License

This module is open-source and uses the license specified by the original `terraform-aws-modules/acm/aws` module.

For more information and advanced usage, please refer to the [official module documentation](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest).