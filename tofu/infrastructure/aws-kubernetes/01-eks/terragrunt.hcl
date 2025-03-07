terraform {
  source = "."
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
    vpc_id = "mock-vcn"
    private_subnet_ids = ["10.10.10.0/24"]

  }
}

inputs = {
  vpc_id = dependency.network.outputs.vpc_id
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  cluster_name         = include.vars.locals.eks.name
  instance_type        = include.vars.locals.eks.instance_type
  desired_capacity     = include.vars.locals.eks.desired_capacity
  ami_id               = include.vars.locals.eks.ami_id
  min_size             = include.vars.locals.eks.min_size
  max_size             = include.vars.locals.eks.max_size
  kubernetes_version   = include.vars.locals.eks.kubernetes_version
}