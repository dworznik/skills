---
tags: [ci]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Our Astro site deploys to Cloudflare Workers from GitHub Actions (ci.yml attached): every PR push uploads a preview and every merge deploys. It's a private repo and the preview + deploy jobs are about 170 minutes a month. Can we flip this around so Cloudflare does the building, like Vercel does? What changes in the repo and what do I have to do in the Cloudflare dashboard?

Input files: ci.yml
