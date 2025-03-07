locals {
  nlb_ports = [
    {
      name = "http",
      port = 80
    },
    {
      name = "https",
      port = 443
    }
  ]
}
resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  cidr_block                 = "10.0.1.0/24"
  route_table_id             = var.vcn_nat_route_id
  security_list_ids          = [oci_core_security_list.private_subnet_sl.id]
  display_name               = "k8s-private-subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = var.vcn_id
  cidr_block        = "10.0.0.0/24"
  route_table_id    = var.vcn_ig_route_id
  security_list_ids = [oci_core_security_list.public_subnet_sl.id]
  display_name      = "k8s-public-subnet"
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "k8s-private-subnet-sl"

  # egress everywhere
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    stateless        = false
    source      = "0.0.0.0/0" #  As we have preserve client ip enabled, we need to allow all traffic
    source_type = "CIDR_BLOCK"
    protocol         = "6"
    description = "Allow all traffic from cluster NLB to k8s"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # ingress only from our cidr
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "k8s-public-subnet-sl"

  # egress everywhere
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # ingres only our cidr
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  # ingress from internet on k8s-api
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  dynamic "ingress_security_rules" {
    for_each =  local.nlb_ports
    content {
      stateless   = false
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      description = "Allow ${ingress_security_rules.value.name} traffic to cluster NLB"
      tcp_options {
        min = ingress_security_rules.value.port
        max = ingress_security_rules.value.port
      }
    }
  }

}
