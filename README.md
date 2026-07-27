# oruganti-dev-main

Source for **oruganti.dev** (home + `/about/`) and **blog.oruganti.dev**
("Control Plane" — *From Code to Controls*). The existing `resume` repo is
untouched and keeps serving `oruganti.dev/about/resume/` via a build-time
composition step (see below) — no runtime proxy/Worker involved.

## Structure

```
apps/site/    → oruganti.dev            (home, /about/)
apps/blog/    → blog.oruganti.dev       (Control Plane blog, Astro content collection)
packages/shared/ → shared layout + CSS used by both apps
.github/workflows/ → build+deploy (GitHub Actions is the sole CI/CD)
terraform/    → Cloudflare Pages projects, custom domains, DNS, zone security settings (IaC)
resume-repo-addition/ → snippet + instructions for the *separate* resume repo
```

## How `/about/resume/` gets served without a Cloudflare Worker

1. `resume` repo builds as it always has, uploads its output as a GitHub
   Actions artifact, and fires a `repository_dispatch` event here.
2. `deploy-site.yml` in this repo downloads that artifact and copies it into
   `apps/site/dist/about/resume/` *after* `astro build` runs, then deploys
   the combined output as one Cloudflare Pages project.

See `resume-repo-addition/README.md` for the small addition needed in the
`resume` repo itself.

## One-time setup

1. **Cloudflare:** create an API token (Pages:Edit, DNS:Edit, Zone
   Settings:Edit on the `oruganti.dev` zone) and note your Account ID and
   Zone ID.
2. **HCP Terraform (free tier):** create an org + workspace named
   `oruganti-dev-main` for remote state; update `terraform/versions.tf` with
   your org name.
3. **GitHub secrets** — set on this repo:
   - `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_ZONE_ID`
   - `TF_API_TOKEN` (HCP Terraform user/team token)
   - `RESUME_REPO_TOKEN` (PAT with read access to the `resume` repo)
4. **GitHub secrets** — set on the `resume` repo:
   - `DISPATCH_TOKEN` (PAT allowed to send `repository_dispatch` to this repo)
5. Push to `main` — `terraform.yml` provisions the Cloudflare Pages
   projects/domains/DNS/zone settings, then `deploy-site.yml` and
   `deploy-blog.yml` build and publish the two sites.
6. Add the snippet in `resume-repo-addition/` to the `resume` repo so it
   notifies this repo on every future resume change.

## Local dev

```bash
npm install
npm run dev:site   # http://localhost:4321
npm run dev:blog
```

## Cost

Public repo → unlimited GitHub Actions minutes on standard runners.
Cloudflare Free plan covers this comfortably (500 Pages builds/mo, 100
custom domains/project, unmetered DDoS protection, baseline WAF, free
Universal SSL) — no paid Cloudflare tier required. HCP Terraform's free tier
covers remote state. Net infra cost: $0.
