resource "cloudflare_record" "default" {
  zone_id = var.cloudflare.zone-id
  name    = var.else.domain-name
  value   = var.kubernetes.load-balancer-ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
  comment = "frontend server of app.lutergs.dev"
}