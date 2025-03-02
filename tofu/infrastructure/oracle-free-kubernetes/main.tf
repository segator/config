module "cluster" {
  source = "../../modules/oracle-k8s"
  cluster_name = var.cluster_name
  compartment_id         = var.compartment_id
  region                 = var.region
  ssh_public_key         = var.ssh_public_key
  kubernetes_version     = var.kubernetes_version
  kubernetes_worker_nodes = var.kubernetes_worker_nodes
  image_id               = var.image_id
  cloudflare_zone_id = var.cloudflare_zone_id
}

resource "local_file" "k8s_cluster_config" {
  content  = module.cluster.kube_config
  filename = "${path.module}/oci.kubeconfig"
}

module "vault" {
  source         = "../../modules/oracle-vault"
  compartment_id = var.compartment_id
  vault_name     = "k8s-vault"
}

module "flux" {
  source = "../../modules/kube-fluxcd"
  github_org = var.github_org
  cluster_name = var.cluster_name
  gitops_repo = var.github_reponame
  kube_config = local_file.k8s_cluster_config.filename
  cluster_context = merge(
    { for port in module.cluster.nlb_details.node_ports : "${port.name}_nodeport" => port.backendPort },
    {
      base_domain = module.cluster.nlb_details.base_domain
      external_nlb_ocid = module.cluster.nlb_details.ocid
      external_nlb_ip = tostring(module.cluster.nlb_details.ip_address)
    })
}
#
# module "kube-external-secrets" {
#   source         = "./kube-external-secrets"
#   region = var.region
#   vault_id       = module.vault.vault_id
#   group_id = module.vault.admin_vault_group_id
#   tenancy_id = var.compartment_id # we use the compartment_id as tenancy_id
#   compartment_id = var.compartment_id
#   mail           = var.mail
# }

output "kube_config" {
  value = local_file.k8s_cluster_config.filename
}