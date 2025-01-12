# AWS ElastiCache Redis Terraform Module

This Terraform module creates and manages an AWS ElastiCache Redis cluster along with its associated subnet group.

## Features

- Create an ElastiCache subnet group
- Deploy a single-node ElastiCache Redis cluster
- Configurable node type and engine version
- Assign security groups to the ElastiCache cluster

## Usage

```hcl
module "redis_cluster" {
  source = "./path/to/this/module"

  subnet_group_name  = "my-redis-subnet-group"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  cluster_id         = "my-redis-cluster"
  node_type          = "cache.t3.micro"
  engine_version     = "6.x"
  security_group_ids = ["sg-12345678"]
  description        = "My Redis Cluster"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subnet_group_name | Name of the ElastiCache subnet group | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ElastiCache subnet group | `list(string)` | n/a | yes |
| cluster_id | ID of the ElastiCache cluster | `string` | n/a | yes |
| node_type | The compute and memory capacity of the nodes | `string` | n/a | yes |
| engine_version | Version number of the Redis engine | `string` | n/a | yes |
| security_group_ids | List of security group IDs to associate with the cluster | `list(string)` | n/a | yes |
| description | Description for the ElastiCache cluster | `string` | n/a | yes |

## Resources Created

- `aws_elasticache_subnet_group`: ElastiCache subnet group
- `aws_elasticache_cluster`: ElastiCache Redis cluster

## Notes

1. This module creates a single-node Redis cluster. For multi-node clusters or replication groups, you would need to modify the module or use `aws_elasticache_replication_group` instead.
2. The module uses the default parameter group for Redis 6.x. If you need a custom parameter group, you'll need to create it separately and reference it in this module.
3. The Redis port is set to the default 6379. If you need a different port, you'll need to modify the module.
4. Tags are automatically set on the ElastiCache cluster with the cluster ID as the Name and the provided description.

## Limitations

1. This module creates a single-node cluster and doesn't support multi-node clusters or replication groups out of the box.
2. The module doesn't manage the creation of the VPC, subnets, or security groups. These need to be created separately and referenced in the module inputs.
3. Custom parameter groups are not supported in this version of the module.
4. The module doesn't handle encryption settings. If you need encryption at rest or in transit, you'll need to modify the module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for the cluster address, cache nodes, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).