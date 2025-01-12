module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  for_each = { for idx, vpc in var.vpc_configs : vpc.vpc_name => vpc }

  name = each.value.vpc_name
  cidr = each.value.vpc_cidr

  azs             = each.value.azs
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway = each.value.enable_nat_gateway
  single_nat_gateway = each.value.enable_nat_gateway

  tags = each.value.tags
}