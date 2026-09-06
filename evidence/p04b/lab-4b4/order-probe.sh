#!/usr/bin/env bash
# Does the POSITION of a tool in an overlay's `tools:` line mean anything to Claude Code 2.1.263?
#
#   ./evidence/p04b/lab-4b4/order-probe.sh          # 2 reps x 4 declared orders
#   REPS=1 ./evidence/p04b/lab-4b4/order-probe.sh   # smoke
#
# WHY THIS EXISTS. Validator pass 14 (findings/track-b-validation-2026-09-06.md) closed with the
# one finding it judged most likely to overturn stop 11's result, and it is aimed at a decision
# I made:
#
#   "Stop 11's entire arm-O population exists only because 'Reading B' of the schema-verdict
#    question was adopted over 'Reading A,' and that choice was made by the same builder whose
#    batch would otherwise have voided itself. [...] the interpretive half — that 'a permutation
#    removes no capability' is asserted, not measured, on this specific runtime."
#
# It is right that it was asserted. The mechanical half it already cleared by running
# verify-schema-verdict-policy.sh itself (16 of 16). This probe measures the other half.
#
# THE QUESTION, MADE FALSIFIABLE. If the runtime's delivered `init.tools` is a CANONICAL function
# of the declared SET — the same array whatever order the four names are written in — then the
# declared position cannot carry information to the model, because the model is handed the
# delivered array and never the declaration. Reading B's premise then holds by measurement.
# If instead the delivered order TRACKS the declared order, position survives into what the model
# sees, "a permutation removes no capability" is unproven at best, and ten already-spent arm-O
# runs need re-reading in that light.
#
#   REFUTES READING B: any two declared orders that deliver DIFFERENT arrays.
#   SUPPORTS READING B: all four declared orders deliver the IDENTICAL array.
#
# Registered before the probe runs, so this cannot be read backwards:
#   PREDICTION (Claude Opus 5, autonomous, 2026-09-06): all four orders deliver
#   ["Read","Task","Grep","Glob"] on every rep — canonical, declaration-independent. Mechanism:
#   the 3 of 3 P1 probe streams and 10 of 10 batch arm-O runs already delivered exactly that
#   array from ONE declared order, and `Task` moving from 4th-declared to 2nd-delivered while
#   Read stayed 1st looks like a fixed internal ordering rather than a permutation of the input.
#   MOST LIKELY TO BE WRONG: order D, which declares the tools in the DELIVERED order. If the
#   runtime were echoing a canonical order it must return `verdict=match` there; if D instead
#   comes back permuted, the runtime is doing something to the list that neither reading models.
#
# OFF THE OBSERVATORY, under author decision 6: plain `claude -p` in scratch worktrees, no run
# records, no experiment key, enters NO B-step comparison and touches NO registered variable.
# The registered overlay is never modified — each order is written into a throwaway copy.
set -euo pipefail
cd "$(dirname "$0")" || exit 1
HERE="$(pwd)"
LAB="$(cd "$HERE/../../.." && pwd)"
OUT="${1:-$HERE/order-probe-$(date -u +%Y%m%dT%H%M%SZ)}"
REPS="${REPS:-2}"
MODEL="claude-haiku-4-5-20251001"
CHECK="$LAB/../agent-observatory/runner/lib/check-init-schema.sh"
SRC="$LAB/build/customizations/orchestration-4b4-P1/.claude"
REGISTERED_ORCH_HASH="4f2af4ba7f740c33"

[[ -d "$SRC/agents" ]] || { echo "order-probe: missing overlay $SRC" >&2; exit 2; }
[[ -x "$CHECK" ]] || { echo "order-probe: missing $CHECK" >&2; exit 2; }
mkdir -p "$OUT"

# The flag set is run-agent.sh's claude arm VERBATIM, as the stop-10 and stop-11 probes used it.
CLAUDE_FLAGS=(
  --permission-mode acceptEdits
  --strict-mcp-config
  --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
  --disable-slash-commands
  --setting-sources project
  --model "$MODEL"
)

# Four declared orders of the SAME four names. A is the registered declaration; D is the order
# 2.1.263 has delivered on every observation so far.
ORDER_A="Read, Grep, Glob, Task"
ORDER_B="Task, Glob, Grep, Read"
ORDER_C="Glob, Task, Read, Grep"
ORDER_D="Read, Task, Grep, Glob"

PROMPT='Reply with exactly the word ready and nothing else.'

printf 'order\tdeclared\trep\tdelivered\tverdict\n' > "$OUT/summary.tsv"

for name in A B C D; do
  case "$name" in
    A) decl="$ORDER_A" ;;
    B) decl="$ORDER_B" ;;
    C) decl="$ORDER_C" ;;
    D) decl="$ORDER_D" ;;
  esac
  for r in $(seq 1 "$REPS"); do
    W="$OUT/wt-$name-$r"
    mkdir -p "$W"
    cp -R "$SRC" "$W/.claude"
    # Rewrite ONLY the tools: line, in the throwaway copy. Everything else is byte-identical to
    # the registered treatment, so the one thing that differs between cells is the declared order.
    ORCH="$W/.claude/agents/orchestrator.md"
    awk -v d="$decl" '/^tools:/ { print "tools: " d; next } { print }' "$ORCH" > "$ORCH.tmp"
    mv "$ORCH.tmp" "$ORCH"
    grep -qE "^tools: ${decl}\$" "$ORCH" || { echo "order-probe: rewrite failed for $name" >&2; exit 2; }

    ( cd "$W" && git init -q . && git add -A \
        && git -c user.name=probe -c user.email=probe@local commit -q -m overlay )

    ( cd "$W" && claude "${CLAUDE_FLAGS[@]}" \
        --agent orchestrator \
        --output-format stream-json --verbose \
        -p "$PROMPT" ) \
      > "$OUT/$name-$r.jsonl" 2>"$OUT/$name-$r.err" \
      || echo "order-probe: $name-$r exited non-zero — recorded anyway" >&2

    delivered="$(jq -c -R 'fromjson? | select(type=="object" and .type=="system" and .subtype=="init") | .tools' \
                 "$OUT/$name-$r.jsonl" 2>/dev/null | head -1)"
    "$CHECK" "$OUT/$name-$r.jsonl" "$ORCH" > "$OUT/$name-$r.schema.txt" 2>&1 || true
    verdict="$(grep -ao 'verdict=[a-z-]*' "$OUT/$name-$r.schema.txt" | head -1)"
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$name" "$decl" "$r" "${delivered:-NONE}" "${verdict:-NONE}" >> "$OUT/summary.tsv"
    echo "  $name rep $r: declared [$decl] -> ${delivered:-NONE} ${verdict:-NONE}"
  done
done

# The registered overlay must be untouched by all of the above.
got="$(shasum -a 256 "$SRC/agents/orchestrator.md" | cut -c1-16)"
if [[ "$got" == "$REGISTERED_ORCH_HASH" ]]; then
  echo "order-probe: registered overlay UNCHANGED ($got)"
else
  echo "order-probe: !! REGISTERED OVERLAY CHANGED: $got, expected $REGISTERED_ORCH_HASH" >&2
  exit 1
fi

echo
echo "== summary =="
column -t -s "$(printf '\t')" "$OUT/summary.tsv" 2>/dev/null || cat "$OUT/summary.tsv"
echo
distinct="$(awk -F'\t' 'NR>1 && $4!="NONE" {print $4}' "$OUT/summary.tsv" | sort -u | wc -l | tr -d ' ')"
echo "distinct delivered arrays across all declared orders: $distinct"
if [[ "$distinct" == "1" ]]; then
  echo "READING B SUPPORTED: delivery is canonical — the declared order does not reach the model."
else
  echo "READING B REFUTED: delivery tracks the declaration. Position survives into the session."
fi
echo "summary: $OUT/summary.tsv"
