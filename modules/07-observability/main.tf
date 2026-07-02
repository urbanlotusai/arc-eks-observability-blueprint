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
  elasticsearch_config = var.elasticsearch_config

  # Fluent Bit config — ships container logs to OpenSearch + S3
  fluentbit_config = var.fluentbit_config

  # Prometheus + Grafana config
  prometheus_config = var.prometheus_config

  tags = var.tags
}
