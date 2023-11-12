// aws variables
variable "aws-access-key" {
  type      = string
  sensitive = true
}
variable "aws-secret-key" {
  type      = string
  sensitive = true
}
variable "aws-region" {
  type = string
}
variable "aws-ecr-key" {
  type      = string
  sensitive = true
}

// github variables
variable "github-access-token" {
  type      = string
  sensitive = true
}
variable "github-owner" {
  type      = string
  sensitive = false
  default   = "lutergs-dev"
}

// vultr variables
variable "vultr-api-token" {
  type      = string
  sensitive = true
}

// cloudflare variables
variable "cloudflare-global-api-key" {
  type      = string
  sensitive = true
}

// oracle setting
variable "oracle-tenancy-ocid" {
  type      = string
  sensitive = true
}
variable "oracle-user-ocid" {
  type      = string
  sensitive = true
}
variable "oracle-private-key" {
  type      = string
  sensitive = true
}
variable "oracle-fingerprint" {
  type      = string
  sensitive = true
}
variable "oracle-region" {
  type      = string
}
variable "oracle-instance-ssh-authorized-keys" {
  type      = map(string)
  sensitive = true
}
variable "oracle-instance-ssh-new-authorized-keys" {
  type      = map(string)
  sensitive = true
}

// kubernetes variables
variable "k8s-host"                   { type = string }
variable "k8s-client-certificate"     { type = string }
variable "k8s-client-key"             { type = string }
variable "k8s-cluster-ca-certificate" { type = string }

// module variables
variable "lutergs-backend-kubernetes-secret"        { type = map(any) }
variable "lutergs-backend-batch-kubernetes-secret"  { type = map(string) }
variable "lutergs-frontend-kubernetes-secret"       { type = map(any) }
