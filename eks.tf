locals {
  node_groups = {
    for prop in var.eks_cluster.node_groups : prop.name => prop
  }
}
module "eks" {
  depends_on = [
    aws_security_group_rule.cluster,
    aws_security_group_rule.node,

    aws_iam_role.cluster,
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.cluster_encryption,

    aws_iam_role.node_group,
    aws_iam_role_policy_attachment.node_group
  ]
  source  = "terraform-aws-modules/eks/aws"
  version = "20.14.0"

  // EKS Cluster authentication
  authentication_mode = var.eks_cluster.authentication_mode

  // EKS Cluster configuration
  cluster_name                    = var.eks_cluster.name
  cluster_version                 = var.eks_cluster.version
  cluster_endpoint_public_access  = var.eks_cluster.endpoint_public_access
  cluster_endpoint_private_access = var.eks_cluster.endpoint_private_access
  cluster_ip_family               = var.eks_cluster.ip_family
  create_cluster_security_group   = false
  cluster_security_group_id       = aws_security_group.cluster.id

  // KMS Symmetric Secretes encryption Keys
  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn : module.kms_cluster.key_arn
    resources : ["secrets"]
  }

  // EKS Cluster service role.
  create_iam_role = false
  iam_role_arn    = aws_iam_role.cluster.arn

  // EKS Cluster Addons
  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
      most_recent              = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_irsa = true

  // EKS Cluster logging configuration
  cluster_enabled_log_types = var.eks_cluster.log_types

  enable_cluster_creator_admin_permissions = true

  vpc_id                   = aws_vpc.cluster.id
  control_plane_subnet_ids = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)

  dataplane_wait_duration = "30s"

  // EKS Managed Node Groups Defaults
  eks_managed_node_group_defaults = {
    ami_type        = var.eks_cluster.ami_type
    subnet_ids      = aws_subnet.private[*].id
    create_iam_role = false
    iam_role_arn    = aws_iam_role.node_group.arn
  }

  // EKS Managed Node Groups
  create_node_security_group = false
  node_security_group_id     = aws_security_group.node.id
  eks_managed_node_groups    = local.node_groups
}
