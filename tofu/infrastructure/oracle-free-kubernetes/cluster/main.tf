module "cluster" {
  source = "../../../modules/oracle-k8s"
  cluster_name = var.cluster_name
  compartment_id         = var.compartment_id
  region                 = var.region
  ssh_public_key         = var.ssh_public_key
  kubernetes_version     = var.kubernetes_version
  kubernetes_worker_nodes = var.kubernetes_worker_nodes
  image_id               = var.image_id
  cloudflare_zone_id = var.cloudflare_zone_id
}

output "kube_config" {
  value = module.cluster.kube_config
}
output "k8s_cluster_id" {
  value = module.cluster.k8s_cluster_id
}

output "public_subnet_id" {
  value = module.cluster.public_subnet_id
}

output "node_pool_id" {
  value = module.cluster.node_pool_id
}


output "cluster_name" {
  value = module.cluster.cluster_name
}

output "base_domain" {
  value = module.cluster.base_domain
}

output "nlb_node_ports" {
  value = module.cluster.nlb_node_ports
}
output "nlb_public_ip" {
  value =  module.cluster.nlb_public_ip
}

output "nlb_ocid" {
  value = module.cluster.nlb_ocid
}