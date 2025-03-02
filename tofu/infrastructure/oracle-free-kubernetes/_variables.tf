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

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string

  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBPjsPbPbEsCywcFfS24iBUV1ISMM+5Yk0eqWuaNSP8YqjgPkJU5K62Pm8tRYUpfoP2mkF5zdT3Zj+6kMtqxkACcvQDui71PzIVQx57AE4wcvsEYXqLYNpvHl/YEdf7fCNvsXounnJjYSHbjRPjTcq+34CgedCVFL5MYXpdRmc5Kl1Do8JscYm5AzVOhfRJJ0Fiqd4bkRMpJN5zYZ+NYw/cnSKFckSTsG4pSbcSCoR1wPNRU6rEPXSQa2hFZPpYORuxKcwua/bb3aRzyU1fT7xdjzkDs++0rQJQ461kvBjsYgD5Zuwgl3MkzouVx2p5ic1dU34kQTrWpH3z5diRut7 ull@rsa"
}

variable "kubernetes_version" {
  # https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
  description = "Version of Kubernetes"
  type        = string

  default = "v1.29.1"
}

variable "kubernetes_worker_nodes" {
  description = "Worker node count"
  type        = number

  default = 2
}

# TODO: search for latest image
variable "image_id" {
  # https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-8x/
  description = "OCID of the latest oracle linux"
  type        = string

  # Oracle-Linux-8.9-aarch64-2024.01.26-0-OKE-1.29.1-679 // 21.02.2024
  default = "ocid1.image.oc1.eu-paris-1.aaaaaaaawbohiyf7sxa2jh25g2377jpiqoljpgelc3wzapghbrh4yhtr3hua"
}

variable "mail" {
  description = "The email address of the user"
  type        = string
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The ID of the Cloudflare zone"
}