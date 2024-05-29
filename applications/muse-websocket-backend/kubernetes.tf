resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "muse-websocket-backend-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    KAFKA_BOOTSTRAP_SERVERS = var.kubernetes-secret.KAFKA_BOOTSTRAP_SERVERS
    KAFKA_API_KEY = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET = var.kubernetes-secret.KAFKA_API_SECRET
    KAFKA_CLIENT_ID = var.kubernetes-secret.KAFKA_CLIENT_ID
    KAFKA_TRUSTSTORE_PASSWORD = var.kubernetes-secret.KAFKA_TRUSTSTORE_PASSWORD

    REDIS_SENTINEL_MASTER_NAME = var.kubernetes-secret.REDIS_SENTINEL_MASTER_NAME
    REDIS_SENTINEL_NODES = var.kubernetes-secret.REDIS_SENTINEL_NODES

    MAIN_SERVER_URL = var.kubernetes-secret.MAIN_SERVER_URL
  }
}


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

        volume {
          name = "kafka-truststore"
          secret {
            secret_name = "kafka-truststore"
          }
        }

        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "muse-websocket-server"

          env_from {
            secret_ref {
              name = kubernetes_secret.deployment-secret.metadata[0].name
            }
          }
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
          env {
            name = "KAFKA_TRUSTSTORE_PATH"
            value = "/etc/truststore/truststore.jks"
          }
          volume_mount {
            mount_path = "/etc/truststore"
            name       = "kafka-truststore"
            read_only  = true
          }
          resources {}
        }
      }
    }
  }
}



resource "kubernetes_service" "default" {
  metadata {
    name = "muse-websocket-backend-service"
    namespace = var.kubernetes.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.default.metadata[0].labels.app
    }
    session_affinity = "ClientIP"
    port {
      port = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_manifest" "virtual-service" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind = "VirtualService"
    metadata = {
      name = "muse-websocket-backend"
      namespace = var.kubernetes.namespace
    }
    spec = {
      hosts = [
        "${var.else.domain-name}.lutergs.dev"
      ]
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


resource "kubernetes_manifest" "destination-rule" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind = "DestinationRule"
    metadata = {
      name = "muse-websocket-backend-rule"
      namespace = var.kubernetes.namespace
    }
    spec = {
      host = "${kubernetes_service.default.metadata[0].name}.${var.kubernetes.namespace}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = {
          consistentHash = {
            httpHeaderName = "Authorization"
          }
        }
      }
    }
  }
}