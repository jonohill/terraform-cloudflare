variable "cloudflare_account_id" {}
variable "cloudflare_api_token" {}
variable "cloudflare_zone" {}
variable "cloudflare_access_emails" {
  type = list(string)
}
variable "app_names" {
  type = list(string)
}