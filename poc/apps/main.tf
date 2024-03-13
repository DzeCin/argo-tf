terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
  }
}


data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.cluster.endpoint
  token = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.cluster.endpoint
    token = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

module "argocd" {
  source               = "../../modules/argo-cd"
  cluster_name         = var.cluster_name
  argocd-values        = abspath(var.argocd-values)
  argocd-secret-values = abspath(var.argocd-secret-values)
  argocd-init-app-values = abspath(var.argocd-init-app-values)
}