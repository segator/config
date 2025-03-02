proxmox_vms = [
  {
    name      = "kube-1"
    proxmox_node = "ms01"
    role      = "controlplane"
    cpu       = 12
    memory    = 8192
    disk_size = 50
    ip_addr = "192.168.0.100"
  },
  {
    name      = "kube-2"
    proxmox_node = "ryzen5800"
    role      = "controlplane"
    cpu       = 8
    memory    = 8192
    disk_size = 50
    ip_addr = "192.168.0.101"
  },
  {
    name      = "kube-3"
    proxmox_node = "terra"
    role      = "controlplane"
    cpu       = 4
    memory    = 4096
    disk_size = 50
    ip_addr = "192.168.0.102"
  }
]
