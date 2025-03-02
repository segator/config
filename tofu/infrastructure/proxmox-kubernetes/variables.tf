# tofu/variables.tf
variable "talos_version" {
    type    = string
    default = "v1.9.4"
}
variable "kubernetes_version" {
  type    = string
  default = "1.32.0"
}
variable "proxmox_vms" {
    description = "List of Proxmox nodes and their VM configurations"
    type = list(object({
            name      = string
            proxmox_node = string
            role      = string
            cpu       = number
            memory    = number
            disk_size = number
            ip_addr = string
    }))
}