terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "kubernetes" {
  host                    = var.kubernetes.host
  client_certificate      = base64decode(var.kubernetes.client-certificate)
  client_key              = base64decode(var.kubernetes.client-key)
  cluster_ca_certificate  = base64decode(var.kubernetes.cluster-ca-certificate)
}

provider "cloudflare" {
  email         = var.cloudflare.email
  api_key       = var.cloudflare.global-api-key
}