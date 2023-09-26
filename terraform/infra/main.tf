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

provider "vultr" {
  api_key = var.vultr-apk-token
  rate_limit = 100
  retry_limit = 3
}

provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region = var.aws-region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
