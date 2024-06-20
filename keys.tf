data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

module "kms_cluster" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  description              = var.cluster_kms_key.description
  key_usage                = var.cluster_kms_key.key_usage
  deletion_window_in_days  = var.cluster_kms_key.deletion_window_in_days
  enable_key_rotation      = var.cluster_kms_key.enable_key_rotation
  customer_master_key_spec = var.cluster_kms_key.customer_master_key_spec

  enable_default_policy = var.cluster_kms_key.enable_default_policy
  key_administrators    = [data.aws_iam_session_context.current.issuer_arn]
  key_users             = [aws_iam_role.cluster.arn]

  aliases = [var.cluster_kms_key.name]
}


module "kms_ebs" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  description              = var.ebs_kms_key.description
  key_usage                = var.ebs_kms_key.key_usage
  deletion_window_in_days  = var.ebs_kms_key.deletion_window_in_days
  enable_key_rotation      = var.ebs_kms_key.enable_key_rotation
  customer_master_key_spec = var.ebs_kms_key.customer_master_key_spec

  enable_default_policy = var.ebs_kms_key.enable_default_policy
  key_administrators    = [data.aws_iam_session_context.current.issuer_arn]
  key_users             = [module.irsa-ebs-csi.iam_role_arn]

  aliases = [var.ebs_kms_key.name]
}
