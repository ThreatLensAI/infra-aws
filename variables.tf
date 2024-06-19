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

// TODO: Implement security groups
variable "security_group_name" {
  type = string
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

variable "eks_cluster" {
  type = object({
    name                    = string
    version                 = optional(string, "1.29")
    ip_family               = optional(string, "ipv4")
    ami_type                = optional(string, "AL2_x86_64")
    authentication_mode     = optional(string, "API_AND_CONFIG_MAP")
    endpoint_public_access  = optional(bool, true)
    endpoint_private_access = optional(bool, true)
    log_types = optional(list(string), [
      "api",
      "audit",
      "authenticator",
      "controllerManager",
      "scheduler"
    ])
    node_groups = list(object({
      name           = string
      ami_type       = optional(string)
      capacity_type  = optional(string, "ON_DEMAND")
      instance_types = optional(list(string), ["c3.large"])
      desired_size   = optional(number, 3)
      min_size       = optional(number, 3)
      max_size       = optional(number, 6)
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
