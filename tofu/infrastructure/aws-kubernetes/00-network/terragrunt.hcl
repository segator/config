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

inputs = {
    vpc_name = include.vars.locals.network.vpc_name
    vpc_cidr = include.vars.locals.network.vpc_cidr
    private_subnet_cidrs = include.vars.locals.network.private_subnet_cidrs
    private_subnet_tags = include.vars.locals.network.private_subnet_tags
    public_subnet_cidrs = include.vars.locals.network.public_subnet_cidrs
    public_subnet_tags = include.vars.locals.network.public_subnet_tags
}