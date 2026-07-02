# =============================================================================
# Module: 04-security-group
# =============================================================================
# Provisions the additional security group attached to the EKS cluster
# control plane. Node groups inherit the cluster-managed security group.
# State file: modules/04-security-group/terraform.tfstate
# Depends on: 03-network (vpc_id)
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

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/03-network/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# Security Group Module
# -----------------------------------------------------------------------------

module "security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.5"

  name        = "${var.namespace}-${var.environment}-eks-cluster"
  description = "Additional security group for the EKS cluster control plane"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [] # EKS manages control-plane SG rules; extend here if needed

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.tags
}
