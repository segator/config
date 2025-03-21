resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = "1.17.2"
  create_namespace = true
  wait = true
  wait_for_jobs = true

  values = [
    file("${path.module}/files/helm-cilium-values.yaml")
  ]
}