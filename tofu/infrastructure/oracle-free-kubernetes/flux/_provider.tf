terraform {

  backend "s3" {
    bucket = "segator-homelab-tofu-state"
    key    = "kubernetes/free-oraclecloud-flux.tfstate"
    region = "eu-central-1"
    profile = "segator"
  }

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
  config_file_profile = "DEFAULT"
}

provider "cloudflare" {
}

provider "helm" {
  kubernetes {
    config_path = "./oci.kubeconfig"
  }
}

provider "github" {
}

provider "kubernetes" {
  config_path    = "./oci.kubeconfig"
}
