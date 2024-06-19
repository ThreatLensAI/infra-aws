resource "aws_eip" "nat" {
  public_ipv4_pool     = "amazon"
  domain               = "vpc"
  network_border_group = "us-east-1"
}

resource "aws_nat_gateway" "cluster" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.cluster]
}
