#!/usr/bin/env bash
# Estimate what a repo's GitHub Actions runs billed, the way GitHub bills them:
# each job rounded up to a whole minute, Linux x1, Windows x2, macOS x10,
# skipped jobs free. Reads the jobs API through `gh`; within a few percent of
# the billing report.
#
#   ci-cost.sh [owner/repo] [days]      default: the current repo, 30 days
#
# Prints billed minutes per job name and per event, the real compute, and what
# the same compute would bill as one job per run.
set -euo pipefail

repo=${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}
days=${2:-30}
since=$(date -u -v-"${days}"d +%Y-%m-%d 2>/dev/null || date -u -d "${days} days ago" +%Y-%m-%d)
private=$(gh repo view "$repo" --json isPrivate --jq .isPrivate)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

gh api --paginate "/repos/$repo/actions/runs?created=>=$since&per_page=100" \
  --jq '.workflow_runs[] | [.id, .name, .event, .conclusion] | @tsv' > "$work/runs"

runs=$(wc -l < "$work/runs" | tr -d ' ')
if [ "$runs" = 0 ]; then
  echo "$repo: no workflow runs since $since"
  exit 0
fi

# One jobs call per run, eight at a time. Jobs with no timestamps never ran;
# skipped jobs have timestamps but bill nothing. A run whose jobs call fails
# (a transient API error) is left out rather than aborting the estimate.
# gh's --jq takes no --arg, so jq runs on the piped pages.
export REPO=$repo
tr '\n' '\0' < "$work/runs" | xargs -0 -P 8 -n 1 bash -c '
  IFS=$'"'"'\t'"'"' read -r id wf ev concl <<< "$1"
  gh api --paginate "/repos/$REPO/actions/runs/$id/jobs?filter=all&per_page=100" 2>/dev/null \
    | jq -r --arg id "$id" --arg wf "$wf" --arg ev "$ev" '"'"'
        .jobs[]
        | select(.started_at != null and .completed_at != null and .conclusion != "skipped")
        | [$id, $wf, $ev, .name, (.labels | join(",")), ((.completed_at | fromdate) - (.started_at | fromdate))]
        | @tsv'"'"' 2>/dev/null || true
' _ > "$work/jobs" || true

awk -F'\t' -v repo="$repo" -v private="$private" -v since="$since" -v runs="$runs" '
  {
    mult = 1
    if ($5 ~ /macos/) mult = 10; else if ($5 ~ /windows/) mult = 2
    billed = int(($6 + 59) / 60) * mult
    if ($3 == "dynamic") billed = 0   # Dependabot update jobs are not billed
    secs_by_run[$1] += $6; job_count[$4]++; job_secs[$4] += $6; job_billed[$4] += billed
    ev_billed[$3] += billed; total += billed; secs += $6; jobs++
  }
  END {
    for (r in secs_by_run) one_job += int((secs_by_run[r] + 59) / 60)
    printf "%s (%s) since %s: %d runs, %d billed jobs\n\n", repo, (private == "true" ? "private: billed" : "public: not billed"), since, runs, jobs
    printf "%-8s %-6s %-9s %s\n", "billed", "jobs", "avg", "job"
    for (j in job_count) printf "%5d min %5d %6d s   %s\n", job_billed[j], job_count[j], job_secs[j] / job_count[j], j | "sort -rn"
    close("sort -rn")
    printf "\nbilled by event:"
    for (e in ev_billed) printf "  %s %d", e, ev_billed[e]
    printf "\n\nbilled %d min, real compute %d min, as one job per run %d min\n", total, secs / 60, one_job
  }' "$work/jobs"
