terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.25.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_access_group" "me" {
  account_id = var.cloudflare_account_id
  name       = "me"

  include {
    email = var.cloudflare_access_emails
  }
}

locals {
  app_names_set = toset(var.app_names)
}

module "apps" {
  source     = "./tunnel_app"
  account_id = var.cloudflare_account_id
  zone_name  = var.cloudflare_zone

  for_each = local.app_names_set

  name         = each.key
  access_group = resource.cloudflare_access_group.me.id
}

output "tunnels" {
    value = [ 
        for k, v in module.apps : {
            "AccountTag": var.cloudflare_account_id, 
            "TunnelID": v.tunnel_id,
            "TunnelSecret": v.tunnel_secret,
            "TunnelName": k
        }
    ]
    sensitive = true
}
