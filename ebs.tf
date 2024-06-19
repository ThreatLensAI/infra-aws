data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# EBS ROLE SETUP FOR KMS

data "aws_iam_policy_document" "ebs_kms_policy" {
  statement {
    sid = "KMSKeyUseRole"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ListGrants",
      "kms:DescribeKey",
    ]
    resources = [module.kms_ebs.key_arn]
  }
}

resource "aws_iam_policy" "ebs_encryption" {
  name   = "AmazonKMSKeyUseEBSCustom"
  policy = data.aws_iam_policy_document.ebs_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_encryption" {
  policy_arn = aws_iam_policy.ebs_encryption.arn
  role       = module.irsa-ebs-csi.iam_role_name
}
