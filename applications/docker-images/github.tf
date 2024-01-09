resource "github_repository" "default" {
  name = "docker-images"
  description = "kubernetes 에서 사용하기 위한 custom image 의 집합입니다."
  visibility = "public"
}