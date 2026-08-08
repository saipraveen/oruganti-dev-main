# Addition needed in the `resume` repo (not this repo)

**Status: already applied.** The `resume` repo's `release.yml` (main-branch
workflow) now uploads a `resume-dist` artifact and fires the
`repository_dispatch` below on every push to `main`; its old standalone
Cloudflare Pages deploy (and the "coming soon" filler page it served at the
`oruganti.dev` apex) have been removed now that this repo owns the root
site. This folder is kept as reference only — it does not get pushed as
part of `oruganti-dev-main`. It shows the small addition your existing
`resume` repo needs so `deploy-resume.yml` here can pull its latest build.

Your `resume` repo's existing workflow presumably already builds the static
resume site. Two things need to be added to that workflow (see
`build-and-dispatch.yml.snippet` for a full example):

1. **Upload the build output as an artifact** named `resume-dist`
   (`index.html` + PDF + a `_headers` file with cache-control rules), so
   `dawidd6/action-download-artifact` in this repo's `deploy-resume.yml` can
   fetch it and deploy it as-is to the dedicated `oruganti-resume`
   Cloudflare Pages project (`resume.oruganti.dev`).
2. **Fire a `repository_dispatch` event** to `oruganti-dev-main` after a
   successful build, so the resume site redeploys automatically whenever the
   resume changes (rather than only on manual `workflow_dispatch` runs here).

## Secrets needed

- In the **resume** repo: a PAT (`DISPATCH_TOKEN`) with permission to send
  `repository_dispatch` events to `oruganti-dev-main`.
- In the **oruganti-dev-main** repo: a PAT (`RESUME_REPO_TOKEN`) with
  `contents:read` / `actions:read` on the `resume` repo, so it can download
  the artifact.

Both can be the same fine-grained PAT if scoped to both repos — just stored
under different secret names in each repo.
