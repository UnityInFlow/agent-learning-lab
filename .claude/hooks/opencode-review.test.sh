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
CALLS="$WORK/reviewer-calls"

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
cat > "$FIXTURE/tools/opencode-review.sh" <<STUBSH
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$CALLS"
exit \${STUB_REVIEWER_EXIT:-0}
STUBSH
chmod +x "$FIXTURE/tools/opencode-review.sh"

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

PASS=0; FAIL=0
run() {  # run <name> <stdin-json> <expect-exit> <expect-calls> [env=val ...]
  local name="$1" payload="$2" want_exit="$3" want_calls="$4"; shift 4
  : > "$CALLS"
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

# and it must pass the artifact, not just fire
if grep -q 'benchmark/rubrics/backend-quality.yaml' "$CALLS" 2>/dev/null; then
  printf 'ok    %-44s argv carries the artifact\n' "reviewer argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "reviewer argv" "$(cat "$CALLS" 2>/dev/null)"; FAIL=$((FAIL+1))
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
if grep -q 'tools/check-something.sh' "$CALLS" 2>/dev/null; then
  printf 'ok    %-44s argv carries the tool\n' "tool argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "tool argv" "$(cat "$CALLS" 2>/dev/null)"; FAIL=$((FAIL+1))
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
: > "$CALLS"
out="$(printf '%s' "$PUSH" | env LAB_REVIEW_MAX_ARTIFACTS=2 PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$CALLS" 2>/dev/null)"
# EVERY dropped path, by name — not "some tools/t- appeared". The guarantee in the hook is
# "every dropped file is named", and an assertion that only greps for one of them passes a
# regression that prints the first and stops, which is the same class of under-reporting the
# notice exists to prevent. The full expected set is spelled out, and the ranked total is
# asserted too, so a file falling out of scope entirely cannot hide as a smaller denominator.
# Ranked order on this branch, contracts first then tools, each in git's path order:
#   benchmark/rubrics/r.yaml, templates/run-record.yaml,
#   tools/check-something.sh, tools/t-a.sh, tools/t-b.sh, tools/t-c.sh, tools/t-d.sh
missing=""
for f in tools/check-something.sh tools/t-a.sh tools/t-b.sh tools/t-c.sh tools/t-d.sh; do
  printf '%s' "$out" | grep -q "$f" || missing="$missing $f"
done
leaked=""
for f in tools/check-something.sh tools/t-a.sh tools/t-b.sh tools/t-c.sh tools/t-d.sh; do
  printf '%s' "$argv" | grep -q "$f" && leaked="$leaked $f"
done
if printf '%s' "$out" | grep -q 'PARTIAL REVIEW — 2 of 7' \
   && [ -z "$missing" ] && [ -z "$leaked" ] \
   && printf '%s' "$argv" | grep -q 'benchmark/rubrics/r.yaml' \
   && printf '%s' "$argv" | grep -q 'templates/run-record.yaml'; then
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
if grep -q 'tools/render-spine-status.py' "$CALLS" 2>/dev/null; then
  printf 'ok    %-44s argv carries the Python tool\n' "python tool argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "python tool argv" "$(cat "$CALLS" 2>/dev/null)"; FAIL=$((FAIL+1))
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
: > "$CALLS"
out="$(printf '%s' "$PUSH" | env PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
calls="$(wc -l < "$CALLS" | tr -d ' ')"
if printf '%s' "$out" | grep -q 'REMOVED' \
   && printf '%s' "$out" | grep -q 'benchmark/rubrics/registered.yaml' \
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
: > "$CALLS"
out="$(printf '%s' "$PUSH" | env PATH="$STUB:$PATH" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$CALLS" 2>/dev/null)"
if printf '%s' "$out" | grep -q 'REMOVED' \
   && printf '%s' "$out" | grep -q 'benchmark/rubrics/registered.yaml' \
   && printf '%s' "$argv" | grep -q 'tools/still-here.sh' \
   && ! printf '%s' "$argv" | grep -q 'registered.yaml'; then
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
: > "$CALLS"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$CALLS" 2>/dev/null)"
if printf '%s' "$out" | grep -q "panel reduced to 'deepseek-v4-pro'" \
   && printf '%s' "$out" | grep -q 'ONE-harness review' \
   && printf '%s' "$argv" | grep -q -- '-P deepseek-v4-pro '; then
  printf 'ok    %-44s panel reduced and announced\n' "codex missing degrades the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "codex missing degrades the panel" "$out" "$argv"; FAIL=$((FAIL+1))
fi

printf '#!/usr/bin/env bash\nexit 0\n' > "$PANELBIN/codex"; chmod +x "$PANELBIN/codex"
: > "$CALLS"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
argv="$(cat "$CALLS" 2>/dev/null)"
if ! printf '%s' "$out" | grep -q 'panel reduced' \
   && printf '%s' "$argv" | grep -q -- '-P deepseek-v4-pro,codex '; then
  printf 'ok    %-44s full panel, no reduction notice\n' "codex present keeps the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "codex present keeps the panel" "$out" "$argv"; FAIL=$((FAIL+1))
fi

run_bare_path() {  # same as run(), but with a PATH that contains no opencode at all
  local name="$1" payload="$2" want_exit="$3" want_calls="$4"
  : > "$CALLS"
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
run "empty stdin"                 ''                          0 0
run "not JSON"                    'not json at all'           0 0
run "JSON without a command"      '{"tool_name":"Bash"}'      0 0
run "JSON, wrong shape"           '{"tool_input":"a string"}' 0 0

echo
if [ "$FAIL" -eq 0 ]; then
  echo "opencode-review.test: all ${PASS} cases behaved as specified."
  exit 0
fi
echo "opencode-review.test: ${FAIL} of $((PASS+FAIL)) cases misbehaved." >&2
exit 1
