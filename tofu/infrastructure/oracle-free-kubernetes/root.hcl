remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "segator-homelab-tofu-state"
    key            = "oracle-free-kubernetes/${path_relative_to_include()}/tf.tfstate"
    region         = "eu-central-1"
    profile = "segator"
  }
  generate = {
    path      = "_backend_gen.tf"
    if_exists = "overwrite_terragrunt"
  }
}