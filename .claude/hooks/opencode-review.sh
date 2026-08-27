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
# Env: LAB_REVIEW_HOOK=0 disables it. LAB_REVIEW_RUNS overrides -n (default 2, because a
# single run at temperature 0 is a lower bound — two runs disagreed on 2 of 12 sections).

set -uo pipefail

# The measurement contracts, and only those. A phase README changing does not need an
# adversarial reviewer; a rubric or an experiment record leaving the machine does.
REVIEWABLE_GLOBS=(
  'benchmark/rubrics/*.yaml'
  'templates/*.yaml'
  'experiments/*.md'
)

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

artifacts=()
while IFS= read -r f; do
  [ -f "$f" ] || continue          # deleted files have nothing to review
  for glob in "${REVIEWABLE_GLOBS[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$f" == $glob ]]; then artifacts+=("$f"); break; fi
  done
done <<< "$changed"

[ ${#artifacts[@]} -gt 0 ] || exit 0

runs="${LAB_REVIEW_RUNS:-2}"
echo "opencode-review hook: reviewing ${#artifacts[@]} changed contract(s) with -n ${runs}" >&2
./tools/opencode-review.sh -n "$runs" "${artifacts[@]}" >&2 || {
  echo "opencode-review hook: reviewer failed; the push already happened and is unaffected" >&2
}
exit 0
