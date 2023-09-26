terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

    vultr = {
      source = "vultr/vultr"
      version = "2.16.1"
    }
  }
  required_version = ">= 1.2.0"
}


provider "aws" {
  access_key  = var.aws-access-key
  secret_key  = var.aws-secret-key
  region      = var.aws-region
}

provider "github" {
  token       = var.github-access-token
}

module "infra" {
  source = "./infra"
  vultr-apk-token   = var.vultr-apk-token
  aws-access-key    = var.aws-access-key
  aws-secret-key    = var.aws-secret-key
  aws-region        = var.aws-region
}

module "lutergs-backend" {
  source = "./applications/lutergs-backend"
  aws-github-oidc-provider  = aws_iam_openid_connect_provider.github-oidc-provider
  aws-access-key            = var.aws-access-key
  aws-secret-key            = var.aws-secret-key
  aws-region                = var.aws-region
  aws-ecr-key               = var.aws-ecr-key
  github-access-token       = var.github-access-token
  kubernetes-secret         = var.lutergs-backend-kubernetes-secret
  kubernetes-version        = module.infra.k8s-version
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
  kubernetes-version        = module.infra.k8s-version
}

module "lutergs-infra" {
  source = "./applications/lutergs-infra"
  github-access-token       = var.github-access-token
}




