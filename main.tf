## Network
# Create VPC
module "vpc" {
  source     = "./network/vpc"
  cidr_block = var.cidr_block
}

# Create Subnets
module "subnets" {
  source           = "./network/subnets"
  vpc_id           = module.vpc.vpc_id
  eks_cluster_name = var.cluster_name
}

# Configure Routes
module "route" {
  source           = "./network/route"
  subnets          = module.subnets.subnets
  public_subnet_id = module.subnets.public_subnet_id
  vpc_id           = module.vpc.vpc_id
}

module "sec_group_rds" {
  source         = "./network/sec_group"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.cidr_block
  rds_port       = var.rds_port
}

# module "kms" {
#   source              = "./kms"
#   eks_fargate_profile = module.eks_cluster.kube-system
#   aws_region   = var.aws_region
#   rds_password = var.rds_password
# }

# module "rds" {
#   source               = "./rds"
#   password_payload     = module.kms.ciphertext_blob
#   kms_key_id           = module.kms.key_id
#   db_subnet_group_name = module.subnets.db_subnet_group_name
#   rds-sg_id            = module.sec_group_rds.rds-sg_id
# }

module "eks_cluster" {
  source       = "./eks"
  cluster_name = var.cluster_name
  subnet_ids   = module.subnets.subnets
  aws_region   = var.aws_region
  vpc_id       = module.vpc.vpc_id
}






