variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_range" {
  type = string
}

variable "subnets" {
  type = list(object({
    name               = string
    public_cidr_block  = string
    private_cidr_block = string
    zone               = string
  }))
  default = []
}

variable "internet_gateway_name" {
  type = string
}

variable "route_tables" {
  type = object({
    public_route_table_name  = string
    private_route_table_name = string
    route_cidr               = string
  })
}

variable "network_acl_ingress" {
  type = list(object({
    protocol = string
    port     = number
    number   = number
    action   = string
    cidr     = string
  }))
}

variable "network_acl_egress" {
  type = list(object({
    protocol = string
    port     = number
    number   = number
    action   = string
    cidr     = string
  }))
}

variable "nat" {
  type = object({
    eip = object({
      public_ipv4_pool     = string
      domain               = string
      network_border_group = string
    })

    name = string
  })
}

variable "node_sg" {
  type = object({
    name = string
    rules = list(object({
      description                   = string
      protocol                      = string
      from_port                     = number
      to_port                       = number
      type                          = string
      self                          = optional(bool, null)
      source_cluster_security_group = optional(bool, null)
      cidr_blocks                   = optional(list(string), null)
    }))
  })
}

variable "cluster_sg" {
  type = object({
    name = string
    rules = list(object({
      description                = string
      protocol                   = string
      from_port                  = number
      to_port                    = number
      type                       = string
      self                       = optional(bool, null)
      source_node_security_group = optional(bool, null)
      cidr_blocks                = optional(list(string), null)
    }))
  })
}

variable "cluster_kms_key" {
  type = object({
    name                     = string
    description              = string
    key_usage                = string
    deletion_window_in_days  = number
    enable_key_rotation      = bool
    customer_master_key_spec = string
    enable_default_policy    = bool
  })
}

variable "ebs_kms_key" {
  type = object({
    name                     = string
    description              = string
    key_usage                = string
    deletion_window_in_days  = number
    enable_key_rotation      = bool
    customer_master_key_spec = string
    enable_default_policy    = bool
  })
}

variable "cluster_iam" {
  type = object({
    role_name   = string
    description = string
    assume_role_policy = object({
      sid         = string
      actions     = list(string)
      type        = string
      identifiers = list(string)
    })
    cluster_policies = list(string)
    kms = object({
      sid         = string
      actions     = list(string)
      policy_name = string
    })
  })
}

variable "node_group_iam" {
  type = object({
    role_name   = string
    description = string
    assume_role_policy = object({
      sid         = string
      actions     = list(string)
      type        = string
      identifiers = list(string)
    })
    policies = list(string)
  })
}

variable "eks_cluster" {
  type = object({
    name                          = string
    version                       = optional(string, "1.29")
    ip_family                     = optional(string, "ipv4")
    ami_type                      = optional(string, "AL2_x86_64")
    authentication_mode           = optional(string, "API_AND_CONFIG_MAP")
    endpoint_public_access        = optional(bool, true)
    endpoint_private_access       = optional(bool, true)
    addons_version_most_recent    = optional(bool, true)
    enable_irsa                   = optional(bool, true)
    creator_admin_permissions     = optional(bool, true)
    create_cluster_security_group = optional(bool, false)
    create_kms_key                = optional(bool, false)
    create_cluster_iam_role       = optional(bool, false)
    create_node_security_group    = optional(bool, false)
    create_node_iam_role          = optional(bool, false)
    dataplane_wait_duration       = optional(string, "30s")
    log_types = optional(list(string), [
      "api",
      "audit",
      "authenticator",
      "controllerManager",
      "scheduler"
    ])
    node_groups = list(object({
      name           = string
      tags           = optional(map(string), {})
      ami_type       = optional(string)
      capacity_type  = optional(string, "ON_DEMAND")
      instance_types = optional(list(string), ["c3.large"])
      desired_size   = optional(number, 1)
      min_size       = optional(number, 1)
      max_size       = optional(number, 2)
      update_config = optional(object({
        max_unavailable = optional(number, 1)
        max_surge       = optional(number, 0)
        }), {
        max_unavailable = 1,
        max_surge       = 0
      })
    }))
  })
}

variable "ebs" {
  type = object({
    ebs_csi_policy                 = string
    create_role                    = optional(bool, true)
    role_name                      = string
    oidc_fully_qualified_audiences = list(string)
    oidc_fully_qualified_subjects  = list(string)
    kms = object({
      sid         = string
      actions     = list(string)
      policy_name = string
    })
  })
}

variable "ca-iam" {
  type = object({
    create_role                    = optional(bool, true)
    role_name                      = string
    oidc_fully_qualified_audiences = list(string)
    oidc_fully_qualified_subjects  = list(string)
    policy = object({
      name        = string
      description = string
      statements = list(object({
        effect    = string
        actions   = list(string)
        resources = list(string)
      }))
    })
  })
}

variable "eks_storage_class" {
  type = object({
    storage_class_name  = optional(string, "gp3")
    storage_provisioner = optional(string, "ebs.csi.aws.com")
    reclaim_policy      = optional(string, "Delete")
    volume_binding_mode = optional(string, "WaitForFirstConsumer")
    parameters = optional(map(string), {
      "type" : "gp3"
      "csi.storage.k8s.io/fstype" : "ext4"
    })
  })
}

variable "eks_bootstrap_postgresql" {
  type = object({
    name              = string
    version           = optional(string, "15.5.9")
    namespace         = optional(string, "postgresql")
    repository        = optional(string, "https://charts.bitnami.com/bitnami")
    chart             = optional(string, "postgresql")
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_postgresql_sensitive_values" {
  sensitive = true
  type = object({
    username = string
    database = string
  })
}

variable "eks_bootstrap_kafka" {
  type = object({
    name              = string
    version           = optional(string, "29.3.4")
    namespace         = optional(string, "kafka")
    repository        = optional(string, "https://charts.bitnami.com/bitnami")
    chart             = optional(string, "kafka")
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_kafka_sensitive_values" {
  sensitive = true
  type = object({
    username = string
  })
}

variable "password_defaults" {
  type = object({
    upper   = optional(bool, true)
    lower   = optional(bool, true)
    numeric = optional(bool, true)
    special = optional(bool, false)
    length  = optional(number, 24)
  })

  default = {
    upper   = true
    lower   = true
    numeric = true
    special = false
    length  = 24
  }
}

variable "eks_bootstrap_autoscaler" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "cluster-autoscaler")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_consumer" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "consumer")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_postgresql_limit_range" {
  type = list(object({
    type            = string
    default         = optional(map(string), null)
    default_request = optional(map(string), null)
    min             = optional(map(string), null)
    max             = optional(map(string), null)
  }))

  default = [{
    type = "Container"
    default = {
      cpu    = "750m"
      memory = "1536Mi"
    }
    default_request = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }]
}

variable "eks_bootstrap_kafka_limit_range" {
  type = list(object({
    type            = string
    default         = optional(map(string), null)
    default_request = optional(map(string), null)
    min             = optional(map(string), null)
    max             = optional(map(string), null)
  }))

  default = [{
    type = "Container"
    default = {
      cpu    = "1"
      memory = "2Gi"
    }
    default_request = {
      cpu    = "750m"
      memory = "1536Mi"
    }
  }]
}

variable "eks_bootstrap_consumer_limit_range" {
  type = list(object({
    type            = string
    default         = optional(map(string), null)
    default_request = optional(map(string), null)
    min             = optional(map(string), null)
    max             = optional(map(string), null)
  }))

  default = [{
    type = "Container"
    default = {
      cpu    = "500m"
      memory = "384Mi"
    }
    default_request = {
      cpu    = "375m"
      memory = "256Mi"
    }
  }]
}

variable "eks_bootstrap_autoscaler_limit_range" {
  type = list(object({
    type            = string
    default         = optional(map(string), null)
    default_request = optional(map(string), null)
    min             = optional(map(string), null)
    max             = optional(map(string), null)
  }))

  default = [{
    type = "Container"
    default = {
      cpu    = "200m"
      memory = "200Mi"
    }
    default_request = {
      cpu    = "100m"
      memory = "100Mi"
    }
  }]
}

variable "eks_bootstrap_processor" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "processor")
    repository        = optional(string, null)
    chart             = optional(string, null)
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_processor_limit_range" {
  type = list(object({
    type            = string
    default         = optional(map(string), null)
    default_request = optional(map(string), null)
    min             = optional(map(string), null)
    max             = optional(map(string), null)
  }))

  default = [{
    type = "Container"
    default = {
      cpu    = "500m"
      memory = "384Mi"
    }
    default_request = {
      cpu    = "375m"
      memory = "256Mi"
    }
  }]
}

variable "eks_bootstrap_secrets" {
  sensitive = true
  type = object({
    dockerhubconfigjson = string
  })
}

variable "helm_provider_registry" {
  type = object({
    url      = string
    username = string
    password = string
  })
  sensitive = true
}

variable "eks_bootstrap_operator" {
  type = object({
    name              = string
    version           = optional(string, "1.3.0")
    namespace         = optional(string, "processor")
    repository        = optional(string, "oci://registry-1.docker.io/marlapativ")
    chart             = optional(string, "helm-cve-operator")
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_istiod" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "istio-system")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_istio_base" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "istio-system")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_istio_gateway" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "istio-system")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_prometheus" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "operations")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_grafana" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "operations")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
    dashboard_paths   = optional(list(string), [])
  })
}

variable "eks_bootstrap_fluentbit" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "fluentbit")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "eks_bootstrap_cluster_operations" {
  type = object({
    name              = string
    version           = optional(string, null)
    namespace         = optional(string, "operations")
    repository        = optional(string, null)
    chart             = string
    values            = optional(map(string), {})
    values_file_paths = optional(list(string), [])
  })
}

variable "fluentbit-iam" {
  type = object({
    create_role                    = optional(bool, true)
    role_name                      = string
    oidc_fully_qualified_audiences = list(string)
    oidc_fully_qualified_subjects  = list(string)
    policy = object({
      name        = string
      description = string
      statements = list(object({
        effect    = string
        actions   = list(string)
        resources = list(string)
      }))
    })
  })
}

variable "eks_bootstrap_operations" {
  type = object({
    aws_load_balancer_controller_values_file_paths = optional(list(string), [])
    route53_hosted_zone_arns                       = list(string)

    external_dns = object({
      namespace         = optional(string, "operations")
      create_namespace  = optional(bool, false)
      chart             = optional(string, "external-dns")
      chart_version     = optional(string, "1.14.3")
      wait              = optional(bool, true)
      values            = optional(list(string), ["provider: aws"])
      values_file_paths = optional(list(string), [])
    })

    cert_manager = object({
      namespace         = optional(string, "operations")
      create_namespace  = optional(bool, false)
      chart             = optional(string, "cert-manager")
      chart_version     = optional(string, "v1.14.3")
      wait              = optional(bool, true)
      values            = optional(list(string), [])
      values_file_paths = optional(list(string), [])
    })

    metrics_server = object({
      namespace         = optional(string, "operations")
      create_namespace  = optional(bool, false)
      chart             = optional(string, "metrics-server")
      chart_version     = optional(string, "3.12.0")
      wait              = optional(bool, true)
      values            = optional(list(string), [])
      values_file_paths = optional(list(string), [])
    })
  })
}

variable "domain" {
  type = string
}

variable "email" {
  type = string
}

variable "wait_duration_aws_load_balancer_controller" {
  type    = string
  default = "5m"
}
