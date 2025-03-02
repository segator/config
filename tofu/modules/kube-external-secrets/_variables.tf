variable "region" {
  description = "OCI region"
  type        = string
}
variable "compartment_id" {
  description = "The compartment to create the resources in"
  type        = string
}
variable "tenancy_id" {
  description = "Tenancy OCID"
  type        = string
}

variable "group_id" {
  description = "The OCID of the group to assign the policy to"
  type        = string
}

variable "vault_id" {
  description = "The OCID of the Vault to store the secrets in"
  type        = string
}

variable "mail" {
  description = "The email address of the user"
  type        = string
}