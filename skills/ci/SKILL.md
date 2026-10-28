---
name: ci
description: Configure, review or trim a repo's GitHub Actions CI through a decision tree, and record the decisions in docs/agents/ci.md. Use whenever you create or edit anything under .github/workflows, add a job or a workflow, set up CI for a new repo, touch rulesets or branch protection, wire a deploy or preview from Actions, or when Actions minutes, the spending limit or the billing report come up, even if the user only asks for "a quick check" or "the usual CI".
---

# CI: one job, on pull requests, decided per repo

Every private repo of an account draws on one monthly pool of Actions minutes, and GitHub bills each job rounded up to a whole minute. A three-second gate job costs the same as a sixty-second test run, so the shape of a workflow matters more than its speed. In October 2026 a fleet of small repos spent 55% of its pool on jobs that did under fifteen seconds of work, and CI stopped everywhere at once when the pool ran out. `references/rationale.md` has the numbers; `references/billing.md` has the rules.

The tree below is the whole method. Walk it for the repo in front of you, write the workflow the answers call for, and leave the answers in `docs/agents/ci.md` so the next agent sees a decision, not a shape to copy.

## 1. Read the repo before deciding

Gather, from the environment rather than from memory:

- Visibility: `gh repo view --json isPrivate`. Public repos bill nothing; the cost rules apply to private ones only.
- The verify command: the `verify` script in `package.json`, a `Makefile` target, `pnpm verify`, `uv run pytest`, `flutter test`. CI runs what the developer runs; it does not invent checks.
- Hooks: `.githooks/`, `lint-staged`, pre-commit. What a hook already enforces on every commit, CI does not need to repeat for cost reasons alone.
- Existing workflows, the ruleset (`gh api repos/{owner}/{repo}/rulesets`) and the deploy target (`wrangler.jsonc`, `vercel.json`, a deploy job).
- Current cost, when a workflow exists: `scripts/ci-cost.sh [owner/repo] [days]` prints billed minutes per job and what the same compute would bill as one job. Run it before and after a change so the result is a number.

## 2. The tree

Answer in order. Each answer narrows the next.

**Does this repo need CI on GitHub at all?** A solo, internal repo whose hooks run format, lint and typecheck on commit, with a verify script the developer runs before a PR, often needs nothing, or tests only. "No CI" is a valid, recorded decision. Reasons to say yes: a second contributor, a deploy or release that must come from a clean build, a check too slow for a hook.

**Private?** If public, the cost rules below are off; still prefer one job, because fewer jobs are easier to read.

**One job.** Put every step in one job: checkout, toolchain, install, the verify command's steps. A second job earns its billed minute only when it needs a different runner, a different OS, or must run while the first is still going and finishes much later. A gate job (`ci-ok` with `needs: [...]` and `if: always()`) exists so a ruleset can require one stable name while jobs change underneath; with one job, name that job what the ruleset requires and the gate is gone. Secret scanning runs in the pre-commit hook, where it costs nothing; as a job it bills a minute for eight seconds of gitleaks.

**Trigger on `pull_request` only.** Everything reaches `main` through a PR, and the PR run tests the merge ref. A `push` to `main` trigger runs the whole workflow again on the same tree; it is a deploy trigger, not a check trigger. Add `concurrency` with `cancel-in-progress: true` keyed on the ref so a new push supersedes the old run, and `timeout-minutes` so a hung step cannot bill the 6-hour default.

**Who enforces merges?** No ruleset: nothing requires the check, so write none and say so. A ruleset: require the one job by its name, keep the ruleset in `.github/rulesets/main.json` so it is versioned, and turn `strict_required_status_checks_policy` on; without it a PR behind `main` merges on a green check that never tested the merged result, which is the only thing dropping the push run gives up.

**Is there a deploy?** The host builds from the repo when it can: Vercel's and Cloudflare's git integrations build `main` into production and other branches into previews, post the preview URL on the PR, and spend the host's minutes, not GitHub's. `references/deploy.md` lists what each host offers. When a push job is unavoidable (a release to a registry, a host without git integration), it is its own workflow on `push` to `main` or on a tag, with a `paths` filter, and with the checks still on the PR, not repeated before the deploy.

**Scheduled jobs.** A cron workflow bills on every run whether or not anything changed. Keep one when its job is to notice the world changing (link rot, a live smoke test); give it `concurrency` with `cancel-in-progress: false` and a timeout; and run it as rarely as the question allows.

**Dependabot.** Its update jobs show as `dynamic` runs and are not billed. Leave them.

## 3. Write the workflow

Start from the stack's reference and change only what the tree decided:

- `references/workflows/pnpm.yml`: Node with pnpm, `pnpm verify`.
- `references/workflows/uv.yml`: Python with uv, ruff and pytest.
- `references/workflows/flutter.yml`: Flutter analyze and test.

Each is one job on `pull_request` with concurrency and a timeout, actions pinned to a major, `permissions: contents: read`. A service container (Postgres, S3) belongs inside the one job as `services:`, not in a job of its own.

A step whose own time is the cost (a Flutter test suite, tests that build a site many times) is a reason to make the step faster, not to split it: a job under sixty seconds bills one minute, one at ninety bills two.

## 4. Record the decisions

Write `docs/agents/ci.md` from `references/ci-decisions-template.md`: one row per question above, the decision, and why in a sentence. Add a `Revisit when:` line naming what would change the answer. A later reader, agent or human, then knows whether the shape is deliberate; a bare workflow file cannot tell them.

When the repo has a `CLAUDE.md` that describes CI, point it at `docs/agents/ci.md` rather than restating the decisions.

## 5. Check the result

- `actionlint` or a dry read: every `uses:` pinned, `permissions` set, `timeout-minutes` present, exactly one job unless the tree said otherwise.
- `scripts/ci-cost.sh` after a week, or the estimate now: billed minutes per PR run, stated in the PR that changed the workflow.
- Across the account, `scripts/billing.sh <login> [YYYY-MM]` reads GitHub's own usage report: minutes per repo and per day, and the overage. Run it when a spending limit, a stopped job or "why are we out of minutes" comes up; the per-repo estimate cannot see the pool.

The whole-account view is what no single repo's workflow shows. When the report says the pool is nearly spent, the fix is the repos at the top of its list, in order, with this tree.
