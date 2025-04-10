locals {
  name   = "terraform-eks-argocd"
  region = "eu-west-1"

  vpc_cidr = try(var.vpc_cidr, "10.23.0.0/16")
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_version = var.kubernetes_version

  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name }
  )

  aws_addons = {
    enable_cert_manager                 = try(var.addons.enable_cert_manager, true)
    enable_aws_load_balancer_controller = try(var.addons.enable_aws_load_balancer_controller, true)

    # enable_aws_efs_csi_driver           = try(var.addons.enable_aws_efs_csi_driver, false)
    # enable_aws_fsx_csi_driver           = try(var.addons.enable_aws_fsx_csi_driver, false)

    enable_aws_cloudwatch_metrics = try(var.addons.enable_aws_cloudwatch_metrics, false)
    enable_aws_privateca_issuer   = try(var.addons.enable_aws_privateca_issuer, false)
    enable_cluster_autoscaler     = try(var.addons.enable_cluster_autoscaler, false)
    enable_external_dns           = try(var.addons.enable_external_dns, false)
    enable_external_secrets       = try(var.addons.enable_external_secrets, true)

    # enable_fargate_fluentbit                     = try(var.addons.enable_fargate_fluentbit, false)
    # enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
    # enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
    # enable_karpenter                             = try(var.addons.enable_karpenter, false)
    # enable_velero                                = try(var.addons.enable_velero, false)
    # enable_aws_gateway_api_controller            = try(var.addons.enable_aws_gateway_api_controller, false)
    # enable_aws_ebs_csi_resources                 = try(var.addons.enable_aws_ebs_csi_resources, false)
    # enable_aws_secrets_store_csi_driver_provider = try(var.addons.enable_aws_secrets_store_csi_driver_provider, false)
    # enable_ack_apigatewayv2                      = try(var.addons.enable_ack_apigatewayv2, false)
    # enable_ack_dynamodb                          = try(var.addons.enable_ack_dynamodb, false)
    # enable_ack_s3                                = try(var.addons.enable_ack_s3, false)
    # enable_ack_rds                               = try(var.addons.enable_ack_rds, false)
    # enable_ack_prometheusservice                 = try(var.addons.enable_ack_prometheusservice, false)
    # enable_ack_emrcontainers                     = try(var.addons.enable_ack_emrcontainers, false)
    # enable_ack_sfn                               = try(var.addons.enable_ack_sfn, false)
    # enable_ack_eventbridge                       = try(var.addons.enable_ack_eventbridge, false)
  }

  oss_addons = {
    enable_argocd = try(var.addons.enable_argocd, true)
    # enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    # enable_argo_events                     = try(var.addons.enable_argo_events, false)
    # enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    # enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
    # enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    # enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
    # enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    # enable_kyverno                         = try(var.addons.enable_kyverno, false)
    # enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    # enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    # enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    # enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    # enable_vpa                             = try(var.addons.enable_vpa, false)
  }

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = module.vpc.vpc_id
    }
    # {
    #   addons_repo_url      = local.gitops_addons_url
    #   addons_repo_basepath = local.gitops_addons_basepath
    #   addons_repo_path     = local.gitops_addons_path
    #   addons_repo_revision = local.gitops_addons_revision
    # },
    # {
    #   workload_repo_url      = local.gitops_workload_url
    #   workload_repo_basepath = local.gitops_workload_basepath
    #   workload_repo_path     = local.gitops_workload_path
    #   workload_repo_revision = local.gitops_workload_revision
    # }
  )

  tags = {
    owner      = "joydeep"
    repository = "Terraform-EKS-ArgoCD"
    github_org = "SKF-Internal"
  }
}