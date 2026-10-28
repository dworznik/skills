# How GitHub bills Actions

Facts the tree relies on, as of October 2026. Verify against the docs when a number matters: https://docs.github.com/billing/managing-billing-for-github-actions/about-billing-for-github-actions

- **The pool.** Included minutes belong to the account that owns the repo, and every private repo of that account draws on the same monthly pool: Free 2,000, Pro 3,000, Team 3,000, Enterprise 50,000. An org's repos draw on the org's pool, a user's on the user's. The count resets on the first of the month.
- **Public repos bill nothing** on GitHub-hosted runners. Self-hosted runners bill nothing either; check the docs for the platform fee that was announced for 2026.
- **Per job, rounded up.** Each job's minutes are rounded up to the next whole minute, separately. A 3-second job bills 1 minute; a 61-second job bills 2. A workflow of four short jobs bills at least 4 minutes a run.
- **Multipliers.** Linux 1x, Windows 2x, macOS 10x. Larger runners have their own rates.
- **Skipped jobs bill nothing.** A job whose `if:` is false still shows timestamps in the API but is not billed. A job GitHub refused to start (spending limit reached, payment failed) fails in about two seconds with an annotation that says so, and is not billed.
- **Canceled jobs bill** the minutes they ran. `cancel-in-progress` saves the rest.
- **Dependabot** update jobs (event `dynamic` in the runs list) are not billed.
- **The spending limit.** Over the pool, Linux minutes cost about $0.006 to $0.008 each. The account's spending limit caps the overage; at the limit every job in every repo of the account is refused until the next month or a higher limit. A limit of $10 is roughly 1,500 minutes of slack.
- **Storage** of artifacts and caches is billed separately and is rarely the problem; cache has a 10 GB per-repo ceiling.

## Reading usage

- The authoritative report: `GET /users/{login}/settings/billing/usage?year=Y&month=M` (or `/organizations/{org}/...`), items per day, product, SKU and repo with quantity, gross, discount and net amounts. The `gh` token needs the `user` scope (`gh auth refresh -s user`). `scripts/billing.sh` prints it.
- The per-run `timing` endpoint returns zeros and is useless. The jobs endpoint (`/repos/{r}/actions/runs/{id}/jobs?filter=all`) gives `started_at`, `completed_at`, `labels` and `conclusion`; `scripts/ci-cost.sh` reconstructs billed minutes from it, within a few percent of the report.
- The Actions usage metrics page and the REST usage endpoints show minutes without rounding or multipliers; they are not the bill.
