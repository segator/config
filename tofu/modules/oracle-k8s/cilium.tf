locals {
  cilium_values = templatefile("${path.module}/files/helm-cilium-values.tpl.yaml",
    {
      loadBalancerIP = local.nlb_public_ip
      insecureNodePort = local.ports[index(local.ports[*].name,"http")].backendPort
      secureNodePort = local.ports[index(local.ports[*].name,"https")].backendPort
    }
  )
}
resource "helm_release" "cilium" {
  //depends_on = [local_sensitive_file.kubeconfig]
  depends_on = [oci_containerengine_node_pool.k8s_node_pool]
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = "1.17.2"
  create_namespace = true
  wait = true
  wait_for_jobs = true

  values = [local.cilium_values]
}

# resource "local_sensitive_file" "kubeconfig" {
#   filename = "/tmp/${var.cluster_name}.kubeconfig"
#   content  = data.oci_containerengine_cluster_kube_config.k8s_cluster.content
# }
#
# resource "null_resource" "delete_cilium_pods" {
#   depends_on = [local_sensitive_file.kubeconfig]
#   triggers = {
#     script_content = md5(file("${path.module}/files/cilium-delete-pods.sh"))
#     helm_release_id = helm_release.cilium.id
#   }
#   # Use a local-exec provisioner to run the shell script.
#   provisioner "local-exec" {
#     interpreter = ["/bin/env", "bash", "-c"]
#     command = "${path.module}/files/cilium-delete-pods.sh"
#
#     environment = {
#       KUBECONFIG = local_sensitive_file.kubeconfig.filename
#     }
#
#   }
# }

resource "kubernetes_cluster_role_v1" "network_cleanup" {
  depends_on = [helm_release.cilium]
  metadata {
    name = "network-cleanup"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs      = ["get", "list", "delete"]
  }
  rule {
    api_groups = ["cilium.io"]
    resources  = ["ciliumendpoints"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_service_account_v1" "network_cleanup" {
  depends_on = [helm_release.cilium]
  metadata {
    name      = "network-cleanup"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding_v1" "network_cleanup" {
  depends_on = [kubernetes_cluster_role_v1.network_cleanup]
  metadata {
    name = "network-cleanup"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.network_cleanup.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.network_cleanup.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map_v1" "cleanup_script" {
  depends_on = [helm_release.cilium]
  metadata {
    name      = "network-cleanup-script"
    namespace = "kube-system"
  }

  data = {
    "cleanup.sh" = file("${path.module}/files/cilium-delete-pods.sh")
  }
}

resource "kubernetes_job_v1" "network_cleanup" {
  depends_on = [helm_release.cilium, kubernetes_cluster_role_binding_v1.network_cleanup, kubernetes_config_map_v1.cleanup_script]
  lifecycle {
    replace_triggered_by = [helm_release.cilium.id]
  }
  metadata {
    name      = "network-cleanup"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {
        name = "network-cleanup"
      }
      spec {
        container {
          name    = "kubectl"
          image   = "bitnami/kubectl:latest"
          command = ["bash", "-c","/scripts/cleanup.sh" ]


          volume_mount {
            name       = "script-volume"
            mount_path = "/scripts"
          }
        }
        volume {
          name = "script-volume"
          config_map {
            name = kubernetes_config_map_v1.cleanup_script.metadata[0].name
            default_mode = "0755"
          }
        }
        restart_policy = "Never"
        service_account_name = kubernetes_service_account_v1.network_cleanup.metadata[0].name
      }
    }
    backoff_limit = 30
    #ttl_seconds_after_finished = 900
  }
  wait_for_completion = true
}