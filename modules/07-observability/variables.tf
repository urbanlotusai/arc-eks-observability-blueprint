variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "search_engine" {
  type = string
}

variable "log_aggregator" {
  type = string
}

variable "metrics_monitoring_system" {
  type = string
}

variable "elasticsearch_config" {
  type = any
}

variable "fluentbit_config" {
  type = any
}

variable "prometheus_config" {
  type = any
}

variable "tags" {
  type = map(string)
}
