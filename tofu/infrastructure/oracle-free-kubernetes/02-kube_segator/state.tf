terraform {
  backend "s3" {
    bucket  = "segator-homelab-tofu-state"
    encrypt = true
    key     = "oracle-free-kubernetes/02-kube_segator/tf.tfstate"
    profile = "segator"
    region  = "eu-central-1"
  }
}
