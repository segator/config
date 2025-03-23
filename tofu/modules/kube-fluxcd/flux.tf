
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
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
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

resource "age_secret_key" "this" {}

resource "kubernetes_secret" "sops_age" {
  depends_on = [kubernetes_namespace.flux_system, age_secret_key.this]

  metadata {
    name      = "flux-sops-agekey"
    namespace = local.flux_namespace
    annotations = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  data = {
    "age.agekey" = age_secret_key.this.secret_key
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, kubernetes_secret.ssh_keypair]
  secret_name = local.flux_git_secret_name
  components_extra     = ["image-reflector-controller", "image-automation-controller"]
  disable_secret_creation = true
  embedded_manifests      = true
  path                    = local.gitops_path

}

resource "github_repository_file" "cluster-config" {
  repository          = var.gitops_repo
  branch              = "main"
  file                = format("%s/cluster-config.env",local.gitops_path)
  content             = templatefile("${path.module}/files/cluster-config.tpl.env", {
    cluster_context = var.cluster_context
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@noreply.com"
  overwrite_on_create = true
  autocreate_branch   = false
}

resource "github_repository_file" "cluster-kustomization" {
  repository          = var.gitops_repo
  branch              = "main"
  file                = format("%s/kustomization.yaml",local.gitops_path)
  content             = templatefile("${path.module}/files/kustomization.tpl.yaml", {
    cluster_name = var.cluster_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@noreply.com"
  overwrite_on_create = true
  autocreate_branch   = false
}