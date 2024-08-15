locals {
  operator_values_files  = [for file_path in var.eks_bootstrap_operator.values_file_paths : "${file(file_path)}"]
  processor_values_files = [for file_path in var.eks_bootstrap_processor.values_file_paths : "${file(file_path)}"]
}

resource "kubernetes_namespace" "processor" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_processor.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
  depends_on = [
    module.eks.cluster_name,
    helm_release.postgresql,
    helm_release.kafka
  ]
}

resource "kubernetes_secret" "processor" {
  provider = kubernetes
  metadata {
    name      = "dockerhub-pull-secrets"
    namespace = kubernetes_namespace.processor.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = base64decode(var.eks_bootstrap_secrets.dockerhubconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.processor]
}

resource "kubernetes_limit_range" "processor" {
  count = length(var.eks_bootstrap_processor_limit_range) > 0 ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.processor.metadata.0.name}-limit-range"
    namespace = kubernetes_namespace.processor.metadata.0.name
  }

  dynamic "spec" {
    for_each = var.eks_bootstrap_processor_limit_range
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
}

resource "helm_release" "cve_operator" {
  provider   = helm
  name       = var.eks_bootstrap_operator.name
  version    = var.eks_bootstrap_operator.version
  repository = var.eks_bootstrap_operator.repository
  chart      = var.eks_bootstrap_operator.chart
  namespace  = kubernetes_namespace.processor.metadata.0.name

  values = local.operator_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_operator.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set_sensitive {
    name  = "secrets.dockerhubconfigjson"
    value = var.eks_bootstrap_secrets.dockerhubconfigjson
  }

  depends_on = [
    module.eks.cluster_name,
    kubernetes_namespace.processor,
    kubernetes_secret.processor,
    helm_release.postgresql,
    helm_release.kafka
  ]
}

resource "helm_release" "processor" {
  provider   = helm
  name       = var.eks_bootstrap_processor.name
  version    = var.eks_bootstrap_processor.version
  repository = var.eks_bootstrap_processor.repository
  chart      = var.eks_bootstrap_processor.chart
  namespace  = kubernetes_namespace.processor.metadata.0.name

  values = local.processor_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_processor.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set_sensitive {
    name  = "secrets.dockerhubconfigjson"
    value = var.eks_bootstrap_secrets.dockerhubconfigjson
  }

  set_sensitive {
    name  = "kafka.secrets.username"
    value = base64encode(var.eks_bootstrap_kafka_sensitive_values.username)
  }

  set_sensitive {
    name  = "kafka.secrets.password"
    value = base64encode(random_password.kafka_password.result)
  }

  depends_on = [
    module.eks.cluster_name,
    helm_release.postgresql,
    helm_release.kafka,
    helm_release.cve_operator
  ]
}

