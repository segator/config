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
resource "local_sensitive_file" "kubeconfig" {
    filename = "oci.kubeconfig"
    content = data.oci_containerengine_cluster_kube_config.k8s_cluster.content
}
provider "helm" {
  kubernetes {
    config_path    = local_sensitive_file.kubeconfig.filename
  }
}
