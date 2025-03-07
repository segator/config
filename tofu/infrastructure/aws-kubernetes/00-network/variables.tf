
variable "vpc_name" {
  type        = string
  description = "Name of the vpc"
  nullable = false
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Good, unique names for your subnets.
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Adjust as needed
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "public_subnet_tags" {
  type        = map(string)
  description = "Tags to apply to the public subnets"
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags to apply to the private subnets"
}
