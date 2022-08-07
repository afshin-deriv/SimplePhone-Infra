output "rds_end_point" {
  value = split(":", aws_db_instance.my_test_mysql.endpoint)[0]
}

output "aws_db_instance" {
  value = aws_db_instance.my_test_mysql.id
}