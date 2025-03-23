terraform {
  source = "git::https://github.com/oracle-terraform-modules/terraform-oci-vcn.git?ref=v3.6.0"
}
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vars" {
  path = find_in_parent_folders("vars.hcl")
  expose = true
}

inputs = {
  source                       = "oracle-terraform-modules/vcn/oci"
  compartment_id               = include.vars.locals.oci.compartment_id
  region                       = include.vars.locals.oci.region
  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null
  vcn_name                     = include.vars.locals.network.vcn_name
  vcn_dns_label                = include.vars.locals.network.vcn_name
  vcn_cidrs                    = [include.vars.locals.network.vcn_cidrs]
  create_internet_gateway      = true
  create_nat_gateway           = true
  create_service_gateway       = true
}