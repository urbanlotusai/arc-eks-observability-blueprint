module "eks_addons" {
  source  = "sourcefuse/arc-eks-addon/aws"
  version = "1.0.3"

  cluster_name = var.cluster_name
  addons       = var.addons

  tags = var.tags
}
