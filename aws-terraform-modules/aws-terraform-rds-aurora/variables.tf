variable "aurora_clusters" {
  description = "A list of Aurora clusters to create"
  type = list(object({
    identifier                 = string
    availability_zone          = string
    engine                     = string
    engine_version             = string
    instance_class             = string
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