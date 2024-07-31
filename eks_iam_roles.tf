data "aws_partition" "current" {}

locals {
  partition = data.aws_partition.current.partition
}

# CLUSTER ROLE SETUP FOR EKS

data "aws_iam_policy_document" "assume_role_policy_cluster" {
  statement {
    sid     = var.cluster_iam.assume_role_policy.sid
    actions = var.cluster_iam.assume_role_policy.actions

    principals {
      type        = var.cluster_iam.assume_role_policy.type
      identifiers = var.cluster_iam.assume_role_policy.identifiers
    }
  }
}

resource "aws_iam_role" "cluster" {
  name        = var.cluster_iam.role_name
  description = var.cluster_iam.description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cluster.json

  tags = {
    Name = var.cluster_iam.role_name
  }
}

locals {
  policies_cluster = [
    for policy in var.cluster_iam.cluster_policies : "arn:${local.partition}:iam::aws:policy/${policy}"
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
    sid       = var.cluster_iam.kms.sid
    actions   = var.cluster_iam.kms.actions
    resources = [module.kms_cluster.key_arn]
  }
}

resource "aws_iam_policy" "cluster_encryption" {
  name   = var.cluster_iam.kms.policy_name
  policy = data.aws_iam_policy_document.cluster_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  policy_arn = aws_iam_policy.cluster_encryption.arn
  role       = aws_iam_role.cluster.name
}

// NODE GROUP ROLE SETUP

data "aws_iam_policy_document" "assume_role_policy_node_group" {
  statement {
    sid     = var.node_group_iam.assume_role_policy.sid
    actions = var.node_group_iam.assume_role_policy.actions

    principals {
      type        = var.node_group_iam.assume_role_policy.type
      identifiers = var.node_group_iam.assume_role_policy.identifiers
    }
  }
}

resource "aws_iam_role" "node_group" {
  name        = var.node_group_iam.role_name
  description = var.node_group_iam.description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_node_group.json

  tags = {
    Name = var.node_group_iam.role_name
  }
}

locals {
  policies_node_group = [
    for policy in var.node_group_iam.policies : "arn:${local.partition}:iam::aws:policy/${policy}"
  ]
}

resource "aws_iam_role_policy_attachment" "node_group" {
  count      = length(local.policies_node_group)
  policy_arn = local.policies_node_group[count.index]
  role       = aws_iam_role.node_group.name
}

// CLUSTER AUTOSCALER POLICY SETUP

data "aws_iam_policy_document" "cluster_autoscaler_policy_document" {
  dynamic "statement" {
    for_each = var.ca-iam.policy.statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = var.ca-iam.policy.name
  description = var.ca-iam.policy.description
  policy      = data.aws_iam_policy_document.cluster_autoscaler_policy_document.json
}

// FLUETBIT CLOUDWATCH POLICY SETUP

data "aws_iam_policy_document" "fluentbit_cloudwatch_policy_document" {
  dynamic "statement" {
    for_each = var.fluentbit-iam.policy.statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "fluentbit_cloudwatch_policy" {
  name        = var.fluentbit-iam.policy.name
  description = var.fluentbit-iam.policy.description
  policy      = data.aws_iam_policy_document.fluentbit_cloudwatch_policy_document.json
}
