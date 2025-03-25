terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "terraform-eks-argocd-state"
    # dynamodb_table = "terraform-state-lock-darwin-marvel-app-dev"
    key     = "terraform-eks-argocd/dev/terraform.tfstate"
    region  = "eu-west-1"
    profile = "stage013"
  }
}
