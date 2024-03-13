terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
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

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = "argo"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "6.6.0"
  force_update     = true
  timeout          = 600

  values = ["${file("${var.argocd-values}")}", "${file("${var.argocd-secret-values}")}"]
}

resource "helm_release" "argocd_apps" {
  chart            = "argocd-apps"
  name             = "argocd-apps"
  namespace        = helm_release.argocd.namespace
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "1.6.2"
  force_update     = true
  timeout          = 600

  values = ["${file("${var.argocd-init-app-values}")}"]

  depends_on = [
    helm_release.argocd,
  ]
}