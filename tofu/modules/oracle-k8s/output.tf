output "k8s_cluster_id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}

output "public_subnet_id" {
  value = oci_core_subnet.vcn_public_subnet.id
}

output "node_pool_id" {
  value = oci_containerengine_node_pool.k8s_node_pool.id
}
output "kube_config" {
  value = data.oci_containerengine_cluster_kube_config.k8s_cluster.content
}

output "cluster_name" {
  value = oci_containerengine_cluster.k8s_cluster.name
}
output "base_domain" {
  value = local.base_domain
}

output "nlb_node_ports" {
  value = local.ports
}
output "nlb_public_ip" {
  value =  local.nlb_public_ip
}

output "nlb_ocid" {
  value = oci_network_load_balancer_network_load_balancer.oke_nlb.id
}
