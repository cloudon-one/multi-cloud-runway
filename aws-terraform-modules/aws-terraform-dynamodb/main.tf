locals {
  autoscaling_tables = [
    for idx, table in var.dynamodb_tables : {
      index = idx
      table = table
    }
    if table.billing_mode == "PROVISIONED" &&
       table.autoscaling_enabled == true &&
       table.autoscaling_read != null &&
       table.autoscaling_write != null
  ]
}

resource "aws_dynamodb_table" "this" {
  count          = length(var.dynamodb_tables)
  name           = var.dynamodb_tables[count.index].name
  billing_mode   = var.dynamodb_tables[count.index].billing_mode
  read_capacity  = var.dynamodb_tables[count.index].billing_mode == "PROVISIONED" ? tonumber(var.dynamodb_tables[count.index].read_capacity) : null
  write_capacity = var.dynamodb_tables[count.index].billing_mode == "PROVISIONED" ? tonumber(var.dynamodb_tables[count.index].write_capacity) : null
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Owner = "Terraform"
  }
}

resource "aws_appautoscaling_target" "read_target" {
  count              = length(local.autoscaling_tables)
  max_capacity       = tonumber(local.autoscaling_tables[count.index].table.autoscaling_read.max_capacity)
  min_capacity       = tonumber(local.autoscaling_tables[count.index].table.autoscaling_read.min_capacity)
  resource_id        = "table/${aws_dynamodb_table.this[local.autoscaling_tables[count.index].index].name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  count              = length(local.autoscaling_tables)
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "write_target" {
  count              = length(local.autoscaling_tables)
  max_capacity       = tonumber(local.autoscaling_tables[count.index].table.autoscaling_write.max_capacity)
  min_capacity       = tonumber(local.autoscaling_tables[count.index].table.autoscaling_write.min_capacity)
  resource_id        = "table/${aws_dynamodb_table.this[local.autoscaling_tables[count.index].index].name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write_policy" {
  count              = length(local.autoscaling_tables)
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}