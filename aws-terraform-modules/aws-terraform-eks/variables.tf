variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "Kubernetes version"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the cluster and workers will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN for the cluster"
}

variable "node_security_group_name" {
  type        = string
  description = "Name of the node security group"
}

variable "cluster_additional_security_group_ids" {
  type        = list(string)
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = true
}

variable "eks_managed_node_groups" {
  type = list(object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    ami_type       = string
    capacity_type  = string
    access_entries = list(object({
      principal          = string
      kubernetes_groups  = list(string)
    }))
    tags           = map(string)
  }))
  description = "List of managed node group configurations"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}