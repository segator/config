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

output "nlb_details" {
  value = {
    ocid         = oci_network_load_balancer_network_load_balancer.oke_nlb.id
    ip_address = local.nlb_public_ip
    node_ports   = local.ports
    base_domain  = local.base_domain
  }
}