# resource "kubernetes_persistent_volume_v1" "k8s-worker-3-pv" {
#   metadata {
#     name = "worker-3-pv"
#   }
#   spec {
#     capacity = {
#       storage = "3Gi"
#     }
#     volume_mode = "Filesystem"
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_reclaim_policy = "Delete"
#     persistent_volume_source {
#       local {
#         path = "/home/ubuntu/k8s-local-pv"
#       }
#     }
#     node_affinity {
#       required {
#         node_selector_term {
#           match_expressions {
#             key      = "kubernetes.io/hostname"
#             operator = "In"
#             values = ["k8s-worker-3"]
#           }
#         }
#       }
#     }
#   }
# }


resource "kubernetes_persistent_volume_claim" "default" {
  metadata {
    name = "ntfy-pvc"
    namespace = var.kubernetes.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "default" {
  metadata {
    name = "ntfy-config"
    namespace = var.kubernetes.namespace
  }
  data = {
    "server.yml" = <<EOF
base-url: "https://ntfy.lutergs.dev"
listen-http: ":80"

cache-file: "/var/ntfy/cache/cache.db"
attachment-cache-dir: "/var/ntfy/cache/attachments"

auth-file: "/var/ntfy/lib/user.db"
auth-default-access: "deny-all"

upstream-base-url: "https://ntfy.sh"
EOF
  }
}

resource "kubernetes_deployment" "default" {
  metadata {
    name = "ntfy"
    namespace = var.kubernetes.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "ntfy"
      }
    }
    template {
      metadata {
        labels = {
          app = "ntfy"
        }
      }
      spec {
        container {
          name = "ntfy"
          image = "binwiederhier/ntfy"
          command = ["/bin/sh", "-c"]
          args = ["mkdir -p /var/ntfy/cache; mkdir -p /var/ntfy/lib; for file in /var/ntfy/cache/cache.db /var/ntfy/lib/user.db; do if [ ! -f $file ]; then touch $file; fi; done; ntfy serve"]
          port {
            container_port = 80
            name = "http"
          }
          volume_mount {
            mount_path = "/etc/ntfy"
            name       = "config"
            read_only = "true"
          }
          volume_mount {
            mount_path = "/var/ntfy"
            name       = "ntfy-cache"
            read_only = "false"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.default.metadata[0].name
          }
        }
        volume {
          name = "ntfy-cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.default.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "default" {
  metadata {
    name = "ntfy-service"
    namespace = var.kubernetes.namespace
  }
  spec {
    selector = {
      app = "ntfy"
    }
    port {
      port = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "virtual-service" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind = "VirtualService"
    metadata = {
      name = "ntfy"
      namespace = var.kubernetes.namespace
    }
    spec = {
      hosts = ["ntfy.lutergs.dev"]
      gateways = ["${var.kubernetes.ingress-namespace}/${var.kubernetes.ingress-name}"]
      http = [{
        match = [{
          uri = {
            prefix = "/"
          }
        }]
        route = [{
          destination = {
            host = kubernetes_service.default.metadata[0].name
            port = {
              number = kubernetes_service.default.spec[0].port[0].port
            }
          }
        }]
      }]
    }
  }
}