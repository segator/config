# tofu/providers.tf
terraform {
  backend "s3" {
    bucket = "segator-homelab-tofu-state"
    key    = "kubernetes/terraform.tfstate"
    region = "eu-central-1"
    profile = "segator"
  }
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.19"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "../../secrets/infra/secrets.yaml"
}

provider "proxmox" {
  # Configure your Proxmox connection details
  endpoint = data.sops_file.secrets.data["proxmox.host"]
  #PROXMOX_VE_USERNAME
  #pm_user = data.sops_file.secrets.data["user"]
  #PROXMOX_VE_PASSWORD
  api_token = data.sops_file.secrets.data["proxmox.token"]
  insecure = true
}

#
# provider "kubernetes" {
#   host = module.talos.kube_config.kubernetes_client_configuration.host
#   client_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
#   client_key = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
#   cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
# }
#
# provider "restapi" {
#   uri                  = var.proxmox.endpoint
#   insecure             = var.proxmox.insecure
#   write_returns_object = true
#
#   headers = {
#     "Content-Type"  = "application/json"
#     "Authorization" = "PVEAPIToken=${var.proxmox.api_token}"
#   }
# }
