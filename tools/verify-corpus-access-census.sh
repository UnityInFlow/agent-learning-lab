#!/usr/bin/env bash
#
# verify-corpus-access-census.sh — the fixture set for evidence/b09/corpus-access-census.sh.
#
# The census's classification is what turned a null into a finding at spine stop 20: it separated a
# run that INVOKED the router from one that READ the corpus by hand, and `H` — the registered
# decision-rule input — counts only the first. A classifier that decides a finding must be shown to
# refuse, so every case below drives one classification or one exit code against a synthetic log.
#
# THE CASE THAT MATTERS MOST IS E: the harness's own output must not be counted. run-agent.sh prints
# `customization installed from <dir>`, echoes the overlay file list, and prints
# `claude args: ... Bash(.ai/knowledge/router.sh:*)`. A plain `grep router.sh` reads every one of
# those as agent activity — the defect run-b9-batch.sh records twice on a single line.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
CENSUS="evidence/b09/corpus-access-census.sh"
SCRATCH="$(mktemp -d)"; trap 'rm -rf "$SCRATCH"' EXIT
PASS=0; FAIL=0

mklog() {  # mklog <name> <body...>
  local d="$SCRATCH/$1"; shift
  mkdir -p "$d"
  printf '%s\n' "$@" > "$d/BE-003-01-treated.log"
  printf '%s' "$d"
}
expect_class() {  # expect_class <label> <dir> <wanted-classification>
  local label="$1" d="$2" want="$3" got
  got="$("$CENSUS" "$d" 2>/dev/null | awk -F'\t' 'NR==2{print $8}')"
  if [[ "$got" == "$want" ]]; then PASS=$((PASS+1)); printf 'PASS  %-56s %s\n' "$label" "$got"
  else FAIL=$((FAIL+1)); printf 'FAIL  %-56s got "%s", wanted "%s"\n' "$label" "$got" "$want"; fi
}
expect_exit() {  # expect_exit <label> <wanted> <args...>
  local label="$1" want="$2"; shift 2
  "$CENSUS" "$@" >/dev/null 2>&1; local rc=$?
  if [[ "$rc" == "$want" ]]; then PASS=$((PASS+1)); printf 'PASS  %-56s exit %s\n' "$label" "$rc"
  else FAIL=$((FAIL+1)); printf 'FAIL  %-56s exit %s (wanted %s)\n' "$label" "$rc" "$want"; fi
}

BASH_ENV_ROUTER='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"cd /tmp/x && .ai/knowledge/router.sh \"status enum\"","description":"consult"}}]}}'
READ_SUMMARY='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/tmp/x/.ai/knowledge/summaries/kotlin-exhaustive-when.md"}}]}}'
READ_DETAILS='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/tmp/x/.ai/knowledge/documents/kotlin-exhaustive-when.md"}}]}}'
READ_INDEX='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/tmp/x/.ai/knowledge/index.yaml"}}]}}'
CAT_SUMMARY='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"cat .ai/knowledge/summaries/kotlin-exhaustive-when.md"}}]}}'
UNRELATED='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"./mvnw -q test"}}]}}'
# Verbatim shapes from a real treated log's header — the harness, not the agent.
HARNESS_1='  customization installed from /Users/x/agent-learning-lab/build/customizations/agent-v1.2-knowledge'
HARNESS_2='  claude args: --allowedTools Bash(./mvnw:*) Bash(mvn:*) Bash(.ai/knowledge/router.sh:*) --agent backend-feature-phases'
HARNESS_3='.ai/knowledge/router.sh'
HARNESS_4='.ai/knowledge/summaries/kotlin-exhaustive-when.md'

expect_class "A router invoked only"            "$(mklog a "$UNRELATED" "$BASH_ENV_ROUTER")"  "router-only"
expect_class "B router + a direct read"         "$(mklog b "$BASH_ENV_ROUTER" "$READ_SUMMARY")" "router+direct"
expect_class "C summary read, router never run" "$(mklog c "$UNRELATED" "$READ_SUMMARY")"     "DIRECT-ONLY-invisible-to-H"
expect_class "D nothing touched the corpus"     "$(mklog d "$UNRELATED")"                     "no-contact"
# *** E: THE HARNESS'S OWN OUTPUT, AND NOTHING ELSE. Must be `no-contact`. ***
expect_class "E harness echo only -> no-contact" "$(mklog e "$HARNESS_1" "$HARNESS_2" "$HARNESS_3" "$HARNESS_4" "$UNRELATED")" "no-contact"
expect_class "F index.yaml read is direct"      "$(mklog f "$UNRELATED" "$READ_INDEX")"       "DIRECT-ONLY-invisible-to-H"
expect_class "G cat of the summary is direct"   "$(mklog g "$UNRELATED" "$CAT_SUMMARY")"      "DIRECT-ONLY-invisible-to-H"
expect_class "H harness echo + a real read"     "$(mklog h "$HARNESS_2" "$HARNESS_4" "$READ_DETAILS")" "DIRECT-ONLY-invisible-to-H"
expect_class "I harness echo + a real invocation" "$(mklog i "$HARNESS_2" "$BASH_ENV_ROUTER")" "router-only"
# A Read of a file that merely MENTIONS the corpus path is not corpus access.
MENTION='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/tmp/x/CLAUDE.md"}}]},"note":"CLAUDE.md names .ai/knowledge/router.sh in its prose"}'
expect_class "J a Read of CLAUDE.md is not corpus access" "$(mklog j "$UNRELATED" "$MENTION")" "no-contact"

# Two router calls on ONE stream-json line must count as two, not one — `grep -c` would count one.
TWO_ON_ONE_LINE="$BASH_ENV_ROUTER$BASH_ENV_ROUTER"
D="$(mklog k "$TWO_ON_ONE_LINE")"
n="$("$CENSUS" "$D" 2>/dev/null | awk -F'\t' 'NR==2{print $2}')"
if [[ "$n" == 2 ]]; then PASS=$((PASS+1)); printf 'PASS  %-56s %s\n' "K two calls on one line count as 2" "$n"
else FAIL=$((FAIL+1)); printf 'FAIL  %-56s got %s, wanted 2\n' "K two calls on one line count as 2" "$n"; fi

expect_exit "L no argument -> exit 2"           2
expect_exit "M a batch directory that is absent -> exit 2" 2 "$SCRATCH/nope"
mkdir -p "$SCRATCH/empty"
expect_exit "N a directory with no treated logs -> exit 3" 3 "$SCRATCH/empty"
expect_exit "O the real stop-20 batch, by tag -> exit 0" 0 20260926T151319Z

echo ""
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] && { echo "all $PASS cases behaved as specified"; exit 0; }
exit 1
