output "id" {
  description = "ID of the additional EKS cluster control-plane security group."
  value       = module.security_group.id
}
