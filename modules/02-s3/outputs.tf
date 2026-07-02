output "bucket_id" {
  description = "S3 bucket name for the long-term observability log archive."
  value       = module.s3.bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN for the long-term observability log archive."
  value       = module.s3.bucket_arn
}
