output "keyring_ids" {
  value = { for r, ring in google_kms_key_ring.ring : r => ring.id }
}

output "key_ids" {
  description = "region/service => crypto key id (wire as service_encryption_key_ids)"
  value       = { for rk, key in google_kms_crypto_key.key : rk => key.id }
}
