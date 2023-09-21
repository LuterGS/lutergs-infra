resource "github_repository" "default" {
  name = "lutergs-backend-batch"
  description = "lutergs app 의 알람 요청 백엔드 서비스입니다."
  visibility = "public"
}

resource "github_repository_environment" "env_default" {
  repository = github_repository.default.name
  environment = "main"
}

resource "github_actions_environment_secret" "aws-connect-arn" {
  repository = github_repository.default.name
  environment = github_repository_environment.env_default.environment
  secret_name = "AWS_CONNECT_ARN"
  plaintext_value = aws_iam_role.default_role.arn
}

resource "github_actions_environment_variable" "aws-region" {
  repository = github_repository.default.name
  environment = github_repository_environment.env_default.environment
  variable_name = "AWS_REGION"
  value = var.aws-region
}

resource "github_actions_environment_variable" "active-profile" {
  repository = github_repository.default.name
  environment = github_repository_environment.env_default.environment
  variable_name = "PROFILE"
  value = "server"
}

resource "github_actions_environment_variable" "ecr-repository" {
  repository = github_repository.default.name
  environment = github_repository_environment.env_default.environment
  variable_name = "ECR_REPOSITORY_NAME"
  value = aws_ecr_repository.default.name
}