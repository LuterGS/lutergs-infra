#resource "grafana_cloud_stack" "default" {
#  provider = grafana.cloud
#
#  name = "lutergs-k8s-stack"
#  slug = "lutergs"
#  region_slug = "ap-southeast-2"
#}
#
#resource "grafana_cloud_stack_service_account" "default" {
#  provider = grafana.cloud
#  stack_slug = grafana_cloud_stack.default.slug
#
#  name = "lutergs-k8s-sa"
#  role = "Admin"
#  is_disabled = false
#}
#
#resource "grafana_cloud_stack_service_account_token" "default" {
#  provider = grafana.cloud
#  stack_slug = grafana_cloud_stack.default.slug
#
#  name               = "${grafana_cloud_stack_service_account.default.name}-token"
#  service_account_id = grafana_cloud_stack_service_account.default.id
#}
#
#provider "grafana" {
#  alias = "lutergs-k8s-stack"
#
#  url = grafana_cloud_stack.default.url
#  auth = grafana_cloud_stack_service_account_token.default.key
#}
#
#resource "grafana_folder" "default" {
#  provider = grafana.lutergs-k8s-stack
#
#  title = "test"
#}