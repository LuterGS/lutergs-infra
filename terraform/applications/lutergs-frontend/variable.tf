// aws settings
variable "aws-github-oidc-provider"   {}
variable "aws-access-key"             { type = string }
variable "aws-secret-key"             { type = string }
variable "aws-region"                 { type = string }
variable "aws-ecr-key"                { type = map(string) }

// github settings
variable "github-access-token"        { type = string }

// kubernetes settings
variable "kubernetes-secret"          { type = map(string) }
variable "kubernetes-version"         { type = string }

// cloudflare variables
variable "cloudflare-global-api-key"  { type = string }
variable "cloudflare-zone-id"         { type = string }

// vultr variables
variable "load-balancer-public-ipv4"  { type = string }