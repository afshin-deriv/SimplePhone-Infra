# VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  # Must be enabled for access EFS endpoint, AWS Fargate does not support EBS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "VPC"
  }
}
