kubernetes_cluster_version           = "1.29.1-do.0"
kubernetes_default_pool_worker_count = 3
kubernetes_default_pool_worker_size  = "s-4vcpu-8gb"
kubernetes_default_pool_name         = "pool-infra"
kubernetes_default_pool_labels       = { "node-role/infra" : "" }
kubernetes_cluster_region            = "fra1"
env                                  = "poc"
kubernetes_pools = [{
  name       = "pool-apps-1"
  size       = "s-2vcpu-4gb"
  node_count = 3
  tags       = []
  labels = {
    "node-role/apps" : ""
  }
  taints = []
}]