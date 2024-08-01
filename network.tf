// Networking
resource "aws_vpc" "cluster" {
  cidr_block = var.vpc_cidr_range

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "private" {
  count             = length(var.subnets)
  vpc_id            = aws_vpc.cluster.id
  cidr_block        = var.subnets[count.index].private_cidr_block
  availability_zone = var.subnets[count.index].zone

  tags = {
    Name = "${var.subnets[count.index].name}-private"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.subnets)
  vpc_id            = aws_vpc.cluster.id
  cidr_block        = var.subnets[count.index].public_cidr_block
  availability_zone = var.subnets[count.index].zone

  tags = {
    Name                     = "${var.subnets[count.index].name}-public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "cluster" {
  vpc_id = aws_vpc.cluster.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cluster.id
  route {
    cidr_block = var.route_tables.route_cidr
    gateway_id = aws_internet_gateway.cluster.id
  }
  tags = {
    Name = var.route_tables.public_route_table_name
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.cluster.id

  route {
    cidr_block     = var.route_tables.route_cidr
    nat_gateway_id = aws_nat_gateway.cluster.id
  }
  tags = {
    Name = var.route_tables.private_route_table_name
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(var.subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_routes" {
  count          = length(var.subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_default_network_acl" "cluster" {
  default_network_acl_id = aws_vpc.cluster.default_network_acl_id
  subnet_ids             = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)

  dynamic "ingress" {
    for_each = var.network_acl_ingress
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.number
      action     = ingress.value.action
      cidr_block = ingress.value.cidr
      from_port  = ingress.value.port
      to_port    = ingress.value.port
    }
  }

  dynamic "egress" {
    for_each = var.network_acl_egress
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.number
      action     = egress.value.action
      cidr_block = egress.value.cidr
      from_port  = egress.value.port
      to_port    = egress.value.port
    }
  }
}
