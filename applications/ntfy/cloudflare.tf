resource "cloudflare_record" "default" {
  zone_id = var.cloudflare.zone-id
  name    = "ntfy"
  value   = var.kubernetes.load-balancer-ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
  comment = "LuterGS custom ntfy server"
}