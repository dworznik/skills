# Where the tree comes from

One personal account on the Pro plan, a few dozen private repos, October 2026. The billing report showed close to twice the included 3,000 minutes. The pool ran out in the third week; the spending limit followed a week later, and from then on every job in every repo of the account failed in two seconds with "The job was not started because recent account payments have failed or your spending limit needs to be increased."

Reconstructed per job from the Actions API over 30 days, as shares of what was billed:

| | Share |
|---|---|
| Real compute | about 45% |
| Billed to jobs that ran 20 s or less | about 50% |
| Same compute as one job per run | about 55% |
| Push-to-main runs repeating the PR run | about 20% |
| Canceled runs | under 5% |

The workflows had been copied from repo to repo by agents, comments included. Every one had a `ci-ok` gate job (3 s) and a gitleaks job (8 s) beside the real checks, "so the ruleset requires one stable name" and "so secrets are a separate check". Half the repos running the gate had no ruleset at all. The Python repos ran a `changes` job, a `commit-messages` job, `lint`, `test` and `runtime-import`: five billed minutes for forty seconds of work.

The three biggest repos told the rest of the story:

- A static site (Astro on Cloudflare Workers): the gate and the scan job cost more than the checks; a preview deploy on every PR push cost a third as much again; the build took 4 s and the tests 42 s, because one test file ran eleven separate Astro builds.
- A data pipeline: half its bill was the gate and the scan job.
- A Flutter app: all real compute, three minutes a run, run again on every merge.

Each rule in the tree removes one of these: one job (the gate, the scan, the `changes` split), `pull_request` only (the merge re-run), the host deploys (the preview and deploy jobs), hooks for secrets (gitleaks), a decision record (the copying), and the account-level report (nobody saw the pool).
