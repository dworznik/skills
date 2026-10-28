# skills

A plugin marketplace of skills for Claude Code. Each skill is `skills/<name>/` with `SKILL.md`, and optionally `references/`, `scripts/` and `evals/`; `.claude-plugin/marketplace.json` lists the plugins.

## Working here

- Writing or editing a `SKILL.md` or a reference: use the `writing-for-agents` skill first. Its rules on context pointers, the information hierarchy and pruning are the house style; a skill body stays under 500 lines and pushes branch-specific material into `references/`.
- A script under `scripts/` is code: `tdd` for changes to it, a run against a real repo before a commit, `code-review` before a merge.
- Test cases live in `skills/<name>/evals/` in the layout `claude plugin eval` reads; `skill-creator` runs and grades them and optimizes the description. Results go to `evals/results/` or a `<skill>-workspace/`, both ignored.
- This repo is public. Nothing in it names a private repo, an account's numbers, or a person other than the owner. Local notes go in `.local/`, which is ignored.
- No CI on GitHub: `docs/agents/ci.md` records why.
- American English. Prettier style for JSON and YAML; no semicolons in any JavaScript that appears.

## Commits

Conventional Commits, `type(scope): summary`, 72 characters or fewer; the scope is the skill name (`feat(ci): …`).
