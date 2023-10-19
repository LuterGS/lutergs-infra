resource "github_repository" "default" {
  name = "lutergs-frontend"
  description = "lutergs.dev 의 프론트 페이지입니다."
  visibility = "public"
  has_downloads = true
  has_issues = true
  has_projects = true
  has_wiki = true
  homepage_url = "https://lutergs.dev"
}

resource "github_actions_secret" "k8s-config" {
  repository = github_repository.default.name
  secret_name = "K8S_CONFIG"
}

resource "github_actions_variable" "k8s-version" {
  repository = github_repository.default.name
  variable_name = "K8S_VERSION"
  value = var.kubernetes-version
}

resource "github_repository_environment" "main" {
  repository = github_repository.default.name
  environment = "main"
}

resource "github_actions_environment_secret" "aws-connect-arn" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  secret_name = "AWS_CONNECT_ARN"
  plaintext_value = aws_iam_role.default_role.arn
}

resource "github_actions_environment_variable" "aws-region" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "AWS_REGION"
  value = var.aws-region
}

resource "github_actions_environment_variable" "ecr-repository" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "ECR_REPOSITORY_NAME"
  value = aws_ecr_repository.default.name
}

resource "github_actions_environment_variable" "k8s-namespace" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "K8S_NAMESPACE"
  value = kubernetes_deployment.default.metadata[0].namespace
}

resource "github_actions_environment_variable" "k8s-deployment-name" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "K8S_DEPLOYMENT_NAME"
  value = kubernetes_deployment.default.metadata[0].name
}