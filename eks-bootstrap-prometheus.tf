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

resource "kubernetes_config_map" "grafana_dashboards_configs" {
  count = length(var.eks_bootstrap_grafana.dashboard_paths)

  provider = kubernetes

  metadata {
    name      = trimsuffix(basename(var.eks_bootstrap_grafana.dashboard_paths[count.index]), ".json")
    namespace = kubernetes_namespace.operations.metadata.0.name
  }

  data = {
    "${basename(var.eks_bootstrap_grafana.dashboard_paths[count.index])}" = file("${path.module}/${var.eks_bootstrap_grafana.dashboard_paths[count.index]}")
  }

  depends_on = [kubernetes_namespace.operations]

}


resource "kubernetes_config_map" "grafana_ini_config" {
  provider = kubernetes

  metadata {
    name      = "grafana-ini-config"
    namespace = kubernetes_namespace.operations.metadata.0.name
  }

  data = {
    "grafana.ini" = templatefile("${path.module}/${var.eks_bootstrap_grafana.ini_config_path}", {
      url                 = "https://${var.domain}/grafana"
      serve_from_sub_path = true
    })
  }

  depends_on = [kubernetes_namespace.operations]
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

  # set {
  #   name  = "config.grafanaIniConfigMap"
  #   value = kubernetes_config_map.grafana_ini_config.metadata.0.name
  # }

  # set {
  #   name  = "config.useGrafanaIniFile"
  #   value = "true"
  # }

  depends_on = [kubernetes_config_map.grafana_dashboards_configs, helm_release.kafka, helm_release.postgresql, helm_release.prometheus]
}
