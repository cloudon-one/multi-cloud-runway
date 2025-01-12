output "iam_access_key_encrypted_secret" {
  value = module.iam_iam-user.iam_access_key_encrypted_secret
}

output "iam_access_key_encrypted_ses_smtp_password_v4" {
  value = module.iam_iam-user.iam_access_key_encrypted_ses_smtp_password_v4
}

output "iam_access_key_id" {
  value = module.iam_iam-user.iam_access_key_id
}

output "iam_access_key_key_fingerprint" {
  value = module.iam_iam-user.iam_access_key_key_fingerprint
}

output "iam_access_key_secret" {
  value = module.iam_iam-user.iam_access_key_secret 
}

output "iam_user_arn" {
  value = module.iam_iam-user.iam_user_arn
}

output "iam_user_name" {
  value = module.iam_iam-user.iam_user_name
}

output "policy_arns" {
  value = module.iam_iam-user.policy_arns   
}