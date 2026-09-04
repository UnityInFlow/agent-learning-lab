#!/usr/bin/env bash
# run-e005.sh — the whole of E-005's execution, in one loop over one flag array.
#
# E-005 registers that the resolved flag set is NOT on any run record for a probe of this kind,
# so "the same flags were passed to every arm" is L3. This file is the mitigation: it is weaker
# than a record and stronger than a claim, because every run of every arm is launched from
# CLAUDE_FLAGS below, and a difference between arms would have to be a bug in a committed,
# diffable file.
#
# Usage:
#   ./run-e005.sh <n-per-arm> [arm ...]
#   E005_TAG=preflight E005_PROMPT='...' ./run-e005.sh 2
#
# Outputs, all under this script's directory:
#   <tag>-results.csv        one row per run
#   <tag>-transcripts/       one stream-json file per run, kept
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)" || exit 1
LAB="$(cd "$HERE/../../.." && pwd)" || exit 1

MODEL="claude-haiku-4-5-20251001"          # the track's controlled variable. Never an alias.
AGENT_NAME="repo-reviewer"
SELFTEST=false
[[ "${1:-}" == "--selftest" ]] && { SELFTEST=true; shift; }
N="${1:-10}"; [[ $# -gt 0 ]] && shift
ARMS=("$@"); [[ ${#ARMS[@]} -eq 0 ]] && ARMS=(control toollist description)
START="${E005_START:-1}"
TAG="${E005_TAG:-batch}"
RUN_TIMEOUT="${E005_TIMEOUT:-180}"

TASK_PROMPT="${E005_PROMPT:-calc.py has a bug: average([]) raises ZeroDivisionError. Fix calc.py so that average([]) returns 0.0, and save the file.}"

OUT="$HERE/${TAG}-results.csv"
TDIR="$HERE/${TAG}-transcripts"
mkdir -p "$TDIR"

# One flag array. Every arm, every run.
CLAUDE_FLAGS=(
  --permission-mode acceptEdits
  --strict-mcp-config
  --setting-sources project
  --disable-slash-commands
  --model "$MODEL"
  --output-format stream-json
  --verbose
)

# `timeout` is NOT on this machine (no coreutils, no gtimeout) -- checked before the batch.
# Using it would have recorded exit 127 on every run and looked like a total agent failure.
# This project also has a RECORDED case of a watchdog that polled and never killed
# (opencode-review.sh run_limited(), 24 minutes against a 600s budget), so this one is
# self-tested by --selftest below and the test is part of the batch's preflight.
run_with_limit() {  # <seconds> <outfile> <workdir> <cmd...>
  local secs="$1" out="$2" wd="$3"; shift 3
  ( cd "$wd" && "$@" ) > "$out" 2>&1 &
  local pid=$! waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if (( waited >= secs )); then
      kill -TERM "$pid" 2>/dev/null
      sleep 2
      kill -KILL "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      return 124
    fi
    sleep 1; waited=$((waited+1))
  done
  wait "$pid"
}

if [[ "$SELFTEST" == true ]]; then
  t="$(mktemp)"
  s0=$(date +%s); run_with_limit 3 "$t" /tmp sleep 60; ec=$?; s1=$(date +%s)
  el=$((s1-s0))
  rm -f "$t"
  if [[ "$ec" -eq 124 ]] && (( el < 12 )); then
    echo "run-e005 selftest: watchdog KILLED a 60s command after ${el}s, exit ${ec} — ok"; exit 0
  fi
  echo "run-e005 selftest: watchdog FAILED — exit ${ec} after ${el}s (wanted 124, under 12s)"; exit 1
fi

if [[ ! -f "$OUT" ]]; then
  echo "arm,run,started_at,finished_at,agent_exit,tracked_changed,any_change,write_tool_calls,bash_calls,read_calls,transcript,repo_tree_sha,prompt_sha" > "$OUT"
fi

PROMPT_SHA="$(printf '%s' "$TASK_PROMPT" | shasum -a 256 | cut -c1-16)"
echo "run-e005: tag=${TAG} n=${N} arms=${ARMS[*]} model=${MODEL} prompt_sha=${PROMPT_SHA}"

for arm in "${ARMS[@]}"; do
  OVERLAY="$LAB/build/customizations/agent-v0.1-${arm}"
  if [[ ! -d "$OVERLAY" ]]; then echo "run-e005: no overlay for arm '${arm}'" >&2; exit 1; fi
  for ((i=START; i<START+N; i++)); do
    W="$(mktemp -d)" || exit 1

    # --- scratch repository, identical every run, from this heredoc ------------------
    cat > "$W/calc.py" <<'PY'
def average(values):
    """Return the arithmetic mean of values."""
    return sum(values) / len(values)


def total(values):
    return sum(values)
PY
    cat > "$W/README.md" <<'MD'
# calc

A tiny arithmetic helper.
MD
    git -C "$W" init -q
    git -C "$W" add -A
    git -C "$W" -c user.email=e005@lab -c user.name=e005 commit -qm "baseline"

    # --- install the arm's overlay as STARTING STATE, committed before the agent runs -
    cp -R "$OVERLAY"/. "$W"/
    git -C "$W" add -A -f -- .claude
    git -C "$W" -c user.email=e005@lab -c user.name=e005 commit -qm "install arm ${arm}"
    TREE_SHA="$(git -C "$W" rev-parse HEAD | cut -c1-12)"

    TRANSCRIPT="$TDIR/${arm}-$(printf '%02d' "$i").jsonl"
    if [[ -e "$TRANSCRIPT" ]]; then
      echo "run-e005: REFUSING to overwrite existing evidence: ${TRANSCRIPT}" >&2
      echo "run-e005: pass E005_START to continue past it" >&2
      rm -rf "$W"; exit 1
    fi
    STARTED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    run_with_limit "$RUN_TIMEOUT" "$TRANSCRIPT" "$W" \
      claude "${CLAUDE_FLAGS[@]}" --agent "$AGENT_NAME" -p "$TASK_PROMPT"
    EC=$?
    FINISHED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    # --- deterministic outcomes: git decides, not prose ------------------------------
    if git -C "$W" diff --quiet HEAD; then TRACKED=0; else TRACKED=1; fi
    if [[ -z "$(git -C "$W" status --porcelain)" ]]; then ANY=0; else ANY=1; fi

    read -r WRITES BASHES READS < <(python3 - "$TRANSCRIPT" <<'PY'
import json, sys
w = b = r = 0
try:
    for line in open(sys.argv[1], encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except Exception:
            continue
        msg = d.get("message") or {}
        if not isinstance(msg, dict):
            continue
        content = msg.get("content")
        if not isinstance(content, list):
            continue
        for c in content:
            if isinstance(c, dict) and c.get("type") == "tool_use":
                n = c.get("name")
                if n in ("Write", "Edit", "NotebookEdit"):
                    w += 1
                elif n == "Bash":
                    b += 1
                elif n in ("Read", "Grep", "Glob"):
                    r += 1
except FileNotFoundError:
    pass
print(w, b, r)
PY
    )

    echo "${arm},${i},${STARTED},${FINISHED},${EC},${TRACKED},${ANY},${WRITES},${BASHES},${READS},${TRANSCRIPT#"$HERE"/},${TREE_SHA},${PROMPT_SHA}" >> "$OUT"
    printf '  %-12s %02d  exit=%s tracked=%s any=%s write=%s bash=%s read=%s\n' \
      "$arm" "$i" "$EC" "$TRACKED" "$ANY" "$WRITES" "$BASHES" "$READS"

    rm -rf "$W"
  done
done

echo "run-e005: done -> ${OUT}"
