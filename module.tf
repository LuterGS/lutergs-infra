module "lutergs-backend" {
  source = "./applications/lutergs-backend"
  aws = {
    github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
    access-key              = var.aws-info.access-key
    secret-key              = var.aws-info.secret-key
    region                  = var.aws-info.region
  }
  github = {
    access-token            = var.github-info.access-token
    owner                   = var.github-info.owner
  }
  kubernetes = {
    host                    = var.kubernetes-info.host
    client-certificate      = var.kubernetes-info.client-certificate
    client-key              = var.kubernetes-info.client-key
    cluster-ca-certificate  = var.kubernetes-info.cluster-ca-certificate
    namespace               = kubernetes_namespace.lutergs.metadata[0].name
    load-balancer-ipv4      = oci_core_instance.k8s-master.public_ip
    image-pull-secret-name  = module.aws-ecr-secret-updater.kubernetes-secret-name
  }
  cloudflare = {
    email                   = var.cloudflare-info.email
    global-api-key          = var.cloudflare-info.global-api-key
    zone-id                 = cloudflare_zone.lutergs_dev.id
  }
  else = {
    domain-name             = var.lutergs-backend-domain
  }
  kubernetes-secret         = var.lutergs-backend-kubernetes-secret
}

module "lutergs-backend-batch" {
  source = "./applications/lutergs-backend-batch"
  aws = {
    github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
    access-key              = var.aws-info.access-key
    secret-key              = var.aws-info.secret-key
    region                  = var.aws-info.region
  }
  github = {
    access-token            = var.github-info.access-token
    owner                   = var.github-info.owner
  }
  kubernetes = {
    host                    = var.kubernetes-info.host
    client-certificate      = var.kubernetes-info.client-certificate
    client-key              = var.kubernetes-info.client-key
    cluster-ca-certificate  = var.kubernetes-info.cluster-ca-certificate
    namespace               = kubernetes_namespace.lutergs.metadata[0].name
    image-pull-secret-name  = module.aws-ecr-secret-updater.kubernetes-secret-name
  }
  kubernetes-secret         = var.lutergs-backend-batch-kubernetes-secret
}

module "lutergs-frontend" {
  source = "./applications/lutergs-frontend"
  aws = {
    github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
    access-key              = var.aws-info.access-key
    secret-key              = var.aws-info.secret-key
    region                  = var.aws-info.region
  }
  github = {
    access-token            = var.github-info.access-token
    owner                   = var.github-info.owner
  }
  kubernetes = {
    host                    = var.kubernetes-info.host
    client-certificate      = var.kubernetes-info.client-certificate
    client-key              = var.kubernetes-info.client-key
    cluster-ca-certificate  = var.kubernetes-info.cluster-ca-certificate
    namespace               = kubernetes_namespace.lutergs.metadata[0].name
    load-balancer-ipv4      = oci_core_instance.k8s-master.public_ip
    image-pull-secret-name  = module.aws-ecr-secret-updater.kubernetes-secret-name
  }
  cloudflare = {
    email                   = var.cloudflare-info.email
    global-api-key          = var.cloudflare-info.global-api-key
    zone-id                 = cloudflare_zone.lutergs_dev.id
  }
  kubernetes-secret           = var.lutergs-frontend-kubernetes-secret
}

module "lutergs-frontend-pwa" {
  source = "./applications/lutergs-frontend-pwa"
  aws = {
    github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
    access-key              = var.aws-info.access-key
    secret-key              = var.aws-info.secret-key
    region                  = var.aws-info.region
  }
  github = {
    access-token            = var.github-info.access-token
    owner                   = var.github-info.owner
  }
  kubernetes = {
    host                    = var.kubernetes-info.host
    client-certificate      = var.kubernetes-info.client-certificate
    client-key              = var.kubernetes-info.client-key
    cluster-ca-certificate  = var.kubernetes-info.cluster-ca-certificate
    namespace               = kubernetes_namespace.lutergs.metadata[0].name
    load-balancer-ipv4      = oci_core_instance.k8s-master.public_ip
    image-pull-secret-name  = module.aws-ecr-secret-updater.kubernetes-secret-name
  }
  cloudflare = {
    email                   = var.cloudflare-info.email
    global-api-key          = var.cloudflare-info.global-api-key
    zone-id                 = cloudflare_zone.lutergs_dev.id
  }
  kubernetes-secret         = var.lutergs-frontend-pwa-kubernetes-secret
  else = {
    domain-name             = var.lutergs-frontend-pwa-public.domain
  }
}

module "lutergs-infra" {
  source = "./applications/lutergs-infra"
  github-access-token         = var.github-info.access-token
  github-owner                = var.github-info.owner
}

module "aws-ecr-secret-updater" {
  source = "./applications/aws-ecr-secret-updater"
  aws = {
    access-key              = var.aws-info.access-key
    secret-key              = var.aws-info.secret-key
    region                  = var.aws-info.region
  }
  github = {
    access-token            = var.github-info.access-token
    owner                   = var.github-info.owner
  }
  kubernetes = {
    host = var.kubernetes-info.host
    client-certificate      = var.kubernetes-info.client-certificate
    client-key              = var.kubernetes-info.client-key
    cluster-ca-certificate  = var.kubernetes-info.cluster-ca-certificate
    namespace               = kubernetes_namespace.lutergs.metadata[0].name
    kubeconfig-file         = file("${path.module}/auths/config")
  }
  kubernetes-secret = {
    aws-repository-url      = module.lutergs-backend.aws_ecr_repository_url
  }
}