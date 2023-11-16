resource "kubernetes_secret" "kubeconfig" {
  metadata {
    name = "aws-secret-updater-kubeconfig"
    namespace = var.kubernetes.namespace
  }

  data = {
    config = var.kubernetes.kubeconfig-file
  }
}

resource "kubernetes_secret" "environment_variables" {
  metadata {
    name = "aws-secret-updater-env"
    namespace = var.kubernetes.namespace
  }

  data = {
    ACCESS_KEY = aws_iam_access_key.default.id
    SECRET_KEY = aws_iam_access_key.default.secret
    REGION = var.aws.region
    NAMESPACE = var.kubernetes.namespace
    SECRET_NAME = var.ecr-access-secret-name
    REPOSITORY_URL = var.kubernetes-secret.aws-repository-url
    REPOSITORY_USERNAME = "AWS"
  }
}

resource "kubernetes_cron_job_v1" "default" {
  metadata {
    name = "aws-secret-updater"
    namespace = var.kubernetes.namespace
    labels = {
      app = "aws-secret-updater"
    }
  }
  spec {
    concurrency_policy = "Replace"
    failed_jobs_history_limit = 5
    schedule = "0 0 * * 0,4"
    timezone = "Asia/Seoul"
    starting_deadline_seconds = 10
    successful_jobs_history_limit = 10

    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {

            volume {
              name = "kubeconfig"
              secret {
                secret_name = kubernetes_secret.kubeconfig.metadata[0].name
              }
            }

            container {
              image = "koo04034/aws-secret-updater:latest"
              image_pull_policy = "Always"
              name = "aws-secret-updater"

              env_from {
                secret_ref {
                  name = kubernetes_secret.environment_variables.metadata[0].name
                }
              }

              volume_mount {
                mount_path = "/etc/secret"
                name       = "kubeconfig"
                read_only  = true
              }
            }
          }
        }
      }
    }
  }
}