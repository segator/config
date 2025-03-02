resource "oci_kms_vault" "vault" {
  compartment_id = var.compartment_id
  display_name   = var.vault_name
  vault_type     = "DEFAULT"
}

resource "oci_identity_group" "vault_admin" {
  compartment_id = var.compartment_id
  description    = "VaultAdmins"
  name           = "VaultAdmins"
}

resource "oci_identity_policy" "vault_admin_policy" {
  compartment_id = var.compartment_id
  description    = "allow vault management"
  name           = "VaultAdmins"
  statements = [
    format("Allow group 'Default'/'%s' to manage secret-family in tenancy where target.vault.id = '%s'", oci_identity_group.vault_admin.name, oci_kms_vault.vault.id),
    format("Allow group 'Default'/'%s' to manage vaults in tenancy where target.vault.id = '%s'", oci_identity_group.vault_admin.name, oci_kms_vault.vault.id)
  ]
}

