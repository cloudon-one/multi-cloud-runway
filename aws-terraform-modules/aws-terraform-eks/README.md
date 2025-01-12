# AWS EKS (Elastic Kubernetes Service) Terraform Module

This Terraform module creates and manages AWS EKS clusters, node groups, and access policies.

## Features

- Create multiple EKS clusters
- Configure managed node groups for each cluster
- Set up cluster access entries and policies
- Customizable cluster and node group configurations

## Requirements

- Terraform >= 0.13
- AWS Provider >= 3.0

## Usage

```hcl
module "eks_clusters" {
  source = "./path/to/this/module"

  clusters = [
    {
      cluster_name = "my-cluster-1"
      iam_role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
      version      = "1.21"
      subnet_ids   = ["subnet-12345678", "subnet-87654321"]
      cluster_endpoint_public_access = true
      cluster_additional_security_group_ids = ["sg-12345678"]
      tags = {
        Environment = "Production"
      }
      eks_managed_node_groups = [
        {
          name           = "ng-1"
          desired_size   = 2
          max_size       = 4
          min_size       = 1
          instance_types = ["t3.medium"]
          capacity_type  = "ON_DEMAND"
          ami_type       = "AL2_x86_64"
        }
      ]
      access_entries = [
        {
          principal       = "arn:aws:iam::123456789012:user/admin"
          type            = "IAM"
          access_policies = ["AdminAccessPolicy", "ViewOnlyAccessPolicy"]
        }
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| clusters | List of EKS cluster configurations | `list(object)` | `[]` | yes |

Each object in the `clusters` list should have the following structure:

```hcl
{
  cluster_name                           = string
  iam_role_arn                           = string
  version                                = string
  subnet_ids                             = list(string)
  cluster_endpoint_public_access         = bool
  cluster_additional_security_group_ids  = list(string)
  tags                                   = map(string)
  eks_managed_node_groups                = list(object({
    name           = string
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    ami_type       = string
  }))
  access_entries                         = list(object({
    principal       = string
    type            = string
    access_policies = list(string)
  }))
}
```

## Resources Created

- `aws_eks_cluster`: EKS clusters
- `aws_eks_node_group`: EKS managed node groups
- `aws_eks_access_entry`: EKS cluster access entries
- `aws_eks_access_policy_association`: EKS cluster access policy associations

## Notes

1. This module creates one managed node group per cluster. If you need multiple node groups per cluster, you'll need to modify the module.
2. The module uses the same IAM role for both the EKS cluster and the node group. Ensure this role has the necessary permissions for both.
3. Cluster access entries and policies are created based on the `access_entries` configuration in each cluster.
4. All access policy associations are created with a cluster-wide scope.

## Limitations

1. This module doesn't create or manage IAM roles. You need to create the necessary roles beforehand and provide their ARNs.
2. The module doesn't handle VPC or subnet creation. You need to provide existing subnet IDs.
3. Only one managed node group is created per cluster. For multiple node groups, you'll need to modify the module.
4. The module assumes that the specified access policies exist in AWS. Make sure to create these policies before applying this module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for cluster endpoints, certificate authorities, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).