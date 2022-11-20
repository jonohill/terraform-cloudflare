terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "random_password" "secret" {
  length = 32
}

locals {
  secret = base64encode(resource.random_password.secret.result)
}

data "cloudflare_zones" "zone" {
  filter {
    name = var.zone_name
  }
}

locals {
  zone_id = lookup(data.cloudflare_zones.zone.zones[0], "id")
}

resource "cloudflare_argo_tunnel" "tunnel" {
  account_id = var.account_id
  name       = var.name
  secret     = local.secret
}

resource "cloudflare_record" "record" {
  zone_id = local.zone_id
  name    = var.name
  type    = "CNAME"
  proxied = true
  value   = "${resource.cloudflare_argo_tunnel.tunnel.id}.cfargotunnel.com"
}

resource "cloudflare_access_application" "app" {
  count = min(1, length(var.access_group))

  zone_id = local.zone_id
  name    = var.name
  domain  = "${var.name}.${var.zone_name}"
  type    = "self_hosted"
}

resource "cloudflare_access_policy" "policy" {
  count = min(1, length(var.access_group))

  application_id = resource.cloudflare_access_application.app[count.index].id
  zone_id        = local.zone_id
  name           = "me"
  precedence     = 1
  decision       = "allow"

  include {
    group = [var.access_group]
  }
}
