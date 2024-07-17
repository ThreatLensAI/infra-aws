resource "kubernetes_namespace" "consumer" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_consumer.namespace
  }
}

locals {
  consumer_values_files = [for file_path in var.eks_bootstrap_consumer.values_file_paths : "${file(file_path)}"]
}

resource "helm_release" "consumer" {
  provider   = helm
  name       = var.eks_bootstrap_consumer.name
  version    = var.eks_bootstrap_consumer.version
  repository = var.eks_bootstrap_consumer.repository
  chart      = var.eks_bootstrap_consumer.chart
  namespace  = kubernetes_namespace.consumer.metadata.0.name

  values = local.consumer_values_files

  dynamic "set" {
    for_each = var.eks_bootstrap_consumer.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set_sensitive {
    name  = "db.secrets.username"
    value = base64encode(var.eks_bootstrap_postgresql_sensitive_values.username)
  }

  set_sensitive {
    name  = "db.secrets.database"
    value = base64encode(var.eks_bootstrap_postgresql_sensitive_values.database)
  }

  set_sensitive {
    name  = "db.secrets.password"
    value = base64encode(random_password.database_password.result)
  }

  set_sensitive {
    name  = "kafka.secrets.username"
    value = base64encode(var.eks_bootstrap_kafka_sensitive_values.username)
  }

  set_sensitive {
    name  = "kafka.secrets.password"
    value = base64encode(random_password.kafka_password.result)
  }

  set_sensitive {
    name  = "secrets.dockerhubconfigjson"
    value = var.eks_bootstrap_consumer_sensitive_values.dockerhubconfigjson
  }

  depends_on = [kubernetes_namespace.consumer, helm_release.kafka, helm_release.postgresql]
}
