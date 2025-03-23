terraform {
  source = "../../../modules/oracle-k8s"
}


include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vars" {
  path = find_in_parent_folders("vars.hcl")
  expose = true
}

dependency "network" {
  config_path = "../00-network"

  mock_outputs = {
    vcn_id = "mock-vcn"
    nat_route_id = "mock_nat_route_id"
    ig_route_id = "mock_ig_route_id"
  }
}

inputs = {
  # Dependencies
  vcn_id = dependency.network.outputs.vcn_id
  vcn_nat_route_id = dependency.network.outputs.nat_route_id
  vcn_ig_route_id = dependency.network.outputs.ig_route_id

  # Variables
  compartment_id = include.vars.locals.oci.compartment_id
  region = include.vars.locals.oci.region
  cluster_name = include.vars.locals.cluster.name
  kubernetes_version = include.vars.locals.cluster.kubernetes_version
  kubernetes_worker_nodes = include.vars.locals.cluster.kubernetes_worker_nodes
  ssh_public_key = include.vars.locals.cluster.ssh_public_key
  # oracle linux 8 aarch64-2024.11.30-0 1.31.1
  image_id = include.vars.locals.cluster.image_id
  mail = include.vars.locals.github.mail
  cloudflare_zone_id = include.vars.locals.dns.cloudflare_zone_id
}