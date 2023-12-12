resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "lutergs-frontend-envs"
    namespace = var.kubernetes.namespace
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
    namespace = var.kubernetes.namespace
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
          name = var.kubernetes.image-pull-secret-name
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
      name = "lutergs-frontend"
      namespace = var.kubernetes.namespace
    }
    spec = {
      hosts = ["lutergs.dev"]
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