# CI decisions

Recorded by the `ci` skill's tree. Edit when a decision changes, not when a workflow does.

| Question | Decision | Why |
|---|---|---|
| CI on GitHub at all? | Yes: `pnpm verify` on pull requests | Two contributors; hooks cover format and lint, tests take 40 s. |
| Visibility | Private | Billed: one job, under a minute when possible. |
| Jobs | One, named `ci` | A gate or a separate scan job bills a minute for seconds of work. |
| Triggers | `pull_request` only | Every change reaches `main` through a PR; the PR run tests the merge ref. |
| Enforcement | Ruleset requires `ci`, strict | So the tested tree is the merged tree. |
| Deploy | Vercel git integration | The host builds `main`; Actions does not deploy. |
| Secrets | gitleaks in the pre-commit hook | Not a billed job. |
| Scheduled | None | Nothing here watches the outside world. |

Revisit when: a job needs another OS, a deploy leaves the host, or a PR run passes two billed minutes.
