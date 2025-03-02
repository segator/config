data "talos_image_factory_extensions_versions" "image" {
  talos_version = var.talos_version
  filters = {
    names = [
      "iscsi-tools",
      "qemu-guest-agent",
      "util-linux-tools"

    ]
  }
}

resource "talos_image_factory_schematic" "image" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.image.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "amd64" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.image.id
  platform      = "nocloud"
  architecture = "amd64"
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_iso" {
  for_each = { for node in var.proxmox_vms : node.proxmox_node => node }
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  file_name               = "talos-${var.talos_version}-nocloud-amd64.iso"
  url                     = data.talos_image_factory_urls.amd64.urls.iso
  #"https://factory.talos.dev/image/${talos_image_factory_schematic.image.id}/${var.talos_version}/nocloud-amd64.raw.gz"
  #decompression_algorithm = "zst"
  overwrite               = false
}



resource "proxmox_virtual_environment_vm" "talos_vm" {
  for_each = { for vm_name in var.proxmox_vms : vm_name.name => vm_name }


    name        = each.key
    description = "Managed by Terraform"
    tags        = ["k8s"]
    node_name   = each.value.proxmox_node
    on_boot     = true
    started = true
    machine = "q35"

    cpu {
      cores = each.value.cpu
      type = "host"
    }

    memory {
      dedicated = each.value.memory
    }

    agent {
      enabled = true
    }

    network_device {
      model = "virtio"
      bridge = "vmbr0"
      #vlan_id = 40
    }
    cdrom {
      file_id = proxmox_virtual_environment_download_file.talos_nocloud_iso[each.value.proxmox_node].id
    }
    disk {
      datastore_id = "local-zfs"
      interface    = "virtio0"
      file_format = "raw"
      ssd          = true
      discard      = "on"
      cache        = "writeback"
      iothread     = true
      size         = each.value.disk_size
    }

    operating_system {
      type = "l26"
    }
    tablet_device = false
    initialization {
     datastore_id = "local-zfs"
      ip_config {
        ipv4 {
          address = "${each.value.ip_addr}/24"
          gateway = "192.168.0.1"
        }
      }
    }
  }