resource "aws_cloudwatch_event_rule" "this" {
  count       = length(var.rules)
  name        = var.rules[count.index].name
  description = var.rules[count.index].description

  event_pattern = jsonencode(var.rules[count.index].event_pattern)
}