#resource "kubernetes_namespace" "airflow" {
#  metadata {
#    name = "airflow"
#  }
#}
#
#resource "helm_release" "airflow" {
#  name = "airflow"
#  namespace = kubernetes_namespace.airflow.metadata[0].name
#  repository = "https://airflow.apache.org/apache-airflow"
#  chart = "airflow"
#
#  values = [<<EOF
#
#EOF
#]
#}