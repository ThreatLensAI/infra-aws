locals {
  prometheus_values_files = [for file_path in var.eks_bootstrap_prometheus.values_file_paths : "${file(file_path)}"]
  grafana_values_files    = [for file_path in var.eks_bootstrap_grafana.values_file_paths : "${file(file_path)}"]
}

resource "helm_release" "prometheus" {
  provider   = helm
  name       = var.eks_bootstrap_prometheus.name
  version    = var.eks_bootstrap_prometheus.version
  repository = var.eks_bootstrap_prometheus.repository
  chart      = var.eks_bootstrap_prometheus.chart
  namespace  = kubernetes_namespace.operations.metadata.0.name

  values = local.prometheus_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_prometheus.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.operations, helm_release.fluentbit]
}


resource "helm_release" "grafana" {
  provider   = helm
  name       = var.eks_bootstrap_grafana.name
  version    = var.eks_bootstrap_grafana.version
  repository = var.eks_bootstrap_grafana.repository
  chart      = var.eks_bootstrap_grafana.chart
  namespace  = kubernetes_namespace.operations.metadata.0.name

  values = local.grafana_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_grafana.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.operations, helm_release.kafka, helm_release.postgresql, helm_release.prometheus]
}
