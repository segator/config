dependency "cluster" {
  config_path = "../01-oracle-k8s"
  mock_outputs_allowed_terraform_commands = [ "plan" ]
  mock_outputs = {
    kube_config_path = "./kubefake.config"
    cluster_name = "cluster_name"
    base_domain = "mock.com"
    nlb_public_ip = "127.0.0.1"
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vars" {
  path = find_in_parent_folders("vars.hcl")
  expose = true
}


inputs = {
  # Local vars
  compartment_id = include.vars.locals.oci.compartment_id
  region = include.vars.locals.oci.region
  github_org = include.vars.locals.github.org
  github_reponame = include.vars.locals.github.reponame
  mail = include.vars.locals.github.mail
  # dependencies
  kube_config = dependency.cluster.outputs.kube_config
  cluster_endpoint = dependency.cluster.outputs.k8s_cluster_endpoint
  cluster_ca_certificate = dependency.cluster.outputs.k8s_cluster_ca_certificate
  cluster_id = dependency.cluster.outputs.k8s_cluster_id
  cluster_name = dependency.cluster.outputs.cluster_name

  base_domain = dependency.cluster.outputs.base_domain
  nlb_public_ip = dependency.cluster.outputs.nlb_public_ip
}




