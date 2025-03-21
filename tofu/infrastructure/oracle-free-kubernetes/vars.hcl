locals {
  network = {
    vcn_name = "vcn"
    vcn_cidrs = "10.0.0.0/16"
  }

  oci = {
    region = "eu-paris-1"
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaa632rwujtjzylpjcumkk5jxcsivcfryhcqxg7dhqaqlddu25x5vea"
  }

  github = {
    org = "segator"
    reponame = "config"
    mail = "2348131+segator@users.noreply.github.com"
  }

  cluster = {
    name = "k8s-cluster"
    kubernetes_version = "v1.32.1"
    kubernetes_worker_nodes = 2
    ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
    image_id = "ocid1.image.oc1.eu-paris-1.aaaaaaaazc4me3oan6wkdnpgp7hw265pb5ovx4nwd4d3a2gmz6vkmmr7ubra"
  }

  dns = {
    cloudflare_zone_id = "7067af02e515b608f80b4c816fdef44c"
  }

}