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

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "ms01"
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = data.talos_image_factory_urls.amd64.urls.disk_image
  #"https://factory.talos.dev/image/${talos_image_factory_schematic.image.id}/${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "zst"
  overwrite               = false
}