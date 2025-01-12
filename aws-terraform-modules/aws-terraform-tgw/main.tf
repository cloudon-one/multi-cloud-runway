module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.12.2"
  name                                  = var.name
  description                           = var.description
  amazon_side_asn                       = var.amazon_side_asn
  enable_auto_accept_shared_attachments = var.enable_auto_accept_shared_attachments
  vpc_attachments                       = var.vpc_attachments
  ram_allow_external_principals         = var.ram_allow_external_principals
  ram_principals                        = var.ram_principals
  tags                                  = var.tags
}