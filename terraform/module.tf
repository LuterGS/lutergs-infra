#module "infra" {
#  source = "./infra"
#  vultr-apk-token   = var.vultr-apk-token
#  aws-access-key    = var.aws-access-key
#  aws-secret-key    = var.aws-secret-key
#  aws-region        = var.aws-region
#}

module "lutergs-backend" {
  source = "./applications/lutergs-backend"
  aws-github-oidc-provider  = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key            = var.aws-access-key
  aws-secret-key            = var.aws-secret-key
  aws-region                = var.aws-region
  aws-ecr-key               = var.aws-ecr-key
  github-access-token       = var.github-access-token
  kubernetes-secret         = var.lutergs-backend-kubernetes-secret
  kubernetes-version        = "v1.27.2"
}

module "lutergs-backend-batch" {
  source = "./applications/lutergs-backend-batch"
  aws-github-oidc-provider  = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key            = var.aws-access-key
  aws-secret-key            = var.aws-secret-key
  aws-region                = var.aws-region
  aws-ecr-key               = var.aws-ecr-key
  github-access-token       = var.github-access-token
  kubernetes-secret         = var.lutergs-backend-batch-kubernetes-secret
  kubernetes-version        = "v1.27.2"
}

module "lutergs-infra" {
  source = "./applications/lutergs-infra"
  github-access-token       = var.github-access-token
}