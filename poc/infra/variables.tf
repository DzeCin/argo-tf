
variable "kubernetes_cluster_version" {
  type    = string
  default = "1.29.1-do.0"
}

variable "kubernetes_cluster_region" {
  type = string
}

variable "kubernetes_default_pool_name" {
  type = string
}

variable "kubernetes_default_pool_worker_count" {
  type    = number
  default = 1
}

variable "kubernetes_default_pool_labels" {
  type    = map(string)
  default = null
}

variable "kubernetes_default_pool_worker_size" {
  type    = string
  default = "s-2vcpu-4gb"
}

variable "kubernetes_default_pool_taints" {
  type = list(object({
    effect = string
    key    = string
    value  = string
  }))
  default = []
}

variable "kubernetes_pools" {
  type = list(object({
    name       = string
    size       = string
    node_count = number
    tags       = list(string)
    labels     = map(string)
    taints = list(object({
      effect = string
      key    = string
      value  = string
    }))
  }))
  default = []
}

variable "env" {
  type = string
}