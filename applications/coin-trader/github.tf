resource "github_repository" "default" {
  name = "coin_trader"
  description = "업비트의 암호화폐를 자동으로 거래하는 프로젝트입니다."
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

resource "github_actions_environment_variable" "manager-ecr-repository" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "MANAGER_ECR_REPOSITORY_NAME"
  value = aws_ecr_repository.manager.name
}

resource "github_actions_environment_variable" "worker-ecr-repository" {
  repository = github_repository.default.name
  environment = github_repository_environment.main.environment
  variable_name = "WORKER_ECR_REPOSITORY_NAME"
  value = aws_ecr_repository.worker.name
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
  value = kubernetes_deployment.manager.metadata[0].name
}