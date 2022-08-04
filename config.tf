# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

terraform {
  required_version = ">= 1.0.0"

  # Terraform state file remote location
  backend "s3" {
    bucket  = "terraform-simplephone"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_id]
      command     = "aws"
    }
  }
}