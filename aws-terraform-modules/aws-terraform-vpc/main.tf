module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets
  database_subnets = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  enable_nat_gateway = var.enable_nat_gateway

  private_subnet_names = var.private_subnet_names
  public_subnet_names  = var.public_subnet_names
  intra_subnet_names   = var.intra_subnet_names
  database_subnet_names = var.database_subnet_names
  elasticache_subnet_names = var.elasticache_subnet_names

  tags = var.tags
}

resource "aws_security_group" "allow_redis_ingress" {
  name        = "allow_redis_ingress"
  description = "Allow redis inbound traffic"
  vpc_id      = module.vpc.vpc_id


  tags = {
    Name = "allow_redis_ingress"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_redis_ingress" {
  security_group_id = aws_security_group.allow_redis_ingress.id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}