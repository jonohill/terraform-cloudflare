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

module "tunnels" {
  source     = "./tunnel_app"
  account_id = var.cloudflare_account_id
  zone_name  = var.cloudflare_zone

  for_each = toset(var.tunnel_names)

  name = each.key
}

output "tunnels" {
  value = {
    for k, v in merge(module.apps, module.tunnels) : k => {
      "account_id" : var.cloudflare_account_id,
      "tunnel_name" : k,
      "tunnel_id" : v.tunnel_id,
      "tunnel_secret" : v.tunnel_secret
    }
  }
  sensitive = true
}
