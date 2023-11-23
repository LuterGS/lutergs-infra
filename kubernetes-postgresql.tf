#test = ""
#
#resource "kubernetes_secret" "oci-blockstorage-csi" {
#  metadata {
#    name = "test"
#    namespace = "lutergs"
#
#  }
#
#  data = {
#    "test.yml" = <<EOT
#auth:
#  region: ${var.oci-info.region}
#  tenancy: ${var.oci-info.tenancy-ocid}
#  user: ${var.oci-info.user-ocid}
#  key: |
#    ${test}
#EOT
#  }
#}