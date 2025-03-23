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
  depends_on = [local_sensitive_file.kubeconfig]
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

resource "null_resource" "delete_cilium_pods" {
  depends_on = [local_sensitive_file.kubeconfig]
  triggers = {
    script_content = md5(file("${path.module}/files/cilium-delete-pods.sh"))
    helm_release_id = helm_release.cilium.id
  }
  # Use a local-exec provisioner to run the shell script.
  provisioner "local-exec" {
    interpreter = ["/bin/env", "bash", "-c"]
    command = "${path.module}/files/cilium-delete-pods.sh"

    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }

  }
}