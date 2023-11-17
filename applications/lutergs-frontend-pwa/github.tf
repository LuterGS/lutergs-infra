resource "github_repository" "default" {
  name = "frontend-pwa"
  description                 = "Svelte PWA 를 이용한 lutergs-frontend 앱입니다. 기존 lutergs-frontend 와 다른 기능을 선보일 예정입니다."
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = true
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

resource "github_actions_environment_secret" "push-key" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  secret_name = "PUSH_KEY"
  plaintext_value = var.kubernetes-secret.PUBLIC_PUSH_KEY
}

resource "github_actions_environment_secret" "backend-server" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  secret_name = "BACKEND_SERVER"
  plaintext_value = var.kubernetes-secret.PUBLIC_BACKEND_SERVER
}