locals {
  cluster_operations_values_files = [for file_path in var.eks_bootstrap_cluster_operations.values_file_paths : "${templatefile(file_path, {
    domain = var.domain,
    email  = var.email
  })}"]
}

resource "helm_release" "cluster_operations" {
  provider   = helm
  name       = var.eks_bootstrap_cluster_operations.name
  version    = var.eks_bootstrap_cluster_operations.version
  repository = var.eks_bootstrap_cluster_operations.repository
  chart      = var.eks_bootstrap_cluster_operations.chart
  namespace  = kubernetes_namespace.istio_system.metadata.0.name

  values = local.cluster_operations_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_cluster_operations.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    helm_release.autoscaler,
    helm_release.fluentbit,
    helm_release.istio_base,
    helm_release.istiod,
    module.operations.cert_manager,
    module.operations.external_dns,
    helm_release.istio_gateway,
    helm_release.kafka,
    helm_release.postgresql,
    helm_release.prometheus,
    helm_release.grafana,
    helm_release.consumer,
    helm_release.processor,
    time_sleep.wait_for_lb_controller
  ]
}
