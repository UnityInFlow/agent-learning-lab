#!/usr/bin/env bash
# verify-skill-activation.sh — prove skill-activation.sh still refuses what it must refuse.
#
# The check that matters is case 3: a run absent from telemetry must NOT be reported as zero
# activations. A counter that cannot tell "no skill loaded" from "no telemetry arrived" would
# score the control arm correct for the wrong reason, and would do it silently.
#
# Every case asserts BOTH the exit code and a line of stdout, because a script can exit 0 and
# print nothing useful, and this fixture set is the only thing that executes.

set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

TOOL=./tools/skill-activation.sh
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0

# one log record for run $1 with optional skill event ($2=source, $3=name, $4=trigger)
rec() {
  local rid="$1" src="${2:-}" name="${3:-}" trig="${4:-}"
  if [[ -z "$src" ]]; then
    printf '{"resourceLogs":[{"resource":{"attributes":[]},"scopeLogs":[{"logRecords":[{"body":{"stringValue":"claude_code.api_request"},"attributes":[{"key":"observatory.run.id","value":{"stringValue":"%s"}}]}]}]}]}\n' "$rid"
  else
    printf '{"resourceLogs":[{"resource":{"attributes":[]},"scopeLogs":[{"logRecords":[{"body":{"stringValue":"claude_code.skill_activated"},"attributes":[{"key":"observatory.run.id","value":{"stringValue":"%s"}},{"key":"skill.source","value":{"stringValue":"%s"}},{"key":"skill.name","value":{"stringValue":"%s"}},{"key":"invocation_trigger","value":{"stringValue":"%s"}}]}]}]}]}\n' "$rid" "$src" "$name" "$trig"
  fi
}

check() { # check <label> <expected-exit> <expected-substring> <file> <run-id>
  local label="$1" want="$2" grepfor="$3" file="$4" rid="$5"
  local out rc
  set +e
  out="$($TOOL "$TMP/$file" "$rid" 2>&1)"; rc=$?
  set -e
  if [[ "$rc" == "$want" ]] && grep -q -- "$grepfor" <<<"$out"; then
    pass=$((pass+1)); printf '  ok    %-58s exit %s\n' "$label" "$rc"
  else
    fail=$((fail+1)); printf '  FAIL  %-58s exit %s (want %s), missing %q\n' "$label" "$rc" "$want" "$grepfor"
    printf '%s\n' "$out" | sed 's/^/          /'
  fi
}

# --- fixtures ---------------------------------------------------------------
{ rec RUN-A; rec RUN-A project shipment-service-conventions claude-proactive; } > "$TMP/one-project.jsonl"
{ rec RUN-A; } > "$TMP/present-no-skill.jsonl"
{ rec RUN-B; } > "$TMP/other-run-only.jsonl"
{ rec RUN-A; rec RUN-A bundled run claude-proactive; } > "$TMP/bundled-only.jsonl"
{ rec RUN-A; rec RUN-A bundled run claude-proactive; rec RUN-A project sc claude-proactive; } > "$TMP/mixed.jsonl"
{ rec RUN-A project custom_skill claude-proactive; rec RUN-A project custom_skill nested-skill; } > "$TMP/two-project.jsonl"
{ rec RUN-A; printf '{"resourceLogs":[{"resource":{"attributes":[]},"scopeLogs":[{"logRecords":[{"body":{"stringValue":"claude_code.skill_activated"},"attributes":[{"key":"observatory.run.id","value":{"stringValue":"RUN-A"}},{"key":"skill.name","value":{"stringValue":"mystery"}}]}]}]}]}\n'; } > "$TMP/no-source.jsonl"
printf 'not json at all\n{"broken":\n' > "$TMP/garbage.jsonl"
: > "$TMP/empty.jsonl"

echo "verify-skill-activation: 13 cases"

check "a project skill that loaded is counted"            0 "project_scope_activations: 1" one-project.jsonl RUN-A
check "a run present with no skill event is a REAL zero"  0 "project_scope_activations: 0" present-no-skill.jsonl RUN-A
check "  and that zero is labelled measured"              0 "status: measured"             present-no-skill.jsonl RUN-A

# THE CASE THIS FILE EXISTS FOR.
check "a run ABSENT from telemetry is NOT reported as 0"  3 "status: UNKNOWN"              other-run-only.jsonl RUN-A
check "  and its count is null, never 0"                  3 "project_scope_activations: null" other-run-only.jsonl RUN-A

check "a bundled skill is NOT project scope"              0 "project_scope_activations: 0" bundled-only.jsonl RUN-A
check "  but is still reported separately"                0 "bundled_activations: 1"       bundled-only.jsonl RUN-A
check "mixed run counts each scope once"                  0 "project_scope_activations: 1" mixed.jsonl RUN-A
check "two project activations both counted"              0 "project_scope_activations: 2" two-project.jsonl RUN-A
# A source-less event must NOT be counted as the installed skill. Counting it would invent
# evidence for the treatment arm out of a missing attribute.
check "an event with NO skill.source is not project scope" 0 "project_scope_activations: 0" no-source.jsonl RUN-A
check "  and it is surfaced, not silently dropped"        0 "unknown_source_activations: 1" no-source.jsonl RUN-A

check "an unparseable telemetry file is rejected"         2 "no parseable JSON"            garbage.jsonl RUN-A

# an empty file parses to nothing -> also exit 2, not a silent zero
check "an empty telemetry file is rejected, not zeroed"   2 "no parseable JSON"            empty.jsonl RUN-A

echo
echo "verify-skill-activation: ${pass} passed, ${fail} failed"
[[ "$fail" -eq 0 ]]
