provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "VPC"
  }
}


# Subnets
resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = {
    "Name"                                      = "private-us-east-1a"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = {
    "Name"                                      = "private-us-east-1b"
  }
}


resource "aws_db_subnet_group" "rds-private-subnet" {
  name = "rds-private-subnet-group"
  subnet_ids = [aws_subnet.private-us-east-1a.id,aws_subnet.private-us-east-1b.id]
}

resource "aws_security_group" "rds-sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.rds-sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds-sg.id
}

data "aws_kms_secrets" "rds-secret" {
  secret {
    name    = "master_password"
    payload = var.aws_kms_secrets_payload

    context = {
      usage = "Database"
    }
  }
}

resource "aws_db_instance" "my_test_mysql" {
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  engine                      = "mysql"
  engine_version              = var.engine_version
  iops                        = var.iops
  instance_class              = var.db_instance
  db_name                     = var.db_name
  username                    = var.username
  port                        = var.port
  password                    = data.aws_kms_secrets.rds-secret.plaintext["master_password"]
  kms_key_id                   = aws_kms_key.rds-key[0].arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  parameter_group_name        = var.parameter_group_name
  db_subnet_group_name        = aws_db_subnet_group.rds-private-subnet.name
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  multi_az                    = var.multi_az
  skip_final_snapshot         = var.skip_final_snapshot
  deletion_protection         = var.deletion_protection

  # The password defined in Terraform is an initial value, it must be changed after creating the RDS instance.
  # Therefore, suppress plan diff after changing the password.
  lifecycle {
    ignore_changes = [password]
  }
}

