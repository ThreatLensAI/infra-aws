data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:${local.partition}:iam::aws:policy/${var.ebs.ebs_csi_policy}"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                    = var.ebs.create_role
  role_name                      = "${var.ebs.role_name}-${module.eks.cluster_name}"
  provider_url                   = module.eks.oidc_provider
  role_policy_arns               = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_audiences = var.ebs.oidc_fully_qualified_audiences
  oidc_fully_qualified_subjects  = var.ebs.oidc_fully_qualified_subjects
}

# EBS ROLE SETUP FOR KMS

data "aws_iam_policy_document" "ebs_kms_policy" {
  statement {
    sid       = var.ebs.kms.sid
    actions   = var.ebs.kms.actions
    resources = [module.kms_ebs.key_arn]
  }
}

resource "aws_iam_policy" "ebs_encryption" {
  name   = var.ebs.kms.policy_name
  policy = data.aws_iam_policy_document.ebs_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_encryption" {
  policy_arn = aws_iam_policy.ebs_encryption.arn
  role       = module.irsa-ebs-csi.iam_role_name
}
