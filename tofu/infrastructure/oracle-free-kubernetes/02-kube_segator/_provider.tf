terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.27"
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

provider "github" {
}

provider "kubernetes" {
  config_path = null
  host = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args = [
      "ce",
      "cluster",
      "generate-token",
      "--cluster-id",
      var.cluster_id
    ]
  }
}