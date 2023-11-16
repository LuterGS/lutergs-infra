resource "github_repository" "default" {
  name = "aws-secret-updater"
  description = "AWS ECR 접근 secret 을 업데이트하는 container 입니다."
  visibility = "public"
}