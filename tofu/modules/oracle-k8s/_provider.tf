terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.27.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    # kubernetes = {
    #   source =  "hashicorp/kubernetes"
    #   version = "~> 2.35"
    # }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = local_sensitive_file.kubeconfig.filename
  }
}
