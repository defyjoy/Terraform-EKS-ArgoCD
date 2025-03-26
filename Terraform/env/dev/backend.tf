terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "eks-terraform-argocd--backend-state"
    # dynamodb_table = "terraform-state-lock-darwin-marvel-app-dev"
    key     = "terraform-eks-argocd/dev/terraform.tfstate"
    region  = "eu-west-1"
    profile = "test"
  }
}
