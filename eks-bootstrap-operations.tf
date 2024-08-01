resource "kubernetes_namespace" "operations" {
  provider = kubernetes
  metadata {
    name = var.eks_bootstrap_prometheus.namespace
  }

  depends_on = [helm_release.fluentbit]
}

module "lb-controller" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [{
      name  = "vpcId"
      value = aws_vpc.cluster.id
    }]

    wait = true
  }

  depends_on = [kubernetes_namespace.operations, helm_release.kafka, helm_release.postgresql, helm_release.prometheus, helm_release.consumer, helm_release.processor, helm_release.cve_operator, helm_release.grafana]
}

resource "time_sleep" "wait_for_lb_controller" {
  depends_on      = [module.lb-controller.aws_load_balancer_controller]
  create_duration = var.wait_duration_aws_load_balancer_controller
}

module "operations" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_cert_manager                   = true
  cert_manager_route53_hosted_zone_arns = var.eks_bootstrap_operations.route53_hosted_zone_arns
  cert_manager                          = var.eks_bootstrap_operations.cert_manager

  enable_external_dns            = true
  external_dns_route53_zone_arns = var.eks_bootstrap_operations.route53_hosted_zone_arns
  external_dns                   = var.eks_bootstrap_operations.external_dns

  depends_on = [kubernetes_namespace.operations, time_sleep.wait_for_lb_controller, module.lb-controller.aws_load_balancer_controller]
}
