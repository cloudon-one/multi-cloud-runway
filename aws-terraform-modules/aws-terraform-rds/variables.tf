variable "rds_instances" {
  description = "A list of RDS instances to create"
  type = list(object({
    identifier                 = string
    availability_zone          = string
    engine                     = string
    engine_version             = string
    instance_class             = string
    allocated_storage          = number
    max_allocated_storage      = number
    storage_encrypted          = bool
    auto_minor_version_upgrade = bool
    multi_az                   = bool
    db_instance_role_associations = optional(list(object({
      s3import = optional(object({
        source_engine_version = string
        bucket_name           = string
        ingestion_role        = string
      }))
      s3export = optional(object({
        source_engine_version = string
        bucket_name           = string
        ingestion_role        = string
      }))
    })), [])
    tags = map(string)
  }))
}
