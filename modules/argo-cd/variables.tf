variable "cluster_name" {
  type = string
}

variable "argocd-values" {
  type        = string
}

variable "argocd-secret-values" {
  type        = string
}

variable "argocd-init-app-values" {
  type        = string
}
