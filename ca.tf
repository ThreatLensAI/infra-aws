module "irsa-ca" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                    = var.ca-iam.create_role
  role_name                      = "${var.ca-iam.role_name}-${module.eks.cluster_name}"
  provider_url                   = module.eks.oidc_provider
  role_policy_arns               = [aws_iam_policy.cluster_autoscaler_policy.arn]
  oidc_fully_qualified_audiences = var.ca-iam.oidc_fully_qualified_audiences
  oidc_fully_qualified_subjects  = var.ca-iam.oidc_fully_qualified_subjects
}
