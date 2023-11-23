terraform {
  backend "pg" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
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

    confluent = {
      source = "confluentinc/confluent"
      version = "1.55.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "kubernetes" {
  host                    = var.kubernetes-info.host
  client_certificate      = base64decode(var.kubernetes-info.client-certificate)
  client_key              = base64decode(var.kubernetes-info.client-key)
  cluster_ca_certificate  = base64decode(var.kubernetes-info.cluster-ca-certificate)
}

provider "cloudflare" {
  email         = var.cloudflare-info.email
  api_key       = var.cloudflare-info.global-api-key
}

provider "kubectl" {
  load_config_file = false
  host                    = var.kubernetes-info.host
  client_certificate      = base64decode(var.kubernetes-info.client-certificate)
  client_key              = base64decode(var.kubernetes-info.client-key)
  cluster_ca_certificate  = base64decode(var.kubernetes-info.cluster-ca-certificate)
}

provider "helm" {
  kubernetes {
    host                    = var.kubernetes-info.host
    client_certificate      = base64decode(var.kubernetes-info.client-certificate)
    client_key              = base64decode(var.kubernetes-info.client-key)
    cluster_ca_certificate  = base64decode(var.kubernetes-info.cluster-ca-certificate)
  }
}

provider "aws" {
  access_key  = var.aws-info.access-key
  secret_key  = var.aws-info.secret-key
  region      = var.aws-info.region
}

provider "github" {
  token = var.github-info.access-token
  owner = var.github-info.owner
}

provider "oci" {
  tenancy_ocid = var.oci-info.tenancy-ocid
  user_ocid = var.oci-info.user-ocid
  private_key = var.oci-info.private-key
  fingerprint = var.oci-info.fingerprint
  region = var.oci-info.region
}

provider "confluent" {
  cloud_api_key = var.confluent-cloud-info.cloud_api_key
  cloud_api_secret = var.confluent-cloud-info.cloud_api_secret
}



