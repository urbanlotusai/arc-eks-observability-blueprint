# ── Mandatory ─────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)."
  type        = string
}

variable "namespace" {
  description = "Project or team namespace used as a resource name prefix."
  type        = string
}

# ── Optional ──────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 6
}

variable "compliance_profile" {
  description = "Compliance overlay: 'general' (default) or 'hipaa' (365-day log retention)."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa"], var.compliance_profile)
    error_message = "compliance_profile must be general or hipaa."
  }
}

variable "log_retention_days" {
  description = "CloudWatch and S3 log retention in days. Overridden to 365 when compliance_profile = hipaa."
  type        = number
  default     = 90
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

variable "kms_deletion_window" {
  description = "Days before a scheduled KMS key deletion takes effect (7–30)."
  type        = number
  default     = 30
}
