---
tags: [ci]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

We hit the GitHub Actions spending limit. This private repo's ci.yml is attached; it's an internal pnpm project, there's a ruleset on main that requires the `ci-ok` check. Trim it down: I just want the checks and tests to run. Tell me what the ruleset needs after the change.

Input files: .github/workflows/ci.yml
