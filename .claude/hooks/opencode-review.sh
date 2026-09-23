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
# by its test and by anyone debugging it. NOTE that the settings.json matcher is a SECOND
# door with its own reach: this script recognises `git -C … push` and the other global-option
# forms (see the trigger below), but whether Claude Code spawns it for them is that matcher's
# question, not this file's, and it is not settled here.
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
# WHAT IT CANNOT REVIEW, IT NAMES. Things that reach stderr instead of the critic: artifacts
# past the budget (PARTIAL REVIEW), artifacts DELETED on this branch (REMOVED), the
# environment failures that used to pass in silence — no `jq`, no merge base with
# `origin/main`, no executable `tools/opencode-review.sh`, a payload that is not JSON at all,
# a `git diff` that failed after the merge base resolved, stdin that could not be read, and a
# repository root this hook could not reach (all NOT REVIEWED). The full list, with each
# site's classification, is THE SWEEP below. Each is printed by name. Nothing in scope leaves
# the machine unmentioned. The reviewer's own exit code is reported by category too, because
# a gate that returned REJECT and a reviewer that never started are not the same event.
#
# THE ONE RULE, because the two promises above disagree exactly where a path is quiet, and a
# list of today's three exceptions is no use on the fourth:
#
#   The hook exits 0 on every path, and exits SILENTLY only where it has ESTABLISHED that no
#   review was owed — the command was not a push, nothing in scope changed. Wherever it merely
#   FAILED TO FIND OUT, it prints one line naming what went unreviewed and why, and still
#   exits 0.
#
# Failing to find out is not the same as finding nothing, and only the second may be silent.
# That is the whole test for a path neither the author nor the critic has thought of yet: ask
# which of the two the path is. A missing `jq` does not mean the command was not a push; it
# means the hook could not read it. That is a decline, and a decline is announced.
#
# THE SWEEP, 2026-09-23, round 3. Two review rounds each fixed the doors they were pointed at
# — three of them, then one more — and a third round found a fourth. Fixing the named door is
# how a corridor stays open, so this is the LIST instead: every place in this file where a
# command's status is discarded or the script leaves early, classified under the one rule
# above, with the reason in a clause. A later reader checks the code against this list rather
# than re-deriving it, and `opencode-review.test.sh` holds the list to the code — every
# `exit 0` below is either preceded by its own notice on stderr or carries a `# SILENT:`
# clause, and the suite fails on one that is neither, and on a `|| true` anywhere in the
# executable part of this file.
#
#   SILENT — the hook ESTABLISHED that no review was owed:
#     LAB_REVIEW_HOOK=0 ................. the operator turned it off; that IS the answer.
#     no command in the payload ......... the call was read; there is no command in it.
#     the command is not a push ......... read, matched against the trigger, and it is not one.
#     the diff listed nothing ........... the diff RAN and this branch changed nothing.
#     nothing matched a glob ............ the changed list was read; no artifact is in scope.
#     every matched artifact deleted .... already announced by name as REMOVED, two lines up.
#     the reviewer exited 0 ............. the review ran; it named its own findings file.
#
#   ANNOUNCED — the hook merely FAILED TO FIND OUT:
#     repo root unreachable ............. cannot locate the tree it would have examined.
#     stdin unreadable (`cat` failed) ... the call was never read — not the same as empty.
#     the payload is not JSON ........... whether this was a push could not be established.
#     `jq` missing, or `jq` non-zero .... the only parser here; no parser, no answer.
#     `opencode` missing ................ nothing on this branch reaches the critic.
#     tools/opencode-review.sh missing .. every artifact on the branch goes unreviewed.
#     no merge base with origin/main .... the changed set is unknown, not empty.
#     `git diff --name-only` failed ..... the same unknown. This is round 3's finding.
#     the panel is empty ................ no harness to send the artifacts to.
#     `codex` gone from a panel naming it the review quietly stopped being a two-harness one.
#     the reviewer exited 1 / 3 / 4 / ?.. a REJECT and a reviewer that never started differ.
#
#   NEITHER, and left alone on purpose — these decline nothing, so the rule does not reach:
#     a non-numeric LAB_REVIEW_MAX_ARTIFACTS makes `[ … -gt 0 ]` exit 2; bash prints its own
#       message on stderr, the cap is not applied, and EVERY artifact is reviewed. It errs
#       toward more review and it is not silent. Listed because omitting it would look like
#       it had not been looked at.
#     `dirname` missing resolves the root to `/`; the run then trips the
#       tools/opencode-review.sh door and announces there. A wrong root, not a silent one.
#     `select_matching` runs no external command and cannot fail, so the two reads of its
#       output are not discarded statuses.
#
# ONE SITE IS ARGUABLE AND IS NOT BEING GUESSED AT QUIETLY. A payload whose `tool_input` is
# the wrong SHAPE (`{"tool_input":"a string"}`) is read with `?` and yields an absent command,
# which this file classifies as ESTABLISHED and keeps SILENT. The other reading is that the
# hook failed to find a command in a call it could not interpret. It stays silent because the
# JSON was parsed whole and genuinely contains no command — but a reader who disagrees is
# disagreeing with a judgement, not finding an oversight, and should say so rather than
# assume nobody looked.
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
  # One level deep ON PURPOSE. The lab's Python tools live directly in tools/, while the eight
  # tools/fixtures/spine-status/mutants/*.py are deliberately-broken renderers — fixtures a
  # verifier must kill, not tools a critic should read. Drawing them in would spend the whole
  # MAX_ARTIFACTS budget reviewing code whose defects are the point. `select_matching` is what
  # makes this depth real; see the slash-count guard there.
  'tools/*.py'
  '.claude/hooks/*.sh'
)
# EVERY ARTIFACT GOES INTO ONE PROMPT PER FAMILY — `opencode-review.sh` attaches them all to
# a single call — so the cost of a wide push is not more calls, it is one huge prompt read by
# a critic that already under-reports. A bound is therefore about attention, not wall clock.
# 4 is a judgement, not a measurement: two artifacts took codex 39s and deepseek 188s, and
# the hook's whole budget is 900s for two families plus the gate. Revise it with numbers.
MAX_ARTIFACTS="${LAB_REVIEW_MAX_ARTIFACTS:-4}"

[ "${LAB_REVIEW_HOOK:-1}" = "0" ] && exit 0  # SILENT: turned off on purpose — no review is owed.

# ONE DOOR, NOT TWO. Resolving the root and entering it were separate silent `|| exit 0`
# lines. Neither had ESTABLISHED anything: a hook that cannot find its own repository has not
# found that nothing changed, it has failed to look. They are announced as one line because
# to a reader they are one event — this hook does not know where it is.
#
# THE TEST SUITE CANNOT CONSTRUCT THIS DOOR, and the reason is a proof rather than an
# omission: `<hook dir>/../..` is a textual PREFIX of the hook's own path, so the kernel
# already traversed it to open this file. It can only fail if the root is deleted or made
# untraversable between that open and this line — a race, not a state a fixture can set up.
# So the suite holds this door STRUCTURALLY (every exit is announced or marked `# SILENT:`)
# rather than behaviourally, and reverting the notice below still fails that case. Said here
# because an untested announcement that nobody admits is untested is the house failure mode.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
if [ -z "$repo_root" ] || ! cd "$repo_root" 2>/dev/null; then
  echo "opencode-review hook: NOT REVIEWED — this hook could not reach its own repository root from ${BASH_SOURCE[0]}, so nothing on this branch could be examined." >&2
  exit 0
fi

# STDIN IS READ, NOT ASSUMED. `cat … || true` discarded the read's status, and an unreadable
# stdin then produced exactly what an empty one does: an empty payload, valid JSON by vacuity,
# no command, silent exit 0. An empty stdin is a FOUND NOTHING — zero JSON values, no command,
# nothing owed. A read that FAILED is a FAILED TO FIND OUT, and only the first may be silent.
cat_status=0
payload="$(cat 2>/dev/null)" || cat_status=$?
[ "$cat_status" -eq 0 ] || {
  echo "opencode-review hook: NOT REVIEWED — the tool call could not be read from stdin (cat exited ${cat_status}), so whether this was a push could not be established." >&2
  exit 0
}

# `jq` is gated like `opencode` and `codex` are, and for the same reason. It is the only
# parser here, so without it the read below fails, `command_line` is empty, and the hook
# exits 0 having said nothing — indistinguishable from "that was not a push". It is not the
# same event: a missing `jq` means the hook never read anything. Announce, per the one rule.
command -v jq >/dev/null 2>&1 || {
  echo "opencode-review hook: NOT REVIEWED — jq is not installed, so the tool call cannot be read; no push on this machine reaches the critic until it is." >&2
  exit 0
}

# TWO QUESTIONS, NOT ONE, and until 2026-09-23 they collapsed into a single empty string.
# `jq -r '.tool_input.command // empty' … || true` exits non-zero on a payload that is not
# JSON, `|| true` swallows that, and the empty result then fell through the silent exit below
# — so "the hook could not tell whether this was a push" left exactly the trace that "the hook
# read the call and there was no command in it" leaves. That is the one rule's own
# distinction, broken in the place it is least visible from outside: a truncated payload on a
# real push exits 0 in silence and the developer records a review that never ran.
#
# So the payload is validated as JSON FIRST, on its own. `jq empty` prints nothing and exits
# 0 for any valid input, including no input at all (an empty stdin is zero JSON values, not a
# parse failure), and exits non-zero only when the bytes are not JSON. That is the decline.
printf '%s' "$payload" | jq empty >/dev/null 2>&1 || {
  echo "opencode-review hook: NOT REVIEWED — the tool call on stdin is not valid JSON, so whether this was a push could not be established; if it was, nothing on this branch reached the critic." >&2
  exit 0
}
# ...and only then read, with `?` on both steps so a wrong SHAPE — `"tool_input":"a string"`,
# which `.tool_input.command` errors on — is an ABSENT command rather than a parse failure.
# That one stays silent, and should: the hook did read the call, and there is no command in
# it. A non-zero status here is a jq that could not answer, so it is announced like the rest;
# `|| true` is deliberately gone, because swallowing the status is what caused this defect.
jq_status=0
command_line="$(printf '%s' "$payload" | jq -r '.tool_input?.command? // empty' 2>/dev/null)" || jq_status=$?
[ "$jq_status" -eq 0 ] || {
  echo "opencode-review hook: NOT REVIEWED — jq exited ${jq_status} reading the tool call, so whether this was a push could not be established." >&2
  exit 0
}
[ -n "$command_line" ] || exit 0  # SILENT: the call was READ and holds no command.

# Match the command NAME, not the substring. A plain `*"git push"*` also fired on
# `git pushdown origin`, which is a different command entirely — the review cost was wasted
# rather than missed, but a trigger that cannot say what it triggers on is not a trigger.
# The boundaries are deliberately loose on the right: `git push;`, `git push && …` and
# `… && git push` must all still match, because a compound command is how this is usually
# invoked. Erring toward reviewing is the safe direction; erring toward not reviewing is the
# failure this hook exists to prevent.
#
# GLOBAL OPTIONS SIT BETWEEN THE COMMAND AND ITS SUBCOMMAND, and until 2026-09-23 the trigger
# required `push` to follow `git` immediately — so `git -C <dir> push`, `git -c k=v push`,
# `git --no-pager push` and `git --git-dir=… push` all failed to match and the hook exited 0
# in silence. `git -C` is the standard form in submodule, monorepo and CI-script pushes, so
# this was not an edge: it was a whole class of real pushes recorded as reviewed because the
# suite was green and `git push` is the documented trigger. The hook had not ESTABLISHED that
# no review was owed; it had failed to recognise a push, and the one rule says those differ.
#
# `_opts` is that gap, and only that: a run of option-shaped tokens IMMEDIATELY after the
# command name — each starting with `-`, each optionally followed by its own value token
# (`-C <dir>`, `-c <k>=<v>`). Contiguity is what keeps it from swallowing subcommands:
# `git commit -m push` does NOT match, because `commit` is not option-shaped and the run
# cannot skip it. The known over-match is `git -C push` (a directory literally named `push`,
# with no subcommand at all), which reviews when it need not — the safe direction, as above.
_opts='([[:space:]]+-[^[:space:]]*([[:space:]]+[^-[:space:]][^[:space:]]*)?)*'
_trigger="(^|[^[:alnum:]_-])git${_opts}[[:space:]]+push([^[:alnum:]_-]|\$)"
_trigger_pr="(^|[^[:alnum:]_-])gh${_opts}[[:space:]]+pr[[:space:]]+create([^[:alnum:]_-]|\$)"
[[ "$command_line" =~ $_trigger || "$command_line" =~ $_trigger_pr ]] || exit 0  # SILENT: read, and it is not a push.

command -v opencode >/dev/null 2>&1 || {
  echo "opencode-review hook: NOT REVIEWED — opencode is not installed, so nothing on this branch reaches the critic." >&2
  exit 0
}
# The loudest of the three, and until 2026-09-23 the quietest: with no executable reviewer,
# EVERY review-scoped artifact on the branch goes unreviewed, and the push said so nowhere.
[ -x tools/opencode-review.sh ] || {
  echo "opencode-review hook: NOT REVIEWED — tools/opencode-review.sh is missing or not executable, so every review-scoped artifact on this branch goes unreviewed." >&2
  exit 0
}

# Compare against the trunk, not against HEAD~1: a push carries every commit on the branch,
# and the artifact worth reviewing may have changed three commits ago.
# An absent `origin/main` — a fork whose default branch is `master`, a remote not yet fetched,
# a renamed default branch — leaves `base` empty. The changed set is then unknown, not empty,
# and the difference is the one rule: the hook did not find nothing, it failed to find out.
base_status=0
base="$(git merge-base HEAD origin/main 2>/dev/null)" || base_status=$?
if [ "$base_status" -ne 0 ] || [ -z "$base" ]; then
  echo "opencode-review hook: NOT REVIEWED — git merge-base HEAD origin/main found nothing (a fork, an unfetched remote, or a renamed default branch), so this branch's changed files could not be listed and no artifact reached the critic." >&2
  exit 0
fi

# THE DOOR TWO LINES BELOW A DOOR, and the reason this file now carries a list instead of a
# growing set of patches. The merge base announced; the diff, in the same file and the same
# class, did not — `2>/dev/null || true` turned a failed diff into an empty string, and the
# emptiness check then exited 0 in silence, indistinguishable from a branch that changed
# nothing. Same file, same class, opposite policy, for no reason anyone had written down.
#
# The two outcomes are separated here because they are separate events: a diff that RAN and
# listed nothing has established that no review is owed, and stays silent; a diff that FAILED
# has established nothing at all, and is announced.
changed_status=0
changed="$(git diff --name-only "$base"...HEAD 2>/dev/null)" || changed_status=$?
[ "$changed_status" -eq 0 ] || {
  echo "opencode-review hook: NOT REVIEWED — git diff --name-only ${base}...HEAD exited ${changed_status}, so this branch's changed files could not be listed and no artifact reached the critic." >&2
  exit 0
}
[ -n "$changed" ] || exit 0  # SILENT: the diff RAN and this branch changed nothing.

# Contracts first, tools second, so a push that exceeds the budget drops tools rather than
# the rubric the experiment is registered against.
# Globs come in positionally rather than through a nameref: `local -n` needs bash 4.3, and
# it also hides the arrays from ShellCheck, which then reports them unused. Passing them as
# arguments keeps the required check honest instead of silenced.
# Existence is NOT tested here; see the removed/ranked split below. A path that matches a
# glob is in scope whether or not it still exists, because a deletion is a change to the
# artifact and the loudest one.
select_matching() {
  local globs=("$@") f glob
  while IFS= read -r f; do
    for glob in "${globs[@]}"; do
      # Every glob above names an exact DEPTH — one path segment after its directory prefix,
      # which is ONE slash for `tools/*.py` and TWO for `benchmark/rubrics/*.yaml`. bash does
      # not enforce that: inside [[ ]] a `*` crosses `/`, so `tools/*.py` also matches
      # tools/fixtures/spine-status/mutants/all-statuses.py, and `experiments/*.md` would match
      # anything nested under experiments/. Comparing SLASH COUNTS between a path and its own
      # glob makes each glob's declared depth actually hold, instead of being a comment a
      # reader believes. Note what this is NOT: a general matcher. A recursive glob
      # (`tools/**/*.py`) would match nothing here, because the guard is depth EQUALITY.
      [ "${f//[^\/]/}" = "${glob//[^\/]/}" ] || continue
      # shellcheck disable=SC2053
      if [[ "$f" == $glob ]]; then printf '%s\n' "$f"; break; fi
    done
  done <<< "$changed"
}

matched=()
while IFS= read -r f; do [ -n "$f" ] && matched+=("$f"); done < <(select_matching "${CONTRACT_GLOBS[@]}")
while IFS= read -r f; do [ -n "$f" ] && matched+=("$f"); done < <(select_matching "${TOOL_GLOBS[@]}")

[ ${#matched[@]} -gt 0 ] || exit 0  # SILENT: the changed list was read; nothing in it is in scope.

# NO SILENT DELETION. `git diff --name-only` lists removed paths, and until 2026-09-23 a
# `[ -f "$f" ] || continue` inside select_matching dropped them before they reached `ranked[]`
# — so they never entered `dropped[]` either, and the PARTIAL REVIEW notice below never fired
# for them. `git rm benchmark/rubrics/backend-quality.yaml && git push` therefore exited 0 in
# total silence over a removed measurement instrument. That is a control reporting success
# over a smaller scope than it claims, which is the exact failure this file's header names.
# A renamed contract is the same event: `git mv` shows the old path as a deletion, and the new
# path may match no glob at all, so without this the whole change disappears.
# A removed file still cannot be REVIEWED — there is nothing left to read, and handing the
# critic a path that does not resolve would be a fabricated review. So it is ANNOUNCED
# instead, and that difference is the entire point: told rather than not told.
ranked=(); removed=()
for f in "${matched[@]}"; do
  if [ -f "$f" ]; then ranked+=("$f"); else removed+=("$f"); fi
done

if [ ${#removed[@]} -gt 0 ]; then
  echo "opencode-review hook: REMOVED — ${#removed[@]} review-scoped artifact(s) deleted on this branch." >&2
  echo "  NOT reviewed (a deleted file has nothing left to read — check the removal by hand):" >&2
  for f in "${removed[@]}"; do echo "    $f" >&2; done
fi

[ ${#ranked[@]} -gt 0 ] || exit 0  # SILENT: every match was deleted and REMOVED named them above.

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
[ -n "$panel" ] || {
  echo "opencode-review hook: NOT REVIEWED — the panel is empty, so there is no harness to send ${#artifacts[@]} changed artifact(s) to." >&2
  exit 0
}

echo "opencode-review hook: reviewing ${#artifacts[@]} of ${#ranked[@]} changed artifact(s) — panel ${panel}, -n ${runs}" >&2
./tools/opencode-review.sh -n "$runs" -P "$panel" "${artifacts[@]}" >&2
review_status=$?

# THE REVIEWER'S EXIT CODE IS NOT A BOOLEAN. Until 2026-09-23 every non-zero status printed
# the one string "reviewer failed", which put a review that RAN and returned REJECT in the
# same sentence as a reviewer that never started — and `tools/classify-model-output.sh`
# exists in this repository precisely because "nothing was five different things wearing one
# word". Collapsing them here re-made that mistake one script further out.
#
# The codes are the reviewer's own, read off `tools/opencode-review.sh`, not the classifier's
# five: 1 is every could-not-produce-a-review path (bad usage, no panel, every family failed),
# 3 is `LAB_ACCEPT_STRICT=1` with an acceptance verdict of REJECT, 4 is the gate having run on
# opencode's default agent instead of `lab-acceptance`. Only the last two are reviews that
# happened, so only the first says NOT REVIEWED. An unrecognised code is reported as
# unrecognised rather than folded into one of these — a new code must not arrive disguised as
# a known one.
case $review_status in
  0) ;;   # the review ran; the reviewer has already named its findings file on stderr.
  3) echo "opencode-review hook: the review RAN and its acceptance gate returned REJECT (reviewer exit 3). This is a finding, not a failure — read the findings file named above. The push already happened and is unaffected." >&2 ;;
  4) echo "opencode-review hook: NOT REVIEWED by the gate — the reviewer exited 4: lab-acceptance was not loaded and opencode used its default agent, whose answer looks identical to a real one. Treat the acceptance verdict as absent. The push already happened and is unaffected." >&2 ;;
  1) echo "opencode-review hook: NOT REVIEWED — the reviewer exited 1 without producing a review (bad usage, an unusable panel, or every family failing), so none of the ${#artifacts[@]} artifact(s) was read. The push already happened and is unaffected." >&2 ;;
  *) echo "opencode-review hook: NOT REVIEWED — the reviewer exited ${review_status}, which this hook does not recognise, so whether the ${#artifacts[@]} artifact(s) were read is unknown. The push already happened and is unaffected." >&2 ;;
esac
exit 0  # SILENT: the reviewer ran and every outcome above has already been named.
