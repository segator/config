locals {
  providers = {
    aws = {
      region = "eu-central-1"
      profile = "migration-dev"
    }
  }

  network = {
    vpc_name = "isaac-test-vpc"
    vpc_cidr= "10.0.0.0/16"
    private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_tags = {
      "kubernetes.io/cluster/${local.eks.name}" = "shared"
      "kubernetes.io/role/internal-elb"             = 1
    }
    public_subnet_cidrs= ["10.0.101.0/24", "10.0.102.0/24"]
    public_subnet_tags = {
      "kubernetes.io/cluster/${local.eks.name}" = "shared"
      "kubernetes.io/role/elb"                      = 1
    }
  }

  eks = {
    name                 = "isaac-kube-test"
    instance_type        = "t4g.small"
    ami_id            = "ami-0e0fdf6665785a83b" #"ami-03379cd655712e6f1"
    desired_capacity     = 1
    min_size             = 1
    max_size             = 2
    kubernetes_version   = "1.32"
  }
}