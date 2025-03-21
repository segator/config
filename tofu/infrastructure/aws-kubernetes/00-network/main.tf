# Configure the AWS Provider


data "aws_availability_zones" "available" {}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Use a compatible version

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway           = true
  single_nat_gateway           = false
  enable_dns_hostnames         = true
  create_database_subnet_group = false
  one_nat_gateway_per_az       = false

  public_subnet_tags = var.public_subnet_tags

  private_subnet_tags = var.private_subnet_tags
}