terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
  }
}

provider "digitalocean" {
}

module "doks-cluster" {
  source                    = "../../modules/kubernetes-cluster"
  cluster_name              = "${var.env}-k8s"
  cluster_region            = var.kubernetes_cluster_region
  cluster_version           = var.kubernetes_cluster_version
  default_pool_name         = var.kubernetes_default_pool_name
  default_pool_labels       = var.kubernetes_default_pool_labels
  default_pool_taints       = var.kubernetes_default_pool_taints
  default_pool_worker_size  = var.kubernetes_default_pool_worker_size
  default_pool_worker_count = var.kubernetes_default_pool_worker_count
  pools                     = var.kubernetes_pools
}