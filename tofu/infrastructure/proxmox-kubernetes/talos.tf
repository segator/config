resource "talos_machine_secrets" "cluster" {
  talos_version = var.talos_version
}


data "talos_machine_configuration" "cp" {
  talos_version = var.talos_version
  kubernetes_version = var.kubernetes_version
  cluster_name     = "cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://cluster.local:6443"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-config/default.yaml.tpl", local.talos_mc_defaults),
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = "example-cluster"
  client_configuration = talos_machine_secrets.cluster.client_configuration
  nodes                = ["10.5.0.2"]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp.machine_configuration
  node                        = "10.5.0.2"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sdd"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = "10.5.0.2"
  client_configuration = talos_machine_secrets.this.client_configuration
}