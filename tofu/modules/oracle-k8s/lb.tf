locals {
  ports = [
    for port in local.nlb_ports : merge(
      port,
      {
        backendPort = random_integer.ingress_nodeport[port.name].result
      }
    )
  ]
}

resource "random_integer" "ingress_nodeport" {
  for_each = { for p in local.nlb_ports : p.name => p.port }
  min      = 30000
  max      = 32767
  keepers = {
    port = each.value
  }
}

resource "oci_network_load_balancer_network_load_balancer" "oke_nlb" {
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-ingress"
  subnet_id      = oci_core_subnet.vcn_public_subnet.id
  is_private          = false
}

# --- Backend Set ---
resource "oci_network_load_balancer_backend_set" "oke_nlb_backend_set" {
  for_each =  { for p in local.ports : p.name => p }
  name                    = "${var.cluster_name}-ingress-backend-set-${each.key}"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.oke_nlb.id
  policy                  = "FIVE_TUPLE" # or other policies like "THREE_TUPLE", "TWO_TUPLE"
  is_preserve_source = true

  health_checker {
    protocol = "TCP" # Use TCP health checks for NodePort
    port     = each.value.backendPort # Use the *NodePort* for HTTP (from values.yaml)
    interval_in_millis = 10000 # optional
    retries = 3 # optional
    timeout_in_millis = 3000 # optional
  }
}

resource "oci_network_load_balancer_backend" "oke_nlb_backend" {
  for_each = merge([
    for node_idx in range(var.kubernetes_worker_nodes):
    {
      for p in local.ports :
      "${node_idx}_${p.name}" => merge(p,{
      node_idx     = node_idx
      })
    }
  ]...)
  backend_set_name         = oci_network_load_balancer_backend_set.oke_nlb_backend_set[each.value.name].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.oke_nlb.id
  port                     = each.value.backendPort
  target_id                = oci_containerengine_node_pool.k8s_node_pool.nodes[each.value.node_idx].id
  is_backup                = false
  is_drain                 = false
  is_offline               = false
  name                     = "${var.cluster_name}-${each.key}-backend"
  weight                   = 1
}

resource "oci_network_load_balancer_listener" "oke_nlb_listener" {
  for_each = { for p in local.nlb_ports : p.name => p.port }
  name                     = "${var.cluster_name}-${each.key}-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.oke_nlb.id
  default_backend_set_name = oci_network_load_balancer_backend_set.oke_nlb_backend_set[each.key].name
  port                     = each.value
  protocol                 = "TCP" # Convert the key to uppercase to match the protocol (HTTP/HTTPS)
}

locals {
  nlb_public_ip =  join(",", [for ip in oci_network_load_balancer_network_load_balancer.oke_nlb.ip_addresses : ip.ip_address if ip.is_public == true])
}