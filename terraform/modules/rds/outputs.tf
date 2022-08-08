output "rds_end_point" {
  value = split(":", aws_db_instance.mysql_db.endpoint)[0]
}

output "aws_db_instance" {
  value = aws_db_instance.mysql_db.id
}
