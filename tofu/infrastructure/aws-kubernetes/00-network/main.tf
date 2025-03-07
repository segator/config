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

  enable_nat_gateway = false  # Disable NAT Gateway for cost savings.
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  # enable dns
  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = var.public_subnet_tags

  private_subnet_tags = var.private_subnet_tags
}