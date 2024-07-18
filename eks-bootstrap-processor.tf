locals {
  processor_values_files = [for file_path in var.eks_bootstrap_processor.values_file_paths : "${file(file_path)}"]
}

resource "kubernetes_namespace" "processor" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_processor.namespace
  }
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
