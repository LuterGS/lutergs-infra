// aws settings
variable "aws-github-oidc-provider"   {}
variable "aws-access-key"             { type = string }
variable "aws-secret-key"             { type = string }
variable "aws-region"                 { type = string }
variable "aws-ecr-key"                { type = string }

// github settings
variable "github-access-token"        { type = string }
variable "github-owner"               { type = string }

// kubernetes settings
variable "k8s-host"                   { type = string }
variable "k8s-client-certificate"     { type = string }
variable "k8s-client-key"             { type = string }
variable "k8s-cluster-ca-certificate" { type = string }
variable "kubernetes-secret"          { type = map(string) }
variable "kubernetes-version"         { type = string }


