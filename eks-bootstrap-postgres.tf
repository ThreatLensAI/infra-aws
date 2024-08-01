locals {
  postgres_values_files = [for file_path in var.eks_bootstrap_postgresql.values_file_paths : "${file(file_path)}"]
}

resource "kubernetes_namespace" "postgresql" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_postgresql.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
  depends_on = [module.eks, helm_release.istiod, helm_release.kafka]
}

resource "random_password" "database_password" {
  length  = var.password_defaults.length
  special = var.password_defaults.special
  upper   = var.password_defaults.upper
  numeric = var.password_defaults.numeric
  lower   = var.password_defaults.lower
}

resource "helm_release" "postgresql" {
  provider   = helm
  name       = var.eks_bootstrap_postgresql.name
  version    = var.eks_bootstrap_postgresql.version
  repository = var.eks_bootstrap_postgresql.repository
  chart      = var.eks_bootstrap_postgresql.chart
  namespace  = kubernetes_namespace.postgresql.metadata.0.name

  values = local.postgres_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_postgresql.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set_sensitive {
    name  = "global.postgresql.auth.username"
    value = var.eks_bootstrap_postgresql_sensitive_values.username
  }

  set_sensitive {
    name  = "global.postgresql.auth.database"
    value = var.eks_bootstrap_postgresql_sensitive_values.database
  }

  set_sensitive {
    name  = "global.postgresql.auth.password"
    value = random_password.database_password.result
  }

  set_sensitive {
    name  = "global.imagePullSecrets[0]"
    value = kubernetes_secret.postgresql.metadata.0.name
  }

  set {
    name  = "global.storageClass"
    value = kubernetes_storage_class.ebs.metadata.0.name
  }

  depends_on = [
    kubernetes_namespace.postgresql,
    random_password.database_password,
    kubernetes_storage_class.ebs,
    module.eks.cluster_name,
    helm_release.autoscaler,
    helm_release.istiod,
    helm_release.kafka
  ]
}

resource "kubernetes_limit_range" "postgresql" {
  count = length(var.eks_bootstrap_postgresql_limit_range) > 0 ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.postgresql.metadata.0.name}-limit-range"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  dynamic "spec" {
    for_each = var.eks_bootstrap_postgresql_limit_range
    content {
      limit {
        type            = spec.value.type
        default         = try(spec.value.default, null)
        default_request = try(spec.value.default_request, null)
        min             = try(spec.value.min, null)
        max             = try(spec.value.max, null)
      }
    }
  }

  depends_on = [kubernetes_namespace.postgresql]
}

resource "kubernetes_secret" "postgresql" {
  provider = kubernetes
  metadata {
    name      = "${kubernetes_namespace.postgresql.metadata.0.name}-dockerhub-secrets"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = base64decode(var.eks_bootstrap_secrets.dockerhubconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.postgresql]
}
