locals {
  istio_base_values_files = [for file_path in var.eks_bootstrap_istio_base.values_file_paths : "${file(file_path)}"]
  istiod_values_files     = [for file_path in var.eks_bootstrap_istiod.values_file_paths : "${file(file_path)}"]
  istio_gateway_values_files = [for file_path in var.eks_bootstrap_istio_gateway.values_file_paths : "${templatefile(file_path, {
    domain = var.domain
  })}"]
}

resource "kubernetes_namespace" "istio_system" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_istiod.namespace
  }
  depends_on = [helm_release.prometheus]
}

resource "helm_release" "istio_base" {
  provider   = helm
  name       = var.eks_bootstrap_istio_base.name
  version    = var.eks_bootstrap_istio_base.version
  repository = var.eks_bootstrap_istio_base.repository
  chart      = var.eks_bootstrap_istio_base.chart
  namespace  = kubernetes_namespace.istio_system.metadata.0.name

  values = local.istiod_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_istio_base.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set {
    name  = "defaultRevision"
    value = "default"
  }

  depends_on = [kubernetes_namespace.istio_system, helm_release.prometheus]
}

resource "helm_release" "istiod" {
  provider   = helm
  name       = var.eks_bootstrap_istiod.name
  version    = var.eks_bootstrap_istiod.version
  repository = var.eks_bootstrap_istiod.repository
  chart      = var.eks_bootstrap_istiod.chart
  namespace  = kubernetes_namespace.istio_system.metadata.0.name

  values = local.istiod_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_istiod.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.istio_system, helm_release.istio_base, helm_release.prometheus]
}

resource "helm_release" "istio_gateway" {
  provider   = helm
  name       = var.eks_bootstrap_istio_gateway.name
  version    = var.eks_bootstrap_istio_gateway.version
  repository = var.eks_bootstrap_istio_gateway.repository
  chart      = var.eks_bootstrap_istio_gateway.chart
  namespace  = kubernetes_namespace.istio_system.metadata.0.name

  values = local.istio_gateway_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_istio_gateway.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [time_sleep.wait_for_lb_controller, module.operations.cert_manager, module.operations.external_dns, kubernetes_namespace.istio_system, helm_release.istio_base, helm_release.istiod]
}
