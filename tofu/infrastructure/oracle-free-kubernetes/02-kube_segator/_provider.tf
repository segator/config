terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.27"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.35"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    helm = {
        source  = "hashicorp/helm"
        version = "~> 2.17.0"
    }
    github = {
        source  = "integrations/github"
        version = "~> 6.5"
    }
  }
}

provider "oci" {
}

provider "cloudflare" {
}

provider "helm" {
  kubernetes {
    config_path = "~"
  }
}

provider "github" {
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
}
