resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "lutergs-frontend-envs"
    namespace = "lutergs"
  }

  data = {
    HOST                    = var.kubernetes-secret.HOST
    PORT                    = var.kubernetes-secret.PORT
    PUBLIC_TINYMCE_APIKEY   = var.kubernetes-secret.PUBLIC_TINYMCE_APIKEY
    PUBLIC_BACKEND_SERVER   = var.kubernetes-secret.PUBLIC_BACKEND_SERVER
    PUBLIC_OAUTH_CLIENT_ID  = var.kubernetes-secret.PUBLIC_OAUTH_CLIENT_ID
  }
}


resource "kubernetes_deployment" "default" {

  metadata {
    name = "lutergs-frontend"
    namespace = "lutergs"
    labels = {
      app = "lutergs-frontend"
    }
  }

  spec {
    replicas = "2"
    selector {
      match_labels = {
        app = "lutergs-frontend"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "lutergs-frontend"
        }
      }
      spec {
        image_pull_secrets {
          name = "lutergs-backend-batch-ecr-access"
        }
        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "lutergs-frontend"

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
    name = "lutergs-frontend-service"
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