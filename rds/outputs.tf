output "rds_end_point" {
  value = aws_db_instance.my_test_mysql.endpoint
}

output "aws_db_instance" {
  value = aws_db_instance.my_test_mysql.id
}