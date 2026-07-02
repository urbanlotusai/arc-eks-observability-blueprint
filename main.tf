# ═══════════════════════════════════════════════════════════════════════════════
# 1. KMS — root of the encryption trust chain
#    Outputs consumed by: module.eks (secrets encryption), module.s3
# ═══════════════════════════════════════════════════════════════════════════════
module "kms" {
  source = "./modules/01-kms"

  alias                   = local.kms_alias
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${local.name_prefix} EKS cluster and observability stack"
  deletion_window_in_days = var.kms_deletion_window

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 2. S3 — long-term log archive from the observability stack
#    Outputs consumed by: (Fluent Bit / Fluentd writes directly via IAM role)
# ═══════════════════════════════════════════════════════════════════════════════
module "s3" {
  source = "./modules/02-s3"

  name = local.log_bucket

  server_side_encryption_config_data = {
    bucket_key_enabled = true
    sse_algorithm      = "aws:kms"
    kms_master_key_id  = module.kms.key_arn
  }

  public_access_config = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Network — VPC + public/private subnets for EKS
#    Outputs consumed by: module.eks, module.observability_stack
# ═══════════════════════════════════════════════════════════════════════════════
module "network" {
  source = "./modules/03-network"

  name        = local.name_prefix
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.vpc_cidr

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 4. Security Group — cluster-level SG; nodes inherit from the managed group
#    Outputs consumed by: module.eks (vpc_config)
# ═══════════════════════════════════════════════════════════════════════════════
module "security_group" {
  source = "./modules/04-security-group"

  name        = "${local.name_prefix}-eks-cluster"
  description = "Additional security group for the EKS cluster control plane"
  vpc_id      = module.network.vpc_id

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

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 5. EKS — Kubernetes cluster with managed node groups
#    Outputs consumed by: module.eks_addons, module.observability_stack
# ═══════════════════════════════════════════════════════════════════════════════
module "eks" {
  source = "./modules/05-eks"

  name        = local.cluster_name
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  vpc_config = {
    vpc_id             = module.network.vpc_id
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [module.security_group.id]
  }

  # Encrypt Kubernetes secrets with the CMK
  cluster_encryption_config = [
    {
      provider_key_arn = module.kms.key_arn
      resources        = ["secrets"]
    }
  ]

  # Managed node group
  managed_node_groups = {
    observability = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      disk_size      = 50
    }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 6. EKS Addons — VPC CNI, CoreDNS, kube-proxy, EBS CSI (required for PVCs)
#    Outputs consumed by: (none — addons are cluster-level)
# ═══════════════════════════════════════════════════════════════════════════════
module "eks_addons" {
  source = "./modules/06-eks-addon"

  cluster_name = module.eks.cluster_id

  addons = {
    vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
    coredns            = { addon_version = "v1.11.1-eksbuild.4" }
    kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
    aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 7. Observability Stack — EFK (OpenSearch) + Prometheus + Grafana on EKS
#    Deploys via Helm into the running EKS cluster
#    S3 bucket wired as long-term log archive destination
# ═══════════════════════════════════════════════════════════════════════════════
module "observability_stack" {
  source = "./modules/07-observability"

  namespace   = var.namespace
  environment = var.environment

  # Log aggregation backend
  search_engine  = var.search_engine  # "opensearch"
  log_aggregator = var.log_aggregator # "fluent-bit"

  # Metrics stack
  metrics_monitoring_system = var.metrics_monitoring_system # "prometheus"

  # OpenSearch / Elasticsearch config (in-cluster)
  elasticsearch_config = {
    name = "${local.name_prefix}-opensearch"
  }

  # Fluent Bit config — ships container logs to OpenSearch + S3
  fluentbit_config = {
    k8s_namespace = {
      create = true
      name   = "logging"
    }
  }

  # Prometheus + Grafana config
  prometheus_config = {
    name = "${local.name_prefix}-prometheus"
    alertmanager_config = {
      name = "${local.name_prefix}-alertmanager"
    }
  }

  tags = local.tags

  depends_on = [module.eks_addons]
}
