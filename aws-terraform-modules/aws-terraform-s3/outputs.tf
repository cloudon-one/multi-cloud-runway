output "bucket_ids" {
  description = "List of bucket IDs"
  value       = aws_s3_bucket.this[*].id
}

output "bucket_arns" {
  description = "List of bucket ARNs"
  value       = aws_s3_bucket.this[*].arn
}