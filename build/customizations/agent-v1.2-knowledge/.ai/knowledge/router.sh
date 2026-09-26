#!/usr/bin/env bash
#
# knowledge router — v1.2's one executing artifact, and spine stop 20's whole mechanism.
#
# Takes a query string, matches it case-insensitively against the trigger lists in
# .ai/knowledge/index.yaml, prints the matched topic's SUMMARY path and then its DETAILS path,
# and APPENDS ONE JSON LINE PER LOOKUP to a log — on a hit, a miss, and every failure.
#
# WHY IT LOGS ON A MISS AS WELL AS A HIT, inherited from B7's policy-gate.sh: a record written
# only on the interesting path is indistinguishable from a tool that never ran, and this
# project's house failure mode is a control reporting success over a scope smaller than it
# claims. The log is the experiment's evidence that the instruction in CLAUDE.md was ACTED ON
# (E-022/E-023 prediction 3, decision-rule row 0). An empty log is a registered result: the
# treatment was not tested.
#
# *** THE LOG IS WRITTEN OUTSIDE THE WORKTREE, AND THAT IS NOT A DETAIL. ***
# It was registered as `.agent/knowledge-log.jsonl` INSIDE the repository under test. It is
# not, and could not be: BE-003's evaluator computes its changed-file set as
# `git diff --name-only $BASELINE_SHA` plus `git ls-files --others --exclude-standard`
# (evaluator.sh:110-127), its ignore pattern covers only target/ .mvn/ .git/ *.log *.class
# *.jar run.json evaluation.json, and anything outside the two allowed production prefixes and
# src/test/ is an AC7 scope violation -> exit 21 (evaluator.sh:279-296). A `.jsonl` under
# `.agent/` matches no ignore rule. B7 already paid for this: preflight runs 2077432c and
# 88b861f3 SOLVED their tasks and were both scored exit 21 because the single unrelated file
# was the guardrail's own log (E-016:227-237). Every treated run of this stop would have been
# scored a scope violation caused entirely by the treatment's bookkeeping.
# The evaluator's ignore pattern is a REGISTERED VARIABLE (§7), so teaching it about `.agent/`
# is not available and was not attempted; neither is a .gitignore entry, which the scope guard
# reads. So the log lives under $TMPDIR with the run in its own name, exactly as v1.1's
# repair-limit.sh and policy-gate.sh already do, and the file still exists if and only if the
# router executed.
# Amended before any run of this experiment, 2026-09-26, by Opus 5 (claude-opus-5),
# autonomously; recorded as a dated amendment in E-022, E-023 and the workbook.
#
# EXIT CODES. Every one of them is proved by tools/verify-knowledge-router.sh:
#   0  HIT        — exactly one topic matched; summary path then details path on stdout
#   1  USAGE      — no query given
#   2  MISS       — no trigger matched; nothing on stdout
#   3  MALFORMED  — the index is unreadable, has no `topics:` key, parses to zero topics, or
#                   the matched topic lacks a summary or a details key
#   4  UNREADABLE — the matched topic's summary or details file is missing or unreadable
#   5  AMBIGUOUS  — the query matches triggers in two or more topics; nothing on stdout
# Nothing here is a boundary: the router cannot make the agent call it, and cannot make the
# agent read what it returned. Layer 2 for "a lookup was recorded", Layer 3 for everything else.
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 3
ROOT="$(cd "$SELF_DIR/../.." && pwd)" || exit 3
INDEX="${KNOWLEDGE_INDEX:-$SELF_DIR/index.yaml}"
CORPUS_DIR="$(dirname "$INDEX")"
LOG="${KNOWLEDGE_EVENT_LOG:-${TMPDIR:-/tmp}/knowledge-log-$(basename "$ROOT").jsonl}"

# One JSON line per lookup. Written with printf and %s only: the query is user text and the
# only two characters that could break the line are escaped below.
emit() {  # emit <status> <query> <topic> <summary> <details> <matched-count>
  printf '{"ts":"%s","status":"%s","query":"%s","topic":"%s","summary":"%s","details":"%s","matches":%s,"pid":%s}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" "$3" "$4" "$5" "$6" "$$" >> "$LOG" 2>/dev/null || true
}
escape() { printf '%s' "$1" | tr '\n\t' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g'; }

QUERY_RAW="${1:-}"
QUERY="$(escape "$QUERY_RAW")"
if [[ -z "$QUERY_RAW" ]]; then
  emit usage "" "" "" "" 0
  echo "usage: router.sh \"<what you are about to write>\"" >&2
  exit 1
fi

if [[ ! -r "$INDEX" ]]; then
  emit malformed "$QUERY" "" "" "" 0
  echo "knowledge router: index not readable at $INDEX" >&2
  exit 3
fi
if ! grep -q '^topics:[[:space:]]*$' "$INDEX"; then
  emit malformed "$QUERY" "" "" "" 0
  echo "knowledge router: $INDEX has no 'topics:' key" >&2
  exit 3
fi

# Parse §10.9's shape and nothing wider: `topics:` -> two-space topic keys -> four-space
# `triggers:` / `summary:` / `details:`, triggers as six-space `- ` items. One TSV record per
# topic, triggers joined by '|'. A key this shape does not define is ignored rather than
# guessed at.
RECORDS="$(awk '
  /^topics:[[:space:]]*$/ { intopics=1; next }
  intopics && /^  [A-Za-z0-9_.-]+:[[:space:]]*$/ {
    if (topic != "") print topic "\t" trig "\t" summ "\t" det
    topic=$1; sub(/:$/, "", topic); trig=""; summ=""; det=""; intrig=0; next
  }
  intopics && /^    triggers:[[:space:]]*$/ { intrig=1; next }
  intopics && intrig && /^      - / {
    v=$0; sub(/^      - /, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v)
    trig = (trig == "" ? v : trig "|" v); next
  }
  intopics && /^    summary:[[:space:]]*/ {
    v=$0; sub(/^    summary:[[:space:]]*/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); summ=v; intrig=0; next
  }
  intopics && /^    details:[[:space:]]*/ {
    v=$0; sub(/^    details:[[:space:]]*/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); det=v; intrig=0; next
  }
  END { if (topic != "") print topic "\t" trig "\t" summ "\t" det }
' "$INDEX")"

if [[ -z "$RECORDS" ]]; then
  emit malformed "$QUERY" "" "" "" 0
  echo "knowledge router: $INDEX parsed to zero topics" >&2
  exit 3
fi

NEEDLE="$(printf '%s' "$QUERY_RAW" | tr '[:upper:]' '[:lower:]')"
MATCHED=""
COUNT=0
while IFS=$'\t' read -r topic trig summ det; do
  [[ -z "$topic" ]] && continue
  hit=0
  OLDIFS="$IFS"; IFS='|'
  for t in $trig; do
    [[ -z "$t" ]] && continue
    lt="$(printf '%s' "$t" | tr '[:upper:]' '[:lower:]')"
    case "$NEEDLE" in *"$lt"*) hit=1; break ;; esac
  done
  IFS="$OLDIFS"
  if [[ "$hit" -eq 1 ]]; then
    COUNT=$((COUNT+1))
    MATCHED="$topic"$'\t'"$summ"$'\t'"$det"
    MATCHED_NAMES="${MATCHED_NAMES:-}${MATCHED_NAMES:+, }$topic"
  fi
done <<<"$RECORDS"

if [[ "$COUNT" -eq 0 ]]; then
  emit miss "$QUERY" "" "" "" 0
  echo "knowledge router: nothing indexed for that query" >&2
  exit 2
fi
if [[ "$COUNT" -gt 1 ]]; then
  emit ambiguous "$QUERY" "" "" "" "$COUNT"
  echo "knowledge router: $COUNT topics match (${MATCHED_NAMES:-}); narrow the query" >&2
  exit 5
fi

IFS=$'\t' read -r TOPIC SUMMARY DETAILS <<<"$MATCHED"
if [[ -z "$SUMMARY" || -z "$DETAILS" ]]; then
  emit malformed "$QUERY" "$TOPIC" "$(escape "$SUMMARY")" "$(escape "$DETAILS")" 1
  echo "knowledge router: topic '$TOPIC' has no summary or no details path" >&2
  exit 3
fi

SUMMARY_ABS="$CORPUS_DIR/$SUMMARY"
DETAILS_ABS="$CORPUS_DIR/$DETAILS"
if [[ ! -r "$SUMMARY_ABS" || ! -r "$DETAILS_ABS" ]]; then
  emit unreadable "$QUERY" "$TOPIC" "$(escape "$SUMMARY")" "$(escape "$DETAILS")" 1
  echo "knowledge router: topic '$TOPIC' points at a path that is not readable" >&2
  exit 4
fi

emit hit "$QUERY" "$TOPIC" "$(escape "$SUMMARY")" "$(escape "$DETAILS")" 1
printf '%s\n' "$SUMMARY_ABS"
printf '%s\n' "$DETAILS_ABS"
exit 0
