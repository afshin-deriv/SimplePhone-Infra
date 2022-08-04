output "subnets" {
  value = [aws_subnet.private-a.id, aws_subnet.private-b.id,
  aws_subnet.public-a.id, aws_subnet.public-b.id]
}

output "db_subnet_group_name" {
  value = aws_subnet.private-a.id
}

output "public_subnet_id" {
  value = aws_subnet.public-a.id
}