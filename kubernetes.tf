resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cloudflare-api-token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  data = {
    "api-token" = cloudflare_api_token.cert-manager-api-token.value
  }
}

resource "kubernetes_namespace" "lutergs" {
  metadata {
    name = "lutergs"
  }
}

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


resource "kubernetes_service" "frontend" {
  metadata {
    namespace = kubernetes_namespace.kong.metadata[0].name
    name = "frontend"
  }
  spec {
    type = "ExternalName"
    external_name = "${module.lutergs-frontend.kubernetes-service}.${kubernetes_namespace.lutergs.metadata[0].name}.svc.cluster.local"

  }
}
resource "kubernetes_service" "frontend-pwa" {
  metadata {
    namespace = kubernetes_namespace.kong.metadata[0].name
    name = "frontend-pwa"
  }
  spec {
    type = "ExternalName"
    external_name = "${module.lutergs-frontend-pwa.kubernetes-service}.${kubernetes_namespace.lutergs.metadata[0].name}.svc.cluster.local"
  }
}
resource "kubernetes_service" "backend" {
  metadata {
    namespace = kubernetes_namespace.kong.metadata[0].name
    name = "backend"
  }
  spec {
    type = "ExternalName"
    external_name = "${module.lutergs-backend.kubernetes-service}.${kubernetes_namespace.lutergs.metadata[0].name}.svc.cluster.local"
  }
}
