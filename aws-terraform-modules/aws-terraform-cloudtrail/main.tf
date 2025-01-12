module "cloudtrail" {
  source  = "cloudposse/cloudtrail/aws"
  version = "0.24.0"
  s3_bucket_name = var.s3_bucket_name
  additional_tag_map = var.additional_tag_map
  advanced_event_selector = var.advanced_event_selector
  attributes = var.attributes
  cloud_watch_logs_group_arn = var.cloud_watch_logs_group_arn
  cloud_watch_logs_role_arn = var.cloud_watch_logs_role_arn
  context = var.context
  delimiter = var.delimiter
  enable_log_file_validation  = var.enable_log_file_validation
  enable_logging = var.enable_logging
  enabled = var.enabled
  environment = var.environment
  event_selector = var.event_selector
  include_global_service_events = var.include_global_service_events
  insight_selector = var.insight_selector
  is_multi_region_trail  = var.is_multi_region_trail
  is_organization_trail = var.is_organization_trail
  kms_key_arn = var.kms_key_arn
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_name = var.sns_topic_name
  tags  = var.tags
}

module "cloudtrail_s3_bucket" {
  source = "cloudposse/cloudtrail-s3-bucket/aws"

  force_destroy            = true
  create_access_log_bucket = true

  context = module.this.context
}
