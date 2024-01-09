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
