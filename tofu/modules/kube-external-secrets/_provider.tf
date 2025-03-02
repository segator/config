terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}
