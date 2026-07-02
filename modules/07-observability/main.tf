# =============================================================================
# Module: 07-observability
# =============================================================================
# Deploys the EFK (OpenSearch) + Prometheus/Grafana observability stack onto
# the EKS cluster via the kubernetes/helm providers.
# State file: modules/07-observability/terraform.tfstate
# No cross-module remote-state dependency: this module's inputs (namespace,
# environment, search_engine, log_aggregator, metrics_monitoring_system,
# elasticsearch_config, fluentbit_config, prometheus_config) don't reference
# any other module's outputs. Apply ordering (after 05-eks/06-eks-addon) is
# handled by the Makefile's numeric directory iteration, not depends_on.
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
# Observability Stack Module
# -----------------------------------------------------------------------------

module "observability_stack" {
  source  = "sourcefuse/arc-observability-stack/aws"
  version = "1.0.2"

  namespace   = var.namespace
  environment = var.environment

  # Log aggregation backend
  search_engine  = var.search_engine
  log_aggregator = var.log_aggregator

  # Metrics stack
  metrics_monitoring_system = var.metrics_monitoring_system

  # OpenSearch / Elasticsearch config (in-cluster)
  elasticsearch_config = {
    name = "${var.namespace}-${var.environment}-opensearch"
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
    name = "${var.namespace}-${var.environment}-prometheus"
    alertmanager_config = {
      name = "${var.namespace}-${var.environment}-alertmanager"
    }
  }

  tags = var.tags
}
