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

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.5.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "vultr" {
  api_key     = var.vultr-apk-token
  rate_limit  = 100
  retry_limit = 3
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "cloudflare" {
  email     = "lutergs@lutergs.dev"
  api_key   = var.cloudflare-global-api-key
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  access_key  = var.aws-access-key
  secret_key  = var.aws-secret-key
  region      = var.aws-region
}

provider "github" {
  token       = var.github-access-token
}






