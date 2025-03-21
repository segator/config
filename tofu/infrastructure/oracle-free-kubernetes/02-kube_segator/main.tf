
# module "vault" {
#   source         = "../../../modules/oracle-vault"
#   compartment_id = var.compartment_id
#   vault_name     = "k8s-vault"
# }

module "flux" {
  source = "../../../modules/kube-fluxcd"
  github_org = var.github_org
  cluster_name = var.cluster_name
  gitops_repo = var.github_reponame
  kube_config = var.kube_config
  cluster_context = merge(
    { for port in var.nlb_node_ports : "${port.name}_nodeport" => port.backendPort },
    {
      base_domain = var.base_domain
      external_nlb_ocid = var.nlb_ocid
      external_nlb_ip = var.nlb_public_ip
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