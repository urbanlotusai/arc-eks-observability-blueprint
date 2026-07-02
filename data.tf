# ── Account identity ──────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}

# ── KMS key policy ────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRoot"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # EKS requires GenerateDataKey to encrypt secrets
  statement {
    sid    = "AllowEKS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

# ── EKS cluster auth token (used by kubernetes + helm providers) ──────────────
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id

  depends_on = [module.eks]
}

# ── Private subnets for EKS node groups ──────────────────────────────────────
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.network.vpc_id]
  }
  tags = {
    Type = "private"
  }

  depends_on = [module.network]
}
