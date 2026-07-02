variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_config" {
  type = any
}

variable "cluster_encryption_config" {
  type = any
}

variable "managed_node_groups" {
  type = any
}

variable "tags" {
  type = map(string)
}
