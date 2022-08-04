variable "subnet_cidr_block" {
  description = "The IPv4 CIDR block for the subnet"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
}

variable "availability_zone" {
  description = "AZ for the subnet"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]
}

variable "vpc_id" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}