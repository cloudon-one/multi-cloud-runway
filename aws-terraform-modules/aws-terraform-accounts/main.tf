# Create Organizational Units
resource "aws_organizations_organizational_unit" "ous" {
  for_each  = { for ou in var.org_units : ou.name => ou }
  name      = each.value.name
  parent_id = each.value.parent_id
}

# Create Accounts
resource "aws_organizations_account" "accounts" {
  for_each  = var.accounts
  name      = each.value.account_name
  email     = each.value.account_email
  parent_id = each.value.ou

  # Prevent destroying the account
  lifecycle {
    prevent_destroy = true
  }
}
