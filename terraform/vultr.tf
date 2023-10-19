resource "vultr_load_balancer" "default" {
  region = "icn"
  label  = "ac99927695614403fa60ba2e54a19fb2"
  balancing_algorithm = "roundrobin"

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port = 80
    backend_protocol = "tcp"
    backend_port = 32585
  }
  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port = 443
    backend_protocol = "tcp"
    backend_port = 32754
  }
}