dependency "cluster" {
  config_path = "../01-oracle-k8s"
  mock_outputs_allowed_terraform_commands = [ "plan" ]
  mock_outputs = {
    kube_config_path = "./kubefake.config"
    cluster_name = "cluster_name"
    base_domain = "mock.com"
    nlb_node_ports = [
      {
        name        = "http"
        port        = 80
        backendPort = 1000
      }
    ]
    nlb_public_ip = "127.0.0.1"
    nlb_ocid = "nlb-ocid"
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
  cluster_name = dependency.cluster.outputs.cluster_name

  base_domain = dependency.cluster.outputs.base_domain
  nlb_node_ports = dependency.cluster.outputs.nlb_node_ports
  nlb_public_ip = dependency.cluster.outputs.nlb_public_ip
  nlb_ocid = dependency.cluster.outputs.nlb_ocid


}




