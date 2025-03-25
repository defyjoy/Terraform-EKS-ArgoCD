
# output "external_dns_role_arn" {
#   description = "description"
#   value       = aws_iam_role.external_dns.arn
# }

output "external_dns_route53_zone_arns" {
  value = values(module.zones.route53_zone_zone_arn)
}