

# resource "aws_iam_role" "external_dns" {
#   name = "external-dns"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           "Federated" = "${var.eks_oidc_arn}"
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",

#         Condition = {
#           "StringEquals" = {
#             "${var.eks_oidc_issuer_url}:aud" = "sts.amazonaws.com",
#             "${var.eks_oidc_issuer_url}:sub" = "system:serviceaccount:external-dns:external-dns"
#           }
#         }
#       },
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = "${var.eks_oidc_arn}"
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals : {
#             "${var.eks_oidc_issuer_url}:aud" = "sts.amazonaws.com",
#             "${var.eks_oidc_issuer_url}:sub" = "system:serviceaccount:external-dns:external-dns-sa"
#           }
#         }
#       }
#     ]
#   })
# }

# data "aws_iam_policy_document" "route53_policy_document" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "route53:ChangeResourceRecordSets"
#     ]
#     resources = [
#       "arn:aws:route53:::hostedzone/*"
#     ]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "route53:GetChange",
#       "route53:ListHostedZones",
#       "route53:ListResourceRecordSets",
#       "route53:ListHostedZonesByName"
#     ]
#     resources = [
#       "*"
#     ]
#   }
# }



# resource "aws_iam_policy" "external_dns_role_policy" {
#   name        = "external-dns-policy"
#   path        = "/"
#   description = "external-dns-policy"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = data.aws_iam_policy_document.route53_policy_document.json
# }

# resource "aws_iam_policy_attachment" "external_dns_role_policy_attachment" {
#   name       = "external-dns-role-policy-attachment"
#   roles      = [aws_iam_role.external_dns.name]
#   policy_arn = aws_iam_policy.external_dns_role_policy.arn
# }

module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = values(module.zones.route53_zone_zone_arn)

  tags = {
    Environment = "management"
  }
}