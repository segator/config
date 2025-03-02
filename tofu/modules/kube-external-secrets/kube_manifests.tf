
locals {
  namespace = "external-secrets"
  vault_oci_secret_name = "oci-vault"
  cluster_secret_store_name = "oracle-vault"
}
resource "kubernetes_namespace" "eso" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_secret" "eso_oci_vault" {
  metadata {
    name = local.vault_oci_secret_name
    namespace = local.namespace
  }
  data = {
    privateKey = base64encode(tls_private_key.external_secrets.private_key_pem)
    fingerprint = base64encode(oci_identity_api_key.external_secrets.fingerprint)
  }
}

resource "kubernetes_manifest" "eso_cluster_secret_store" {
  manifest = yamldecode(templatefile("${path.module}/files/eso_cluster_secret_store.yaml", {
    cluster_secret_store_name = local.cluster_secret_store_name
    namespace = local.namespace
    vault_id = var.vault_id
    region = var.region
    user_id = oci_identity_user.external_secrets.id
    tenancy_id = var.tenancy_id
    vault_oci_secret_name = local.vault_oci_secret_name
  }))
}