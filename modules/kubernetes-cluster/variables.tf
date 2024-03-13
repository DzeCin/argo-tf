variable "cluster_version" {
  type = string
}

variable "default_pool_worker_count" {
  type = number
}

variable "default_pool_worker_size" {
  type = string
}

variable "default_pool_name" {
  type = string
}

variable "default_pool_labels" {
  type    = map(string)
  default = null
}

variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "default_pool_taints" {
  type = list(object({
    effect = string
    key    = string
    value  = string
  }))
  default = []
}

variable "pools" {
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