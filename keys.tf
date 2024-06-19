data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
    arn = data.aws_caller_identity.current.arn
}

module "kms_cluster" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  description             = "Amazon EKS cluster secrets encryption key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  enable_default_policy     = true
  key_administrators        = [data.aws_iam_session_context.current.issuer_arn]
  key_users                 = [aws_iam_role.cluster.arn]
  
  aliases = ["EKS_CLUSTER_KEY"]
}


module "kms_ebs" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  description             = "Amazon EBS secrets encryption key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  enable_default_policy     = true
  key_administrators        = [data.aws_iam_session_context.current.issuer_arn]
  key_users                 = [module.irsa-ebs-csi.iam_role_arn]

  aliases = ["EBS_KEY"]
}
