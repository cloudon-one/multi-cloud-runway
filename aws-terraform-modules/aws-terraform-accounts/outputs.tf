output "organizational_units" {
  value       = aws_organizations_organizational_unit.ous
  description = "The created organizational units"
}

output "accounts" {
  value       = aws_organizations_account.accounts
  description = "The created AWS accounts"
}