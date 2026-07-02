# =============================================================================
# Module: 03-network
# =============================================================================
# Provisions the VPC + public/private subnets used by the EKS cluster.
# State file: modules/03-network/terraform.tfstate
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
# Network Module
# -----------------------------------------------------------------------------

module "network" {
  source  = "sourcefuse/arc-network/aws"
  version = "3.0.14"

  name        = "${var.namespace}-${var.environment}"
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.vpc_cidr

  tags = var.tags
}
