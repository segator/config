output "vault_id" {
  description = "The OCID of the created vault"
  value       = oci_kms_vault.vault.id
}

output "admin_vault_group_id" {
  description = "The OCID of the group that can manage the vault"
  value       = oci_identity_group.vault_admin.id
}