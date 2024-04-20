resource "github_repository" "default" {
  name = "muse-backend"
  description = "음악 공유 프로젝트 Muse 의 백엔드 서비스입니다."
  visibility = "public"
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

resource "github_actions_environment_variable" "active-profile" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "PROFILE"
  value = "server"
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
  value = var.kubernetes.namespace
}

resource "github_actions_environment_variable" "k8s-deployment-name" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "K8S_DEPLOYMENT_NAME"
  value = kubernetes_deployment.default.metadata[0].name
}

resource "github_actions_environment_variable" "dockerfile-name" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "DOCKERFILE"
  value = "Dockerfile"
}