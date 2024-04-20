resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "muse-backend-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    KAFKA_API_KEY = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET = var.kubernetes-secret.KAFKA_API_SECRET
    KAFKA_BOOTSTRAP_SERVERS = var.kubernetes-secret.KAFKA_BOOTSTRAP_SERVERS
    KAFKA_CLIENT_ID = var.kubernetes-secret.KAFKA_CLIENT_ID

    ORACLE_DESCRIPTOR_STRING = var.kubernetes-secret.ORACLE_DESCRIPTOR_STRING

    REDIS_CLUSTER_NODES = var.kubernetes-secret.REDIS_CLUSTER_NODES
    REDIS_SENTINEL_MASTER_NAME = var.kubernetes-secret.REDIS_SENTINEL_MASTER_NAME
    REDIS_SENTINEL_NODE = var.kubernetes-secret.REDIS_SENTINEL_NODE

    KUBERNETES_SERVICE = var.kubernetes-secret.KUBERNETES_SERVICE

    STREAMS_COMMUNICATION_KEY = var.kubernetes-secret.STREAMS_COMMUNICATION_KEY
    STREAMS_INPUT_TOPIC_NAME = var.kubernetes-secret.STREAMS_INPUT_TOPIC_NAME
    STREAMS_TTL_STORE = var.kubernetes-secret.STREAMS_TTL_STORE
    STREAMS_USER_NOW_PLAYING_STORE = var.kubernetes-secret.STREAMS_USER_NOW_PLAYING_STORE
    STREAMS_STOP_TIMEOUT_SECOND = var.kubernetes-secret.STREAMS_STOP_TIMEOUT_SECOND
    STREAMS_SCAN_FREQUENCY_SECOND = var.kubernetes-secret.STREAMS_SCAN_FREQUENCY_SECOND
  }
}


resource "kubernetes_deployment" "default" {

  metadata {
    name = "muse-backend"
    namespace = var.kubernetes.namespace
    labels = {
      app = "muse-backend"
    }
  }

  spec {
    replicas = "0"
    selector {
      match_labels = {
        app = "muse-backend"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "muse-backend"
        }
      }
      spec {
        image_pull_secrets {
          name = var.kubernetes.image-pull-secret-name
        }
        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "muse-backend"

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
            name = "KUBERNETES_SERVICE"
            value = "muse-backend-headless-service"
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
            name = "STREAMS_MACHINE_KEY"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          resources {}
        }
      }
    }
  }
}

resource "kubernetes_service" "headless" {
  metadata {
    name = "muse-backend-headless-service"
    namespace = var.kubernetes.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.default.metadata[0].labels.app
    }
    type = "ClusterIP"
    cluster_ip = "None"
    port {
      protocol = "TCP"
      port = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "default" {
  metadata {
    name = "muse-backend-service"
    namespace = var.kubernetes.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.default.metadata[0].labels.app
    }
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
      name = "muse-backend"
      namespace = var.kubernetes.namespace
    }
    spec = {
      hosts = ["${var.else.domain-name}.lutergs.dev"]
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

output "kubernetes-service" {
  value = kubernetes_service.default.metadata[0].name
}