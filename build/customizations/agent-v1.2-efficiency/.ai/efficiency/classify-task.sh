#!/usr/bin/env bash
#
# classify-task — B11 (v1.2) mechanism 1. *** THIS IS LAYER 3 AND IT IS LABELLED L3 BECAUSE OF
# WHAT IS MISSING, NOT BECAUSE OF WHAT IS HERE. *** Nothing invokes it. The overlay's CLAUDE.md
# asks the model to run it once; a run that never does proceeds unclassified and nothing refuses
# it. Applying the workspace rule in order: can the bad value still be written down after the
# fix? Yes — the run can simply not classify. Does something execute and reject that? No. L3.
#
# IT COULD NOT HONESTLY BE MADE L2 AT THIS STEP. A hook that REFUSED an unclassified run would
# change the task's pass condition — a run that solves the ticket would fail for not having run a
# bookkeeping script — and that is a change to what the benchmark measures, which is a §7 halt
# rather than a design choice. So it is registered as L3 and `H1` is predicted low (P2, from
# B9's H = 2 of 10 on exactly this delivery: a script the prose asks for).
#
# WHAT IT WRITES: the classification the spec's step 1 asks for — api / jpa / kafka / cache /
# security / build / test-only / migration — with the evidence that chose it, so a reader can
# disagree with the label and see why it was picked.
#
# WHERE IT WRITES: OUTSIDE the worktree, beside B8's run-state, for the reason recorded in
# .ai/hooks/retrieval-budget.sh — B7's preflight pair was scored exit 21 for its own guardrail's
# log. The documented path is `.agent/task-classification.yaml` and that is the name `H1` is
# registered against.
#
# Usage: .ai/efficiency/classify-task.sh <ticket-file> [more files...]
#        .ai/efficiency/classify-task.sh --text "the ticket text"
set -uo pipefail

WT="${CLAUDE_PROJECT_DIR:-$PWD}"
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
OUT="${AGENT_TASK_CLASSIFICATION:-$DIR/task-classification-$(basename "$WT").yaml}"

TEXT=""
if [[ "${1:-}" == --text ]]; then
  TEXT="${2:-}"
else
  for f in "$@"; do [[ -r "$f" ]] && TEXT+="$(cat "$f")"$'\n'; done
fi
if [[ -z "$TEXT" ]]; then
  echo "classify-task: nothing to classify. Pass the ticket file, or --text '<ticket>'." >&2
  exit 1
fi

lower="$(printf '%s' "$TEXT" | tr '[:upper:]' '[:lower:]')"
hits=""; score() { printf '%s' "$lower" | grep -oE "$1" | wc -l | tr -d ' '; }

declare -a TYPES=(api jpa kafka cache security build test-only migration)
declare -a PATTERNS=(
  'endpoint|controller|http|rest|request|response|status code|route'
  'entity|repository|jpa|hibernate|persist|transaction|@column|database column'
  'kafka|topic|producer|consumer|event stream|publish an event'
  'cache|evict|ttl|memoiz'
  'auth|permission|role|token|secret|credential|vulnerab'
  'pom\.xml|gradle|dependency|build file|maven|ci pipeline'
  'only a test|test only|add a test|missing test|test coverage'
  'migration|flyway|liquibase|schema change|alter table'
)
best=""; bestn=0; evidence=""
for i in "${!TYPES[@]}"; do
  n="$(score "${PATTERNS[$i]}")"
  hits+="  ${TYPES[$i]}: ${n}"$'\n'
  if [[ "$n" -gt "$bestn" ]]; then bestn="$n"; best="${TYPES[$i]}"; fi
done
[[ -n "$best" ]] || { best="unclassified"; }
evidence="$(printf '%s' "$lower" | grep -oE "${PATTERNS[0]}" | sort -u | head -6 | paste -sd',' -)"

cat > "$OUT" <<YAML
# Written by .ai/efficiency/classify-task.sh (B11 v1.2, mechanism 1). LAYER 3: nothing enforced this
# file's existence, so its absence on a run means the model did not run the script — which is
# what H1 measures.
documentedPath: .agent/task-classification.yaml
schemaVersion: b11-v1.2
worktree: ${WT}
generatedAt: $(date -u +%Y-%m-%dT%H:%M:%SZ)
task_type: ${best}
confidence_basis: keyword-count, highest wins; ties go to the earlier type in the spec's own order
keyword_counts:
${hits}api_evidence: "${evidence}"
loads:
  # What the classification is FOR: the spec's step 1 says the output "drives what loads". At
  # this version it drives the verification planner's choice in CLAUDE.md and nothing else, and
  # that too is L3 — a sequence the model is asked to prefer, not one anything checks.
  verification_profile: ${best}
YAML
echo "classify-task: ${best} -> ${OUT}"
exit 0
