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
  cloudflare-global-api-key = var.cloudflare-global-api-key
  cloudflare-zone-id        = cloudflare_zone.lutergs_dev.id
  load-balancer-public-ipv4 = vultr_load_balancer.default.ipv4
  domain-name               = var.lutergs-backend-domain
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

module "lutergs-frontend" {
  source = "./applications/lutergs-frontend"
  aws-github-oidc-provider  = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key            = var.aws-access-key
  aws-secret-key            = var.aws-secret-key
  aws-region                = var.aws-region
  aws-ecr-key               = var.aws-ecr-key
  github-access-token       = var.github-access-token
  kubernetes-secret         = var.lutergs-frontend-kubernetes-secret
  kubernetes-version        = "v1.27.2"
  cloudflare-global-api-key = var.cloudflare-global-api-key
  cloudflare-zone-id        = cloudflare_zone.lutergs_dev.id
  load-balancer-public-ipv4 = vultr_load_balancer.default.ipv4
}

module "lutergs-infra" {
  source = "./applications/lutergs-infra"
  github-access-token       = var.github-access-token
}