resource "aws_rds_cluster" "this" {
  for_each = { for cluster in var.aurora_clusters : cluster.identifier => cluster }

  cluster_identifier              = each.value.identifier
  availability_zones              = [each.value.availability_zone]
  engine                          = each.value.engine
  engine_version                  = each.value.engine_version
  storage_encrypted               = each.value.storage_encrypted
  tags                            = each.value.tags
}

resource "aws_rds_cluster_instance" "this" {
  for_each = { for cluster in var.aurora_clusters : cluster.identifier => cluster }

  identifier                   = "${each.value.identifier}-instance"
  cluster_identifier           = aws_rds_cluster.this[each.value.identifier].id
  instance_class               = each.value.instance_class
  engine                       = each.value.engine
  engine_version               = each.value.engine_version
  auto_minor_version_upgrade   = each.value.auto_minor_version_upgrade
  tags                         = each.value.tags
}

resource "aws_db_instance_role_association" "s3_import" {
  for_each = merge([for cluster in var.aurora_clusters : {
    for role in lookup(cluster, "db_instance_role_associations", []) : "${cluster.identifier}_${role.s3import.ingestion_role}" => {
      db_instance_identifier = aws_rds_cluster_instance.this[cluster.identifier].id
      s3_import             = role.s3import
    } if lookup(role, "s3import", null) != null
  }]...)

  db_instance_identifier = each.value.db_instance_identifier
  feature_name           = "s3Import"
  role_arn               = each.value.s3_import.ingestion_role
}

resource "aws_db_instance_role_association" "s3_export" {
  for_each = merge([for cluster in var.aurora_clusters : {
    for role in lookup(cluster, "db_instance_role_associations", []) : "${cluster.identifier}_${role.s3export.ingestion_role}" => {
      db_instance_identifier = aws_rds_cluster_instance.this[cluster.identifier].id
      s3_export             = role.s3export
    } if lookup(role, "s3export", null) != null
  }]...)

  db_instance_identifier = each.value.db_instance_identifier
  feature_name           = "s3Export"
  role_arn               = each.value.s3_export.ingestion_role
}