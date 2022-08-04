output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "gw_id" {
  value = aws_internet_gateway.igw.id
}

output "main_route_table_id" {
  value = aws_vpc.main.main_route_table_id
}
