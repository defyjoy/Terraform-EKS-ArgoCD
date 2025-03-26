variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
  default     = "10.23.0.0/16"
}

# variable "vpc_id" {
#   type        = string
#   description = "description"
# }

# variable "private_subnet_ids" {
#   type        = list(string)
#   description = "private subnet ids"
# }

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.32"
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
  }
}

