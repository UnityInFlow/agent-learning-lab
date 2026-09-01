#!/usr/bin/env bash
# Send this branch's changed measurement contracts to the independent critic when the work
# leaves the machine — on `git push` and `gh pr create`.
#
# WHY A HOOK AND NOT A HABIT. The critic has already caught, in one session, a "guaranteed
# null" that nothing enforced and an artifact asserting a property a reader had to go and
# verify. Both were written by someone who had just built a control against that exact
# mistake. A review you have to remember to run is Layer 3. This is the Layer 2 version, and
# push is the right trigger because it is the moment the artifact stops being yours alone.
#
# CONTRACT WITH CLAUDE CODE. The tool call arrives as JSON on stdin:
#   {"tool_name":"Bash","tool_input":{"command":"git push …"},"tool_response":{…}}
# Command filtering lives in settings.json as `"if": "Bash(git push:*)"`, so this script is
# not spawned at all for anything else. It re-checks anyway, because it is also run directly
# by its test and by anyone debugging it.
#
# THIS SCRIPT NEVER FAILS A TOOL CALL. It exits 0 on every path — missing opencode, a broken
# reviewer, malformed stdin, no git. A reviewer that can break `git push` would be removed
# within a day, and then nothing would be reviewed at all.
#
#   echo '{"tool_name":"Bash","tool_input":{"command":"git push"}}' | .claude/hooks/opencode-review.sh
#
# TWO HARNESSES, NOT TWO RUNS. The hook used to send `-n 2` — the same model twice, which
# measures that model's detection threshold and nothing about the artifact. It now sends a
# PANEL: one opencode family plus `codex`, which is a different agent loop with a different
# system prompt and a schema-constrained output, not just a different model id.
#
# The evidence for the change, 2026-08-28 on the BE-003 rubric: glm-5.2 found gaps in the
# anchor ladder and an anchor citing a file that is not attached; deepseek-v4-pro found four
# textual ambiguities in the same file. Neither saw the other's list. One model run twice
# would have produced neither list twice.
#
# Env: LAB_REVIEW_HOOK=0 disables it. LAB_REVIEW_PANEL overrides the panel.
# LAB_REVIEW_RUNS is runs PER FAMILY (default 1 — the panel is the diversity now).

set -uo pipefail

# The measurement contracts, and only those. A phase README changing does not need an
# adversarial reviewer; a rubric or an experiment record leaving the machine does.
# TWO TIERS, AND THE ORDER IS THE BUDGET'S PRIORITY. Contracts are the registered
# measurement artifacts; tools are the things that execute against them. Until 2026-08-28
# only the first tier existed, so nine changed tools on one branch — including a gate
# deciding whether a submission may be scored at all — were never in the critic's scope. The
# gap was not theoretical: reviewed by hand that day, the panel found a BLOCKING defect in
# `check-sheet-categories.sh`, a control that had shipped with ShellCheck clean, 9 passing
# fixtures and a green CI job. None of those can catch "this gate admits something it should
# not"; only a reader can.
CONTRACT_GLOBS=(
  'benchmark/rubrics/*.yaml'
  'templates/*.yaml'
  'experiments/*.md'
)
TOOL_GLOBS=(
  'tools/*.sh'
  '.claude/hooks/*.sh'
)
# EVERY ARTIFACT GOES INTO ONE PROMPT PER FAMILY — `opencode-review.sh` attaches them all to
# a single call — so the cost of a wide push is not more calls, it is one huge prompt read by
# a critic that already under-reports. A bound is therefore about attention, not wall clock.
# 4 is a judgement, not a measurement: two artifacts took codex 39s and deepseek 188s, and
# the hook's whole budget is 900s for two families plus the gate. Revise it with numbers.
MAX_ARTIFACTS="${LAB_REVIEW_MAX_ARTIFACTS:-4}"

[ "${LAB_REVIEW_HOOK:-1}" = "0" ] && exit 0

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)" || exit 0
cd "$repo_root" || exit 0

payload="$(cat 2>/dev/null || true)"
command_line="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -n "$command_line" ] || exit 0

case "$command_line" in
  *"git push"*|*"gh pr create"*) ;;
  *) exit 0 ;;
esac

command -v opencode >/dev/null 2>&1 || {
  echo "opencode-review hook: opencode not installed, skipping" >&2; exit 0
}
[ -x tools/opencode-review.sh ] || exit 0

# Compare against the trunk, not against HEAD~1: a push carries every commit on the branch,
# and the artifact worth reviewing may have changed three commits ago.
base="$(git merge-base HEAD origin/main 2>/dev/null || true)"
[ -n "$base" ] || exit 0
changed="$(git diff --name-only "$base"...HEAD 2>/dev/null || true)"
[ -n "$changed" ] || exit 0

# Contracts first, tools second, so a push that exceeds the budget drops tools rather than
# the rubric the experiment is registered against.
# Globs come in positionally rather than through a nameref: `local -n` needs bash 4.3, and
# it also hides the arrays from ShellCheck, which then reports them unused. Passing them as
# arguments keeps the required check honest instead of silenced.
select_matching() {
  local globs=("$@") f glob
  while IFS= read -r f; do
    [ -f "$f" ] || continue          # deleted files have nothing to review
    for glob in "${globs[@]}"; do
      # shellcheck disable=SC2053
      if [[ "$f" == $glob ]]; then printf '%s\n' "$f"; break; fi
    done
  done <<< "$changed"
}

ranked=()
while IFS= read -r f; do [ -n "$f" ] && ranked+=("$f"); done < <(select_matching "${CONTRACT_GLOBS[@]}")
while IFS= read -r f; do [ -n "$f" ] && ranked+=("$f"); done < <(select_matching "${TOOL_GLOBS[@]}")

[ ${#ranked[@]} -gt 0 ] || exit 0

artifacts=("${ranked[@]}")
dropped=()
if [ "$MAX_ARTIFACTS" -gt 0 ] && [ ${#ranked[@]} -gt "$MAX_ARTIFACTS" ]; then
  artifacts=("${ranked[@]:0:$MAX_ARTIFACTS}")
  dropped=("${ranked[@]:$MAX_ARTIFACTS}")
fi

# NO SILENT CAP. A review that covered four of eleven artifacts and said nothing reads
# exactly like one that covered everything — which is the failure this whole project keeps
# re-finding. Every dropped file is named, by name, on the way past.
if [ ${#dropped[@]} -gt 0 ]; then
  echo "opencode-review hook: PARTIAL REVIEW — ${#artifacts[@]} of ${#ranked[@]} artifacts." >&2
  echo "  NOT reviewed (raise LAB_REVIEW_MAX_ARTIFACTS or review them by hand):" >&2
  for f in "${dropped[@]}"; do echo "    $f" >&2; done
fi

runs="${LAB_REVIEW_RUNS:-1}"
panel="${LAB_REVIEW_PANEL:-deepseek-v4-pro,codex}"

# A missing codex must DEGRADE the panel, never fail the push. Dropping it silently would be
# worse than the miss it prevents, so the drop is announced: a review that quietly stopped
# being a two-harness review is exactly the kind of thing this hook exists to catch.
if ! command -v codex >/dev/null 2>&1 || [ ! -x tools/codex-critic.sh ]; then
  case ",$panel," in
    *,codex,*|*,codex/*)
      panel="$(printf '%s' "$panel" | tr ',' '\n' | grep -v '^codex' | paste -sd, -)"
      echo "opencode-review hook: codex unavailable — panel reduced to '${panel}'." >&2
      echo "  This is a ONE-harness review now. It is not the review the panel names." >&2 ;;
  esac
fi
[ -n "$panel" ] || { echo "opencode-review hook: empty panel, skipping" >&2; exit 0; }

echo "opencode-review hook: reviewing ${#artifacts[@]} of ${#ranked[@]} changed artifact(s) — panel ${panel}, -n ${runs}" >&2
./tools/opencode-review.sh -n "$runs" -P "$panel" "${artifacts[@]}" >&2 || {
  echo "opencode-review hook: reviewer failed; the push already happened and is unaffected" >&2
}
exit 0
