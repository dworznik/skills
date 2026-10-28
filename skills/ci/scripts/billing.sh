#!/usr/bin/env bash
# GitHub's own Actions usage report for a user or organization: minutes per
# SKU, per repo and per day, with the overage. Needs the `user` scope on the gh
# token for a user (`gh auth refresh -s user`), or admin on an org.
#
#   billing.sh [login] [YYYY-MM]        default: the signed-in user, this month
set -euo pipefail

login=${1:-$(gh api user --jq .login)}
month=${2:-$(date -u +%Y-%m)}
year=${month%-*}; mon=${month#*-}; mon=${mon#0}
kind=$(gh api "users/$login" --jq .type)
if [ "$kind" = "Organization" ]; then
  path="/organizations/$login/settings/billing/usage"
else
  path="/users/$login/settings/billing/usage"
fi

report=$(gh api "$path?year=$year&month=$mon")

echo "$login, $month"
echo
echo "$report" | jq -r '
  [.usageItems[] | select(.product == "actions" and .unitType == "Minutes")]
  | group_by(.sku)
  | map({sku: .[0].sku, min: (map(.quantity) | add), gross: (map(.grossAmount) | add), net: (map(.netAmount) | add), price: .[0].pricePerUnit})
  | .[]
  | "\(.sku): \(.min | round) min, gross $\(.gross * 100 | round / 100), billed $\(.net * 100 | round / 100) (at $\(.price)/min)"'
echo
echo "by repo:"
echo "$report" | jq -r '
  [.usageItems[] | select(.product == "actions" and .unitType == "Minutes")]
  | group_by(.repositoryName)
  | map({repo: .[0].repositoryName, min: (map(.quantity) | add)})
  | sort_by(-.min)
  | .[]
  | "  \(.min | round)\t\(.repo)"'
echo
echo "by day (minutes, billed $):"
echo "$report" | jq -r '
  [.usageItems[] | select(.product == "actions" and .unitType == "Minutes")]
  | group_by(.date[0:10])
  | map({d: .[0].date[0:10], min: (map(.quantity) | add), net: (map(.netAmount) | add)})
  | .[]
  | "  \(.d)\t\(.min | round)\t\(if .net > 0 then "$" + (.net * 100 | round / 100 | tostring) else "" end)"'
echo
echo "Included per month: Free 2,000, Pro 3,000, Team 3,000. The first day with a billed amount is the day the pool ran out."
