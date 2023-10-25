// Zone setting
resource "cloudflare_account" "default" {
  name = "Lutergs@lutergs.dev's Account"
  // imported via "terraform import"
}

resource "cloudflare_zone" "lutergs_dev" {
  account_id = cloudflare_account.default.id
  zone = "lutergs.dev"
}


// Account permissions
data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "cert-manager-api-token" {
  name = "kubernetes-cert-manager-api-token"

  policy {
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"],
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"]
    ]
  }
}