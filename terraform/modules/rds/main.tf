resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  engine                      = "mysql"
  engine_version              = var.engine_version
  iops                        = var.iops
  instance_class              = var.db_instance
  db_name                     = var.db_name
  username                    = var.username
  port                        = var.rds_port
  password                    = var.DB_PASSWORD
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  parameter_group_name        = var.parameter_group_name
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.id
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


resource "null_resource" "db_setup" {

  depends_on = [aws_db_instance.mysql_db]

    provisioner "local-exec" {
        command = "mysql -h $DB_HOST -u $USERNAME -p $DB_PASSWORD $DB_NAME < ./files/init_db.sql"
        environment {
          DB_PASSWORD = var.DB_PASSWORD
          DB_NAME     = var.db_name
          DB_HOST     = split(":", aws_db_instance.my_test_mysql.endpoint)[0]
          USERNAME    = var.username
        }
    }
}