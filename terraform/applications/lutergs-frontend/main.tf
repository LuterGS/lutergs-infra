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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region = var.aws-region
}

provider "github" {
  token = var.github-access-token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "cloudflare" {
  email         = "lutergs@lutergs.dev"
  api_key       = var.cloudflare-global-api-key
}