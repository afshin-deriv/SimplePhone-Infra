# Internet Gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
}

# NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Route
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = var.subnets[0]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = var.subnets[1]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = var.subnets[2]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = var.subnets[3]
  route_table_id = aws_route_table.public.id
}