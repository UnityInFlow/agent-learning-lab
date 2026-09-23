#!/usr/bin/env bash
# Test the review hook with opencode, git and the reviewer all stubbed. No network, no
# tokens, no model calls — runnable in CI and before trusting the hook in a new repo.
#
#   ./.claude/hooks/opencode-review.test.sh
#
# Exit 0 if every case behaves, 1 otherwise. A hook that silently does nothing is worse than
# no hook, so the cases that assert the reviewer was NOT called matter as much as the ones
# that assert it was.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
HOOK=".claude/hooks/opencode-review.sh"
[ -x "$HOOK" ] || { echo "not executable: $HOOK" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STUB="$WORK/bin"; mkdir -p "$STUB"
CALLS="$WORK/reviewer-calls"   # one line per INVOCATION — this is what the call count reads
ARGV="$WORK/reviewer-argv"     # one line per ARGUMENT — this is what the argv assertions read

# A fake repo with a fake trunk, so `git merge-base HEAD origin/main` resolves without
# touching the real one.
FIXTURE="$WORK/repo"
mkdir -p "$FIXTURE/tools" "$FIXTURE/benchmark/rubrics" "$FIXTURE/experiments" "$FIXTURE/.claude/hooks"
cp "$HOOK" "$FIXTURE/.claude/hooks/"
git -C "$FIXTURE" init -q -b main
git -C "$FIXTURE" config user.email t@t; git -C "$FIXTURE" config user.name t
echo base > "$FIXTURE/README.md"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm base
git -C "$FIXTURE" update-ref refs/remotes/origin/main HEAD

# The reviewer stub records its argv instead of calling a model.
#
# ONE LINE PER ARGUMENT, in its own file. Recording "$*" instead — one flattened line per
# call — destroys the argument boundaries, and the boundaries are the contract: the hook
# invokes `./tools/opencode-review.sh -n N -P panel "${artifacts[@]}"`, and each artifact has
# to arrive as ONE element. A regression that expands the paths unquoted splits
# `benchmark/rubrics/backend quality.yaml` into two arguments — a real reviewer then cannot
# open either — while a grep of the flattened text still finds the whole path and every
# assertion still passes. The invocation contract would be broken and the suite green.
# The call COUNT stays in its own file so `wc -l` keeps counting invocations, not arguments.
cat > "$FIXTURE/tools/opencode-review.sh" <<STUBSH
#!/usr/bin/env bash
printf 'call with %s argument(s)\n' "\$#" >> "$CALLS"
printf '%s\n' "\$@" >> "$ARGV"
exit \${STUB_REVIEWER_EXIT:-0}
STUBSH
chmod +x "$FIXTURE/tools/opencode-review.sh"

# `<flag>` and its value as TWO ADJACENT argv elements, which is what the hook promises and
# what a flattened log cannot express: `-P deepseek-v4-pro` as one string, or a panel split
# across two arguments, both read the same once the elements are joined.
argv_has_flag_value() {  # argv_has_flag_value <argv-file> <flag> <value>
  awk -v flag="$2" -v val="$3" \
    'prev == flag && $0 == val { found = 1 } { prev = $0 } END { exit !found }' "$1"
}

# A codex-critic stub, so the hook's `[ -x tools/codex-critic.sh ]` half of the
# panel-reduction test is satisfied and the reduction then turns on `command -v codex` alone.
# Without it that branch fires unconditionally and the two panel cases below cannot separate.
printf '#!/usr/bin/env bash\nexit 0\n' > "$FIXTURE/tools/codex-critic.sh"
chmod +x "$FIXTURE/tools/codex-critic.sh"

# A rubric that exists ON THE TRUNK. Deleting it on a branch is a real deletion in
# `git diff base...HEAD`; a rubric a branch both creates and removes nets out of that diff
# entirely and therefore cannot test deletion at all.
echo 'version: 0' > "$FIXTURE/benchmark/rubrics/registered.yaml"

# The stub lives under tools/, which became reviewable on 2026-08-28. Commit it to the TRUNK
# so it is not in every branch diff — otherwise every case reviews the stub, and the cases
# that assert the reviewer was NOT called can never be observed. Found by this test failing
# the moment the globs widened, which is the test doing its job.
git -C "$FIXTURE" add -A >/dev/null
git -C "$FIXTURE" commit -qm "reviewer stub on the trunk" >/dev/null
git -C "$FIXTURE" update-ref refs/remotes/origin/main HEAD

printf '#!/usr/bin/env bash\nexit 0\n' > "$STUB/opencode"; chmod +x "$STUB/opencode"

# A PATH holding ONLY what the hook needs — no opencode anywhere on it. Removing the stub is
# not enough: the developer's real opencode is still on $PATH and `command -v` finds it, so
# the "not installed" case passed for the wrong reason until this existed.
MINBIN="$WORK/minbin"; mkdir -p "$MINBIN"
# bash and env too: the shebang is `#!/usr/bin/env bash`, so both must be findable
for t in bash env git jq cat dirname; do
  src="$(command -v "$t" 2>/dev/null)" && ln -sf "$src" "$MINBIN/$t"
done

# Every case below is counted; the tail guard refuses a run whose total drifts from this,
# because a suite that quietly lost a case still exits 0 and reads exactly like a pass.
#
# THREE OUTCOMES, NOT TWO. A case that could not run in this environment is SKIPPED, and a
# skip is neither a pass nor a failure: it is a case whose verdict this run does not have.
# Counting it as a pass is the failure this file exists to catch — the trunk-liveness check
# is the only case that reads the real hook against the real trunk, and in a checkout with no
# trunk ref (a shallow CI clone) it cannot run. If its skip incremented PASS, the tail read
# "all 42 cases behaved as specified" and the EXPECTED_CASES guard matched, while the one
# check that detects a dead glob never executed: a control reporting success over a smaller
# scope than it claims. So SKIP is its own counter, the tail line names all three, and only
# PASS+FAIL — the cases that actually ran — is compared against EXPECTED_CASES, which means a
# skipped case fails that comparison and the run cannot read as a complete pass. "Everything
# ran and passed" and "everything that ran, passed" are different sentences and now print
# differently.
EXPECTED_CASES=42
PASS=0; FAIL=0; SKIP=0
run() {  # run <name> <stdin-json> <expect-exit> <expect-calls> [env=val ...]
  local name="$1" payload="$2" want_exit="$3" want_calls="$4"; shift 4
  : > "$CALLS"; : > "$ARGV"
  local out; out="$(printf '%s' "$payload" | env "$@" PATH="$STUB:$PATH" \
      "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
  local got_exit=$?
  local got_calls; got_calls="$(wc -l < "$CALLS" | tr -d ' ')"
  if [ "$got_exit" = "$want_exit" ] && [ "$got_calls" = "$want_calls" ]; then
    printf 'ok    %-44s exit %s, %s reviewer call(s)\n' "$name" "$got_exit" "$got_calls"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s (want %s), %s call(s) (want %s)\n' \
      "$name" "$got_exit" "$want_exit" "$got_calls" "$want_calls"
    [ -n "$out" ] && printf '        %s\n' "$out"
    FAIL=$((FAIL+1))
  fi
}

PUSH='{"tool_name":"Bash","tool_input":{"command":"git push -u origin feature"}}'
PR='{"tool_name":"Bash","tool_input":{"command":"gh pr create --title x"}}'

# --- nothing changed yet: matching command, but no artifact on the branch
run "push, no changes"            "$PUSH" 0 0
run "gh pr create, no changes"    "$PR"   0 0

# --- non-matching commands must not spawn a review even when an artifact HAS changed
git -C "$FIXTURE" checkout -q -b feature
echo 'version: 1' > "$FIXTURE/benchmark/rubrics/backend-quality.yaml"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm rubric

run "git status is not a push"    '{"tool_name":"Bash","tool_input":{"command":"git status"}}' 0 0
run "pushd is not a push"         '{"tool_name":"Bash","tool_input":{"command":"pushd /tmp"}}'  0 0
run "gh pr view is not create"    '{"tool_name":"Bash","tool_input":{"command":"gh pr view 3"}}' 0 0
# The near misses. These pass trivially against a substring match only because they contain
# no `git push` at all; the two below DO contain it as a prefix of a longer command name, and
# a substring trigger fires on both.
run "git pushdown is not a push"  '{"tool_name":"Bash","tool_input":{"command":"git pushdown origin"}}' 0 0
run "gh pr created is not create" '{"tool_name":"Bash","tool_input":{"command":"gh pr created 3"}}' 0 0
# ...while a compound command still is one. A trigger tightened until it misses a real push
# is a worse bug than the one it fixed, so both directions are asserted.
run "a compound git push counts"  '{"tool_name":"Bash","tool_input":{"command":"make lint && git push"}}' 0 1
run "git push with a semicolon"   '{"tool_name":"Bash","tool_input":{"command":"git push; echo done"}}' 0 1

# --- the case the hook exists for
run "push with a changed rubric"  "$PUSH" 0 1
run "gh pr create, changed rubric" "$PR"  0 1

# and it must pass the artifact, not just fire — as ONE argument, which is what `-Fx` says
# and a substring grep does not. Every positive argv assertion below is whole-line for the
# same reason; the negative ones stay substring, because "this path must not appear anywhere
# in the argv" is the stronger claim to make about absence.
if grep -Fxq 'benchmark/rubrics/backend-quality.yaml' "$ARGV" 2>/dev/null; then
  printf 'ok    %-44s argv carries the artifact\n' "reviewer argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "reviewer argv" "$(cat "$ARGV" 2>/dev/null)"; FAIL=$((FAIL+1))
fi

# --- a changed file outside the contract globs is not worth a model call.
# The `git rm` here removes the rubric THIS BRANCH created two commits ago, so it nets out of
# `git diff base...HEAD` completely: after this commit the branch diff carries README.md and
# nothing else. That is what makes the case honest — it says "no reviewable file changed" and
# means it. It is NOT a deletion test and must not be read as one; a branch removing a rubric
# that exists on the trunk is a different event, and it has its own cases further down.
(cd "$FIXTURE" && git rm -q benchmark/rubrics/backend-quality.yaml)
echo notes > "$FIXTURE/README.md"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm readme
run "README change is not reviewable" "$PUSH" 0 0

# --- every way the reviewer can be unavailable or broken, the push still stands
git -C "$FIXTURE" checkout -q -b feature2
mkdir -p "$FIXTURE/templates"
echo 'runId: x' > "$FIXTURE/templates/run-record.yaml"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm template
run "reviewer exits 1"            "$PUSH" 0 1 STUB_REVIEWER_EXIT=1
run "LAB_REVIEW_HOOK=0 disables"  "$PUSH" 0 0 LAB_REVIEW_HOOK=0

# --- tools became reviewable on 2026-08-28, after the panel found a blocking defect in one
git -C "$FIXTURE" checkout -q -b feature3
printf '#!/usr/bin/env bash\necho hi\n' > "$FIXTURE/tools/check-something.sh"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm tool
run "a changed tool IS reviewable"  "$PUSH" 0 1
if grep -Fxq 'tools/check-something.sh' "$ARGV" 2>/dev/null; then
  printf 'ok    %-44s argv carries the tool\n' "tool argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "tool argv" "$(cat "$ARGV" 2>/dev/null)"; FAIL=$((FAIL+1))
fi

# --- the budget must DROP tools before contracts, and must never drop silently
git -C "$FIXTURE" checkout -q -b feature4
# mkdir -p, because the earlier `git rm` of the only file in benchmark/rubrics/ removed the
# directory too. Without this the redirect fails silently, the contract is never created,
# and the case passes or fails for a reason that has nothing to do with the budget.
mkdir -p "$FIXTURE/benchmark/rubrics"
echo 'version: 9' > "$FIXTURE/benchmark/rubrics/r.yaml"
for n in a b c d; do printf '#!/usr/bin/env bash\nexit 0\n' > "$FIXTURE/tools/t-$n.sh"; done
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm many
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env LAB_REVIEW_MAX_ARTIFACTS=2 PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$ARGV" 2>/dev/null)"
# EVERY dropped path, by name — not "some tools/t- appeared". The guarantee in the hook is
# "every dropped file is named", and an assertion that only greps for one of them passes a
# regression that prints the first and stops, which is the same class of under-reporting the
# notice exists to prevent. The full expected set is spelled out, and the ranked total is
# asserted too, so a file falling out of scope entirely cannot hide as a smaller denominator.
# Ranked order on this branch, contracts first then tools, each in git's path order:
#   benchmark/rubrics/r.yaml, templates/run-record.yaml,
#   tools/check-something.sh, tools/t-a.sh, tools/t-b.sh, tools/t-c.sh, tools/t-d.sh
# -F, not a regex. A filename is a literal, and `.` in a regex matches any character: with
# `grep -q` the notice could print `tools/check-somethingXsh` and this loop would still call
# it named. The asserted contract is "every dropped path, BY NAME", so the assertion has to
# be by name too — a one-character corruption must fail it. Same for the leak loop, where a
# regex would report a leak the argv does not contain.
missing=""
for f in tools/check-something.sh tools/t-a.sh tools/t-b.sh tools/t-c.sh tools/t-d.sh; do
  printf '%s' "$out" | grep -qF "$f" || missing="$missing $f"
done
leaked=""
for f in tools/check-something.sh tools/t-a.sh tools/t-b.sh tools/t-c.sh tools/t-d.sh; do
  printf '%s' "$argv" | grep -qF "$f" && leaked="$leaked $f"
done
if printf '%s' "$out" | grep -q 'PARTIAL REVIEW — 2 of 7' \
   && [ -z "$missing" ] && [ -z "$leaked" ] \
   && grep -Fxq 'benchmark/rubrics/r.yaml' "$ARGV" \
   && grep -Fxq 'templates/run-record.yaml' "$ARGV"; then
  printf 'ok    %-44s all 5 dropped named, both contracts kept\n' "budget names what it dropped"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s missing=%s leaked=%s out=%s argv=%s\n' \
    "budget names what it dropped" "$missing" "$leaked" "$out" "$argv"; FAIL=$((FAIL+1))
fi

# --- Python tools became reviewable on 2026-09-23. The lab's checkers are .py as often as
# .sh (render-spine-status.py, check-phase-contract.py, count-state-reread.py), and a critic
# that cannot see them reports on half the tools and says nothing about the half it missed.
# From main, so the Python tool is the ONLY file in the branch diff: on a branch that also
# carried the .sh tools, the reviewer would be called whatever the .py glob did, and only the
# argv assertion below would notice.
git -C "$FIXTURE" checkout -q main
git -C "$FIXTURE" checkout -q -b feature5
printf 'print("hi")\n' > "$FIXTURE/tools/render-spine-status.py"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm pytool
run "a changed Python tool IS reviewable" "$PUSH" 0 1
if grep -Fxq 'tools/render-spine-status.py' "$ARGV" 2>/dev/null; then
  printf 'ok    %-44s argv carries the Python tool\n' "python tool argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "python tool argv" "$(cat "$ARGV" 2>/dev/null)"; FAIL=$((FAIL+1))
fi

# --- a path with a SPACE in it still reaches the reviewer as one argument
#
# The regression this case exists for: `./tools/opencode-review.sh … $files` in place of
# `"${artifacts[@]}"`. The reviewer then receives `benchmark/rubrics/backend` and
# `quality.yaml` — two arguments, neither of which opens — and reviews nothing while
# reporting a review. Every argv assertion in this file was blind to it until the stub stopped
# flattening its argv: the joined line still contained the whole path, so every grep matched.
# Whole-line matching plus a path that cannot survive word splitting is what makes the
# boundary observable; on any other path the two recordings agree.
# From main, so this is the only artifact in the branch diff.
git -C "$FIXTURE" checkout -q main
git -C "$FIXTURE" checkout -q -b feature9
printf 'version: 2\n' > "$FIXTURE/benchmark/rubrics/backend quality.yaml"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm "a rubric with a space"
run "a spaced path IS reviewable"  "$PUSH" 0 1
if grep -Fxq 'benchmark/rubrics/backend quality.yaml' "$ARGV" 2>/dev/null; then
  printf 'ok    %-44s one argument, boundary intact\n' "spaced path argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "spaced path argv" "$(cat "$ARGV" 2>/dev/null)"; FAIL=$((FAIL+1))
fi

# --- ...but a mutant fixture is NOT a tool. These are deliberately-broken renderers that a
# verifier exists to kill; reviewing them spends the artifact budget on defects that are the
# point. `tools/*.py` is one level deep, and bash's [[ ]] does not enforce that on its own —
# this case is the only thing standing between the glob and eight fixtures.
git -C "$FIXTURE" checkout -q main
git -C "$FIXTURE" checkout -q -b feature6
mkdir -p "$FIXTURE/tools/fixtures/spine-status/mutants"
printf 'print("all statuses")\n' > "$FIXTURE/tools/fixtures/spine-status/mutants/all-statuses.py"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm mutant
run "a mutant fixture is NOT reviewable" "$PUSH" 0 0

# --- DELETING a reviewable artifact is a change to it, and the loudest one. Until 2026-09-23
# `[ -f "$f" ] || continue` in select_matching dropped deleted paths before they reached the
# ranked list, so they entered neither the review nor the dropped[] notice:
# `git rm benchmark/rubrics/registered.yaml && git push` exited 0 printing nothing at all, and
# the author would have recorded "rubric reviewed" against a file that no longer existed.
# A deleted file cannot be REVIEWED — there is nothing left to read — which is precisely why
# it has to be ANNOUNCED. `registered.yaml` is on the trunk, so this is a real deletion in the
# branch diff, unlike the README case above where the rubric nets out.
git -C "$FIXTURE" checkout -q main
git -C "$FIXTURE" checkout -q -b feature7
(cd "$FIXTURE" && git rm -q benchmark/rubrics/registered.yaml)
git -C "$FIXTURE" commit -qm "rm the registered rubric" >/dev/null
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
calls="$(wc -l < "$CALLS" | tr -d ' ')"
if printf '%s' "$out" | grep -q 'REMOVED' \
   && printf '%s' "$out" | grep -qF 'benchmark/rubrics/registered.yaml' \
   && [ "$calls" = 0 ]; then
  printf 'ok    %-44s announced by name, nothing reviewed\n' "a deleted contract is announced"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s calls=%s\n' "a deleted contract is announced" "$out" "$calls"; FAIL=$((FAIL+1))
fi

# ...and the announcement has to survive a push that DOES review something. A lone notice on
# an otherwise silent push is easy to get right; the version that matters is the one printed
# beside the review banner, where it is easiest to lose. The deleted path must also stay OUT
# of the reviewer's argv: handing a critic a path that does not resolve produces a review of
# nothing, reported as a review.
git -C "$FIXTURE" checkout -q main
git -C "$FIXTURE" checkout -q -b feature8
(cd "$FIXTURE" && git rm -q benchmark/rubrics/registered.yaml)
printf '#!/usr/bin/env bash\nexit 0\n' > "$FIXTURE/tools/still-here.sh"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm "rm rubric, add tool"
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$ARGV" 2>/dev/null)"
if printf '%s' "$out" | grep -q 'REMOVED' \
   && printf '%s' "$out" | grep -qF 'benchmark/rubrics/registered.yaml' \
   && grep -Fxq 'tools/still-here.sh' "$ARGV" \
   && ! printf '%s' "$argv" | grep -qF 'registered.yaml'; then
  printf 'ok    %-44s named in stderr, absent from argv\n' "deletion announced beside a review"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "deletion announced beside a review" "$out" "$argv"; FAIL=$((FAIL+1))
fi

# Back to a branch that DOES carry reviewable artifacts. The cases below assert the reviewer
# was not called; on feature6 nothing is reviewable, so they would pass without proving
# anything about the reason they name.
git -C "$FIXTURE" checkout -q feature4

# --- the codex-unavailable branch, which had no case at all until 2026-09-23. In CI there is
# no codex on $PATH, so that branch fires on EVERY run that reaches the reviewer — and nothing
# asserted what it produced. A `paste -sd,` leaving a trailing comma, or a `grep -v` removing
# the wrong entry, would have left the whole suite green with a corrupted panel, because every
# other case only counts reviewer invocations. Both halves are asserted here: reduced when
# codex is absent, NOT reduced when it is present, and the exact panel string either way.
PANELBIN="$WORK/panelbin"; mkdir -p "$PANELBIN"
for t in bash env git jq cat dirname tr grep paste; do
  src="$(command -v "$t" 2>/dev/null)" && ln -sf "$src" "$PANELBIN/$t"
done
ln -sf "$STUB/opencode" "$PANELBIN/opencode"
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$ARGV" 2>/dev/null)"
if printf '%s' "$out" | grep -q "panel reduced to 'deepseek-v4-pro'" \
   && printf '%s' "$out" | grep -q 'ONE-harness review' \
   && argv_has_flag_value "$ARGV" -P 'deepseek-v4-pro'; then
  printf 'ok    %-44s panel reduced and announced\n' "codex missing degrades the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "codex missing degrades the panel" "$out" "$argv"; FAIL=$((FAIL+1))
fi

printf '#!/usr/bin/env bash\nexit 0\n' > "$PANELBIN/codex"; chmod +x "$PANELBIN/codex"
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$ARGV" 2>/dev/null)"
if ! printf '%s' "$out" | grep -q 'panel reduced' \
   && argv_has_flag_value "$ARGV" -P 'deepseek-v4-pro,codex'; then
  printf 'ok    %-44s full panel, no reduction notice\n' "codex present keeps the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "codex present keeps the panel" "$out" "$argv"; FAIL=$((FAIL+1))
fi

run_bare_path() {  # same as run(), but with a PATH that contains no opencode at all
  local name="$1" payload="$2" want_exit="$3" want_calls="$4"
  : > "$CALLS"; : > "$ARGV"
  local out; out="$(printf '%s' "$payload" | env -i PATH="$MINBIN" HOME="$HOME" \
      "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
  local got_exit=$?
  local got_calls; got_calls="$(wc -l < "$CALLS" | tr -d ' ')"
  if [ "$got_exit" = "$want_exit" ] && [ "$got_calls" = "$want_calls" ]; then
    printf 'ok    %-44s exit %s, %s reviewer call(s)\n' "$name" "$got_exit" "$got_calls"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s (want %s), %s call(s) (want %s)\n' \
      "$name" "$got_exit" "$want_exit" "$got_calls" "$want_calls"
    [ -n "$out" ] && printf '        %s\n' "$out"
    FAIL=$((FAIL+1))
  fi
}
run_bare_path "opencode not installed" "$PUSH" 0 0

# --- malformed input must not produce a stack trace on someone's push
#
# Exit 0 and no reviewer call is only half of that promise, and it is the half that cannot
# fail loudly. A hook that exits 0 while printing `jq: error (at <stdin>:0)` satisfies both
# and still drops a parse error on the developer's terminal on every push — and run() captures
# the hook's merged stdout+stderr but prints it only when a case FAILS, so the noise these
# cases are named after is exactly what their assertion could not see. They assert the
# OUTPUT IS EMPTY instead: input the hook cannot read, it says nothing about.
# (`2>&1` on the capture is what makes stderr reach `$out` at all; without it this asserts
# half as much as it reads.)
run_silent() {  # run_silent <name> <stdin-json> — exit 0, no reviewer call, and no output
  local name="$1" payload="$2"
  : > "$CALLS"; : > "$ARGV"
  local out; out="$(printf '%s' "$payload" | env PATH="$STUB:$PATH" \
      "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
  local got_exit=$?
  local got_calls; got_calls="$(wc -l < "$CALLS" | tr -d ' ')"
  if [ "$got_exit" = 0 ] && [ "$got_calls" = 0 ] && [ -z "$out" ]; then
    printf 'ok    %-44s exit 0, 0 call(s), said nothing\n' "$name"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s (want 0), %s call(s) (want 0), said: %s\n' \
      "$name" "$got_exit" "$got_calls" "${out:-<nothing>}"
    FAIL=$((FAIL+1))
  fi
}
run_silent "empty stdin"                 ''
run_silent "not JSON"                    'not json at all'
run_silent "JSON without a command"      '{"tool_name":"Bash"}'
run_silent "JSON, wrong shape"           '{"tool_input":"a string"}'

# --- a review glob that matches nothing is a dead glob, not a clean repository
#
# A glob whose directory was renamed, or which carries a typo, selects nothing. The hook then
# exits 0 with "no review-scoped files in the diff" — the exact line a genuinely unreviewable
# diff produces — so a hole in the review scope and a clean pass are indistinguishable from
# the outside. Nothing else in this suite notices: every other case supplies its own files, so
# a dead glob sitting beside the live ones changes no count, no verdict and no message.
#
# This hook carries TWO arrays, and a failure that only said "dead glob" would leave a reader
# grepping both, so every line names the array the entry came from.
#
# The entries are read OUT OF THE HOOK, never restated here, so the two cannot drift: a glob
# added to either array is checked by this case on the next run without anyone remembering to.
#
# WHAT THIS CASE DOES NOT CATCH, AND WHERE THAT IS CAUGHT. Reading the arrays out of the hook
# means this can only see the entries that ARE there. A glob DELETED from an array is not a
# dead entry — it is absent from the iteration entirely, so nothing names it, and the `>= 3`
# floor below refuses an empty extraction, not a shorter array. So the claim here is the
# narrow one, and it is the one the ok line states: every glob the hook still carries matches
# a tracked file. "The hook still covers the scope it is supposed to cover" is a different
# claim — it cannot be derived from the hook, because an expectation read from the hook moves
# with the hook — and it is asserted by name in the required-set case below.
#
# WHICH FILE LIST THE GLOBS ARE RESOLVED AGAINST, AND WHY IT IS NOT THIS CHECKOUT. `git ls-files`
# answers for whatever branch, worktree or sparse clone the suite happens to run in. A scoped
# file deleted or renamed on a feature branch — or simply never fetched — is then absent, this
# case FAILs naming a glob that is perfectly live on trunk, and the cheapest way for a reader to
# silence it is to delete that glob from the hook. That is exactly the scope shrinkage the
# required-set case below exists to catch: a check that pushes a reader toward the harm its
# neighbour prevents is worse than no check at all. So the list is read from the TRUNK TREE, and
# a checkout with no trunk ref to read skips this case BY NAME rather than guessing from the
# working tree. The case says "on trunk" in its name either way, so nobody has to infer it.
TRACKED="$WORK/tracked"
TRUNK_REF=''
for _ref in origin/main origin/master main master; do
  git rev-parse --verify --quiet "${_ref}^{commit}" >/dev/null 2>&1 || continue
  git ls-tree -r --name-only "$_ref" > "$TRACKED" 2>/dev/null || continue
  TRUNK_REF="$_ref"; break
done

glob_coverage_failures() {  # <file-list> <array-name> <glob>... -> "<array-name> <glob>" per dead entry
  local list="$1" array="$2"; shift 2
  local glob f matched
  for glob in "$@"; do
    matched=0
    while IFS= read -r f; do
      # shellcheck disable=SC2053 # unquoted RHS is a deliberate glob match, as in the hook
      if [[ "$f" == $glob ]]; then matched=1; break; fi
    done < "$list"
    [ "$matched" = 1 ] || printf '%s %s\n' "$array" "$glob"
  done
}

# READING THE ARRAYS OUT OF THE HOOK, AND THE COUPLING THAT COMES WITH IT.
#
# The entries are read from the hook so the two cannot drift. The obvious reader — an awk line
# range `/^NAME=\(/,/^\)/` piped into `eval` — is the wrong one twice over. A range whose end
# pattern never matches does not fail, it runs to end of file; and if the end pattern is merely
# `^\)` then reindenting ONE array's closing paren silently extends its range to the NEXT
# array's paren, so the eval quietly redefines both. Neither is caught by a count floor: the
# `>= 3` assertions below refuse an EMPTY extraction, never a corrupt one, and the corrupt
# extraction above still yields three entries.
#
# So this reads the array itself rather than a line range, and there is no eval. Between the
# opener and the closing paren, every line must be one single-quoted entry, a comment or blank.
# Anything else — an entry left unquoted, two entries on one line, the opener carrying its
# entries inline, a paren that never arrives — is REFUSED by name, and the refusal reaches the
# reader as this case's FAIL rather than as a corrupted array. That is the coupling, stated:
# each array opens with `NAME=(` alone on its line, carries one quoted entry per line, and
# closes with a paren on a line of its own. Indentation is free; structure is not.
extract_glob_array() {  # <file> <array-name> -> one entry per line; non-zero if malformed
  awk -v name="$2" -v q="'" '
    $0 == name "=(" { inside = 1; next }
    !inside { next }
    $0 ~ "^[[:space:]]*\\)[[:space:]]*$" { closed = 1; exit }
    $0 ~ "^[[:space:]]*(#|$)" { next }
    $0 ~ "^[[:space:]]*" q "[^" q "]+" q "[[:space:]]*$" {
      entry = $0
      sub("^[[:space:]]*" q, "", entry)
      sub(q "[[:space:]]*$", "", entry)
      print entry
      next
    }
    { bad = 1; exit }
    END { if (!closed || bad) exit 3 }
  ' "$1"
}

# The sentinels survive only if the extraction fails; an unread array would otherwise make the
# next case pass over nothing at all. The `>= 3` assertions are the second half of that guard:
# an array read as empty cannot slip through as "no dead entries".
CONTRACT_GLOBS=('CONTRACT_GLOBS-was-not-extracted-from-the-hook')
TOOL_GLOBS=('TOOL_GLOBS-was-not-extracted-from-the-hook')
extraction_errors=''
if _entries="$(extract_glob_array "$HOOK" CONTRACT_GLOBS)" && [ -n "$_entries" ]; then
  CONTRACT_GLOBS=()
  while IFS= read -r _entry; do
    [ -n "$_entry" ] && CONTRACT_GLOBS+=("$_entry")
  done <<< "$_entries"
else
  extraction_errors="${extraction_errors}CONTRACT_GLOBS "
fi
if _entries="$(extract_glob_array "$HOOK" TOOL_GLOBS)" && [ -n "$_entries" ]; then
  TOOL_GLOBS=()
  while IFS= read -r _entry; do
    [ -n "$_entry" ] && TOOL_GLOBS+=("$_entry")
  done <<< "$_entries"
else
  extraction_errors="${extraction_errors}TOOL_GLOBS "
fi

# A file list in which every glob the hook carries is live BY CONSTRUCTION — each glob with its
# wildcards filled in. The two refusal cases below run against this rather than against the
# trunk tree, so what they prove is a property of the CHECK and not of whatever the repository
# happens to contain today: they behave identically on trunk, in CI and in a sparse clone.
SYNTH="$WORK/synthetic-trunk"
: > "$SYNTH"
for _glob in "${CONTRACT_GLOBS[@]}" "${TOOL_GLOBS[@]}"; do
  printf '%s\n' "${_glob//\*/x}" >> "$SYNTH"
done

CONTRACT_COUNT=${#CONTRACT_GLOBS[@]}
TOOL_COUNT=${#TOOL_GLOBS[@]}
if [ -n "$extraction_errors" ]; then
  printf 'FAIL  %-44s could not read %sfrom %s; each array opens with NAME=( alone, one quoted entry per line, closing paren on its own line\n' \
    "every review glob is live on trunk" "$extraction_errors" "$HOOK"
  FAIL=$((FAIL+1))
elif [ -z "$TRUNK_REF" ]; then
  # A skip, not a pass: this run has no verdict on glob liveness. See the SKIP counter's note
  # at the head of the file — counting this as a pass let a shallow checkout print a full pass
  # while the only check that detects a dead glob never ran.
  printf 'skip  %-44s no trunk ref here (tried origin/main origin/master main master); this check reads the trunk tree, never the checkout\n' \
    "every review glob is live on trunk"
  SKIP=$((SKIP+1))
else
  dead_globs="$(glob_coverage_failures "$TRACKED" CONTRACT_GLOBS "${CONTRACT_GLOBS[@]}"
                glob_coverage_failures "$TRACKED" TOOL_GLOBS "${TOOL_GLOBS[@]}")"
  if [ "$CONTRACT_COUNT" -ge 3 ] && [ "$TOOL_COUNT" -ge 3 ] && [ -z "$dead_globs" ]; then
    printf 'ok    %-44s %s contract + %s tool globs, each live in %s\n' \
      "every review glob is live on trunk" "$CONTRACT_COUNT" "$TOOL_COUNT" "$TRUNK_REF"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s %s contract + %s tool entries read, dead in %s: %s\n' \
      "every review glob is live on trunk" "$CONTRACT_COUNT" "$TOOL_COUNT" "$TRUNK_REF" "${dead_globs:-none}"
    FAIL=$((FAIL+1))
  fi
fi

# The refusal, run rather than described: the same check over the same entries plus one
# deliberately dead glob per array must name both, each with its array, and nothing else.
DEAD_CONTRACT='benchmark/renamed-away/*.yaml'
DEAD_TOOL='tools/renamed-away/*.sh'
injected_dead="$(glob_coverage_failures "$SYNTH" CONTRACT_GLOBS "${CONTRACT_GLOBS[@]}" "$DEAD_CONTRACT"
                 glob_coverage_failures "$SYNTH" TOOL_GLOBS "${TOOL_GLOBS[@]}" "$DEAD_TOOL")"
want_dead="CONTRACT_GLOBS $DEAD_CONTRACT
TOOL_GLOBS $DEAD_TOOL"
if [ "$injected_dead" = "$want_dead" ]; then
  printf 'ok    %-44s both dead entries named, with their arrays\n' "a dead glob is caught"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s reported: %s (want exactly: %s)\n' \
    "a dead glob is caught" "${injected_dead:-nothing}" "$want_dead"
  FAIL=$((FAIL+1))
fi

# The other direction, and the reason the list is pinned to a ref at all: a file that is on
# trunk but not in THIS checkout — deleted or renamed on the branch under test, never fetched
# into a sparse clone — must NOT make its glob look dead. The two lists here differ by exactly
# one file. The same glob is live against the first and dead against the second, so the choice
# of list IS the bug, and it is exercised rather than asserted in a comment.
BRANCH_LIST="$WORK/branch-missing-a-file"
absent_glob="${CONTRACT_GLOBS[0]}"
grep -Fxv -- "${absent_glob//\*/x}" "$SYNTH" > "$BRANCH_LIST" || true
still_live="$(glob_coverage_failures "$SYNTH" CONTRACT_GLOBS "$absent_glob")"
looks_dead="$(glob_coverage_failures "$BRANCH_LIST" CONTRACT_GLOBS "$absent_glob")"
if [ -z "$still_live" ] && [ "$looks_dead" = "CONTRACT_GLOBS $absent_glob" ]; then
  printf 'ok    %-44s %s live on trunk, dead only where the file is missing\n' \
    "a branch-missing file is not a dead glob" "$absent_glob"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s trunk list said [%s], branch list said [%s] (want [] and [CONTRACT_GLOBS %s])\n' \
    "a branch-missing file is not a dead glob" "$still_live" "$looks_dead" "$absent_glob"
  FAIL=$((FAIL+1))
fi

# The refusal for the reader itself, since a reader that mis-reads the hook fails every case
# above for the wrong reason. A well-formed array must come back as exactly its entries, and
# each of the three malformations the old line-range reader swallowed must be refused: a
# closing paren that never arrives (it used to read to end of file, or to the NEXT array's
# paren), entries carried inline on the opener, and an entry left unquoted.
MALFORMED_DIR="$WORK/glob-array-shapes"; mkdir -p "$MALFORMED_DIR"
printf "G=(\n  'a/*.yaml'\n  'b/*.yaml'\n)\nH=(\n  'c/*.sh'\n)\n"  > "$MALFORMED_DIR/wellformed"
printf "G=(\n  'a/*.yaml'\n  'b/*.yaml'\nH=(\n  'c/*.sh'\n)\n"     > "$MALFORMED_DIR/unclosed"
printf "G=('a/*.yaml' 'b/*.yaml')\n"                               > "$MALFORMED_DIR/inline"
printf "G=(\n  a/*.yaml\n)\n"                                      > "$MALFORMED_DIR/unquoted"
want_entries='a/*.yaml
b/*.yaml'
got_entries="$(extract_glob_array "$MALFORMED_DIR/wellformed" G 2>/dev/null || echo REFUSED)"
refused=''
for _shape in unclosed inline unquoted; do
  extract_glob_array "$MALFORMED_DIR/$_shape" G >/dev/null 2>&1 && refused="${refused}${_shape}-was-accepted "
done
if [ "$got_entries" = "$want_entries" ] && [ -z "$refused" ]; then
  printf 'ok    %-44s 2 entries read; unclosed, inline and unquoted all refused\n' \
    "a malformed glob array is refused"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s well-formed read as [%s]; accepted anyway: %s\n' \
    "a malformed glob array is refused" "$got_entries" "${refused:-none}"
  FAIL=$((FAIL+1))
fi

# --- ...and a glob REMOVED from either array is named too
#
# The half the two cases above cannot reach, and the likelier accident of the two: a refactor
# tidies `experiments/*.md` out of CONTRACT_GLOBS, every remaining entry is still live, the
# injected dead ones are still caught, the suite exits 0 green — and from that push on an
# experiment record leaving the machine is reviewed by nobody, in exactly the silence this
# whole section exists to break.
#
# So the required scope is RESTATED here, deliberately, and it is the only thing in this
# section that is. That is not a lapse from the read-it-from-the-hook rule above, it is the
# reason the rule cannot do this job: a check derived from the hook cannot notice the hook
# losing an entry, because the expectation moves with it. Pinning the scope by name is what
# makes a removal FAIL, and fail naming the glob and the array it left.
# ADDING a glob does not fail this — additions are covered by the liveness case above — so
# widening the review scope stays a one-file change, while narrowing it has to come here and
# say so. That asymmetry is the point: scope may grow quietly, never shrink quietly.
REQUIRED_CONTRACT_GLOBS=('benchmark/rubrics/*.yaml' 'templates/*.yaml' 'experiments/*.md')
REQUIRED_TOOL_GLOBS=('tools/*.sh' 'tools/*.py' '.claude/hooks/*.sh')

missing_required_globs() {  # <array-name> <required-newline-list> <present-newline-list>
  local array="$1" required="$2" present="$3" glob
  while IFS= read -r glob; do
    [ -n "$glob" ] || continue
    printf '%s\n' "$present" | grep -Fxq -- "$glob" || printf '%s %s\n' "$array" "$glob"
  done <<< "$required"
}

missing_globs="$(missing_required_globs CONTRACT_GLOBS \
                   "$(printf '%s\n' "${REQUIRED_CONTRACT_GLOBS[@]}")" \
                   "$(printf '%s\n' "${CONTRACT_GLOBS[@]}")"
                 missing_required_globs TOOL_GLOBS \
                   "$(printf '%s\n' "${REQUIRED_TOOL_GLOBS[@]}")" \
                   "$(printf '%s\n' "${TOOL_GLOBS[@]}")")"
if [ -z "$missing_globs" ]; then
  printf 'ok    %-44s %s contract + %s tool globs still in the hook\n' \
    "no required review glob was removed" \
    "${#REQUIRED_CONTRACT_GLOBS[@]}" "${#REQUIRED_TOOL_GLOBS[@]}"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s no longer in the hook: %s\n' \
    "no required review glob was removed" "$missing_globs"
  FAIL=$((FAIL+1))
fi

# The refusal, run rather than described, exactly as above: the same check against arrays with
# one entry taken out of each must name both, with their arrays, and nothing else.
GONE_CONTRACT='experiments/*.md'
GONE_TOOL='tools/*.py'
injected_missing="$(missing_required_globs CONTRACT_GLOBS \
                      "$(printf '%s\n' "${REQUIRED_CONTRACT_GLOBS[@]}")" \
                      "$(printf '%s\n' "${CONTRACT_GLOBS[@]}" | grep -Fxv -- "$GONE_CONTRACT")"
                    missing_required_globs TOOL_GLOBS \
                      "$(printf '%s\n' "${REQUIRED_TOOL_GLOBS[@]}")" \
                      "$(printf '%s\n' "${TOOL_GLOBS[@]}" | grep -Fxv -- "$GONE_TOOL")")"
want_missing="CONTRACT_GLOBS $GONE_CONTRACT
TOOL_GLOBS $GONE_TOOL"
if [ "$injected_missing" = "$want_missing" ]; then
  printf 'ok    %-44s both removals named, with their arrays\n' "a removed glob is caught"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s reported: %s (want exactly: %s)\n' \
    "a removed glob is caught" "${injected_missing:-nothing}" "$want_missing"
  FAIL=$((FAIL+1))
fi

# --- THE THREE DOORS THAT USED TO CLOSE IN SILENCE (2026-09-23)
#
# Each is a path where the hook cannot do its job: no `jq` to read the tool call, no merge
# base with origin/main to list the branch's changes, no executable reviewer to send them to.
# Each exited 0 with nothing on stderr, which reads from the outside exactly like "that push
# had nothing to review" — so a developer records "rubric reviewed on push" against an
# artifact the critic never saw. The hook now prints one line per door; these three cases are
# what keeps it printing. They assert the NOTICE, not just exit 0 and zero calls: the old
# behaviour already satisfied both of those, which is why the suite was green while all three
# doors were shut.
#
# The substring each case looks for is a FIXED STRING containing the thing that went
# unreviewed — `origin/main`, `jq`, `tools/opencode-review.sh` — so a notice that stops naming
# it fails here rather than passing on a generic word like "skipping".
#
# STDERR AND STDOUT ARE SEPARATED HERE, unlike run() and run_silent() which merge them. A
# hook's stdout goes back to Claude Code as tool output; stderr is where a notice belongs and
# what the step requires. Merging the two would let a notice moved to stdout keep passing,
# which is the same class of under-assertion as matching on a flattened argv.
run_announcing() {  # run_announcing <name> <root> <path> <stdin-json> <want-calls> <must-say>
  local name="$1" root="$2" path="$3" payload="$4" want_calls="$5" must_say="$6"
  : > "$CALLS"; : > "$ARGV"
  local errf="$WORK/announce-stderr"
  local out; out="$(printf '%s' "$payload" | env PATH="$path" \
      "$root/.claude/hooks/opencode-review.sh" 2>"$errf")"
  local got_exit=$?
  local got_calls; got_calls="$(wc -l < "$CALLS" | tr -d ' ')"
  local err; err="$(cat "$errf")"
  local said=no
  case "$err" in *"$must_say"*) said=yes ;; esac
  if [ "$got_exit" = 0 ] && [ "$got_calls" = "$want_calls" ] && [ "$said" = yes ] && [ -z "$out" ]; then
    printf 'ok    %-44s exit 0, %s call(s), named it on stderr\n' "$name" "$got_calls"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s (want 0), %s call(s) (want %s), on stderr: %s, stdout: %s\n' \
      "$name" "$got_exit" "$got_calls" "$want_calls" "$said" "${out:-<empty, as wanted>}"
    printf '        wanted to hear: %s\n' "$must_say"
    printf '        heard on stderr: %s\n' "${err:-<nothing>}"
    FAIL=$((FAIL+1))
  fi
}

# A pristine copy of the fixture, forced onto its own branch off the trunk with exactly one
# changed rubric on it. Off the trunk and force-cleaned because the cases above leave FIXTURE
# on whatever branch they last used, with whatever they last wrote still in the tree — a case
# that inherits that is not testing what its name says. One changed rubric because a door is
# only worth naming when a review was owed: each of the three copies has an artifact the
# critic should have seen.
prepare_copy() {  # prepare_copy <dir> <branch>
  local dir="$1" branch="$2"
  cp -R "$FIXTURE" "$dir" || return 1
  git -C "$dir" checkout -q -f -b "$branch" main || return 1
  git -C "$dir" clean -qfd || return 1
  echo 'version: 9' > "$dir/benchmark/rubrics/backend-quality.yaml" || return 1
  git -C "$dir" add -A >/dev/null || return 1
  git -C "$dir" commit -qm "a changed rubric on $branch" >/dev/null || return 1
}

# THE CONTROL FIRST, because a notice is only worth anything where a review was OWED. With all
# three doors open, this same preparation reviews one artifact and says so. Without this case
# the three below could each be firing over a copy where nothing reviewable changed at all —
# a true notice about an empty change set, which would prove nothing and read identically.
CONTROL="$WORK/repo-control"
if ! prepare_copy "$CONTROL" control; then
  printf 'skip  %-44s could not build a copy of the fixture (cp/git failed)\n' \
    "prepare_copy leaves a review owed"
  SKIP=$((SKIP+1))
else
  run_announcing "prepare_copy leaves a review owed" "$CONTROL" "$STUB:$PATH" "$PUSH" 1 \
    "reviewing 1 of 1 changed artifact(s)"
fi

# (a) no merge base with origin/main. The ref is deleted from the copy, which is what a fork
# with a `master` default, an unfetched remote or a renamed default branch looks like here.
NOTRUNK="$WORK/repo-notrunk"
if ! prepare_copy "$NOTRUNK" notrunk || ! git -C "$NOTRUNK" update-ref -d refs/remotes/origin/main; then
  printf 'skip  %-44s could not build a trunkless copy of the fixture (cp/git failed)\n' \
    "no trunk ref is named, not silent"
  SKIP=$((SKIP+1))
else
  run_announcing "no trunk ref is named, not silent" "$NOTRUNK" "$STUB:$PATH" "$PUSH" 0 \
    "NOT REVIEWED — git merge-base HEAD origin/main found nothing"
fi

# (b) no jq. A PATH holding only what the hook needs MINUS jq — and the opencode stub, so the
# case turns on jq alone and cannot pass by tripping the opencode gate instead. If any of
# those binaries cannot be linked, or jq is somehow still resolvable there, this case did not
# run: that is a SKIP, not a pass.
NOJQBIN="$WORK/nojqbin"; mkdir -p "$NOJQBIN"
nojq_missing=""
for t in bash env git cat dirname; do
  src="$(command -v "$t" 2>/dev/null)" || { nojq_missing="$nojq_missing $t"; continue; }
  ln -sf "$src" "$NOJQBIN/$t" || nojq_missing="$nojq_missing $t"
done
ln -sf "$STUB/opencode" "$NOJQBIN/opencode" || nojq_missing="$nojq_missing opencode"
NOJQ="$WORK/repo-nojq"
if [ -n "$nojq_missing" ]; then
  printf 'skip  %-44s could not build a jq-less PATH; missing:%s\n' \
    "no jq is named, not silent" "$nojq_missing"
  SKIP=$((SKIP+1))
elif ( PATH="$NOJQBIN"; command -v jq >/dev/null 2>&1 ); then
  printf 'skip  %-44s jq is still resolvable on the jq-less PATH; the case would pass for the wrong reason\n' \
    "no jq is named, not silent"
  SKIP=$((SKIP+1))
elif ! prepare_copy "$NOJQ" nojq; then
  printf 'skip  %-44s could not build a copy of the fixture (cp/git failed)\n' \
    "no jq is named, not silent"
  SKIP=$((SKIP+1))
else
  run_announcing "no jq is named, not silent" "$NOJQ" "$NOJQBIN" "$PUSH" 0 \
    "NOT REVIEWED — jq is not installed"
fi

# (c) no executable reviewer. The stub is left in place and stripped of its executable bit,
# so this is a missing REVIEWER and not a deleted artifact — the two are different events and
# the hook has a different notice for each.
NOREVIEWER="$WORK/repo-noreviewer"
if ! prepare_copy "$NOREVIEWER" noreviewer || ! chmod -x "$NOREVIEWER/tools/opencode-review.sh"; then
  printf 'skip  %-44s could not build a copy with a non-executable reviewer\n' \
    "a missing reviewer is named, not silent"
  SKIP=$((SKIP+1))
else
  run_announcing "a missing reviewer is named, not silent" "$NOREVIEWER" "$STUB:$PATH" "$PUSH" 0 \
    "NOT REVIEWED — tools/opencode-review.sh is missing or not executable"
fi

echo
# The tail line names all three outcomes, always, so a reader never has to infer a skip from
# a total. RAN is PASS+FAIL: a skipped case did not run and is not part of what this run
# verified, which is why the guard below compares RAN — not RAN+SKIP — against EXPECTED_CASES.
RAN=$((PASS+FAIL))
printf 'opencode-review.test: %s passed, %s failed, %s skipped.\n' "$PASS" "$FAIL" "$SKIP"
if [ "$RAN" -ne "$EXPECTED_CASES" ]; then
  echo "opencode-review.test: ran ${RAN} of ${EXPECTED_CASES} cases." >&2
  if [ "$SKIP" -gt 0 ]; then
    echo "  ${SKIP} case(s) were SKIPPED — each printed 'skip' with its name and its reason above." >&2
    echo "  A skip is not a pass. This run verified less than the suite claims to verify, so it" >&2
    echo "  is NOT a complete pass, whatever the other cases did. Re-run it where the skipped" >&2
    echo "  case can execute (the trunk-liveness case needs a checkout with a trunk ref) before" >&2
    echo "  treating the hook as covered." >&2
  else
    echo "  A case was added or lost without updating EXPECTED_CASES. Fix the count or find the" >&2
    echo "  missing case; a shrinking suite that still exits 0 is indistinguishable from a pass." >&2
  fi
  exit 1
fi
if [ "$FAIL" -eq 0 ]; then
  echo "opencode-review.test: all ${PASS} cases ran and behaved as specified."
  exit 0
fi
echo "opencode-review.test: ${FAIL} of ${RAN} cases misbehaved." >&2
exit 1
