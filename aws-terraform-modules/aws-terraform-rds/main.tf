resource "aws_db_instance" "this" {
  for_each = { for db in var.rds_instances : db.identifier => db }

  identifier                 = each.value.identifier
  availability_zone          = each.value.availability_zone
  engine                     = each.value.engine
  engine_version             = each.value.engine_version
  instance_class             = each.value.instance_class
  allocated_storage          = each.value.allocated_storage
  max_allocated_storage      = each.value.max_allocated_storage
  storage_encrypted          = each.value.storage_encrypted
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  multi_az                   = each.value.multi_az

  tags = each.value.tags
}

resource "aws_db_instance_role_association" "s3_import" {
  for_each = merge([for db in var.rds_instances : {
    for role in lookup(db, "db_instance_role_associations", []) : "${db.identifier}_${role.s3import.ingestion_role}" => {
      db_instance_identifier = db.identifier
      s3_import             = role.s3import
    } if lookup(role, "s3import", null) != null
  }]...)

  db_instance_identifier = aws_db_instance.this[each.value.db_instance_identifier].id
  feature_name           = "s3Import"
  role_arn               = each.value.s3_import.ingestion_role
}

resource "aws_db_instance_role_association" "s3_export" {
  for_each = merge([for db in var.rds_instances : {
    for role in lookup(db, "db_instance_role_associations", []) : "${db.identifier}_${role.s3export.ingestion_role}" => {
      db_instance_identifier = db.identifier
      s3_export             = role.s3export
    } if lookup(role, "s3export", null) != null
  }]...)

  db_instance_identifier = aws_db_instance.this[each.value.db_instance_identifier].id
  feature_name           = "s3Export"
  role_arn               = each.value.s3_export.ingestion_role
}