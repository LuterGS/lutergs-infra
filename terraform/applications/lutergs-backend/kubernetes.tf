resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "lutergs-backend-envs"
    namespace = "lutergs"
  }

  data = {
    MONGO_USERNAME              = var.kubernetes-secret.MONGO_USERNAME
    MONGO_PASSWORD              = var.kubernetes-secret.MONGO_PASSWORD
    MONGO_URL                   = var.kubernetes-secret.MONGO_URL
    MONGO_DATABASE              = var.kubernetes-secret.MONGO_DATABASE

    POSTGRES_URL                = var.kubernetes-secret.POSTGRES_URL
    POSTGRES_PORT               = var.kubernetes-secret.POSTGRES_PORT
    POSTGRES_DB                 = var.kubernetes-secret.POSTGRES_DB
    POSTGRES_SCHEMA             = var.kubernetes-secret.POSTGRES_SCHEMA
    POSTGRES_USERNAME           = var.kubernetes-secret.POSTGRES_USERNAME
    POSTGRES_PASSWORD           = var.kubernetes-secret.POSTGRES_PASSWORD

    AWS_ACCESS_KEY              = var.kubernetes-secret.AWS_ACCESS_KEY
    AWS_SECRET_KEY              = var.kubernetes-secret.AWS_SECRET_KEY
    AWS_BUCKET_NAME             = var.kubernetes-secret.AWS_BUCKET_NAME
    AWS_BUCKET_PREFIX           = var.kubernetes-secret.AWS_BUCKET_PREFIX

    SERVER_PORT                 = 8080

    FRONTEND_URL                = "https://lutergs.dev"
    FRONTEND_PWA_URL            = "https://app.lutergs.dev"
    BACKEND_URL                 = "https://api2.lutergs.dev"
    ROOT_DOMAIN                 = "lutergs.dev"

    OAUTH_CLIENT_ID             = var.kubernetes-secret.OAUTH_CLIENT_ID
    OAUTH_CLIENT_SECRET         = var.kubernetes-secret.OAUTH_CLIENT_SECRET

    RSA_KEY_LOCATION            = "./private.pem"
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
    namespace = "lutergs"
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
        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "lutergs-backend"

          env_from {
            secret_ref {
              name = kubernetes_secret.deployment-secret.metadata[0].name
            }
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