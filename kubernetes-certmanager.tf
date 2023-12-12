module "cert_manager" {
  source                = "terraform-iaac/cert-manager/kubernetes"

  namespace_name        = kubernetes_namespace.cert-manager.metadata[0].name
  create_namespace      = false
  cluster_issuer_email  = "lutergs@lutergs.dev"
  solvers = [
    {
      dns01 = {
        cloudflare = {
          email = "lutergs@lutergs.dev"
          apiTokenSecretRef = {
            name = kubernetes_secret.cloudflare-api-token.metadata[0].name
            key = "api-token"
          }
        }
      }
    }
  ]
}

resource "kubernetes_manifest" "cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "Certificate"
    metadata = {
      name = "lutergs-cert"
      namespace = "istio-ingress"
    }
    spec = {
      secretName = "lutergs-tls"
      dnsNames = [
        "lutergs.dev",
        "api.lutergs.dev",
        "app.lutergs.dev"
      ]
      issuerRef = {
        name = "cert-manager"
        kind = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}