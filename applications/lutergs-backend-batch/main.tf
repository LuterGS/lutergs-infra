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
  owner = var.github-owner
}

provider "kubernetes" {
  host                    = var.k8s-host
  client_certificate      = base64decode(var.k8s-client-certificate)
  client_key              = base64decode(var.k8s-client-key)
  cluster_ca_certificate  = base64decode(var.k8s-cluster-ca-certificate)
}