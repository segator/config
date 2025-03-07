locals {
  root_vars = read_terragrunt_config(find_in_parent_folders("vars.hcl"))
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "skip" # Allow modules to override provider settings
  contents = <<EOF
provider "aws" {
  # The AWS region in which all resources will be created
  region = "${local.root_vars.locals.providers.aws.region}"
  profile = "${local.root_vars.locals.providers.aws.profile}"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terraform-isaac-test"
    key            = "aws-kubernetes/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    profile        = "${local.root_vars.locals.providers.aws.profile}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
