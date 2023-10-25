resource "kubernetes_secret" "jwt-token" {
  metadata {
    name = "lutergs-backend-pem"
    namespace = var.kubernetes.namespace
  }

  // openssl genpkey -out rsakey.pem -algorithm RSA -pkeyopt rsa_keygen_bits:2048
  data = {
    "private.pem" = file("${path.module}/rsakey.pem")
  }
}

resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "lutergs-backend-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    MONGO_USERNAME              = var.kubernetes-secret.MONGO_USERNAME
    MONGO_PASSWORD              = var.kubernetes-secret.MONGO_PASSWORD
    MONGO_URL                   = var.kubernetes-secret.MONGO_URL
    MONGO_DATABASE              = var.kubernetes-secret.MONGO_DATABASE

    ORACLE_DESCRIPTOR           = var.kubernetes-secret.ORACLE_DESCRIPTOR
    ORACLE_USERNAME             = var.kubernetes-secret.ORACLE_USERNAME
    ORACLE_PASSWORD             = var.kubernetes-secret.ORACLE_PASSWORD
    ORACLE_MAX_CONN             = var.kubernetes-secret.ORACLE_MAX_CONN
    ORACLE_MIN_CONN             = var.kubernetes-secret.ORACLE_MIN_CONN

    AWS_ACCESS_KEY              = var.kubernetes-secret.AWS_ACCESS_KEY
    AWS_SECRET_KEY              = var.kubernetes-secret.AWS_SECRET_KEY
    AWS_BUCKET_NAME             = var.kubernetes-secret.AWS_BUCKET_NAME
    AWS_BUCKET_PREFIX           = var.kubernetes-secret.AWS_BUCKET_PREFIX

    SERVER_PORT                 = 8080

    FRONTEND_URL                = "https://lutergs.dev"
    FRONTEND_PWA_URL            = "https://app.lutergs.dev"
    BACKEND_URL                 = "https://${var.else.domain-name}.lutergs.dev"
    ROOT_DOMAIN                 = "lutergs.dev"

    OAUTH_CLIENT_ID             = var.kubernetes-secret.OAUTH_CLIENT_ID
    OAUTH_CLIENT_SECRET         = var.kubernetes-secret.OAUTH_CLIENT_SECRET

    RSA_KEY_LOCATION            = "/etc/secret/private.pem"
    TOKEN_EXPIRE_HOUR           = 3
    ENABLE_SECURE_TOKEN         = true

    PUSH_PUBLIC_KEY             = var.kubernetes-secret.PUSH_PUBLIC_KEY
    PUSH_PRIVATE_KEY            = var.kubernetes-secret.PUSH_PRIVATE_KEY
    PUSH_TOPIC_TRIGGER_KEY      = var.kubernetes-secret.PUSH_TOPIC_TRIGGER_KEY
    PUSH_NEW_TOPIC_REQUEST_URL  = var.kubernetes-secret.PUSH_NEW_TOPIC_REQUEST_URL
    PUSH_NEW_TOPIC_USERNAME     = var.kubernetes-secret.PUSH_NEW_TOPIC_USERNAME
    PUSH_NEW_TOPIC_PASSWORD     = var.kubernetes-secret.PUSH_NEW_TOPIC_PASSWORD
  }
}


resource "kubernetes_deployment" "default" {

  metadata {
    name = "lutergs-backend"
    namespace = var.kubernetes.namespace
    labels = {
      app = "lutergs-backend"
    }
  }

  spec {
    replicas = "2"
    selector {
      match_labels = {
        app = "lutergs-backend"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "lutergs-backend"
        }
      }
      spec {
        image_pull_secrets {
          name = "lutergs-backend-batch-ecr-access"
        }
        volume {
          name = "jwt-token"
          secret {
            secret_name = kubernetes_secret.jwt-token.metadata[0].name
          }
        }

        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "lutergs-backend"

          env_from {
            secret_ref {
              name = kubernetes_secret.deployment-secret.metadata[0].name
            }
          }

          volume_mount {
            mount_path = "/etc/secret/"
            name       = "jwt-token"
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
    name = "lutergs-backend-service"
    namespace = "lutergs"
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

output "kubernetes-service" {
  value = kubernetes_service.default.metadata[0].name
}