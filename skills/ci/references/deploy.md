# Deploys: the host builds from the repo

Actions is the wrong place for a deploy when the host can watch the repo itself. The host's build minutes are separate from GitHub's pool, previews come for free, and the deploy token never lives in GitHub.

| Host | Integration | Production | Previews | Included |
|---|---|---|---|---|
| Vercel | GitHub app | push to the production branch | every other branch and PR, URL on the PR | per plan; Hobby is free for personal use |
| Cloudflare Workers | Workers Builds (Settings → Builds, connect the repo) | push to the production branch | non-production branches, URL posted on the PR | 3,000 build minutes a month on Free, 1 concurrent build, 100 previews per Worker |
| Cloudflare Pages | Pages git integration | same | same | 500 builds a month on Free |
| GitHub Pages | `actions/deploy-pages` | needs a workflow | none | GitHub minutes, free on a public repo |
| npm, PyPI | trusted publishing from a workflow on a release tag | the tag | none | a workflow is unavoidable; one job, on `push: tags` |

Setting up a host integration is the owner's step in a dashboard: connect the repo, set the production branch, the build and deploy commands, build-time variables, and runtime secrets once (they survive later deploys). Hand the owner those steps as a list; do not try to drive the dashboard.

What moves out of the repo when the host takes over: the deploy and preview jobs, the Actions environments, and the host's API token and account id from the repository secrets. What stays: the checks on `pull_request`.

A second Worker or app in the same repo is a second connection with its own deploy command (`npx wrangler deploy --config other.jsonc`), or a manual deploy when it never changes.

Fork PRs: a host integration may or may not build them. The old workflow usually skipped previews for forks so deploy secrets never reached a fork; check the host's behavior during setup and record it in `docs/agents/ci.md`.

When a push job is unavoidable, it is its own workflow: `on: push: branches: [main]` or `tags`, a `paths` filter so docs changes do not deploy, `concurrency` with `cancel-in-progress: false` and its own group, one job, and no repeat of the checks.
