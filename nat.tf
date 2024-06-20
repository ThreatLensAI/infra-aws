resource "aws_eip" "nat" {
  public_ipv4_pool     = var.nat.eip.public_ipv4_pool
  domain               = var.nat.eip.domain
  network_border_group = var.nat.eip.network_border_group
}

resource "aws_nat_gateway" "cluster" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = var.nat.name
  }

  depends_on = [aws_internet_gateway.cluster]
}
