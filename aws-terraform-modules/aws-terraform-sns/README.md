# AWS SNS (Simple Notification Service) Terraform Module

This Terraform module creates and manages AWS SNS topics and subscriptions.

## Features

- Create multiple SNS topics
- Manage subscriptions to SNS topics
- Support for various subscription protocols

## Usage

```hcl
module "sns" {
  source = "./path/to/this/module"

  topics = [
    { name = "alerts" },
    { name = "notifications" }
  ]

  subscriptions = [
    {
      topic    = "alerts"
      protocol = "email"
      id       = "admin@example.com"
    },
    {
      topic    = "notifications"
      protocol = "sms"
      id       = "+1234567890"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| topics | List of SNS topics to create | `list(object({ name = string }))` | `[]` | no |
| subscriptions | List of subscriptions to SNS topics | `list(object({ topic = string, protocol = string, id = string }))` | `[]` | no |

### Topics

Each object in the `topics` list should have the following structure:

```hcl
{
  name = string
}
```

### Subscriptions

Each object in the `subscriptions` list should have the following structure:

```hcl
{
  topic    = string
  protocol = string
  id       = string
}
```

The `id` field is used as the endpoint for the subscription. Its format depends on the protocol:
- For email: email address
- For SMS: phone number
- For SQS: queue ARN
- For Lambda: function ARN
- etc.

## Resources Created

- `aws_sns_topic`: SNS topics
- `aws_sns_topic_subscription`: Subscriptions to SNS topics

## Notes

1. This module creates SNS topics based on the unique set of topic names provided in both the `topics` and `subscriptions` inputs.
2. Subscriptions are created for all entries in the `subscriptions` input.
3. The module uses the `id` field of the subscription as the endpoint. Make sure this matches the expected format for the chosen protocol.

## Limitations

1. This module doesn't manage SNS topic policies. If you need to set specific policies, you'll need to extend the module.
2. The module doesn't handle encryption settings for SNS topics. If you need server-side encryption, you'll need to modify the module.
3. Advanced features like message filtering or delivery status logging are not included in this basic version of the module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for the topic ARNs or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).