# Create VPC
module "vpc" {
  source     = "./modules/network/vpc"
  cidr_block = var.cidr_block
}

# Create Subnets
module "subnets" {
  source           = "./modules/network/subnets"
  vpc_id           = module.vpc.vpc_id
  eks_cluster_name = var.cluster_name
}

# Configure Routes
module "route" {
  source           = "./modules/network/route"
  subnets          = module.subnets.subnets
  public_subnet_id = module.subnets.public_subnet_id
  vpc_id           = module.vpc.vpc_id
}

# RDS Security Group
module "sec_group_rds" {
  source         = "./modules/network/sec_group"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.cidr_block
  rds_port       = var.rds_port
}

# Create Mysql RDS
module "rds" {
  source               = "./modules/rds"
  DB_PASSWORD          = var.DB_PASSWORD
  subnet_ids           = module.subnets.private_subnet_ids
  db_subnet_group_name = module.subnets.db_subnet_group_name
  rds-sg_id            = module.sec_group_rds.rds-sg_id
}

# Create EKS Cluster (Fargate)
module "eks_cluster" {
  source         = "./modules/eks"
  cluster_name   = var.cluster_name
  subnet_ids     = module.subnets.subnets
  aws_region     = var.aws_region
  vpc_id         = module.vpc.vpc_id
  rds_end_point  = module.rds.rds_end_point
}






