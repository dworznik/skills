# skills

Skills for Claude Code, as a plugin marketplace.

```sh
claude plugin marketplace add dworznik/skills
claude plugin install ci@dworznik
```

| Skill | What it does |
|---|---|
| [`ci`](skills/ci/SKILL.md) | Configures, reviews or trims a repo's GitHub Actions CI through a decision tree: one job on pull requests, deploys from the host, a ruleset only where something enforces merges, and the decisions written to `docs/agents/ci.md`. Ships the cost scripts that read the Actions API and the billing report. |

Each skill is a folder under `skills/` with a `SKILL.md`, optional `references/`, `scripts/` and `evals/` (test cases in the layout `claude plugin eval` reads). This repo runs no CI on GitHub; see [`docs/agents/ci.md`](docs/agents/ci.md).
