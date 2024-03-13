terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
  }
}

data "digitalocean_kubernetes_versions" "current" {
  version_prefix = var.cluster_version
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.cluster_region
  version = data.digitalocean_kubernetes_versions.current.latest_version

  node_pool {
    name       = var.default_pool_name
    size       = var.default_pool_worker_size
    node_count = var.default_pool_worker_count
    labels     = var.default_pool_labels
    dynamic "taint" {
      for_each = { for taint in var.default_pool_taints: taint.key => taint}
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }
  }
}

resource "digitalocean_kubernetes_node_pool" "pool" {
  for_each   = { for pools in var.pools: pools.name => pools}
  cluster_id = digitalocean_kubernetes_cluster.cluster.id

  name       = each.value["name"]
  size       = each.value["size"]
  node_count = each.value["node_count"]
  tags       = each.value["tags"]

  labels = each.value["labels"]

  dynamic "taint" {
    for_each = each.value.taints
    content {
      effect = taint.value.effect
      key    = taint.value.key
      value  = taint.value.value
    }
  }
}