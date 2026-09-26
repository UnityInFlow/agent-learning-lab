#!/usr/bin/env bash
#
# verify-b9-preflight-guards — the fixture set for run-b9-preflight.sh's guards.
#
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing (§6), and this guard set is the only thing standing between $8 of benchmark runs
# and a batch that measures two variables. Every case drives the REAL script through its
# B9_OVERLAY_T / B9_OVERLAY_C / B9_API / B9_OTLP / B9_LOCK overrides — which exist for this file
# and for nothing else — and asserts the exit code it documents.
#
# NO CASE STARTS A BENCHMARK RUN. Cases A–H exit inside guards-only mode; I and J are refused by
# the endpoint check, which runs before the pid lock and before any run; K is refused by the lock
# itself, which is the first thing the script does.
#
# Usage: evidence/b09/verify-b9-preflight-guards.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b09/run-b9-preflight.sh"
T="$LAB/build/customizations/agent-v1.2-knowledge"
C="$LAB/build/customizations/agent-v1.1"
EXPECTED_CASES=11

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }
# expect <wanted-rc> <label> -- <env assignments and the driver invocation>
expect() {
  local want="$1" label="$2"; shift 3
  local out rc
  out="$("$@" 2>&1)"; rc=$?
  if [[ "$rc" -eq "$want" ]]; then ok "$label (exit $rc)"
  else bad "$label — wanted exit $want, got $rc: $(printf '%s' "$out" | grep -m1 'ABORT\|refus' || true)"; fi
}

copy_t() { local d="$WORK/$1"; rm -rf "$d"; cp -R "$T" "$d"; echo "$d"; }
copy_c() { local d="$WORK/$1"; rm -rf "$d"; cp -R "$C" "$d"; echo "$d"; }

echo "verify-b9-preflight-guards: $EXPECTED_CASES cases against $DRIVER"

# A — the happy path. Without it every case below is satisfied by a script that refuses everything.
expect 0 "A the registered overlays pass every guard" -- \
  env B9_GUARDS_ONLY=1 "$DRIVER"

# B — the arms' agent files differ: more than one variable moves.
d="$(copy_c B)"; printf '\nedited\n' >> "$d/.claude/agents/backend-feature-phases.md"
expect 6 "B the arms' agent files differ" -- env B9_GUARDS_ONLY=1 B9_OVERLAY_C="$d" "$DRIVER"

# C — the agent file is identical in both arms but is not the REGISTERED one. B cannot catch this:
#     an equal-but-wrong pair passes B and changes what the comparison is about.
dt="$(copy_t C1)"; dc="$(copy_c C2)"
printf '\nedited in both\n' >> "$dt/.claude/agents/backend-feature-phases.md"
printf '\nedited in both\n' >> "$dc/.claude/agents/backend-feature-phases.md"
expect 6 "C both arms carry the same UNREGISTERED agent file" -- \
  env B9_GUARDS_ONLY=1 B9_OVERLAY_T="$dt" B9_OVERLAY_C="$dc" "$DRIVER"

# D — the treated CLAUDE.md is not the registered one.
d="$(copy_t D)"; printf '\nextra clause\n' >> "$d/CLAUDE.md"
expect 6 "D the treated CLAUDE.md is not the registered sha" -- env B9_GUARDS_ONLY=1 B9_OVERLAY_T="$d" "$DRIVER"

# E — the control CLAUDE.md is not v1.1's.
d="$(copy_c E)"; printf '\nextra clause\n' >> "$d/CLAUDE.md"
expect 6 "E the control CLAUDE.md is not v1.1's sha" -- env B9_GUARDS_ONLY=1 B9_OVERLAY_C="$d" "$DRIVER"

# F — THE TREATMENT IN BOTH ARMS. The failure that produces a confident null.
d="$(copy_c F)"; mkdir -p "$d/.ai/knowledge"; cp "$T/.ai/knowledge/index.yaml" "$d/.ai/knowledge/"
expect 6 "F the CONTROL carries .ai/knowledge" -- env B9_GUARDS_ONLY=1 B9_OVERLAY_C="$d" "$DRIVER"

# G — the corpus is not the registered one. A one-byte edit must move the value.
d="$(copy_t G)"; printf '\n# one byte\n' >> "$d/.ai/knowledge/index.yaml"
expect 6 "G the corpus sha is not the registered one" -- env B9_GUARDS_ONLY=1 B9_OVERLAY_T="$d" "$DRIVER"

# H — THE CONTENT CONSTRAINT. Nothing in the corpus may derive from a task; the runner's leak check
#     greps object path NAMES only (run-agent.sh:259-262), so this guard is the only thing that
#     executes on content. Uses the registered-sha override so the case tests the WORD check and
#     not the sha check it would otherwise trip first.
d="$(copy_t H)"; printf '\n# mentions confirm\n' >> "$d/.ai/knowledge/summaries/kotlin-exhaustive-when.md"
nk="$( (cd "$d" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
          printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
expect 6 "H the corpus names a task word" -- \
  env B9_GUARDS_ONLY=1 B9_OVERLAY_T="$d" B9_EXPECT_KNOWLEDGE_HASH="sha256:$nk" "$DRIVER"

# I — a dead API. Runs with the guards passing and no guards-only exit, so it proves the endpoint
#     check refuses BEFORE the lock is taken and before any run is launched.
expect 7 "I a dead API refuses the preflight" -- env B9_API="http://127.0.0.1:1" "$DRIVER"

# J — a dead OTLP endpoint. A run that reaches the wrong collector records null cost, which looks
#     exactly like a run that made no model calls.
expect 7 "J a dead OTLP endpoint refuses the preflight" -- env B9_OTLP="http://127.0.0.1:1" "$DRIVER"

# K — the pid lock. A second preflight or batch must refuse; a duplicate benchmark run is evidence
#     that cannot be deleted. The lock holds THIS shell's pid, so `kill -0` succeeds.
printf '%s\n' "$$" > "$WORK/held.lock"
expect 8 "K a held pid lock refuses a second preflight" -- env B9_LOCK="$WORK/held.lock" "$DRIVER"

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-b9-preflight-guards: ${ran} cases ran, ${EXPECTED_CASES} registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  exit 1
fi
echo "verify-b9-preflight-guards: ${pass} passed, ${fail} failed, ${ran} of ${EXPECTED_CASES} cases ran."
[[ "$fail" -eq 0 ]] || exit 1
