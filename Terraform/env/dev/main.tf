#########################################
##              BASE MODULE            ##
#########################################

module "base" {
  source = "../../base"

  eks_oidc_arn        = module.eks.oidc_provider_arn
  eks_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

}

################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = true

  # EKS Blueprints Addons
  enable_cert_manager = local.aws_addons.enable_cert_manager
  # enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  # enable_aws_fsx_csi_driver           = local.aws_addons.enable_aws_fsx_csi_driver
  # enable_aws_cloudwatch_metrics       = local.aws_addons.enable_aws_cloudwatch_metrics
  enable_aws_privateca_issuer = local.aws_addons.enable_aws_privateca_issuer
  # enable_cluster_autoscaler           = local.aws_addons.enable_cluster_autoscaler

  enable_external_dns = local.aws_addons.enable_external_dns
  # external_dns_route53_zone_arns = module.base.external_dns_route53_zone_arns

  enable_external_secrets             = local.aws_addons.enable_external_secrets
  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  # enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  # enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  # enable_aws_node_termination_handler = local.aws_addons.enable_aws_node_termination_handler
  # enable_karpenter                    = local.aws_addons.enable_karpenter
  # enable_velero                       = local.aws_addons.enable_velero
  # enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true


  # vpc_id = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_groups = {
    management = {
      instance_types = ["m5.large"]
      capacity_type  = "SPOT"


      min_size     = 1
      max_size     = 3
      desired_size = 3
    }
  }
  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  tags = local.tags
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
# module "gitops_bridge_bootstrap" {
#   source = "github.com/gitops-bridge-dev/terraform-helm-gitops-bridge?ref=v0.0.2"

#   cluster = {
#     metadata = local.addons_metadata
#     addons   = local.addons
#   }
# }

################################################################################
# Supporting Resources
################################################################################
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.0"

#   name = local.name
#   cidr = try(local.vpc_cidr, "10.23.0.0/16")

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

#   enable_nat_gateway = true
#   single_nat_gateway = true

#   public_subnet_tags = {
#     "kubernetes.io/role/elb" = 1
#   }

#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = 1
#   }

#   tags = local.tags
# }