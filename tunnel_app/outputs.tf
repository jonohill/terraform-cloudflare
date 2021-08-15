output "tunnel_id" {
  value = resource.cloudflare_argo_tunnel.tunnel.id
}

output "tunnel_secret" {
  value     = local.secret
  sensitive = true
}
