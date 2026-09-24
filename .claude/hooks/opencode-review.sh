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
# a `git diff` that failed after the merge base resolved, stdin that could not be read, a
# push aimed at a repository this hook is not in, and a repository root this hook could not
# reach (all NOT REVIEWED). The full list, with each
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
# RECOGNITION IS THREE-WAY, NOT TWO. This is round 5's finding, and it is deliberately not a
# fifth shape added to the trigger. Four rounds each taught that regex one more form — `-C`,
# then `--git-dir`, then `--no-pager`, then a quoted directory — and a regex reading a shell
# command line does not run out of forms. The third outcome is the fix instead:
#
#   RECOGNISED as a push (or a `gh pr create`) THIS TREE RUNS — review it, as before. The
#     second half is the first-token rule added 2026-09-24: the command is split on the
#     shell's separators, quote-aware, and it is reviewable only if some segment's FIRST TOKEN
#     is `git` or `gh`. Recognising a push and being able to place it in this tree are two
#     different things, and matching the trigger only ever bought the first.
#   ESTABLISHED not to be one — SILENT. Either no push token stands anywhere the trigger could
#     have reached (`git status`, `pushd /tmp`, `git pushdown origin`, `gh pr created 3`), or
#     there is one and the hook READ its way past it: every token between the command name and
#     that token was readable, so one of them is the subcommand and the token is that
#     subcommand's argument (`git commit -m push`, `git log --grep="fix push bug"`).
#   NEITHER — ANNOUNCED. The command carries `push` or `pr create`, and a token standing
#     between the command name and it carries shell quoting, or an expansion of ANY kind, that
#     this recogniser's token language does not read (`git -C "my repo" push`, `git $(cat d)
#     push`, `git $GIT_OPTS push`). Expansion and substitution are one case, not two: this
#     process holds neither value. The hook has not found that no review was owed; it has
#     failed to find out which of the two this was, and the one rule above sends that to
#     stderr.
#
# The third branch is the point: the NEXT unreadable form is announced without anyone having
# to think of it first, because being announced requires only being unrecognised. Round 4's
# quoted `-C` directory is one instance of it and has a case below — pinned, not special-cased.
#
# THE SWEEP, 2026-09-24, rounds 3 to 5. Two review rounds each fixed the doors they were
# pointed at — three of them, then one more — a third round found a fourth, and a fourth round
# found one this file had just built: the trigger widening below made `git -C <dir> push` match
# without making the directory it names reviewable. A widening that admits a command it cannot
# serve owes a decline, not a review of whatever tree it happens to be standing in. A fifth
# round then found the shape the four had in common — every one of them was a form the trigger
# could not read leaving in silence — and that is answered by the three-way classification
# above rather than by a fifth widening.
# Fixing the named door is how a corridor stays open, so this is the LIST instead: every place in this file where a
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
#     the command is not a push ......... read, matched against the trigger, it is not one, AND
#       it carries no push token the trigger failed to reach — the ESTABLISHED branch of the
#       three-way classification above. Round 4 found this exit covering something it had not
#       established (a quoted `-C` directory); that case now leaves through the ANNOUNCED
#       entry below instead, and this one no longer admits an exception.
#     the diff listed nothing ........... the diff RAN and this branch changed nothing.
#     nothing matched a glob ............ the changed list was read; no artifact is in scope.
#     every matched artifact deleted .... already announced by name as REMOVED, two lines up.
#     the reviewer exited 0 ............. the review ran; it named its own findings file.
#
#   ANNOUNCED — the hook merely FAILED TO FIND OUT:
#     a push token in a form it cannot read . the command carries `push` or `pr create`, and a
#       token before it carries shell quoting or an expansion (`git -C "my repo" push`, `git
#       $(cat d) push`, `git $GIT_OPTS push`). Round 5's finding, and the third branch of the
#       classification above: unrecognised is now declined by default rather than by
#       enumeration. Plain `$VAR` joined `$(…)` on 2026-09-24, round 1 of step 31's review —
#       until then it left through the SILENT exit, which is the defect wearing the other coat.
#     the push runs through another program . a recognised push whose command has NO segment
#       whose FIRST TOKEN is `git` or `gh` — `ssh host 'git push'`, `bash -c 'git push'`,
#       `sh -c`, `eval`, `sudo`, `env`, `docker exec …`. Every one of these matched the
#       trigger and was reviewed against whatever tree this file stands in, announcing
#       `reviewing N artifact(s)` about a push executing elsewhere. It is a whitelist, not a
#       sixth enumerated prefix: an unlisted wrapper declines by default rather than lying by
#       default. PRE-EXISTING — `ssh host 'git push'` matched the original trigger too.
#     an earlier segment can move the shell . a segment whose first token IS `git`, preceded in
#       the same command line by a segment that can change the current shell's directory —
#       `cd /other && git push`, `eval "$setup"; git push`. Only current-shell constructs can
#       do this (`cd`, `pushd`, `popd`, `eval`, `source`, `.`, and `builtin`/`command` in front
#       of them); an external program runs in a fork and cannot. That set is closed by shell
#       semantics, which is why it may be written out where a list of wrapper programs may not.
#       Round 1 of step 31's own review.
#     repo root unreachable ............. cannot locate the tree it would have examined.
#     stdin unreadable (`cat` failed) ... the call was never read — not the same as empty.
#     the payload is not JSON ........... whether this was a push could not be established.
#     `jq` missing, or `jq` non-zero .... the only parser here; no parser, no answer.
#     `opencode` missing ................ nothing on this branch reaches the critic.
#     tools/opencode-review.sh missing .. every artifact on the branch goes unreviewed.
#     no merge base with origin/main .... the changed set is unknown, not empty.
#     `git diff --name-only` failed ..... the same unknown. This is round 3's finding.
#     the push names ANOTHER repository . `-C <dir>` / `--git-dir=<dir>` resolving to a git
#       directory that is not this one: recognised as a push, and not reviewable from here.
#       This is round 4's finding, and it arrived as the cost of round 3's widening.
#     that directory did not resolve .... no repository there, or more than one named at once;
#       whether it is this tree was never established, so neither answer may be assumed.
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

# THE THIRD BRANCH, and the only reason the two regexes above are allowed to be incomplete.
# See RECOGNITION IS THREE-WAY in the header for why this is here instead of a fifth widening.
#
# `_undecided` does not try to recognise a push. It asks the far cheaper question the trigger
# cannot: is there a `push` / `pr create` token that the trigger FAILED TO REACH because a
# token in front of it is written in a language this recogniser does not read — shell quoting
# (`"`, `'`, a backtick, a backslash) or an EXPANSION of any kind (`$(…)`, `$VAR`, `${VAR}`)?
#
# PLAIN PARAMETER EXPANSION WAS THE ONE SHELL FORM NEITHER SIDE READ (fixed 2026-09-24, round
# 1 of step 31's review). `$(` was listed and bare `$` was not, so `git $GIT_OPTS push origin
# main` — with `GIT_OPTS='-C ../other'` or `-c k=v` in the developer's shell — failed the
# trigger (`$GIT_OPTS` is not option-shaped, so `push` does not follow `git`) AND failed this
# branch (`$GIT_OPTS` has no `$(`), and left through the silent not-a-push exit below. A real
# push, possibly aimed at another tree, was recorded as reviewed with nothing said. The
# distinction the old pattern drew — substitution is unreadable, expansion is not — describes
# no property of this recogniser: it cannot read EITHER, because both are the shell's values
# and not this process's. So the test is now the `$` itself, which subsumes `$(` and needs no
# list of expansion syntaxes to keep up with.
#
# The lead is what keeps it off ordinary commands, and it is doing the whole job of separating
# ESTABLISHED from NEITHER. The gap between the command name and the push token may begin ONLY
# with an option-shaped token or with an unreadable one. If it begins with a plain word, that
# word is the subcommand, the hook has READ its way past the push token, and the token is that
# subcommand's argument: `git commit -m push` and `git log --grep="fix push bug"` both stop
# here and stay silent. That is an establishment, not a guess — nothing unreadable stood
# between `git` and the word.
_sq="'"
_unreadable_chars="[\"${_sq}\`\\\\]"
_unreadable_tok="[^[:space:]]*(${_unreadable_chars}|[\$])[^[:space:]]*"
_readable_run='([^[:space:]]+[[:space:]]+)*'
_opt_lead="(-[^[:space:]]*[[:space:]]+${_readable_run})?"
_undecided="(^|[^[:alnum:]_-])(git|gh)[[:space:]]+${_opt_lead}(${_unreadable_tok})[[:space:]]+${_readable_run}(push|pr[[:space:]]+create)([^[:alnum:]_-]|\$)"

# WHOSE TREE THE PUSH RUNS IN — positive recognition, and the reason no list of delegation
# prefixes appears anywhere below. Everything above asks whether a PUSH is in the command;
# until 2026-09-24 nothing asked whether THIS MACHINE'S TREE is the one it happens in.
# `ssh build-host 'git push origin main'`, `bash -c 'git push'`, `sh -c '…'`, `eval 'git
# push'`, `sudo git push`, `env FOO=1 git push` and `docker exec c git push` all match the
# trigger, so the hook read every one of them as local, diffed the files under
# ${BASH_SOURCE[0]} and announced `reviewing N artifact(s)` about a push executing somewhere
# else. That is a FALSE REVIEW TRACE — the same family as the `-C <other repo>` review round 4
# found, and worse than silence, because a developer reading the trace concludes the pushed
# artifacts were seen by the critic. The shape is PRE-EXISTING: `ssh host 'git push'` matched
# the original `git push` trigger too, before any of the option widenings above.
#
# THE FIX IS A WHITELIST, NOT A SIXTH BLACKLIST ENTRY. A list of delegation prefixes measures
# whoever wrote it — `ssh`, `sudo`, `env`, `nohup`, `xargs`, `timeout`, `docker exec`, a
# wrapper script with a name nobody here has heard of — and loses to every shape nobody
# listed, which is the defect the three-way classification above was adopted to end. So the
# question is inverted. The command is split into segments on the shell's own separators, and
# a segment is a REVIEWABLE LOCAL PUSH only when its FIRST TOKEN is `git` or `gh` and the push
# follows it with nothing but recognised options in between. Every other shape — including the
# next delegation prefix nobody has thought of — declines by DEFAULT rather than by
# enumeration, and the decline is announced like every other one.
#
# SPLITTING IS QUOTE-AWARE, and that is load-bearing rather than decorative. `ssh host 'cd /w
# && git push'` splits on a naive `&&` into a second segment beginning `git push`, which would
# read as local and reinstate the exact bug this replaces. A quote or a backslash suspends the
# separators until it closes, so that command stays ONE segment whose first token is `ssh`.
#
# IT CANNOT NARROW THE TRIGGER, only redirect what the trigger already caught. A command with
# no `git … push` / `gh … pr create` shape in it never reaches here, so `grep push notes.txt`
# and `echo "do not push"` stay silent rather than announcing — the notice is reserved for a
# command that carries a real push this hook cannot place in its own tree.
_SEGMENTS=()
_split_segments() {  # <command> -> _SEGMENTS: split on & | ; and newline, OUTSIDE quotes
  local s="$1" i ch q='' cur=''
  _SEGMENTS=()
  for (( i = 0; i < ${#s}; i++ )); do
    ch="${s:i:1}"
    if [ -n "$q" ]; then               # inside '…' or "…": separators are ordinary text
      cur+="$ch"
      if [ "$ch" = "$q" ]; then q=''; fi
      continue
    fi
    case "$ch" in
      '\')  cur+="$ch"; i=$((i+1)); cur+="${s:i:1}" ;;   # an escape carries its next char
      '"'|"'") q="$ch"; cur+="$ch" ;;
      '&'|'|'|';'|$'\n') _SEGMENTS+=("$cur"); cur='' ;;
      *) cur+="$ch" ;;
    esac
  done
  _SEGMENTS+=("$cur")                  # always at least one, so `${_SEGMENTS[@]}` is safe
}

# The same two triggers, ANCHORED. `^[[:space:]]*git` is the whole first-token rule: nothing
# may precede the command name in its segment but whitespace, and `_opts` then permits only
# the option run the trigger above already permits before the subcommand. `git` is required to
# end there — `gitfoo push` fails, because `_opts` cannot match `foo` and `push` does not
# follow `git` directly.
_local_trigger="^[[:space:]]*git${_opts}[[:space:]]+push([^[:alnum:]_-]|\$)"
_local_trigger_pr="^[[:space:]]*gh${_opts}[[:space:]]+pr[[:space:]]+create([^[:alnum:]_-]|\$)"

# WHAT AN EARLIER SEGMENT CAN STILL DO TO A LATER ONE — round 1 of this step's own review.
#
# The first-token rule reads each segment ALONE, and `cd /path/to/other-repo && git push
# origin main` has a segment whose first token is `git`. The rule called it local, the hook
# diffed the tree under ${BASH_SOURCE[0]} and announced `reviewing N artifact(s)` — the same
# false review trace the rule was built to end, wearing a `cd` instead of an `ssh`.
#
# THIS IS A CLOSED SET AND THE `ssh`/`sudo`/`docker exec` LIST WAS NOT, which is the whole
# reason one is written out here and the other never will be. For a later segment to run
# anywhere but this hook's own cwd, an EARLIER segment must have changed the cwd of the
# CURRENT SHELL. An external program cannot: it runs in a fork, and its cwd dies with it —
# that is shell semantics, not a survey of what is installed. Only current-shell constructs
# reach it: the builtins that move it (`cd`, `pushd`, `popd`), the constructs that execute
# arbitrary text in it (`eval`, `source`, `.`), and the two prefixes that run a builtin
# through another word (`builtin`, `command`). `exec` is in for completeness — it replaces the
# shell, so nothing after it runs at all. Add to this list only when the SHELL grows a new way
# to move the current process; do not add program names to it.
#
# A FIRST TOKEN THIS FILE CANNOT READ COUNTS AS RELOCATING, in the same direction as
# everything else here: `$CD /other && git push` and `"$helper" && git push` may expand to any
# word in the set above, so they decline. The cost is real and is accepted on purpose — `FOO=$BAR
# make lint && git push` declines too. It declines LOUDLY, on stderr, with the reason and the
# remedy (push from a command whose segments this hook can read), which is the trade this file
# makes everywhere: an announced decline over a review of the wrong tree.
#
# ONLY SEGMENTS BEFORE THE PUSH MATTER. `git push && cd /other` reviews normally — the push
# has already run in this tree. `||` is not distinguished from `&&`, so `cd /other || git
# push` declines although a failed `cd` leaves the cwd alone; that is the safe direction and
# is deliberate, not an oversight.
# IT PRINTS ITS VERDICT AND DOES NOT RETURN ONE. A predicate written as `return 0` / `return 1`
# would read the same here, and it would be indistinguishable — to the test's exit-site sweep
# and to a human — from a DOOR: a successful early departure that skips the review, which the
# sweep classifies and counts. This function ends nothing; it answers a question about one
# token. Printing keeps that visible in the shape rather than in a comment.
_relocating_token() {  # <segment> -> its first token when THAT token can move the shell; else nothing
  local t="${1#"${1%%[![:space:]]*}"}"   # leading whitespace off
  t="${t%%[[:space:]]*}"                 # first token only
  t="${t#\(}"; t="${t#\{}"               # a subshell or group opener is not the token
  case "${t#\\}" in
    cd|pushd|popd|eval|source|.|builtin|command|exec) printf '%s' "$t" ;;
    *'$'*|*'"'*|*"'"*|*'`'*) printf '%s' "$t" ;;   # unreadable: it may expand to one of the above
  esac
}

_local_push=no
_relocated_by=''
_split_segments "$command_line"
for _seg in "${_SEGMENTS[@]}"; do
  if [[ "$_seg" =~ $_local_trigger || "$_seg" =~ $_local_trigger_pr ]]; then
    if [ -n "$_relocated_by" ]; then _local_push=relocated; else _local_push=yes; fi
    break
  fi
  if [ -z "$_relocated_by" ]; then _relocated_by="$(_relocating_token "$_seg")"; fi
done

if [[ "$command_line" =~ $_trigger || "$command_line" =~ $_trigger_pr ]]; then
  if [ "$_local_push" = relocated ]; then
    echo "opencode-review hook: NOT REVIEWED — this command's push does begin a segment with 'git' or 'gh', but an earlier segment of the same command line starts with '${_relocated_by}', which can change the working directory of the shell the push then runs in (cd, pushd, popd, eval, source, . — or a token this hook cannot read). The push may therefore happen in a tree this hook cannot see, and reviewing the files under this checkout would record a review of the wrong tree. Nothing reached the critic; review it by hand, or push from a command with no segment before the push." >&2
    exit 0
  fi
  if [ "$_local_push" = no ]; then
    echo "opencode-review hook: NOT REVIEWED — this command carries a push, and no segment of it is a push this hook can place in its own tree: the first token of every segment is something other than 'git' or 'gh', so the push is being run through another program (ssh, sudo, env, bash -c, docker exec or the like) and executes in a tree this hook cannot see. Reviewing the files under this checkout would record a review of the wrong tree. Nothing reached the critic; review it by hand, or push again from a command whose first token is git or gh." >&2
    exit 0
  fi
else
  if [[ "$command_line" =~ $_undecided ]]; then
    # BASH_REMATCH: 2 is the command name, 5 the token that could not be read, 8 the push
    # token it stands in front of. Named rather than echoed whole, because the notice is about
    # a FORM — the next one will be a different command with the same defect in it.
    #
    # EVERY INDEX CARRIES `:-`, and that is this file's own promise rather than a defensive
    # habit. `set -u` is on, so an index this regex stops producing — anyone adding a group, or
    # reordering these — aborts the hook with EXIT 1, and a hook that exits non-zero FAILS THE
    # PUSH, which the header's first promise says it never does. A mutation run on 2026-09-24
    # hit exactly that while testing a different change, so the failure is observed rather than
    # imagined. No case can reach it while the numbering is right, which is why it is written
    # here as well as fixed.
    echo "opencode-review hook: NOT REVIEWED — this command carries a push token ('${BASH_REMATCH[8]:-?}') in a form this hook does not recognise: the token '${BASH_REMATCH[5]:-?}' standing between '${BASH_REMATCH[2]:-?}' and it uses shell quoting or an expansion (\$VAR, \$(…)), which this recogniser does not read — the value is the shell's, not this process's. Whether this was a push was never established, so if it was, nothing it pushed reached the critic. Review it by hand, or push again from a command this hook can read." >&2
    exit 0
  fi
  exit 0  # SILENT: read, and it is not a push — no push token the trigger failed to reach.
fi

# WHICH TREE THE PUSH IS AIMED AT — the door the widening directly above opened, and round 3's
# finding. `git -C <dir> push` now MATCHES, which was the point; but `repo_root` comes from
# ${BASH_SOURCE[0]} and every git command below runs in THAT tree, never in the directory `-C`
# or `--git-dir` names. A push aimed at a sibling repository was therefore reviewed against
# this one: the developer records a review that happened on the wrong tree while the pushed
# artifacts go unseen — worse than the silence the widening replaced, because it leaves a
# positive trace. Recognising a push and being able to review it are two different things, and
# the widening bought only the first.
#
# This hook cannot review a tree it is not in: nothing here can enter another repository and
# call the result this branch's changed set. So it is a CANNOT REVIEW door, and the one rule
# sends it to stderr — named and declined, never quietly reviewed against the wrong diff.
#
# ANOTHER TREE IS DECIDED BY GIT DIRECTORY, not by string prefix. `git -C tools push` is this
# repository seen from a subdirectory and must review normally; a submodule or a nested clone
# under the same prefix is a different repository despite the prefix; a linked worktree is a
# different checkout on a different branch. `rev-parse --absolute-git-dir` answers all three
# alike, and both sides are pushed through `cd … && pwd -P` so a symlinked root (`/var` ->
# `/private/var` on macOS) cannot read as two repositories. A directory that resolves to no
# repository at all is not "different" — it is UNESTABLISHED, and that is its own notice,
# because guessing in either direction here is exactly how the wrong diff got reviewed.
#
# ONLY `git` IS PARSED, not `gh`: `gh --repo o/r pr create` names a GitHub repository while the
# branch being proposed is this local one, which is the tree the hook should read.
#
# THE NARROWING IS STILL HERE AND IS NO LONGER SILENT. A directory whose name contains a space
# (`git -C "my repo" push`) still does not match the trigger — `_opts` takes a value token as
# one whitespace-free word — so this check never sees it. It no longer leaves quietly: it is
# caught by `_undecided` above and declined by name. The trigger's reach did not change; what
# changed is that falling outside it is an announced outcome rather than an unrecorded one.
_git_opts_re="(^|[^[:alnum:]_-])git(${_opts})[[:space:]]+push([^[:alnum:]_-]|\$)"
push_targets=''        # "<option> <dir>" per tree-naming option found, verbatim, for the notice
push_target_count=0
push_target_dir=''
push_target_opt=''
if [[ "$command_line" =~ $_git_opts_re ]]; then
  # BASH_REMATCH[2] is the WHOLE option run because `_opts` is wrapped in its own group here;
  # matching `_opts` directly would hand back only its last repetition and lose every earlier
  # option. The walk below consumes a value token exactly where `_opts` did, so it stays
  # aligned with what the trigger actually matched rather than with a second, divergent idea
  # of git's command line.
  read -r -a _opt_tokens <<< "${BASH_REMATCH[2]}"
  _i=0
  while [ "$_i" -lt "${#_opt_tokens[@]}" ]; do
    _tok="${_opt_tokens[$_i]}"
    _next="${_opt_tokens[$((_i+1))]:-}"
    case "$_tok" in
      --git-dir=*)
        push_target_opt='--git-dir'; push_target_dir="${_tok#--git-dir=}"
        push_targets="${push_targets}${push_targets:+, }--git-dir ${push_target_dir}"
        push_target_count=$((push_target_count+1)); _i=$((_i+1)) ;;
      -C|--git-dir)
        # A bare `-C` with nothing after it is the documented over-match `git -C push`: the
        # regex backtracked to an option with no value, there is no directory, and nothing is
        # recorded — that push reviews this tree, as it did before.
        if [ -n "$_next" ]; then
          push_target_opt="$_tok"; push_target_dir="$_next"
          push_targets="${push_targets}${push_targets:+, }${_tok} ${_next}"
          push_target_count=$((push_target_count+1))
        fi
        _i=$((_i+2)) ;;
      *)
        case "$_next" in ''|-*) _i=$((_i+1)) ;; *) _i=$((_i+2)) ;; esac ;;
    esac
  done
fi

if [ "$push_target_count" -gt 0 ]; then
  _abs_gitdir() {  # <dir> -> physical git directory git would use there, or nothing at all
    local g
    g="$(git -C "$1" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
    [ -n "$g" ] || return 1
    (cd "$g" 2>/dev/null && pwd -P)
  }
  own_gitdir="$(_abs_gitdir . 2>/dev/null)" || own_gitdir=''
  target_gitdir=''
  # MORE THAN ONE tree-naming option (`git -C a --git-dir=b push`) is left unresolved on
  # purpose: git composes them, this does not, and a wrong answer here reviews the wrong tree
  # while saying nothing. Unresolved is announced, so the developer learns rather than guesses.
  if [ "$push_target_count" -eq 1 ]; then
    case "$push_target_opt" in
      --git-dir) target_gitdir="$(cd "$push_target_dir" 2>/dev/null && pwd -P)" ;;
      *)         target_gitdir="$(_abs_gitdir "$push_target_dir" 2>/dev/null)" || target_gitdir='' ;;
    esac
  fi
  # WHY IT COULD NOT BE RESOLVED IS PART OF THE NOTICE (round 1 of step 31's review). `git -C
  # $dir push` reaches here with `$dir` as a literal four characters, and the old wording —
  # "could not resolve" — told the developer their directory was wrong when the truth is that
  # this hook cannot expand a shell variable: the value is the shell's, not this process's.
  # The decline was right and the diagnosis was not, and a notice nobody can act on is most of
  # the way back to silence. Same vocabulary as the third branch above, for the same reason.
  _why_unresolved='it names no repository this hook can reach'
  case "$push_target_dir" in *'$'*|*'"'*|*"'"*|*'`'*)
    _why_unresolved='its directory is written as a shell expansion or quotation, which this hook cannot expand — the value is the shell'"'"'s, not this process'"'"'s' ;;
  esac
  if [ -z "$own_gitdir" ] || [ -z "$target_gitdir" ]; then
    echo "opencode-review hook: NOT REVIEWED — this push names a repository directory this hook could not resolve (${push_targets}): ${_why_unresolved}. Whether it targets this tree could not be established, and nothing it pushed reached the critic." >&2
    exit 0
  fi
  if [ "$target_gitdir" != "$own_gitdir" ]; then
    echo "opencode-review hook: NOT REVIEWED — this push targets another repository (${push_targets}), and this hook can only examine the tree it lives in (${repo_root}); nothing pushed from there reached the critic. Run the review in that repository." >&2
    exit 0
  fi
fi

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
# An absent `origin/main` — a trunk still called `master`, a remote not yet fetched, a fork, a
# renamed default branch — leaves `base` empty. The changed set is then unknown, not empty,
# and the difference is the one rule: the hook did not find nothing, it failed to find out.
#
# ONLY `origin/main` IS TRIED, and the notice now says so. A repository whose trunk is
# `origin/master` has a fetched remote and no rename to undo, so a notice offering those as
# causes sends its reader to fetch and retry forever: the decline is permanent there until
# this hook learns a second ref, which is a change to what it reviews and not a wording fix.
# Naming the limit is the honest half of that, and it is the half this file can do today.
base_status=0
base="$(git merge-base HEAD origin/main 2>/dev/null)" || base_status=$?
if [ "$base_status" -ne 0 ] || [ -z "$base" ]; then
  echo "opencode-review hook: NOT REVIEWED — git merge-base HEAD origin/main found nothing (a trunk still called origin/master, a remote not yet fetched, a fork, or a renamed default branch), so this branch's changed files could not be listed and no artifact reached the critic. Only origin/main is tried; a repository whose trunk is named anything else declines here every time, and fetching will not change that." >&2
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
