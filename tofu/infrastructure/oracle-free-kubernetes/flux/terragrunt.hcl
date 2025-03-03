dependency "cluster" {
  config_path = "../cluster"
}

inputs = {
  k8s_cluster_id = dependency.cluster.outputs.k8s_cluster_id
  public_subnet_id = dependency.cluster.outputs.public_subnet_id
  node_pool_id = dependency.cluster.outputs.node_pool_id
  cluster_name = dependency.cluster.outputs.cluster_name
  base_domain = dependency.cluster.outputs.base_domain
  nlb_node_ports = dependency.cluster.outputs.nlb_node_ports
  nlb_public_ip = dependency.cluster.outputs.nlb_public_ip
  nlb_ocid = dependency.cluster.outputs.nlb_ocid
}
