locals {
  autoscaler_values_files = [for file_path in var.eks_bootstrap_autoscaler.values_file_paths : "${file(file_path)}"]
}

resource "kubernetes_namespace" "autoscaler" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_autoscaler.namespace
  }
  depends_on = [module.eks]
}

resource "helm_release" "autoscaler" {
  provider   = helm
  name       = var.eks_bootstrap_autoscaler.name
  version    = var.eks_bootstrap_autoscaler.version
  repository = var.eks_bootstrap_autoscaler.repository
  chart      = var.eks_bootstrap_autoscaler.chart
  namespace  = kubernetes_namespace.autoscaler.metadata.0.name

  values = local.autoscaler_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_autoscaler.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set {
    name  = "cluster-autoscaler.awsRegion"
    value = var.region
  }

  set {
    name  = "cluster-autoscaler.autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "cluster-autoscaler.autoDiscovery.namespace"
    value = kubernetes_namespace.autoscaler.metadata.0.name
  }

  set {
    name  = "cluster-autoscaler.rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa-ca.iam_role_arn
  }

  dynamic "set" {
    for_each = module.eks.eks_managed_node_groups_autoscaling_group_names
    content {
      name  = "cluster-autoscaler.autoscalingGroups[${set.key}].name"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.eks_cluster.node_groups
    content {
      name  = "cluster-autoscaler.autoscalingGroups[${set.key}].minSize"
      value = set.value.min_size
    }
  }

  dynamic "set" {
    for_each = var.eks_cluster.node_groups
    content {
      name  = "cluster-autoscaler.autoscalingGroups[${set.key}].maxSize"
      value = set.value.max_size
    }
  }

  set {
    name = "cluster-autoscaler.extraArgs.balance-similar-node-groups"
    value = true
  }

  depends_on = [
    kubernetes_namespace.autoscaler,
    module.eks.cluster_name,
    module.irsa-ca
  ]
}
