resource "kubernetes_secret" "deployment-secret" {
  metadata {
    name = "lutergs-backend-batch-envs"
    namespace = var.kubernetes.namespace
  }

  data = {
    BACKEND_SERVER_ENDPOINT = var.kubernetes-secret.BACKEND_SERVER_ENDPOINT
    BACKEND_SERVER_TOKEN = var.kubernetes-secret.BACKEND_SERVER_TOKEN
    HEALTH_CHECKER_UUID = var.kubernetes-secret.HEALTH_CHECKER_UUID
    SHARP_HOUR_ALARMER_UUID = var.kubernetes-secret.SHARP_HOUR_ALARMER_UUID
    SHARP_MINUTE_ALARMER_UUID = var.kubernetes-secret.SHARP_MINUTE_ALARMER_UUID
    SUNRISE_ALARMER_UUID = var.kubernetes-secret.SUNRISE_ALARMER_UUID
    SUNRISE_ALARMER_WEATHER_URL = var.kubernetes-secret.SUNRISE_ALARMER_WEATHER_URL
    SUNRISE_ALARMER_LATITUDE = var.kubernetes-secret.SUNRISE_ALARMER_LATITUDE
    SUNRISE_ALARMER_LONGITUDE = var.kubernetes-secret.SUNRISE_ALARMER_LONGITUDE
    SUNRISE_ALARMER_TOKEN = var.kubernetes-secret.SUNRISE_ALARMER_TOKEN
    SUNSET_ALARMER_UUID = var.kubernetes-secret.SUNSET_ALARMER_UUID
    SUNSET_ALARMER_WEATHER_URL = var.kubernetes-secret.SUNSET_ALARMER_WEATHER_URL
    SUNSET_ALARMER_LATITUDE = var.kubernetes-secret.SUNSET_ALARMER_LATITUDE
    SUNSET_ALARMER_LONGITUDE = var.kubernetes-secret.SUNSET_ALARMER_LONGITUDE
    SUNSET_ALARMER_TOKEN = var.kubernetes-secret.SUNSET_ALARMER_TOKEN
  }
}



resource "kubernetes_deployment" "default" {

  metadata {
    name = "lutergs-backend-batch"
    namespace = var.kubernetes.namespace
    labels = {
      app = "lutergs-backend-batch"
    }
  }

  spec {
    replicas = "1"    // if replica is larger then 1, alarms will trigger more than 1 times.
    selector {
      match_labels = {
        app = "lutergs-backend-batch"
      }
    }
    progress_deadline_seconds = 60
    template {
      metadata {
        labels = {
          app = "lutergs-backend-batch"
        }
      }
      spec {
        image_pull_secrets {
          name = var.kubernetes.image-pull-secret-name
        }
        container {
          image = "${aws_ecr_repository.default.repository_url}:latest"
          image_pull_policy = "Always"
          name = "lutergs-backend-batch"

          env_from {
            secret_ref {
              name = kubernetes_secret.deployment-secret.metadata[0].name
            }
          }

          resources {
#            limits = {         # do not limit memory or cpu because resource of k8s is low
#              cpu    = "0.5"
#              memory = "512Mi"
#            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "default" {
  metadata {
    name = "lutergs-backend-batch-service"
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