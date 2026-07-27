variable "cloudflare_api_token" {
  description = "Cloudflare API token (Pages:Edit, DNS:Edit, Zone Settings:Edit permissions)"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for oruganti.dev"
  type        = string
}
