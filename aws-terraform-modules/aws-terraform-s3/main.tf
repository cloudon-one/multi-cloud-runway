locals {
  # Create a map of bucket names with the prefix applied
  bucket_names = {
    for bucket in var.buckets :
    bucket.bucket_name => "${var.name_prefix}${bucket.bucket_name}"
  }
}

locals {
  bucket_config = {
    for bucket in var.buckets : bucket.bucket_name => bucket
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.bucket_config
  bucket   = "${var.name_prefix}${each.key}"

  tags = {
    Environment = each.value.tags.Environment
    Owner       = each.value.tags.Owner
    Department  = each.value.tags.Department
    Description = each.value.tags.Description
    Terraform   = each.value.tags.Terraform
    Name        = "${var.name_prefix}${each.value.tags.Name}"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
