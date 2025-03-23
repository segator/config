resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = format("Flux %s",var.gitops_repo)
  repository = var.gitops_repo
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}