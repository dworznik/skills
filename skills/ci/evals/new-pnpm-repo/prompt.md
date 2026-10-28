---
tags: [ci]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Set up CI for this repo. It's a private TypeScript library, pnpm, Node 24, just me working on it. package.json has a `verify` script that runs format:check, lint, typecheck and vitest, and .githooks runs lint-staged on commit. No deploy, I publish to npm by hand for now. Keep it cheap, we're already short on Actions minutes this month.
