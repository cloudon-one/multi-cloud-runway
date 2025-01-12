resource "aws_iam_policy_attachment" "policy_attachments" {
  count = length(var.policies)

  name       = var.policies[count.index].name
  policy_arn = var.policies[count.index].arn
  
  groups = [for member in var.policies[count.index].members : member if can(regex("group", member))]
  roles  = [for member in var.policies[count.index].members : member if can(regex("role", member))]
  users  = [for member in var.policies[count.index].members : member if can(regex("user", member))]

  lifecycle {
    ignore_changes = [groups, roles, users]
  }
}