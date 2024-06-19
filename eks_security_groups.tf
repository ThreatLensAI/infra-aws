resource "aws_security_group" "node" {
  name   = var.node_sg.name
  vpc_id = aws_vpc.cluster.id
  tags = {
    Name = var.node_sg.name
  }
}

resource "aws_security_group" "cluster" {
  name   = var.cluster_sg.name
  vpc_id = aws_vpc.cluster.id
  tags = {
    Name = var.cluster_sg.name
  }
}

resource "aws_security_group_rule" "node" {
  count = length(var.node_sg.rules)

  security_group_id = aws_security_group.node.id
  protocol          = var.node_sg.rules[count.index].protocol
  from_port         = var.node_sg.rules[count.index].from_port
  to_port           = var.node_sg.rules[count.index].to_port
  type              = var.node_sg.rules[count.index].type

  description              = var.node_sg.rules[count.index].description
  cidr_blocks              = var.node_sg.rules[count.index].cidr_blocks
  self                     = var.node_sg.rules[count.index].self
  source_security_group_id = var.node_sg.rules[count.index].source_cluster_security_group != null ? aws_security_group.cluster.id : null
}

resource "aws_security_group_rule" "cluster" {
  count = length(var.cluster_sg.rules)

  security_group_id = aws_security_group.cluster.id
  protocol          = var.cluster_sg.rules[count.index].protocol
  from_port         = var.cluster_sg.rules[count.index].from_port
  to_port           = var.cluster_sg.rules[count.index].to_port
  type              = var.cluster_sg.rules[count.index].type

  description              = var.cluster_sg.rules[count.index].description
  cidr_blocks              = var.cluster_sg.rules[count.index].cidr_blocks
  self                     = var.cluster_sg.rules[count.index].self
  source_security_group_id = var.cluster_sg.rules[count.index].source_node_security_group != null ? aws_security_group.node.id : null
}
