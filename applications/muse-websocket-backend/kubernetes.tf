resource "kubernetes_deployment" "default" {

  metadata {
    name = "muse-websocket-server"
    namespace = var.kubernetes.namespace
    labels = {
      app = "muse-websocket-server"
    }
  }

  spec {
    replicas = "2"
    selector {
      match_labels = {
        app = "muse-websocket-server"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "muse-websocket-server"
        }
      }
      spec {
        image_pull_secrets {
          name = var.kubernetes.image-pull-secret-name
        }

        container {
          image = "busybox"
          image_pull_policy = "Always"
          name = "muse-websocket-server"
          command = ["sh", "-c", "sleep 1000000"]
          env {
            name = "KUBERNETES_HOSTNAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "KUBERNETES_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          resources {}
        }
      }
    }
#     service_name = ""
  }
}