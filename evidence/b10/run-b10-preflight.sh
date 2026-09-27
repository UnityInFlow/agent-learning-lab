#!/usr/bin/env bash
# run-b10-preflight — §4 step 5 for spine stop 21 (B10). FOUR RUNS: one per arm per task, each
# under its OWN registered key (EXP-B10-PREFLIGHT-BE003 / -BE004), which both experiments exclude
# from the population in terms. No batch starts until this passes.
#
#   ./evidence/b10/run-b10-preflight.sh
#
# WHY THE KEY IS ITS OWN AND NOT THE BATCH'S. run-b9-preflight.sh:134 handed the preflight the
# BATCH's key, so EXP-B9-ROUTER-BE003 ended up holding 25 runs where the registered population was
# 20, and `make baseline-report` POOLED them silently. Only `analyze-experiment.py --expect-n`
# refused, which is the only reason it was found rather than quoted.
#
# THE THREE CONDITIONS, from E-024/E-025's `Preflight assertion` and `Control assertion` rows:
#   (i)   the TREATED run's instructionsHash and knowledgeHash equal the REGISTERED VALUES — not
#         merely non-null. A proof that only asserts non-null passes when the wrong overlay is
#         installed, and this stop's whole claim is that these two digests are the ones stop 20
#         registered on claude.
#   (ii)  the CONTROL run's five customization hashes are ALL null, READ BACK FROM THE RECORD.
#         Not inferred from the absence of --customization: "the flag was not passed" and "the
#         record says null" are different claims, and this project has been wrong about the
#         difference before.
#   (iii) the `init.tools` read-back is taken ON THE CODEX ARM even though codex has no `tools:`
#         field at all (SOURCES.md:108). It is taken precisely because E-005's rewrite —
#         `Read, Grep, Glob, Bash` delivered as ["Read","Bash"] on 10 of 10 — was found by taking
#         this read-back on an arm nobody expected it from. Whatever it shows here is recorded;
#         `absent` is a measurement and is not a failure of the preflight.
#
# Exit 0 all conditions hold · 3 condition (i) or (ii) failed · 5 the overlay is not the
# registered one · 8 another b10 driver holds the lock
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="${B10_OBS:-$(cd ../agent-observatory && pwd)}" || exit 1

OVERLAY_T="${B10_OVERLAY_T:-$LAB/build/customizations/agent-v1.2-knowledge-codex}"
MODEL="${B10_MODEL:-gpt-5.6-sol}"
RUNTIME="${B10_RUNTIME:-codex}"
EXPECT_INSTR_T="${B10_EXPECT_INSTR_T:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_KNOWLEDGE_T="${B10_EXPECT_KNOWLEDGE_T:-sha256:0770219ae7f4281a80071d78dadea285}"
RUNNER="${B10_RUNNER:-runner/run-agent.sh}"

export API="${B10_API:-http://127.0.0.1:8081}"
export WEB="${B10_WEB:-http://localhost:5174}"
export TEMPO_URL="${B10_TEMPO:-http://localhost:3200}"
export OTLP_HTTP_ENDPOINT="${B10_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B10_OTLP_GRPC:-http://localhost:4317}"

TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)

LOCK="$LAB/evidence/b10/.batch.lock"
if [[ -e "$LOCK" ]]; then
  other="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$other" ]] && kill -0 "$other" 2>/dev/null; then
    echo "run-b10-preflight: a b10 driver is running as pid $other. Refusing." >&2; exit 8
  fi
fi
echo "$$" > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

instr_digest() { printf 'sha256:%s' "$(shasum -a 256 "$1/AGENTS.md" | cut -c1-32)"; }
knowledge_digest() {
  ( cd "$1" && find .ai/knowledge -type f 2>/dev/null | LC_ALL=C sort \
    | while IFS= read -r f; do printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done ) \
    | shasum -a 256 | cut -c1-32 | sed 's/^/sha256:/'
}
if [[ "$(instr_digest "$OVERLAY_T")" != "$EXPECT_INSTR_T" \
   || "$(knowledge_digest "$OVERLAY_T")" != "$EXPECT_KNOWLEDGE_T" ]]; then
  echo "run-b10-preflight: the overlay on disk is not the registered one. Refusing." >&2; exit 5
fi

TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="${B10_EVID_ROOT:-$LAB/evidence/b10}/preflight-$TAG"
mkdir -p "$EVID/init-schema" "$EVID/router-logs"
MANIFEST="$EVID/manifest.tsv"
{
  printf '# B10 PREFLIGHT %s — one run per arm per task, four runs, §4 step 5\n' "$TAG"
  printf '# runtime %s  model %s  treated %s  control NO OVERLAY\n' "$RUNTIME" "$MODEL" "$OVERLAY_T"
  printf '# registered treated instructionsHash %s / knowledgeHash %s\n' "$EXPECT_INSTR_T" "$EXPECT_KNOWLEDGE_T"
  printf '# codex %s  benchmarks %s\n' "$(codex --version 2>/dev/null | head -1)" \
    "$(git -C ../agent-observatory-benchmarks rev-parse --short HEAD 2>/dev/null)"
  printf '# NOT IN THE POPULATION — key EXP-B10-PREFLIGHT-<task>, excluded by E-024/E-025\n'
  printf 'task\tarm\trun_id\trc\teval\tinstr_hash\tknowledge_hash\tskills_hash\tagent_hash\tagents_hash\tverdict\truntime_ver\tinit_tools\tcost\ttokens\tmodel_calls\ttool_calls\tduration_ms\tchanged\trouter_log\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
FAILED=0

one() {  # one <task> <arm>
  local task="$1" arm="$2" key log rc rid wt rec
  key="EXP-B10-PREFLIGHT-$(echo "$task" | tr -d '-')"
  log="$EVID/${task}-${arm}.log"
  echo ""; echo "======== PREFLIGHT $task $arm  key=$key  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime "$RUNTIME" --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then
    args+=(--customization "$OVERLAY_T" --variant agent-v1.2-knowledge-codex)
  else
    args+=(--variant plain)
  fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" "$RUNNER" "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local ih kh sh ah gh ver ev cost tok mc tc dur chg
  ih="$(printf '%s' "$rec"  | jq -r '.customization.instructionsHash // "null"')"
  kh="$(printf '%s' "$rec"  | jq -r '.customization.knowledgeHash // "null"')"
  sh="$(printf '%s' "$rec"  | jq -r '.customization.skillsHash // "null"')"
  ah="$(printf '%s' "$rec"  | jq -r '.customization.agentHash // "null"')"
  gh="$(printf '%s' "$rec"  | jq -r '.customization.agentsHash // "null"')"
  ver="$(printf '%s' "$rec" | jq -r '.runtime.version // "null"')"
  ev="$(printf '%s' "$rec"  | jq -r '.evaluation.exitCode // "null"')"
  cost="$(printf '%s' "$rec"| jq -r '.efficiency.estimatedCost // "null"')"
  tok="$(printf '%s' "$rec" | jq -r '.efficiency.reportedTotalTokens // "null"')"
  mc="$(printf '%s' "$rec"  | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"  | jq -r '.behavior.toolCalls // "null"')"
  dur="$(printf '%s' "$rec" | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec" | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"

  local verdict="ok"
  if [[ "$arm" == treated ]]; then
    [[ "$ih" == "$EXPECT_INSTR_T" ]] || verdict="FAIL-instr"
    [[ "$kh" == "$EXPECT_KNOWLEDGE_T" ]] || verdict="${verdict}+FAIL-knowledge"
  else
    [[ "$ih" == null && "$kh" == null && "$sh" == null && "$ah" == null && "$gh" == null ]] \
      || verdict="FAIL-control-not-clean"
  fi
  [[ "$verdict" == ok ]] || FAILED=1

  # The author-decision-8 read-back. `absent` is a measurement.
  local it; it="$(find "$EVID/init-schema" -name "*${rid:-none}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -f "$it" ]]; then
    it="$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ -n "$it" ]] || it="file-present-no-verdict-line"
  else
    it="absent"
  fi

  local rlog="none" src
  src="${TMPDIR:-/tmp}/knowledge-log-observatory-run-${rid:-none}.jsonl"
  if [[ -s "$src" ]]; then rlog="$EVID/router-logs/$(basename "$src")"; cp "$src" "$rlog"; fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$arm" "${rid:-none}" "$rc" "$ev" "$ih" "$kh" "$sh" "$ah" "$gh" "$verdict" "$ver" \
    "$it" "$cost" "$tok" "$mc" "$tc" "$dur" "$chg" "$rlog" "${wt:-none}" >> "$MANIFEST"
  echo "  rc=$rc eval=$ev verdict=$verdict instr=$ih knowledge=$kh init_tools=$it tokens=$tok"
}

for task in "${TASKS[@]}"; do
  one "$task" control
  one "$task" treated
done

echo ""
if [[ "$FAILED" == 0 ]]; then
  echo "======== PREFLIGHT PASSED — every arm's hashes are what E-024/E-025 registered ========"
else
  echo "======== PREFLIGHT FAILED — read the verdict column. THE BATCH DOES NOT OPEN. ========"
fi
echo "manifest $MANIFEST"
exit $(( FAILED * 3 ))
