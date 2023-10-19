resource "cloudflare_record" "default" {
  zone_id = var.cloudflare-zone-id
  name    = "@"
  value   = var.load-balancer-public-ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
  comment = "frontend server of lutergs.dev"
}