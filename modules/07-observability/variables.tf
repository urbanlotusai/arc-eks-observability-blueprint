variable "namespace" {
  description = "Organization or team namespace"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "arc-eks-observability-blueprint"
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "search_engine" {
  description = "Log aggregation backend: elasticsearch or opensearch."
  type        = string
  default     = "opensearch"
}

variable "log_aggregator" {
  description = "Log shipper to deploy: fluent-bit or fluentd."
  type        = string
  default     = "fluent-bit"
}

variable "metrics_monitoring_system" {
  description = "Metrics stack to deploy: prometheus."
  type        = string
  default     = "prometheus"
}
