terraform {

  backend "s3" {
    bucket = "segator-homelab-tofu-state"
    key    = "kubernetes/free-oraclecloud-cluster.tfstate"
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
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
}

provider "cloudflare" {
}


