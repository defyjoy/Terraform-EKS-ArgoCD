
resource "random_password" "zitadel_masterkey" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create a new secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "zitadel_masterkey" {
  name        = "zitade-masterkey" # Replace with your desired secret name
  description = "zitadel masterkey"
}

resource "aws_secretsmanager_secret_version" "elasticache_token_version" {
  secret_id = aws_secretsmanager_secret.zitadel_masterkey.id
  secret_string = jsonencode({
    token = random_password.zitadel_masterkey.result
  })
}