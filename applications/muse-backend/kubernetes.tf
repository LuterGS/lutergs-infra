resource "kubernetes_secret" "rsa-key-pair" {
  metadata {
    name = "muse-backend-rsa-keypair"
    namespace = var.kubernetes.namespace
  }

  // openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
  // openssl rsa -pubout -in private_key.pem -out public_key.pem

  data = {
    "private.pem" = file("${path.module}/private_key.pem")
    "public.pem" = file("${path.module}/public_key.pem")
  }
}

# kubectl create secret -n music-share generic kafka-truststore --from-file=truststore.jks=./applications/muse-backend/truststore.jks
# 로 대체


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
    KAFKA_TRUSTSTORE_PASSWORD = var.kubernetes-secret.KAFKA_TRUSTSTORE_PASSWORD

    ORACLE_USERNAME = var.kubernetes-secret.ORACLE_USERNAME
    ORACLE_PASSWORD = var.kubernetes-secret.ORACLE_PASSWORD
    ORACLE_DESCRIPTOR_STRING = var.kubernetes-secret.ORACLE_DESCRIPTOR_STRING

    REDIS_SENTINEL_MASTER_NAME = var.kubernetes-secret.REDIS_SENTINEL_MASTER_NAME
    REDIS_SENTINEL_NODES = var.kubernetes-secret.REDIS_SENTINEL_NODES

    STREAMS_COMMUNICATION_KEY = var.kubernetes-secret.STREAMS_COMMUNICATION_KEY
    STREAMS_INPUT_TOPIC_NAME = var.kubernetes-secret.STREAMS_INPUT_TOPIC_NAME
    STREAMS_USER_NOW_PLAYING_STORE = var.kubernetes-secret.STREAMS_USER_NOW_PLAYING_STORE
    STREAMS_PAUSE_TIMEOUT_SECOND = var.kubernetes-secret.STREAMS_PAUSE_TIMEOUT_SECOND
    STREAMS_PLAYING_TIMEOUT_SECOND = var.kubernetes-secret.STREAMS_PLAYING_TIMEOUT_SECOND
    STREAMS_SCAN_FREQUENCY_SECOND = var.kubernetes-secret.STREAMS_SCAN_FREQUENCY_SECOND

    ACCESS_TOKEN_EXPIRE_SECOND = var.kubernetes-secret.ACCESS_TOKEN_EXPIRE_SECOND
    REFRESH_TOKEN_EXPIRE_SECOND = var.kubernetes-secret.REFRESH_TOKEN_EXPIRE_SECOND
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
    replicas = "2"
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

        volume {
          name = "rsa-keypair"
          secret {
            secret_name = kubernetes_secret.rsa-key-pair.metadata[0].name
          }
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
          env {
            name = "MUSE_DOMAIN"
            value = var.else.domain-name
          }
          env {
            name = "RSA_PRIVATE_KEY_PATH"
            value = "/etc/secret/private.pem"
          }
          env {
            name = "RSA_PUBLIC_KEY_PATH"
            value = "/etc/secret/public.pem"
          }
          env {
            name = "KAFKA_TRUSTSTORE_PATH"
            value = "/etc/truststore/truststore.jks"
          }
          volume_mount {
            mount_path = "/etc/secret/"
            name       = "rsa-keypair"
            read_only  = true
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
      hosts = [
        "${var.else.domain-name}.lutergs.dev",
        "${kubernetes_service.default.metadata[0].name}.${var.kubernetes.namespace}.svc.cluster.local"
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

output "kubernetes-service" {
  value = kubernetes_service.default.metadata[0].name
}