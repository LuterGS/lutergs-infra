resource "kubernetes_manifest" "istio-gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind = "Gateway"
    metadata = {
      namespace = kubernetes_namespace.istio-ingress.metadata[0].name
      name = "default-gateway"
    }
    spec = {
      selector = {
        istio = "ingress"
      }
      servers = [
        {
          port = {
            number = 443
            name = "http"
            protocol = "HTTPS"
          }
          tls = {
            mode = "SIMPLE"
            credentialName = kubernetes_manifest.cert.manifest.spec.secretName
          }
          hosts = kubernetes_manifest.cert.manifest.spec.dnsNames
        }
      ]
    }
  }
}