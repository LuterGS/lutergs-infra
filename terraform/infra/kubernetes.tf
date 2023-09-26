#resource "kubernetes_service_account" "aws-ecr-secret-updater" {
#  metadata {
#    name = "aws-ecr-secret-updater"
#    namespace = "lutergs"
#  }
#}
#
#resource "kubernetes_role" "aws-ecr-secret-updater-role" {
#  metadata {
#    name = "aws-ecr-secret-updater-role"
#    namespace = kubernetes_service_account.aws-ecr-secret-updater.metadata[0].namespace
#  }
#  rule {
#    api_groups {}
#    resources = ["secrets"]
#    resource_names = ["ecr-access"]
#    verbs = ["get"]
#  }
#}
#
#resource "kubernetes_role_binding" "aws-ecr-secret-updater-role-binding" {
#  metadata {
#    name = "aws-ecr-secret-updater-role-binding"
#    namespace = "lutergs"
#  }
#  subject {
#    kind = "ServiceAccount"
#    name = kubernetes_service_account.aws-ecr-secret-updater.metadata[0].name
#    namespace = kubernetes_service_account.aws-ecr-secret-updater.metadata[0].namespace
#  }
#  role_ref {
#    api_group = ""
#    kind      = "Role"
#    name      = kubernetes_role.aws-ecr-secret-updater-role.metadata[0].name
#  }
#}
#
#// cronjob
#resource "kubernetes_cron_job" "aws-ecr-secret-update-cron-job" {
#  metadata {
#    name = "aws-ecr-secret-updater-cron"
#    namespace = "lutergs"
#  }
#}