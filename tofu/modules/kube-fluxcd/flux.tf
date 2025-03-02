
locals {
  flux_namespace = "flux-system"
  flux_git_secret_name = "flux-gitops"
  gitops_path = "gitops/clusters/${var.cluster_name}"

}
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = local.flux_namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "ssh_keypair" {
  metadata {
    name      = local.flux_git_secret_name
    namespace = local.flux_namespace
  }

  type = "Opaque"

  data = {
    "identity.pub" = tls_private_key.flux.public_key_openssh
    "identity"     = tls_private_key.flux.private_key_pem
    "known_hosts"  = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }

  depends_on = [kubernetes_namespace.flux_system]
}


resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, kubernetes_secret.ssh_keypair]
  secret_name = local.flux_git_secret_name
  components_extra     = ["image-reflector-controller", "image-automation-controller"]
  disable_secret_creation = true
  embedded_manifests      = true
  path                    = local.gitops_path
}

resource "github_repository_file" "values" {
  repository          = var.gitops_repo
  branch              = "main"
  file                = format("%s/infrastructure.yaml",local.gitops_path)
  content             = templatefile("${path.module}/files/infrastructure-kustomize.yaml", {
    substitutions = var.cluster_context
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@noreply.com"
  overwrite_on_create = true
  autocreate_branch   = false
}