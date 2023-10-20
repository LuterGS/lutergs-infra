// aws settings
variable "aws-github-oidc-provider"   {}
variable "aws-access-key"             { type = string }
variable "aws-secret-key"             { type = string }
variable "aws-region"                 { type = string }

// github settings
variable "github-access-token"        { type = string }

// kubernetes settings
variable "k8s-host"                   { type = string }
variable "k8s-client-certificate"     { type = string }
variable "k8s-client-key"             { type = string }
variable "k8s-cluster-ca-certificate" { type = string }
variable "kubernetes-secret"          { type = map(string) }
variable "kubernetes-version"         { type = string }

// cloudflare variables
variable "cloudflare-global-api-key"  { type = string }
variable "cloudflare-zone-id"         { type = string }

// vultr variables
variable "load-balancer-public-ipv4"  { type = string }

// domain settings
variable "domain-name"                { type = string }
