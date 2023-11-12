terraform {
  cloud {
    organization = "LuterGS"

    workspaces {
      name = "lutergs-server"
    }
  }

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
      version = ">= 2.11.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    oci = {
      source = "oracle/oci"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "vultr" {
  api_key     = var.vultr-api-token
  rate_limit  = 100
  retry_limit = 3
}

provider "kubernetes" {
  host                    = var.k8s-host
  client_certificate      = base64decode(var.k8s-client-certificate)
  client_key              = base64decode(var.k8s-client-key)
  cluster_ca_certificate  = base64decode(var.k8s-cluster-ca-certificate)
}

provider "cloudflare" {
  email         = "lutergs@lutergs.dev"
  api_key       = var.cloudflare-global-api-key
}

provider "kubectl" {
  load_config_file = false
  host                    = var.k8s-host
  client_certificate      = base64decode(var.k8s-client-certificate)
  client_key              = base64decode(var.k8s-client-key)
  cluster_ca_certificate  = base64decode(var.k8s-cluster-ca-certificate)
}

provider "helm" {
  kubernetes {
    host                    = var.k8s-host
    client_certificate      = base64decode(var.k8s-client-certificate)
    client_key              = base64decode(var.k8s-client-key)
    cluster_ca_certificate  = base64decode(var.k8s-cluster-ca-certificate)
  }
}

provider "aws" {
  access_key  = var.aws-access-key
  secret_key  = var.aws-secret-key
  region      = var.aws-region
}

provider "github" {
  token = var.github-access-token
  owner = var.github-owner
}

provider "oci" {
  tenancy_ocid = var.oracle-tenancy-ocid
  user_ocid = var.oracle-user-ocid
  private_key = var.oracle-private-key
  fingerprint = var.oracle-fingerprint
  region = var.oracle-region
}






