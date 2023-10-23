terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
  required_version = ">= 1.2.0"
}

provider "github" {
  token = var.github-access-token
  owner = var.github-owner
}