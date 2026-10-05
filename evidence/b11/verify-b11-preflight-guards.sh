#!/usr/bin/env bash
#
# verify-b11-preflight-guards — the fixture set for run-b11-preflight.sh's guards.
#
# A control that has never been shown to reject anything is indistinguishable from one that rejects
# nothing (§6), and this guard set is the only thing standing between about $1.50 of benchmark runs
# and a preflight that certifies a two-variable comparison. Every case drives the REAL script
# through its B11_OVERLAY_T / B11_OVERLAY_C / B11_API / B11_OTLP / B11_LOCK / B11_FIXTURE_DIR
# overrides — which exist for this file and for nothing else — and asserts the exit code it
# documents.
#
# NO CASE STARTS A BENCHMARK RUN. Cases A–I exit inside guards-only mode; J and K are refused by
# the endpoint check, which runs before the pid lock and before any run; L is refused by the lock
# itself; M and N need no run at all.
#
# *** EVERY CASE POINTS B11_FIXTURE_DIR AT STUBS, AND THAT IS NOT A SHORTCUT. *** The three real
# hook fixture sets take about three minutes together (the dedup set builds a git repo and makes
# ~30 hook calls, and a hook call costs seconds on this machine because jq and git process startup
# dominate it). Running them fourteen times here would make this file the slowest thing in the
# repository while testing them a fourteenth time. They are run for real by the preflight itself,
# by CI, and by cases H and I below — which are the cases that prove the GATE works, in both
# directions, with a stub that passes and a stub that fails.
#
# Usage: evidence/b11/verify-b11-preflight-guards.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b11/run-b11-preflight.sh"
T="$LAB/build/customizations/agent-v1.2-efficiency"
C="$LAB/build/customizations/agent-v1.1"
EXPECTED_CASES=14

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }
expect() {  # expect <wanted-rc> <label> -- <env assignments and the driver invocation>
  local want="$1" label="$2"; shift 3
  local out rc
  out="$("$@" 2>&1)"; rc=$?
  if [[ "$rc" -eq "$want" ]]; then ok "$label (exit $rc)"
  else bad "$label — wanted exit $want, got $rc: $(printf '%s' "$out" | grep -m1 'ABORT\|refus' || true)"; fi
}
copy_t() { local d="$WORK/$1"; rm -rf "$d"; cp -R "$T" "$d"; echo "$d"; }
copy_c() { local d="$WORK/$1"; rm -rf "$d"; cp -R "$C" "$d"; echo "$d"; }

# Two stub fixture directories: one whose three sets pass, one whose middle set fails.
PASSDIR="$WORK/fixtures-pass"; FAILDIR="$WORK/fixtures-fail"
mkdir -p "$PASSDIR" "$FAILDIR"
for v in verify-retrieval-budget verify-summary-cache verify-command-dedup; do
  printf '#!/bin/sh\nexit 0\n' > "$PASSDIR/$v.sh"; chmod +x "$PASSDIR/$v.sh"
  printf '#!/bin/sh\nexit 0\n' > "$FAILDIR/$v.sh"; chmod +x "$FAILDIR/$v.sh"
done
printf '#!/bin/sh\necho "a case failed" >&2\nexit 1\n' > "$FAILDIR/verify-summary-cache.sh"
chmod +x "$FAILDIR/verify-summary-cache.sh"
G=(env B11_GUARDS_ONLY=1 B11_FIXTURE_DIR="$PASSDIR")

echo "verify-b11-preflight-guards: $EXPECTED_CASES cases against $DRIVER"

# A — the happy path. Without it every case below is satisfied by a script that refuses everything.
expect 0 "A the registered overlays pass every guard" -- "${G[@]}" "$DRIVER"

# B — the arms' agent files differ: more than one variable moves.
d="$(copy_c B)"; printf '\nedited\n' >> "$d/.claude/agents/backend-feature-phases.md"
expect 6 "B the arms' agent files differ" -- "${G[@]}" B11_OVERLAY_C="$d" "$DRIVER"

# C — the agent file is identical in both arms but is not the REGISTERED one. B cannot catch this:
#     an equal-but-wrong pair passes B and changes what the comparison is about.
dt="$(copy_t C1)"; dc="$(copy_c C2)"
printf '\nedited in both\n' >> "$dt/.claude/agents/backend-feature-phases.md"
printf '\nedited in both\n' >> "$dc/.claude/agents/backend-feature-phases.md"
expect 6 "C both arms carry the same UNREGISTERED agent file" -- \
  "${G[@]}" B11_OVERLAY_T="$dt" B11_OVERLAY_C="$dc" "$DRIVER"

# D — one of v1.1's four carried-over hook/policy files was edited in the treated arm. v1.2 is
#     v1.1 PLUS five mechanisms; a changed repair-limit.sh would be a second moving variable.
d="$(copy_t D)"; printf '\n# edited\n' >> "$d/.ai/hooks/repair-limit.sh"
expect 6 "D a carried-over v1.1 hook was edited in the treated arm" -- "${G[@]}" B11_OVERLAY_T="$d" "$DRIVER"

# E — the treated CLAUDE.md is not the registered one.
d="$(copy_t E)"; printf '\nextra clause\n' >> "$d/CLAUDE.md"
expect 6 "E the treated CLAUDE.md is not the registered sha" -- "${G[@]}" B11_OVERLAY_T="$d" "$DRIVER"

# F — the control CLAUDE.md is not v1.1's.
d="$(copy_c F)"; printf '\nextra clause\n' >> "$d/CLAUDE.md"
expect 6 "F the control CLAUDE.md is not v1.1's sha" -- "${G[@]}" B11_OVERLAY_C="$d" "$DRIVER"

# G — THE TREATMENT IN BOTH ARMS. The failure that produces a confident null: a control carrying
#     one of the treatment's hook files is a second treated arm with a control's label.
d="$(copy_c G)"; mkdir -p "$d/.ai/hooks"; cp "$T/.ai/hooks/command-dedup.sh" "$d/.ai/hooks/"
expect 6 "G the CONTROL carries one of the new hook files" -- "${G[@]}" B11_OVERLAY_C="$d" "$DRIVER"

# H — the control's settings.json REGISTERS a new hook. G cannot catch this: the file can be
#     absent while the wiring names it, and a wiring that names a missing hook is still a
#     difference between the arms.
d="$(copy_c H)"; python3 - "$d" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1]) / ".claude/settings.json"
j = json.loads(p.read_text())
j["hooks"]["PreToolUse"][0]["hooks"].append(
    {"type": "command", "command": "$CLAUDE_PROJECT_DIR/.ai/hooks/command-dedup.sh", "timeout": 15})
p.write_text(json.dumps(j, indent=2) + "\n")
PY
expect 6 "H the CONTROL's settings.json registers a new hook" -- "${G[@]}" B11_OVERLAY_C="$d" "$DRIVER"

# I — a new hook file is present on the treated arm but NOT wired in settings.json. This is the
#     case that catches DEAD WEIGHT: the file ships, no event reaches it, its log is empty on every
#     run, and the batch reports the decision rule's VOID row for a mechanism that was never
#     delivered. That would read as "the treatment did nothing" rather than "the treatment was not
#     installed", which are different findings.
d="$(copy_t I)"; python3 - "$d" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1]) / ".claude/settings.json"
j = json.loads(p.read_text())
for ev in j["hooks"].values():
    for m in ev:
        m["hooks"] = [h for h in m["hooks"] if "command-dedup.sh" not in h["command"]]
p.write_text(json.dumps(j, indent=2) + "\n")
PY
expect 6 "I a new hook FILE is present but not WIRED on the treated arm" -- "${G[@]}" B11_OVERLAY_T="$d" "$DRIVER"

# J — a new file is missing from the treated overlay altogether.
d="$(copy_t J)"; rm -f "$d/.ai/policies/retrieval-budget.yaml"
expect 6 "J the treated overlay is missing a registered new file" -- "${G[@]}" B11_OVERLAY_T="$d" "$DRIVER"

# K — THE FIXTURE GATE REFUSES. Proved with a stub that exits 1, because the only other way to
#     prove it is to break a registered hook. Case A is its other direction: the same gate with
#     three passing stubs lets the guards through.
expect 6 "K the fixture gate refuses when a hook fixture set fails" -- \
  env B11_GUARDS_ONLY=1 B11_FIXTURE_DIR="$FAILDIR" "$DRIVER"

# L — a dead API. Runs with the guards passing and no guards-only exit, so it proves the endpoint
#     check refuses BEFORE the lock is taken and before any run is launched.
expect 7 "L a dead API refuses the preflight" -- env B11_FIXTURE_DIR="$PASSDIR" B11_API="http://127.0.0.1:1" "$DRIVER"

# M — a dead OTLP endpoint. A run that reaches the wrong collector records null cost, which looks
#     exactly like a run that made no model calls.
expect 7 "M a dead OTLP endpoint refuses the preflight" -- env B11_FIXTURE_DIR="$PASSDIR" B11_OTLP="http://127.0.0.1:1" "$DRIVER"

# N — the pid lock. A second preflight or batch must refuse; a duplicate benchmark run is evidence
#     that cannot be deleted. The lock holds THIS shell's pid, so `kill -0` succeeds.
printf '%s\n' "$$" > "$WORK/held.lock"
expect 8 "N a held pid lock refuses a second preflight" -- env B11_FIXTURE_DIR="$PASSDIR" B11_LOCK="$WORK/held.lock" "$DRIVER"

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-b11-preflight-guards: ${ran} cases ran, ${EXPECTED_CASES} registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  exit 1
fi
echo "verify-b11-preflight-guards: ${pass} passed, ${fail} failed, ${ran} of ${EXPECTED_CASES} cases ran."
[[ "$fail" -eq 0 ]] || exit 1
