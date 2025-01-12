# AWS DynamoDB Terraform Module

This Terraform module creates and manages AWS DynamoDB tables with optional auto-scaling capabilities for read and write capacity units.

## Features

- Create multiple DynamoDB tables
- Support for both PROVISIONED and PAY_PER_REQUEST billing modes
- Configurable auto-scaling for read and write capacity units
- Consistent hash key attribute across all tables

## Usage

```hcl
module "dynamodb_tables" {
  source = "./path/to/this/module"

  dynamodb_tables = [
    {
      name           = "my-table-1"
      billing_mode   = "PROVISIONED"
      read_capacity  = 5
      write_capacity = 5
      autoscaling_enabled = true
      autoscaling_read = {
        max_capacity = 100
        min_capacity = 5
      }
      autoscaling_write = {
        max_capacity = 100
        min_capacity = 5
      }
    },
    {
      name           = "my-table-2"
      billing_mode   = "PAY_PER_REQUEST"
      autoscaling_enabled = false
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dynamodb_tables | List of DynamoDB table configurations | `list(object)` | `[]` | yes |

Each object in the `dynamodb_tables` list should have the following structure:

```hcl
{
  name                = string
  billing_mode        = string
  read_capacity       = number
  write_capacity      = number
  autoscaling_enabled = bool
  autoscaling_read    = object({
    max_capacity = number
    min_capacity = number
  })
  autoscaling_write   = object({
    max_capacity = number
    min_capacity = number
  })
}
```

## Resources Created

- `aws_dynamodb_table`: DynamoDB tables
- `aws_appautoscaling_target`: Auto Scaling targets for read and write capacity
- `aws_appautoscaling_policy`: Auto Scaling policies for read and write capacity

## Notes

1. All tables are created with a hash key attribute named "id" of type String.
2. Auto-scaling is only applied to tables with PROVISIONED billing mode and when `autoscaling_enabled` is set to true.
3. The auto-scaling policies use a target tracking configuration with a 70% utilization target for both read and write capacity.
4. Tags are applied to all DynamoDB tables with "Owner" set to "Terraform".

## Limitations

1. This module only supports a single attribute (id) as the hash key. If you need more complex key schemas, you'll need to modify the module.
2. Global Secondary Indexes are not supported in this version of the module.
3. The auto-scaling configuration is fixed at 70% utilization. If you need different targets, you'll need to modify the module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for table ARNs or names if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).