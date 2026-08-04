output "org_dry_run_policies" {
  description = "Org-scope dry-run policy names"
  value       = [for p in google_org_policy_policy.org_dry_run : p.name]
}

output "folder_enforced_policies" {
  description = "Folder-scope enforcing policy names"
  value       = [for p in google_org_policy_policy.folder_enforced : p.name]
}
