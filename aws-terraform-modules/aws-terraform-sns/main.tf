locals {
  all_topics = distinct(concat(var.topics[*].name, var.subscriptions[*].topic))
}

resource "aws_sns_topic" "this" {
  for_each = toset(local.all_topics)
  name     = each.key
}

resource "aws_sns_topic_subscription" "this" {
  count     = length(var.subscriptions)
  topic_arn = aws_sns_topic.this[var.subscriptions[count.index].topic].arn
  protocol  = var.subscriptions[count.index].protocol
  endpoint  = var.subscriptions[count.index].id  # Using 'id' as the endpoint

  depends_on = [aws_sns_topic.this]
}
