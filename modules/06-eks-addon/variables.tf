variable "cluster_name" {
  type = string
}

variable "addons" {
  type = any
}

variable "tags" {
  type = map(string)
}
