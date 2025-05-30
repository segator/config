terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    age = {
      source = "clementblaise/age"
      version = ">= 0.1"
    }
  }
}

resource "local_sensitive_file" "kubeconfig" {
  content  = var.kube_config
  filename = "/tmp/${var.cluster_name}.kubeconfig"
}

provider "flux" {
  kubernetes = {
    config_path = local_sensitive_file.kubeconfig.filename
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.gitops_repo}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}