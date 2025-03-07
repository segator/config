variable "vpc_id" {
    type        = string
    description = "VPC ID"
}

variable "private_subnet_ids" {
    type        = list(string)
    description = "List of private subnet IDs"
}
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "my-eks-cluster-tf-arm"
}


variable "instance_type" {
  type        = string
  description = "EC2 instance type for worker nodes"
  default     = "t4g.small" # Cost-effective ARM instance
}
variable "ami_id" {
    type        = string
    description = "AMI ID for worker nodes"
    default     = "ami-0a9d27a9f4f5c0e3c" # Amazon Linux 2 ARM
}
variable "desired_capacity" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 1
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 2
}

variable "kubernetes_version" {
  type = string
  description = "Kubernetes version to use"
  default = "1.28"  #  Pin to a specific version
}