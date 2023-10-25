module "lutergs-backend" {
  source = "./applications/lutergs-backend"

  aws = {
    github-oidc-provider = aws_iam_openid_connect_provider.github-oidc-provider
    access-key           = var.aws-access-key
    secret-key           = var.aws-secret-key
    region               = var.aws-region
  }
  github = {
    access-token = var.github-access-token
    owner = var.github-owner
  }
  kubernetes = {
    host = var.k8s-host
    client-certificate = var.k8s-client-certificate
    client-key = var.k8s-client-key
    cluster-ca-certificate = var.k8s-cluster-ca-certificate
    namespace = kubernetes_namespace.lutergs.metadata[0].name
    load-balancer-ipv4 = oci_core_instance.k8s-master-bak.public_ip
  }
  cloudflare = {
    email = "lutergs@lutergs.dev"
    global-api-key = var.cloudflare-global-api-key
    zone-id = cloudflare_zone.lutergs_dev.id
  }
  else = {
    domain-name = var.lutergs-backend-domain
  }
  kubernetes-secret           = var.lutergs-backend-kubernetes-secret
}

module "lutergs-backend-batch" {
  source = "./applications/lutergs-backend-batch"
  aws-github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key              = var.aws-access-key
  aws-secret-key              = var.aws-secret-key
  aws-region                  = var.aws-region
  aws-ecr-key                 = var.aws-ecr-key
  github-access-token         = var.github-access-token
  github-owner                = var.github-owner
  k8s-host                    = var.k8s-host
  k8s-cluster-ca-certificate  = var.k8s-cluster-ca-certificate
  k8s-client-certificate      = var.k8s-client-certificate
  k8s-client-key              = var.k8s-client-key
  kubernetes-secret           = var.lutergs-backend-batch-kubernetes-secret
  kubernetes-version          = "v1.27.2"
}

module "lutergs-frontend" {
  source = "./applications/lutergs-frontend"
  aws-github-oidc-provider    = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key              = var.aws-access-key
  aws-secret-key              = var.aws-secret-key
  aws-region                  = var.aws-region
  github-access-token         = var.github-access-token
  github-owner                = var.github-owner
  k8s-host                    = var.k8s-host
  k8s-cluster-ca-certificate  = var.k8s-cluster-ca-certificate
  k8s-client-certificate      = var.k8s-client-certificate
  k8s-client-key              = var.k8s-client-key
  kubernetes-secret           = var.lutergs-frontend-kubernetes-secret
  kubernetes-version          = "v1.27.2"
  cloudflare-global-api-key   = var.cloudflare-global-api-key
  cloudflare-zone-id          = cloudflare_zone.lutergs_dev.id
  load-balancer-public-ipv4   = oci_core_instance.k8s-master-bak.public_ip
}

module "lutergs-infra" {
  source = "./applications/lutergs-infra"
  github-access-token         = var.github-access-token
  github-owner                = var.github-owner
}