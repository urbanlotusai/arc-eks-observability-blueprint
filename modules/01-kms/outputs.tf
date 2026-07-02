output "key_arn" {
  description = "ARN of the KMS CMK used by the EKS cluster and S3 log archive."
  value       = module.kms.key_arn
}

output "key_id" {
  description = "ID of the KMS CMK."
  value       = module.kms.key_id
}
