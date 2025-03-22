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