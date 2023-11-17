#resource "kubernetes_deployment" "test" {
#  metadata {
#    name = "aws-secret-updater-test-deploy"
#    namespace = var.kubernetes.namespace
#    labels = {
#      app = "aws-secret-updater-test-deploy"
#    }
#  }
#
#  spec {
#    replicas = "1"
#    selector {
#      match_labels = {
#        app = "aws-secret-updater-test-deploy"
#      }
#    }
#    template {
#      metadata {
#        labels = {
#          app = "aws-secret-updater-test-deploy"
#        }
#      }
#      spec {
#
#        volume {
#          name = "kubeconfig"
#          secret {
#            secret_name = kubernetes_secret.kubeconfig.metadata[0].name
#          }
#        }
#
#        container {
#          image = "koo04034/aws-ecr-secret-updater:latest"
#          image_pull_policy = "Always"
#          name = "aws-secret-updater"
#          tty = true
#          stdin = true
#
#          env_from {
#            secret_ref {
#              name = kubernetes_secret.environment_variables.metadata[0].name
#            }
#          }
#
#          volume_mount {
#            mount_path = "/etc/secret"
#            name       = "kubeconfig"
#            read_only  = true
#          }
#          command = ["/bin/sleep", "3600"]
#        }
#      }
#    }
#  }
#}