# CI decisions

Recorded by the `ci` skill's tree. Edit when a decision changes, not when a workflow does.

| Question | Decision | Why |
|---|---|---|
| CI on GitHub at all? | No | Markdown, JSON and two shell scripts; nothing to build. A skill is checked by running it. |
| Visibility | Public | Nothing in a skill is secret, and a public repo's Actions would be free anyway. |
| Enforcement | None | One author; merges are the author's call. |
| Deploy | None | Installed from the repo by `claude plugin marketplace add`. |
| Secrets | Pre-commit hook, when one is added | Not a billed job. |

Revisit when: a script grows tests, or a second contributor arrives.
