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

output "k8s_cluster_endpoint" {
  value = yamldecode(data.oci_containerengine_cluster_kube_config.k8s_cluster.content).clusters[0].cluster.server
}

output "k8s_cluster_ca_certificate" {
  value = yamldecode(data.oci_containerengine_cluster_kube_config.k8s_cluster.content).clusters[0].cluster.certificate-authority-data
}

output "cluster_name" {
  value = oci_containerengine_cluster.k8s_cluster.name
}
output "base_domain" {
  value = local.base_domain
}

output "nlb_public_ip" {
  value =  local.nlb_public_ip
}

