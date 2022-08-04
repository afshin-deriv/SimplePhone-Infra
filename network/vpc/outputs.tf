output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "main_route_table_id" {
  value = aws_vpc.main.main_route_table_id
}
