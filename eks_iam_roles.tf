data "aws_partition" "current" {}

locals {
  partition = data.aws_partition.current.partition
}

# CLUSTER ROLE SETUP FOR EKS

data "aws_iam_policy_document" "assume_role_policy_cluster" {
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name        = "ClusterRole"
  description = "Role for EKS Cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cluster.json

  tags = {
    Name = "ClusterRole"
  }
}

locals {
  policies_cluster = [
    "arn:${local.partition}:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:${local.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

resource "aws_iam_role_policy_attachment" "cluster" {
  count      = length(local.policies_cluster)
  policy_arn = local.policies_cluster[count.index]
  role       = aws_iam_role.cluster.name
}

# CLUSTER ROLE SETUP FOR KMS

data "aws_iam_policy_document" "cluster_kms_policy" {
  statement {
    sid = "KMSKeyUseRole"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ListGrants",
      "kms:DescribeKey",
    ]
    resources = [module.kms_cluster.key_arn]
  }
}

resource "aws_iam_policy" "cluster_encryption" {
  name   = "AmazonKMSKeyUseClusterCustom"
  policy = data.aws_iam_policy_document.cluster_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  policy_arn = aws_iam_policy.cluster_encryption.arn
  role       = aws_iam_role.cluster.name
}

// NODE GROUP ROLE SETUP

data "aws_iam_policy_document" "assume_role_policy_node_group" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_group" {
  name        = "NodeGroupRole"
  description = "Role for Node Group"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_node_group.json

  tags = {
    Name = "NodeGroupRole"
  }
}

locals {
  policies_node_group = [
    "arn:${local.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${local.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

resource "aws_iam_role_policy_attachment" "node_group" {
  count      = length(local.policies_node_group)
  policy_arn = local.policies_node_group[count.index]
  role       = aws_iam_role.node_group.name
}

