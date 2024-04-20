variable worker_secret_env_name {
  type = string
  default = "coin-trade-worker-envs"
}

resource "kubernetes_secret" "kubeconfig" {
  metadata {
    name = "coin-trader-kubeconfig"
    namespace = var.kubernetes.namespace
  }

  data = {
    config = var.kubernetes.kubeconfig-file
  }
}

resource "kubernetes_secret" "manager" {
  metadata {
    name = "coin-trade-manager-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    SPRING_PROFILES_ACTIVE          = "server"
    MONGO_USERNAME                  = var.kubernetes-secret.MONGO_USERNAME
    MONGO_PASSWORD                  = var.kubernetes-secret.MONGO_PASSWORD
    MONGO_URL                       = var.kubernetes-secret.MONGO_URL
    MONGO_DATABASE                  = var.kubernetes-secret.MONGO_DATABASE
    MONGO_OPTION                    = var.kubernetes-secret.MONGO_OPTION
    KAFKA_BOOTSTRAP_SERVERS         = var.kubernetes-secret.KAFKA_BOOTSTRAP_SERVERS
    KAFKA_API_KEY                   = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET                = var.kubernetes-secret.KAFKA_API_SECRET
    KAFKA_TRADE_RESULT_TOPIC        = var.kubernetes-secret.KAFKA_TRADE_RESULT_TOPIC
    KAFKA_DANGER_COIN_TOPIC         = var.kubernetes-secret.KAFKA_DANGER_COIN_TOPIC
    UPBIT_ACCESS_KEY                = var.kubernetes-secret.UPBIT_ACCESS_KEY
    UPBIT_SECRET_KEY                = var.kubernetes-secret.UPBIT_SECRET_KEY
    MESSAGE_SENDER_URL              = var.kubernetes-secret.MESSAGE_SENDER_URL
    MESSAGE_SENDER_TOPIC            = var.kubernetes-secret.MESSAGE_SENDER_TOPIC
    MESSAGE_SENDER_USERNAME         = var.kubernetes-secret.MESSAGE_SENDER_USERNAME
    MESSAGE_SENDER_PASSWORD         = var.kubernetes-secret.MESSAGE_SENDER_PASSWORD
    INFLUX_HOST_URL                 = var.kubernetes-secret.INFLUX_HOST_URL
    INFLUX_API_TOKEN                = var.kubernetes-secret.INFLUX_API_TOKEN
    INFLUX_DATABASE                 = var.kubernetes-secret.INFLUX_DATABASE
    KUBERNETES_KUBECONFIG_LOCATION  = "/var/kube/config"

    // worker init setting
    PHASE_1_WAIT_MINUTE               = 150
    PHASE_1_PROFIT_PERCENT            = 1.5
    PHASE_1_LOSS_PERCENT              = 3
    PHASE_2_WAIT_MINUTE               = 60
    PHASE_2_PROFIT_PERCENT            = 0.3
    PHASE_2_LOSS_PERCENT              = 2
    PROFIT_MOVING_AVERAGE_BIG         = 30
    PROFIT_MOVING_AVERAGE_SMALL       = 10
    KUBERNETES_NAMESPACE              = var.kubernetes.namespace
    KUBERNETES_IMAGE_PULL_SECRET_NAME = var.kubernetes.image-pull-secret-name
    KUBERNETES_IMAGE_PULL_POLICY      = "Always"
    KUBERNETES_IMAGE_NAME             = "${aws_ecr_repository.worker.repository_url}:latest"
    KUBERNETES_ENV_SECRET_NAME        = var.worker_secret_env_name
  }
}


resource "kubernetes_secret" "worker" {
  metadata {
    name = var.worker_secret_env_name
    namespace = var.kubernetes.namespace
  }

  data = {
    SPRING_PROFILES_ACTIVE    = "server"
    MONGO_USERNAME            = var.kubernetes-secret.MONGO_USERNAME
    MONGO_PASSWORD            = var.kubernetes-secret.MONGO_PASSWORD
    MONGO_URL                 = var.kubernetes-secret.MONGO_URL
    MONGO_DATABASE            = var.kubernetes-secret.MONGO_DATABASE
    MONGO_OPTION              = var.kubernetes-secret.MONGO_OPTION
    KAFKA_REST_PROXY_URL      = var.kubernetes-secret.KAFKA_REST_PROXY_URL
    KAFKA_CLUSTER_NAME        = var.kubernetes-secret.KAFKA_CLUSTER_NAME
    KAFKA_API_KEY             = var.kubernetes-secret.KAFKA_API_KEY
    KAFKA_API_SECRET          = var.kubernetes-secret.KAFKA_API_SECRET
    KAFKA_ALARM_TOPIC_NAME    = var.kubernetes-secret.KAFKA_DANGER_COIN_TOPIC
    KAFKA_TRADE_RESULT_NAME   = var.kubernetes-secret.KAFKA_TRADE_RESULT_TOPIC
    UPBIT_ACCESS_KEY          = var.kubernetes-secret.UPBIT_ACCESS_KEY
    UPBIT_SECRET_KEY          = var.kubernetes-secret.UPBIT_SECRET_KEY
    MANAGER_URL               = "http://${kubernetes_service.manager.metadata[0].name}"
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
    replicas = "0" # disable coin-trader
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
            secret_name = kubernetes_secret.kubeconfig.metadata[0].name
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

resource "kubernetes_service" "manager" {
  metadata {
    name = "coin-trader-service"
    namespace = var.kubernetes.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.manager.metadata[0].labels.app
    }
    port {
      port = 80
      target_port = 8080
    }
  }
}