# --- Pages projects -----------------------------------------------------
# NOTE: these resources create the project shell (name, production branch,
# build config) only. They do NOT deploy content — actual deploys happen via
# `wrangler pages deploy` in .github/workflows/deploy-site.yml and
# deploy-blog.yml. Terraform = what exists; GitHub Actions = what runs.

resource "cloudflare_pages_project" "main_site" {
  account_id        = var.cloudflare_account_id
  name              = "oruganti-main"
  production_branch = "main"
}

resource "cloudflare_pages_project" "blog" {
  account_id        = var.cloudflare_account_id
  name              = "oruganti-blog"
  production_branch = "main"
}

resource "cloudflare_pages_project" "resume" {
  account_id        = var.cloudflare_account_id
  name              = "oruganti-resume"
  production_branch = "main"
}

# --- Custom domains -------------------------------------------------------

resource "cloudflare_pages_domain" "main_site_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.main_site.name
  domain       = "oruganti.dev"
}

resource "cloudflare_pages_domain" "blog_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.blog.name
  domain       = "blog.oruganti.dev"
}

resource "cloudflare_pages_domain" "resume_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.resume.name
  domain       = "resume.oruganti.dev"
}

# --- DNS --------------------------------------------------------------
# Cloudflare Pages custom domains normally auto-create the needed DNS record
# once verified in the dashboard/API; these explicit records make that state
# reproducible under Terraform instead of implicit/dashboard-managed.

resource "cloudflare_record" "apex" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "CNAME"
  content = "${cloudflare_pages_project.main_site.name}.pages.dev"
  proxied = true
}

resource "cloudflare_record" "blog" {
  zone_id = var.cloudflare_zone_id
  name    = "blog"
  type    = "CNAME"
  content = "${cloudflare_pages_project.blog.name}.pages.dev"
  proxied = true
}

resource "cloudflare_record" "resume" {
  zone_id = var.cloudflare_zone_id
  name    = "resume"
  type    = "CNAME"
  content = "${cloudflare_pages_project.resume.name}.pages.dev"
  proxied = true
}

# --- Zone security settings -------------------------------------------
# DDoS mitigation is always-on/unmetered on every Cloudflare plan (including
# Free) and isn't a Terraform-managed toggle. These settings cover what IS
# configurable: TLS posture and baseline hardening.

resource "cloudflare_zone_settings_override" "oruganti_dev" {
  zone_id = var.cloudflare_zone_id

  settings {
    ssl                      = "full"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    automatic_https_rewrites = "on"
    security_level           = "medium"
    browser_check             = "on"
  }
}
