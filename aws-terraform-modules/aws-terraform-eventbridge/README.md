# AWS EventBridge Terraform Module

This Terraform module creates and manages AWS EventBridge resources, including event buses, rules, targets, and associated permissions.

## Features

- Create and manage EventBridge event buses
- Define and manage EventBridge rules
- Configure various targets for EventBridge rules (e.g., Lambda, ECS, Kinesis, SQS, SNS)
- Set up API destinations and connections
- Create and manage EventBridge Pipes
- Configure EventBridge Scheduler resources
- Manage EventBridge Archives
- Set up Schemas Discoverer
- Flexible IAM role and policy management

## Usage

```hcl
module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.10.0"

  bus_name = "my-event-bus"

  rules = {
    orders = {
      description   = "Capture all order events"
      event_pattern = jsonencode({
        source = ["myapp.orders"]
      })
    }
  }

  targets = {
    orders = [
      {
        name = "send-orders-to-sqs"
        arn  = aws_sqs_queue.orders.arn
      }
    ]
  }

  tags = {
    Environment = "dev"
    Project     = "MyApp"
  }
}
```

## Inputs

This module supports a large number of input variables. Here are some of the key ones:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bus_name | Name of the EventBridge bus to create | `string` | `"default"` | no |
| rules | A map of objects with EventBridge Rule definitions | `any` | `{}` | no |
| targets | A map of objects with EventBridge Target definitions | `any` | `{}` | no |
| create_bus | Controls whether EventBridge Bus should be created | `bool` | `true` | no |
| create_role | Whether to create IAM role for EventBridge | `bool` | `true` | no |
| role_name | Name of IAM role to use for EventBridge | `string` | `null` | no |
| attach_kinesis_policy | Controls whether Kinesis policy should be added to IAM role | `bool` | `false` | no |
| attach_sqs_policy | Controls whether SQS policy should be added to IAM role | `bool` | `false` | no |
| attach_sns_policy | Controls whether SNS policy should be added to IAM role | `bool` | `false` | no |

For a complete list of supported variables, please refer to the [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-eventbridge/blob/master/variables.tf) file in the official module repository.

## Resources Created

This module can create and manage the following AWS resources:

- EventBridge Event Bus
- EventBridge Rules
- EventBridge Targets
- EventBridge API Destinations
- EventBridge Connections
- EventBridge Pipes
- EventBridge Scheduler (Schedule Groups and Schedules)
- EventBridge Archives
- EventBridge Schemas Discoverer
- IAM Roles and Policies

The exact resources created depend on the module configuration.

## Notes

1. This module is highly configurable and can manage a wide range of EventBridge-related resources. Make sure to review the official documentation for detailed usage instructions.
2. The module supports attaching various AWS service-specific policies to the created IAM role. Enable these as needed based on your target configurations.
3. When using API destinations, connections, or pipes, make sure to properly configure the necessary permissions and network settings.

## Limitations

1. The module doesn't create the target resources (e.g., Lambda functions, SQS queues). You need to create these separately and reference them in the module configuration.
2. Some advanced EventBridge features may require additional configuration outside of this module.

## Outputs

This module provides various outputs, including the event bus ARN, rule ARNs, and more. Refer to the [outputs.tf](https://github.com/terraform-aws-modules/terraform-aws-eventbridge/blob/master/outputs.tf) file in the official module repository for a complete list of outputs.

## License

This module is released under the MIT License. For more information, please see the [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eventbridge/blob/master/LICENSE) file in the official module repository.