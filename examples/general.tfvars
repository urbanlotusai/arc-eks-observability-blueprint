environment = "prod"
namespace   = "myorg"

kubernetes_version  = "1.29"
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
search_engine       = "opensearch"
log_aggregator      = "fluent-bit"
metrics_monitoring_system = "prometheus"
