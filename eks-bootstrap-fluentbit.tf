locals {
  fluentbit_values_files = [for file_path in var.eks_bootstrap_fluentbit.values_file_paths : "${templatefile(file_path, {
    cluster_name = module.eks.cluster_name
    region       = var.region
  })}"]
}

module "irsa-fluentbit" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                    = var.fluentbit-iam.create_role
  role_name                      = "${var.fluentbit-iam.role_name}-${module.eks.cluster_name}"
  provider_url                   = module.eks.oidc_provider
  role_policy_arns               = [aws_iam_policy.fluentbit_cloudwatch_policy.arn]
  oidc_fully_qualified_audiences = var.fluentbit-iam.oidc_fully_qualified_audiences
  oidc_fully_qualified_subjects  = var.fluentbit-iam.oidc_fully_qualified_subjects
}

resource "kubernetes_namespace" "fluentbit" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_fluentbit.namespace
  }
  depends_on = [module.eks]
}

resource "helm_release" "fluentbit" {
  provider   = helm
  name       = var.eks_bootstrap_fluentbit.name
  version    = var.eks_bootstrap_fluentbit.version
  repository = var.eks_bootstrap_fluentbit.repository
  chart      = var.eks_bootstrap_fluentbit.chart
  namespace  = kubernetes_namespace.postgresql.metadata.0.name

  values = local.fluentbit_values_files

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa-fluentbit.iam_role_arn
  }

  depends_on = [
    kubernetes_namespace.fluentbit,
    module.eks.cluster_name,
    helm_release.autoscaler
  ]
}
