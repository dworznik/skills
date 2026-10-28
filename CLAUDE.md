# skills

A plugin marketplace of skills for Claude Code. Each skill is `skills/<name>/` with `SKILL.md`, and optionally `references/`, `scripts/` and `evals/`; `.claude-plugin/marketplace.json` lists the plugins.

## Working here

- Writing or editing a `SKILL.md` or a reference: use the `writing-for-agents` skill first. Its rules on context pointers, the information hierarchy and pruning are the house style; a skill body stays under 500 lines and pushes branch-specific material into `references/`.
- A script under `scripts/` is code: `tdd` for changes to it, a run against a real repo before a commit, `code-review` before a merge.
- Test cases live in `skills/<name>/evals/` in the layout `claude plugin eval` reads; `skill-creator` runs and grades them and optimizes the description. Results go to `evals/results/` or a `<skill>-workspace/`, both ignored.
- This repo is public. Nothing in it names a private repo, an account's numbers, or a person other than the owner. Local notes go in `.local/`, which is ignored.
- No CI on GitHub: `docs/agents/ci.md` records why.
- American English. Prettier style for JSON and YAML; no semicolons in any JavaScript that appears.

## Commits and branches

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <subject>`, with a header of 72 characters or fewer.

- **Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Add `!` before the colon for a breaking change.
- **Scope** is the skill name (`feat(ci): …`). Leave it out for a change that spans the repo (`chore: …`).
- **Subject** is imperative mood, lowercase, with no trailing period.

`main` is the only long-lived branch. Branch first for every change, docs-only included, even when a skill says to commit to the current branch.

- **Names**: `<type>/<issue>-<slug>`, for example `feat/12-ci-cost-script`. `type` is a commit type, `issue` is the GitHub issue number, and `slug` is short kebab-case. With no issue, drop the number (`fix/ci-eval-paths`).
- **Agent branches** take the same names. Rename a tool's default prefix, such as `claude/`, to a commit type before the first commit.

## Agent skills

### Issue tracker

GitHub Issues on `dworznik/skills`, through the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root, created when first needed. See `docs/agents/domain.md`.
