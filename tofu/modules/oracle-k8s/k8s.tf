resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  # cluster_pod_network_options {
  #   cni_type = "OCI_VCN_IP_NATIVE"  # Use VCN-Native Pod Networking
  # }
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.vcn_public_subnet.id
  }
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [oci_core_subnet.vcn_public_subnet.id]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "k8s-node-pool"

  node_metadata = {
    user_data = base64encode(file("${path.module}/files/node-pool-init.sh"))
  }

  node_config_details {
    # node_pool_pod_network_option_details {
    #   cni_type = "OCI_VCN_IP_NATIVE"
    #   pod_subnet_ids = [oci_core_subnet.vcn_private_subnet.id]
    # }
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    size = var.kubernetes_worker_nodes
  }

  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }
  node_source_details {
    image_id    = var.image_id
    source_type = "image"

    boot_volume_size_in_gbs = 100
  }

  ssh_public_key = var.ssh_public_key
}

# resource oci_containerengine_addon disabled_addon {
#   for_each = toset(["KubeProxy","KubernetesDashboard","OciVcnIpNative"])
#   addon_name                       = each.key
#   cluster_id                       = oci_containerengine_cluster.k8s_cluster.id
#   remove_addon_resources_on_delete = "true"
# }

data "oci_containerengine_cluster_kube_config" "k8s_cluster" {
  depends_on = [oci_containerengine_cluster.k8s_cluster]
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
}
