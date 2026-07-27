output "main_site_url" {
  value = "https://${cloudflare_pages_domain.main_site_domain.domain}"
}

output "blog_url" {
  value = "https://${cloudflare_pages_domain.blog_domain.domain}"
}
