module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    # "terraform-aws-modules-example.com" = {
    #   comment = "terraform-aws-modules-examples.com (production)"
    #   tags = {
    #     env = "production"
    #   }
    # }

    "jrconline.xyz" = {
      comment = "jrconline.xyz"

      tags = {
        env = "production"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
