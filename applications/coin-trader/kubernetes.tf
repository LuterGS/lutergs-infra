resource "kubernetes_secret" "manager" {
  metadata {
    name = "coin-trade-manager-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    SPRING_PROFILES_ACTIVE = "server"
    MONGO_USERNAME = var.kubernetes-secret.MONGO_USERNAME
    MONGO_PASSWORD = var.kubernetes-secret.MONGO_PASSWORD
    MONGO_URL = var.kubernetes-secret.MONGO_URL
    MONGO_DATABASE = var.kubernetes-secret.MONGO_DATABASE
    KAFKA_BOOTSTRAP_SERVERS = var.kubernetes-secret.KAFKA_BOOTSTRAP_SERVERS
    KAFKA_API_KEY = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET = var.kubernetes-secret.KAFKA_API_SECRET
    UPBIT_ACCESS_KEY = var.kubernetes-secret.UPBIT_ACCESS_KEY
    UPBIT_SECRET_KEY = var.kubernetes-secret.UPBIT_SECRET_KEY
    MESSAGE_SENDER_URL      = var.kubernetes-secret.MESSAGE_SENDER_URL
    MESSAGE_SENDER_TOPIC    = var.kubernetes-secret.MESSAGE_SENDER_TOPIC
    MESSAGE_SENDER_USERNAME = var.kubernetes-secret.MESSAGE_SENDER_USERNAME
    MESSAGE_SENDER_PASSWORD = var.kubernetes-secret.MESSAGE_SENDER_PASSWORD
    KUBERNETES_KUBECONFIG_LOCATION = "/var/kube/config"

    // worker init setting
    KUBERNETES_NAMESPACE = var.kubernetes.namespace
    KUBERNETES_IMAGE_PULL_SECRET_NAME = var.kubernetes.image-pull-secret-name
    KUBERNETES_IMAGE_PULL_POLICY = "Always"
    KUBERNETES_IMAGE_NAME = "${aws_ecr_repository.worker.repository_url}:latest"
    KUBERNETES_ENV_SECRET_NAME = kubernetes_secret.worker.metadata[0].name
  }
}


resource "kubernetes_secret" "worker" {
  metadata {
    name = "coin-trade-worker-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    SPRING_PROFILES_ACTIVE = "server"
    KAFKA_REST_PROXY_URL = var.kubernetes-secret.KAFKA_REST_PROXY_URL
    KAFKA_CLUSTER_NAME = var.kubernetes-secret.KAFKA_CLUSTER_NAME
    KAFKA_API_KEY = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET = var.kubernetes-secret.KAFKA_API_SECRET
    KAFKA_ALARM_TOPIC_NAME = var.kubernetes-secret.KAFKA_ALARM_TOPIC_NAME
    KAFKA_TRADE_RESULT_NAME = var.kubernetes-secret.KAFKA_TRADE_RESULT_NAME
    ORACLE_DESCRIPTOR = var.kubernetes-secret.ORACLE_DESCRIPTOR
    ORACLE_USERNAME = var.kubernetes-secret.ORACLE_USERNAME
    ORACLE_PASSWORD = var.kubernetes-secret.ORACLE_PASSWORD
    ORACLE_MAX_CONN = var.kubernetes-secret.ORACLE_MAX_CONN
    ORACLE_MIN_CONN = var.kubernetes-secret.ORACLE_MIN_CONN
    UPBIT_ACCESS_KEY = var.kubernetes-secret.UPBIT_ACCESS_KEY
    UPBIT_SECRET_KEY = var.kubernetes-secret.UPBIT_SECRET_KEY
  }
}


resource "kubernetes_deployment" "manager" {

  metadata {
    name = "coin-trade-manager"
    namespace = var.kubernetes.namespace
    labels = {
      app = "coin-trade-manager"
    }
  }

  spec {
    replicas = "2"
    selector {
      match_labels = {
        app = "coin-trade-manager"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "coin-trade-manager"
        }
      }
      spec {
        image_pull_secrets {
          name = var.kubernetes.image-pull-secret-name
        }
        volume {
          name = "kubeconfig"
          secret {
            secret_name = "aws-secret-updater-kubeconfig"
          }
        }

        container {
          image = "${aws_ecr_repository.manager.repository_url}:latest"
          image_pull_policy = "Always"
          name = "coin-trade-manager"

          env_from {
            secret_ref {
              name = kubernetes_secret.manager.metadata[0].name
            }
          }

          volume_mount {
            mount_path = "/var/kube/"
            name       = "kubeconfig"
            read_only  = true
          }

          resources {}
        }
      }
    }
  }
}