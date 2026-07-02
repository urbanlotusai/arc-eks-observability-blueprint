output "kms_key_arn" {
  description = "ARN of the KMS CMK used by the EKS cluster and S3 archive."
  value       = module.kms.key_arn
}

output "cluster_id" {
  description = "EKS cluster name/ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the EKS VPC."
  value       = module.network.vpc_id
}

output "log_bucket_id" {
  description = "S3 bucket name for long-term observability log archive."
  value       = module.s3.bucket_id
}

output "kubeconfig_command" {
  description = "Run this command to update your local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}
