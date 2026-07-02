# =============================================================================
# Module: 06-eks-addon
# =============================================================================
# Provisions the core EKS add-ons: VPC CNI, CoreDNS, kube-proxy, EBS CSI
# driver (required for PVCs used by OpenSearch/Prometheus).
# State file: modules/06-eks-addon/terraform.tfstate
# Depends on: 05-eks (cluster_id)
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/05-eks/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# EKS Addons Module
# -----------------------------------------------------------------------------

module "eks_addons" {
  source  = "sourcefuse/arc-eks-addon/aws"
  version = "1.0.3"

  cluster_name = data.terraform_remote_state.eks.outputs.cluster_id

  addons = {
    vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
    coredns            = { addon_version = "v1.11.1-eksbuild.4" }
    kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
    aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
  }

  tags = var.tags
}
