resource "kubectl_manifest" "kong-crd" {
  yaml_body = file("${path.module}/assets/kong-crd-v1.0.0.yaml")
}

resource "kubectl_manifest" "kong-gateway-gatewayclass" {
  yaml_body = <<EOF
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: kong
  annotations:
    konghq.com/gatewayclass-unmanaged: 'true'

spec:
  controllerName: konghq.com/kic-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kong
spec:
  gatewayClassName: kong
  listeners:
  - name: proxy
    port: 80
    protocol: HTTP
EOF
}

resource "kubernetes_namespace" "kong" {
  metadata {
    name = "kong"
  }
}

resource "helm_release" "kong" {
  name = "kong-ingress-controller"
  namespace = kubernetes_namespace.kong.metadata[0].name
  repository = "https://charts.konghq.com"
  chart = "ingress"
  set {
    name  = "proxy.loadBalancerIP"
    value = oci_core_instance.k8s-master.public_ip
  }
}




resource "kubernetes_ingress_v1" "kong-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "kong-ingress"
    namespace = kubernetes_namespace.kong.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = module.cert_manager.cluster_issuer_name
    }
  }
  spec {
    ingress_class_name = "kong"

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
              name = kubernetes_service.frontend.metadata[0].name
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
              name = kubernetes_service.backend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    // rule for lutergs-frontend-pwa
    tls {
      hosts = ["${var.lutergs-frontend-pwa-public.domain}.lutergs.dev"]
      secret_name = "${var.lutergs-frontend-pwa-public.domain}-lutergs-dev-tls"
    }
    rule {
      host = "${var.lutergs-frontend-pwa-public.domain}.lutergs.dev"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend-pwa.metadata[0].name
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