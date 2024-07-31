resource "kubernetes_namespace" "operations" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_prometheus.namespace
  }

  depends_on = [helm_release.fluentbit]
}
