variable "aws" {
  type = object({
    github-oidc-provider = any
    access-key = string
    secret-key = string
    region = string
  })
  sensitive = true
}

variable "github" {
  type = object({
    access-token = string
    owner = string
  })
  sensitive = true
}

variable "kubernetes" {
  type = object({
    host = string
    client-certificate = string
    client-key = string
    cluster-ca-certificate = string
    namespace = string
    load-balancer-ipv4 = string
    image-pull-secret-name = string
    ingress-namespace = string
    ingress-name = string
  })
}

variable "cloudflare" {
  type = object({
    email = string
    global-api-key = string
    zone-id = string
  })
}

variable "kubernetes-secret"  { type = map(any) }
variable "else"               { type = map(any) }
