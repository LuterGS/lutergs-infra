resource "github_actions_organization_secret" "k8s-config" {
  secret_name     = "K8S_CONFIG"
  visibility      = "all"
  plaintext_value = file("${path.module}/auths/config")
}

resource "github_actions_organization_variable" "k8s-version" {
  value         = "v1.27.6"
  variable_name = "K8S_VERSION"
  visibility    = "all"
}

resource "github_actions_organization_variable" "aws-region" {
  value         = var.aws-region
  variable_name = "AWS_REGION"
  visibility    = "all"
}