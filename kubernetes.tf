resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cloudflare-api-token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  data = {
    "api-token" = cloudflare_api_token.cert-manager-api-token.value
  }
}

module "cert_manager" {
  source                = "terraform-iaac/cert-manager/kubernetes"

  namespace_name        = kubernetes_namespace.cert-manager.metadata[0].name
  create_namespace      = false
  cluster_issuer_email  = "lutergs@lutergs.dev"
  solvers = [
    {
      dns01 = {
        cloudflare = {
          email = "lutergs@lutergs.dev"
          apiTokenSecretRef = {
            name = kubernetes_secret.cloudflare-api-token.metadata[0].name
            key = "api-token"
          }
        }
      }
    }
  ]
}


resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "kubernetes_namespace" "lutergs" {
  metadata {
    name = "lutergs"
  }
}

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"
  namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  ip_address = "152.70.95.33"
}

resource "kubernetes_ingress_v1" "nginx-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "nginx-ingress"
    namespace = "lutergs"
    annotations = {
      "cert-manager.io/cluster-issuer" = module.cert_manager.cluster_issuer_name
    }
  }
  spec {
    ingress_class_name = "nginx"

    // rule for lutergs-frontend
    tls {
      hosts = ["lutergs.dev"]
      secret_name = "lutergs-dev-tls"
    }
    rule {
      host = "lutergs.dev"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = module.lutergs-frontend.kubernetes-service
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    // rule for lutergs-backend
    tls {
      hosts = ["${var.lutergs-backend-domain}.lutergs.dev"]
      secret_name = "${var.lutergs-backend-domain}-lutergs-dev-tls"
    }
    rule {
      host = "${var.lutergs-backend-domain}.lutergs.dev"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = module.lutergs-backend.kubernetes-service
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
