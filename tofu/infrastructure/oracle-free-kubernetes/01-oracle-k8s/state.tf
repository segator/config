terraform {
  backend "s3" {
    bucket  = "segator-homelab-tofu-state"
    encrypt = true
    key     = "oracle-free-kubernetes/01-oracle-k8s/tf.tfstate"
    profile = "segator"
    region  = "eu-central-1"
  }
}
