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
run "git pushd is not a push"     '{"tool_name":"Bash","tool_input":{"command":"pushd /tmp"}}'  0 0
run "gh pr view is not create"    '{"tool_name":"Bash","tool_input":{"command":"gh pr view 3"}}' 0 0

# --- the case the hook exists for
run "push with a changed rubric"  "$PUSH" 0 1
run "gh pr create, changed rubric" "$PR"  0 1

# and it must pass the artifact, not just fire
if grep -q 'benchmark/rubrics/backend-quality.yaml' "$CALLS" 2>/dev/null; then
  printf 'ok    %-44s argv carries the artifact\n' "reviewer argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s argv was: %s\n' "reviewer argv" "$(cat "$CALLS" 2>/dev/null)"; FAIL=$((FAIL+1))
fi

# --- a changed file outside the contract globs is not worth a model call
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
