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
{ rec RUN-A; rec RUN-A plugin custom_skill claude-proactive; } > "$TMP/plugin-only.jsonl"
printf 'not json at all\n{"broken":\n' > "$TMP/garbage.jsonl"
: > "$TMP/empty.jsonl"

# --- damage, which is neither presence nor absence --------------------------
# Round 3 of the §4a gate: a run whose stream is PARTLY unreadable reported `measured` with
# a clean-looking zero, indistinguishable from a genuinely clean zero. The dropped line is
# exactly where a refuting activation would have been, so the error runs one way.
{ rec RUN-A; printf '{"resourceLogs": TRUNCATED\n'; } > "$TMP/present-plus-badline.jsonl"
# a record carrying RUN-A whose attribute list is structurally broken
{ rec RUN-A; printf '{"resourceLogs":[{"resource":{"attributes":[]},"scopeLogs":[{"logRecords":[{"body":{"stringValue":"claude_code.skill_activated"},"attributes":[{"key":"observatory.run.id"}]}]}]}]}\n'; } > "$TMP/present-plus-badrecord.jsonl"
# damage must not resurrect an ABSENT run into a measured one
{ rec RUN-B; printf 'not json\n'; } > "$TMP/absent-plus-badline.jsonl"

echo "verify-skill-activation: 21 cases"

check "a project-source activation is reported by source"            0 "bundled_activations: 0" one-project.jsonl RUN-A
check "a run present with no skill event is a REAL zero"  0 "activations_by_source: -" present-no-skill.jsonl RUN-A
check "  and that zero is labelled measured"              0 "status: measured"             present-no-skill.jsonl RUN-A

# THE CASE THIS FILE EXISTS FOR.
check "a run ABSENT from telemetry is NOT reported as 0"  3 "status: UNKNOWN"              other-run-only.jsonl RUN-A
check "  and its counts are null, never 0"                3 "other_source_activations: null" other-run-only.jsonl RUN-A

check "a bundled skill is reported as bundled, not ours"  0 "activations_by_source: bundled=1" bundled-only.jsonl RUN-A
check "  but is still reported separately"                0 "bundled_activations: 1"       bundled-only.jsonl RUN-A
check "mixed run counts each scope separately"            0 "activations_by_source: bundled=1,project=1" mixed.jsonl RUN-A
check "two project activations both counted"              0 "activations_by_source: project=2" two-project.jsonl RUN-A
# A source-less event must NOT be counted as the installed skill. Counting it would invent
# evidence for the treatment arm out of a missing attribute.
check "an event with NO skill.source is bucketed as None" 0 "activations_by_source: None=1" no-source.jsonl RUN-A
check "  and it is surfaced, not silently dropped"        0 "unknown_source_activations: 1" no-source.jsonl RUN-A

# A PLUGIN skill is not the installed one either. This is the case the first two fixture sets
# missed: plugin is the only non-bundled source ever observed on this instrument, so counting it
# as the installed skill would record an activation on the CONTROL arm, which installs nothing.
check "a plugin skill is reported as plugin, not as ours" 0 "other_source_activations: 0"   plugin-only.jsonl RUN-A
check "  and is reported on its own line"                 0 "plugin_activations: 1"          plugin-only.jsonl RUN-A

check "an unparseable telemetry file is rejected"         2 "no parseable JSON"            garbage.jsonl RUN-A

# an empty file parses to nothing -> also exit 2, not a silent zero
check "an empty telemetry file is rejected, not zeroed"   2 "no parseable JSON"            empty.jsonl RUN-A

# THE CASES ROUND 3 OF THE §4a GATE ASKED FOR. A count from a damaged stream is a lower
# bound; reporting it as `measured` is the same error as reporting an absent run as zero,
# one step further in.
check "a present run with an unparseable line is PARTIAL"  4 "status: PARTIAL-telemetry-damaged" present-plus-badline.jsonl RUN-A
check "  and the damage is counted, not just flagged"      4 "malformed_lines: 1"            present-plus-badline.jsonl RUN-A
check "an unreadable RECORD is damage too"                 4 "damaged_records: 1"            present-plus-badrecord.jsonl RUN-A
check "  and it does not abort the whole read"             4 "status: PARTIAL"               present-plus-badrecord.jsonl RUN-A
# Absence outranks damage: a run that is not there has still not been measured, and saying
# "lower bound" about it would imply a bound exists.
check "damage does NOT promote an absent run to present"   3 "status: UNKNOWN"               absent-plus-badline.jsonl RUN-A
# And the case that must NOT be damage, or every source-less activation would be reclassified
# out of the bucket built for it.
check "a source-less activation is NOT damage"             0 "damaged_records: 0"            no-source.jsonl RUN-A

echo
echo "verify-skill-activation: ${pass} passed, ${fail} failed"
[[ "$fail" -eq 0 ]]
