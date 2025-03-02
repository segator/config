
variable "github_org" {
  description = "The name of the GitHub repository to create"
  type        = string
}

variable "gitops_repo" {
    description = "The name of the GitHub gitops repo"
    type        = string
    }

variable "cluster_name" {
    description = "The name of the cluster"
    type        = string
    }

variable "kube_config" {
    description = "The kubeconfig file"
    type        = string
}

variable "cluster_context" {
  description = "Map of parameters for flux substitution"
  type        = map(any)
  default     = {}
}