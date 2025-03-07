variable "kube_config" {
  description = "The kubeconfig file"
  type        = string
}
variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string

  default = "eu-frankfurt-1"
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "github_org" {
  description = "The github organization or username if not an org"
  type        = string
}

variable "github_reponame" {
  description = "The name of the GitHub gitops repo"
  type        = string
}


variable "mail" {
  description = "The email address of the user"
  type        = string
}



variable "base_domain" {
  type = string
}

variable "nlb_node_ports" {
    type = list(object({
        name        = string
        port = number
        backendPort = number
    }))
}

variable "nlb_public_ip" {
  type = string
}

variable "nlb_ocid" {
  type = string
}