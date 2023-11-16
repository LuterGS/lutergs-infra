variable "aws" {
  type = object({
    access-key = string
    secret-key = string
    region = string
  })
}
variable "github" {
  type = object({
    access-token = string
    owner = string
  })
}
variable "kubernetes" {
  type = object({
    host = string
    client-certificate = string
    client-key = string
    cluster-ca-certificate = string
    namespace = string
    kubeconfig-file = string
  })
}
variable "kubernetes-secret" {
  type = object({
    aws-repository-url = string
  })
  sensitive = true
}


variable "ecr-access-secret-name" {
  type = string
  default = "aws-ecr-secret"
}

output "kubernetes-secret-name" {
  value = var.ecr-access-secret-name
}

