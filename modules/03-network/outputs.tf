output "vpc_id" {
  description = "ID of the EKS VPC."
  value       = module.network.vpc_id
}
