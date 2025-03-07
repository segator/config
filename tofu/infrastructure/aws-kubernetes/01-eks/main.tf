module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20"  # Use a compatible version of the EKS module

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
    capacity_type  = "SPOT"
    ami_id       = var.ami_id
  }

  eks_managed_node_groups = {
    main = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_capacity
    }
  }

  # IRSA setup
  enable_irsa = true

  # Example Service Account (IRSA) -  Make sure this matches your namespace/service account name
  node_iam_role_name = "${var.cluster_name}-node-role"
  node_iam_role_permissions_boundary = null

}


module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  enable_cluster_proportional_autoscaler = true
  enable_karpenter                       = true
  karpenter_enable_spot_termination = true
  enable_kube_prometheus_stack           = false
  enable_metrics_server                  = true
  enable_external_dns                    = false
  enable_cert_manager                    = true
}