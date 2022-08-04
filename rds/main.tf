
data "aws_kms_secrets" "rds-secret" {
  secret {
    name    = "master_password"
    payload = var.password_payload

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
  port                        = var.rds_port
  password                    = data.aws_kms_secrets.rds-secret.plaintext["rds_password"]
  kms_key_id                   = var.kms_key_id
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  parameter_group_name        = var.parameter_group_name
  db_subnet_group_name        = var.db_subnet_group_name
  vpc_security_group_ids      = [var.rds-sg_id]
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  multi_az                    = var.multi_az
  skip_final_snapshot         = var.skip_final_snapshot
  deletion_protection         = var.deletion_protection
}

