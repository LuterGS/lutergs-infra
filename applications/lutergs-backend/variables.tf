// new setting
variable "aws" {
  type = object({
    github-oidc-provider = any
    access-key = string
    secret-key = string
    region = string
  })
}
variable "github" {
  type = object({
    access-token = string
    owner = string
  })
}
variable "kubernetes" {
  type = object({
    host = string
    client-certificate = string
    client-key = string
    cluster-ca-certificate = string
    namespace = string
    load-balancer-ipv4 = string
  })
}
variable "cloudflare" {
  type = object({
    email = string
    global-api-key = string
    zone-id = string
  })
}
variable "else" {
  type = object({
    domain-name = string
  })
}

//else
variable "kubernetes-secret" {
  type =  map(any)
}

