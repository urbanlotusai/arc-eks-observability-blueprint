module "eks" {
  source  = "sourcefuse/arc-eks/aws"
  version = "6.0.4"

  name        = var.name
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  vpc_config = var.vpc_config

  cluster_encryption_config = var.cluster_encryption_config

  managed_node_groups = var.managed_node_groups

  tags = var.tags
}
