#!/usr/bin/env bash
# Test the review hook with opencode, git and the reviewer all stubbed. No network, no
# tokens, no model calls — runnable in CI and before trusting the hook in a new repo.
#
#   ./.claude/hooks/opencode-review.test.sh
#
# Exit 0 if every case behaves, 1 otherwise. A hook that silently does nothing is worse than
# no hook, so the cases that assert the reviewer was NOT called matter as much as the ones
# that assert it was.
#
# THE MUTATION SWEEP OF 2026-09-24, recorded here because a case nobody has ever seen fail is
# a claim, not a test. Each mutant was applied to a COPY of the hook in a clone of this
# repository — the hook in the tree is byte-identical to the trunk's — and run twice: once
# against this file, once against the file as it stood on the trunk before these assertions
# existed. The second column is what the round-5 gaps cost.
#
#   mutant                                        this file          the file before it
#   `-n` dropped from the invocation .......... 7 cases fail ....... (count 4+N caught it)
#   `-n` SPLIT from its value, count unchanged . 7 cases fail ....... 69/69 GREEN — gap (a)
#   `runs=` hardcoded past LAB_REVIEW_RUNS ..... 1 case fails ....... n/a, no case existed
#   the reviewer fired TWICE on one push ...... all 5 blocks fail ... all 5 blocks GREEN
#   exit 1 after a completed review ........... 4 of 5 blocks fail .. all 5 blocks GREEN
#   exit 1 on the deletion-only path .......... deletion-only fails . all 5 blocks GREEN
#
# The split-flag row is the one to read twice: the argv element count was 5 before and after,
# so the suite's strongest existing assertion could not see it and every case passed. The
# three bottom rows are the five hand-written blocks, which asserted their notice and (some of
# them) their call count while never capturing the hook's exit status at all.
#
# THE THIRD SWEEP, 2026-09-24, step 31 — the first-token rule, six mutants of the HOOK, each
# applied to the committed file, run, and reverted with `git checkout --`. Both directions are
# here on purpose: a rule that is absent reviews a delegated push, and a rule that is too wide
# announces on `git status`. Only one of those is the bug this step fixed, and a suite that
# only tested the first would accept the second as a fix.
#
#   mutant of the hook                                   result
#   the `_local_push` gate never fires .......... 5 fail: every delegated shape is reviewed
#                                                 against this tree again — the defect itself.
#   the anchor dropped from `_local_trigger` .... the same 5. `ssh host 'git push'` has a
#                                                 segment CONTAINING `git push`; the claim is
#                                                 that it BEGINS with it.
#   the notice reduced to "NOT REVIEWED — a
#     push." .................................... the same 5, on their stderr string alone —
#                                                 the wording is load-bearing, and the
#                                                 corridor guard still passes, which is why
#                                                 these cases exist beside it.
#   the splitter made quote-unaware ............. 1: "a quoted && inside ssh still declines".
#                                                 The other four have no separator in them, so
#                                                 this is the only case that can see it.
#   a quote made to run to end of segment ....... 1: "a quoted separator keeps the push local"
#                                                 — the same splitter, failing the other way,
#                                                 and the way that stops real reviews.
#   the decline hoisted OUT of the trigger's
#     yes-branch ................................ 11, of which "a push token with no git stays
#                                                 silent" is the one written for it: `git
#                                                 status`, `pushd /tmp` and `grep push` all
#                                                 announce that their push could not be
#                                                 placed. A notice on every shell command is
#                                                 how a real notice stops being read.
#
# THE FOURTH SWEEP, 2026-09-24, round 1 of step 31's OWN review — five mutants, each applied
# to the committed file, run, reverted with `git checkout --`. Three fixes, two directions
# each where a direction exists.
#
#   mutant                                             result
#   `_unreadable_tok` back to `$(`-only ....... 1: "a $VAR push form is declined, not
#                                               silent". `git $GIT_OPTS push` leaves through
#                                               the SILENT exit again — the defect itself.
#   the relocation gate never fires ........... 1: "cd elsewhere then push declines". `cd
#                                               /other && git push` is reviewed against this
#                                               tree again.
#   the relocation gate widened by one word
#     (`make` added to the set) ............... 1: "a compound git push counts". The other
#                                               direction, and the one that matters more:
#                                               a gate that declines `make lint && git push`
#                                               stops reviewing the ordinary local push, and
#                                               a suite testing only the first direction
#                                               would accept it as a fix.
#   the liveness matcher's depth guard
#     removed ................................. 1: "a glob whose files moved deeper is dead"
#                                               — 0 of 6 globs reported dead, which is the
#                                               check agreeing with a hook that selects
#                                               nothing.
#   the two unresolved reasons collapsed
#     into one ................................ 1: "an unexpandable -C says so, not 'wrong
#                                               dir'".
#
# THE FIFTH SWEEP, 2026-09-24, round 2 of step 31's own review — two mutants of the HOOK, one
# per direction of the same rule, each applied to the committed file, run, and reverted with
# `git checkout --`. The rule is "a push this hook can place does not END the scan; only one it
# cannot does", and it has exactly two ways to be wrong.
#
#   mutant                                             result
#   the `break` restored on the PLACEABLE
#     push ...................................... 1: "a cd and a SECOND push after a local one
#                                               declines" — and it fails by REVIEWING (1
#                                               reviewer call, nothing on stderr), which is
#                                               the defect itself rather than a near miss:
#                                               `git push && cd /other && git push` earns a
#                                               `reviewing N artifact(s)` trace from the first
#                                               push while the second runs in the sibling
#                                               repository, unreviewed and unannounced.
#   the relocation gate made order-blind (a
#     relocating token ANYWHERE on the line
#     counts) ................................... 1: "cd AFTER the push still reviews" — 0
#                                               reviewer calls where 1 was wanted. The other
#                                               direction, and the one that costs reviews: a
#                                               fix that declined on any `cd` in the command
#                                               would pass the new case and stop reviewing the
#                                               ordinary `git push && cd ..`.
#
# NEITHER MUTANT MOVES THE OTHER'S CASE, which is what makes this a pair rather than two
# spellings of one assertion.
#
#
# THE SECOND SWEEP, 2026-09-24, review round 1 of step 30. These three mutants are of THIS
# FILE, not of the hook: the first round of review found the suite's own instruments — its
# array reader, its tail guard, its exit classifier — each claiming a scope wider than it
# checked. Each mutant was applied to a copy of this file beside it, run, and removed.
#
#   mutant of this file                                  result
#   opener back to `$0 == name "=("` ............ 1 case fails: "an indented glob array is
#                                                 still read" reads REFUSED. Nothing else
#                                                 moves — which is what the false "could not
#                                                 read the hook" failure looked like.
#   an undeclared, always-skipping case added ... with the TOTAL guard: exit 1, "75 cases
#                                                 exist … EXPECTED_CASES is 74". With the
#                                                 guard removed: exit 0, "all 74 cases ran
#                                                 and behaved as specified", one case
#                                                 skipped. The false sentence, produced.
#   classifier back to `exit 0` only ............ 1 case fails: the `return 0` shape comes
#                                                 back "<not seen at all>" — not
#                                                 UNCLASSIFIED, ABSENT, which is why the
#                                                 count check could not notice it either.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
HOOK=".claude/hooks/opencode-review.sh"
[ -x "$HOOK" ] || { echo "not executable: $HOOK" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STUB="$WORK/bin"; mkdir -p "$STUB"
CALLS="$WORK/reviewer-calls"   # one line per INVOCATION — this is what the call count reads
ARGV="$WORK/reviewer-argv"     # one line per ARGUMENT — this is what the argv assertions read
# run_announcing's stderr capture, named here rather than inside the runner so a case that
# needs MORE than one notice — every dropped path by name, a deleted path beside a reviewed
# one — can route exit status and call count through the runner and still read the same
# stderr afterwards, instead of re-running the hook in a block of its own.
ANNOUNCE_ERR="$WORK/announce-stderr"

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
#
# THAT COMPARISON IS NECESSARY AND IS NOT SUFFICIENT, which round 1 of step 30's review found
# and the tail now fixes. "A skipped case fails that comparison" holds only while
# EXPECTED_CASES already counts the skipped case. Add a NEW skip-capable case without bumping
# the count and, in the environment where it skips, PASS+FAIL is exactly EXPECTED_CASES again:
# green, with the tail claiming every case ran. So the tail compares TWICE — PASS+FAIL against
# the declared count, and PASS+FAIL+SKIP against it as well — because "did everything run?"
# and "is every case that exists declared?" are two questions and the second one is how an
# undeclared case hides.
# 69 → 73 on 2026-09-24 (round 5): one new case for the `-n` override, and three hand-written
# blocks that each became TWO counted cases when their exit status and call count moved into
# run_announcing — "it announced" and "it named the file" are separate claims that fail for
# separate reasons, and a block asserting both under one name can only report the first thing
# that broke.
# 73 → 74 on 2026-09-24 (step 30, review round 1): the indented-but-well-formed glob array,
# the shape the reader's own contract promised to accept and the only shape none of the three
# malformed fixtures could have caught.
# 74 → 81 on 2026-09-24 (step 31): the first-token rule. Four delegated shapes that used to be
# reviewed against this tree (`ssh`, `bash -c`, `eval`, `sudo`), the quote-aware split in both
# directions, and the guard that the new notice did not widen into every command carrying the
# word `push`.
# 81 → 86 on 2026-09-24 (step 31, review round 1): plain `$VAR` before the push token, the
# relocation gate in both directions, the `-C` whose directory is an unexpandable expansion,
# and the glob-liveness matcher's depth guard.
# 86 → 87 on 2026-09-24 (step 31, review round 2): the command line carrying TWO pushes with a
# `cd` between them. The trail above stopped at 81 while the count was 86 — the round-1
# reviewer read that as stale prose rather than a defect, correctly, because the tail guard
# holds the count to the code; it is completed here so the next reader does not have to.
EXPECTED_CASES=87
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

# THE RUNNER FOR "IT REVIEWED, AND IT REVIEWED THIS", added 2026-09-23 after round 4.
#
# run() asserts the hook's exit status and the reviewer's CALL COUNT. It cannot see WHAT the
# reviewer was handed, and six cases asserting the round-3 trigger shapes were green on
# exactly that blindness: one of them named `/srv/mono/.git/`, a path this fixture does not
# contain, and passed because the stub is invoked against the fixture whatever the payload
# says. The case could observe "does this shape match the trigger?" and nothing else, while
# reading — to anyone scanning the file — as proof that such a push is reviewed end to end.
# A green case over a behaviour the suite cannot see is the failure this project names most
# often, and it was sitting inside the test that exists to catch it.
#
# So this runner asserts the ARTIFACT SET. Each expected path must appear as its own WHOLE
# argv line, and the argv must be exactly `-n N -P panel` plus those paths — four flag
# elements plus one per artifact. The COUNT is what makes it "exactly these": a whole-line
# grep alone cannot see an extra artifact that also arrived, and an extra artifact is how a
# review of the wrong tree would look from here.
# THE `-n` HALF OF THE ARGV CONTRACT LIVES HERE, added 2026-09-24 after round 5.
#
# The preamble above states the invocation as `-n N -P panel "${artifacts[@]}"`, and until
# now only `-P` was ever checked — at the two panel blocks, and nowhere else. So a hook that
# dropped `-n "$runs"` entirely, or split the flag from its value, passed every case in this
# file on exactly the dimension the preamble says is the contract: the element count 4+N was
# the only thing standing near it, and a two-element `-P panel` plus two artifacts counts the
# same as `-n 1 -P panel` plus one. Folding the assertion into this runner rather than into
# one new case is what makes it cover ground: every run_reviewing case now enforces
# flag/value ADJACENCY for `-n` too, on every trigger shape it already exercises.
#
# `--runs N` drives the override AND the expectation from one number, so a case cannot assert
# a value it did not ask the hook for. Without it the runner passes no LAB_REVIEW_RUNS at all
# and wants `-n 1` — the hook's own default, which is the thing worth testing by default and
# which an always-exported override would hide.
run_reviewing() {  # run_reviewing [--runs N] <name> <stdin-json> <artifact>... — exit 0, one call, exactly these
  local want_runs=1 runs_env=()
  if [ "${1:-}" = --runs ]; then want_runs="$2"; runs_env=("LAB_REVIEW_RUNS=$2"); shift 2; fi
  local name="$1" payload="$2"; shift 2
  : > "$CALLS"; : > "$ARGV"
  local out; out="$(printf '%s' "$payload" | env ${runs_env[@]+"${runs_env[@]}"} PATH="$STUB:$PATH" \
      "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
  local got_exit=$?
  local got_calls; got_calls="$(wc -l < "$CALLS" | tr -d ' ')"
  local got_args; got_args="$(wc -l < "$ARGV" | tr -d ' ')"
  local want_args=$((4 + $#))
  local missing='' a
  for a in "$@"; do grep -Fxq -- "$a" "$ARGV" || missing="$missing $a"; done
  local n_adjacent=no
  argv_has_flag_value "$ARGV" -n "$want_runs" && n_adjacent=yes
  if [ "$got_exit" = 0 ] && [ "$got_calls" = 1 ] && [ -z "$missing" ] && [ "$got_args" = "$want_args" ] \
     && [ "$n_adjacent" = yes ]; then
    printf 'ok    %-44s reviewed exactly %s artifact(s) at -n %s: %s\n' "$name" "$#" "$want_runs" "$*"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s (want 0), %s call(s) (want 1), %s argv element(s) (want %s), -n %s adjacent: %s, not handed over:%s\n' \
      "$name" "$got_exit" "$got_calls" "$got_args" "$want_args" "$want_runs" "$n_adjacent" "${missing:-none}"
    [ -n "$out" ] && printf '        %s\n' "$out"
    printf '        argv was: %s\n' "$(tr '\n' ' ' < "$ARGV")"
    FAIL=$((FAIL+1))
  fi
}

# The third runner: a case that must SAY something. It lives here with the other three
# rather than beside its first user, because it has users in three places — the pushes aimed
# at another tree just below, the malformed payload further down, and the environment doors
# at the end of the file.
#
# STDERR AND STDOUT ARE SEPARATED HERE, unlike run() and run_silent() which merge them. A
# hook's stdout goes back to Claude Code as tool output; stderr is where a notice belongs and
# what the step requires. Merging the two would let a notice moved to stdout keep passing,
# which is the same class of under-assertion as matching on a flattened argv.
#
# THE SEVENTH ARGUMENT IS A STDIN MODE, not a second runner. `unreadable` hands the hook an
# fd 0 that is open for WRITING (`0>/dev/null`), which is the one way to make `cat` fail
# deterministically without ever blocking: a closed fd 0 gets reopened somewhere up the chain
# on this platform, and a directory on fd 0 can hang. Everything the runner asserts — exit 0,
# the call count, the notice on stderr, an empty stdout — is asserted identically in both
# modes, which is the point of putting it here instead of in a sixth bespoke block.
run_announcing() {  # run_announcing <name> <root> <path> <stdin-json> <want-calls> <must-say> [pipe|unreadable]
  local name="$1" root="$2" path="$3" payload="$4" want_calls="$5" must_say="$6"
  local stdin_mode="${7:-pipe}"
  : > "$CALLS"; : > "$ARGV"
  local errf="$ANNOUNCE_ERR"
  local out
  if [ "$stdin_mode" = unreadable ]; then
    out="$(env PATH="$path" "$root/.claude/hooks/opencode-review.sh" 2>"$errf" 0>/dev/null)"
  else
    out="$(printf '%s' "$payload" | env PATH="$path" \
      "$root/.claude/hooks/opencode-review.sh" 2>"$errf")"
  fi
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

# THE FOURTH RUNNER, hoisted here 2026-09-24 from beside the malformed-payload cases further
# down. It asserts what run() cannot: that the hook produced NO OUTPUT AT ALL. run() captures
# the merged streams and prints them only on failure, so a case asserting "exit 0, 0 reviewer
# calls" passes just as happily when the hook has printed a notice. That blindness was
# harmless while every non-push command left through one silent exit; it stops being harmless
# the moment a second, ANNOUNCING branch sits next to it, because then "said nothing" is the
# only thing separating `git status` from a spurious notice on every shell command.
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

PUSH='{"tool_name":"Bash","tool_input":{"command":"git push -u origin feature"}}'
PR='{"tool_name":"Bash","tool_input":{"command":"gh pr create --title x"}}'

# --- nothing changed yet: matching command, but no artifact on the branch
run "push, no changes"            "$PUSH" 0 0
run "gh pr create, no changes"    "$PR"   0 0

# --- non-matching commands must not spawn a review even when an artifact HAS changed
git -C "$FIXTURE" checkout -q -b feature
echo 'version: 1' > "$FIXTURE/benchmark/rubrics/backend-quality.yaml"
git -C "$FIXTURE" add -A >/dev/null; git -C "$FIXTURE" commit -qm rubric

# THESE ASSERT SILENCE, NOT JUST THE ABSENCE OF A REVIEW, and the change from run() to
# run_silent() on 2026-09-24 is the guard on the new announcing branch rather than a tidy-up.
# The three-way classification's whole risk is that it trades a silent miss for a notice on
# every shell command a developer runs; under run() that trade would have been invisible here,
# because run() asserts exit status and reviewer call count and prints the output only when a
# case has already failed. Every one of these is an ESTABLISHED non-push and must say nothing.
run_silent "git status is not a push"    '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
run_silent "pushd is not a push"         '{"tool_name":"Bash","tool_input":{"command":"pushd /tmp"}}'
run_silent "gh pr view is not create"    '{"tool_name":"Bash","tool_input":{"command":"gh pr view 3"}}'
# The near misses. These pass trivially against a substring match only because they contain
# no `git push` at all; the two below DO contain it as a prefix of a longer command name, and
# a substring trigger fires on both.
run_silent "git pushdown is not a push"  '{"tool_name":"Bash","tool_input":{"command":"git pushdown origin"}}'
run_silent "gh pr created is not create" '{"tool_name":"Bash","tool_input":{"command":"gh pr created 3"}}'
# ...while a compound command still is one. A trigger tightened until it misses a real push
# is a worse bug than the one it fixed, so both directions are asserted.
run "a compound git push counts"  '{"tool_name":"Bash","tool_input":{"command":"make lint && git push"}}' 0 1
run "git push with a semicolon"   '{"tool_name":"Bash","tool_input":{"command":"git push; echo done"}}' 0 1

# A GLOBAL OPTION BETWEEN `git` AND `push` IS STILL A PUSH, and until 2026-09-23 none of these
# four matched: the trigger required `push` to follow `git` immediately, so each exited 0 in
# silence with no review and no notice. `git -C` is the ordinary form in submodule, monorepo
# and CI-script pushes, so the hook was quiet on a whole class of real ones while the suite
# was green — the near-miss cases above only ever tested token BOUNDARIES around `push`, never
# something standing between it and `git`, which is why nothing here caught it. Each of the
# four option SHAPES is its own case because they are different shapes, not one shape written
# four ways: a value in a separate argument (`-C <dir>`), a value attached with `=`
# (`--git-dir=…`), a long option with no value at all (`--no-pager`), and a short option whose
# value is itself `k=v` (`-c k=v`) — a trigger can accept one and miss the others.
# EACH OF THESE ASSERTS WHAT WAS REVIEWED, NOT JUST THAT SOMETHING WAS. Until round 4 they
# asserted a call count, which cannot tell a review of this branch from a review of some other
# tree that happened to be handed to the same stub — and one of them named a directory this
# fixture does not contain, so it could never have observed the difference. The artifact named
# here is the only reviewable file on this branch, so "exactly this one" is a real claim.
run_reviewing "git -C <dir> push counts"    '{"tool_name":"Bash","tool_input":{"command":"git -C . push origin main"}}' \
  'benchmark/rubrics/backend-quality.yaml'
run_reviewing "git -c k=v push counts"      '{"tool_name":"Bash","tool_input":{"command":"git -c user.name=x push"}}' \
  'benchmark/rubrics/backend-quality.yaml'
run_reviewing "git --no-pager push counts"  '{"tool_name":"Bash","tool_input":{"command":"git --no-pager push"}}' \
  'benchmark/rubrics/backend-quality.yaml'
run_reviewing "gh --repo … pr create counts" '{"tool_name":"Bash","tool_input":{"command":"gh --repo o/r pr create --title x"}}' \
  'benchmark/rubrics/backend-quality.yaml'
# THE `--git-dir=…` SHAPE HAS MOVED, and the move is the round-4 finding rather than a tidy-up.
# It used to live here as `run "git --git-dir=… push counts" … 0 1`, asserting that a push at
# `/srv/mono/.git/` produced one reviewer call — against THIS fixture, which contains no such
# path. The shape matching the trigger is worth asserting and is asserted still; what the hook
# then DOES with a directory it is not in is a decline, and both halves are exercised in
# "THE PUSH AIMED SOMEWHERE ELSE" further down, where the second fixture repository lives.
# (The trailing slash there remains load-bearing: written `--git-dir=/srv/mono/.git push` the
# command contains the literal `.git push`, which the pre-widening trigger matched for reasons
# that have nothing to do with option tolerance, and the case would pass before the fix and
# after it. A case that cannot fail is not a case.)
# ...and the boundary must survive the widening. This is the near miss ABOVE wearing a global
# option, and it is a PAIRED guard rather than a case with a mutation of its own: dropping the
# `([^[:alnum:]_-]|$)` after `push` fails it and `git pushdown is not a push` together, and
# every looser trigger tried against it fails that one too. Said plainly because a reader
# checking whether each case can fail alone will find that this one cannot, and should meet
# that here rather than conclude the suite is padded. It is kept for the direction it covers:
# the widening admitted options, and this is the assertion that it admitted only options.
run_silent "git -C . pushdown is not a push" '{"tool_name":"Bash","tool_input":{"command":"git -C . pushdown origin"}}'
# A subcommand is not an option, so the option run cannot skip one to reach a later `push`:
# `git commit -m push` is a commit whose message happens to be the word.
#
# THIS ONE CARRIES A PUSH TOKEN, which makes it the case that separates the two silent
# readings from each other. Under a naive third branch — "contains `push`, did not match the
# trigger, therefore announce" — this command announces, and so does every `git log
# --grep="fix push bug"` a developer runs. It stays silent because the hook READ its way past
# the token: `commit` is a plain word standing between `git` and `push` with nothing
# unreadable in front of it, so the token is that subcommand's argument and no review is owed.
# That is an establishment, and only an establishment may be silent.
run_silent "git commit -m push is not a push" '{"tool_name":"Bash","tool_input":{"command":"git commit -m push"}}'
# The same shape with the quoting that DOES defeat the recogniser, on the other side of the
# same boundary: a quoted message is read past (the lead token `commit` is a plain word), a
# quoted option VALUE is not (the lead token is `-C`). Kept adjacent so the boundary is one
# thing a reader can see rather than two cases in different sections.
run_silent "a quoted commit message stays silent" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"push the button\""}}'

# --- THE THIRD BRANCH (2026-09-24, round 5): UNRECOGNISED IS DECLINED, NOT DISCARDED
#
# Four review rounds each found one more command form the trigger could not read — `-C`, then
# `--git-dir`, then `--no-pager`, then a directory name containing a space — and each was
# fixed by teaching the regex that form. The fourth finding is the argument against the first
# three fixes: a regex reading a shell command line does not run out of forms, so a suite that
# enumerates them measures the author's imagination and calls it coverage.
#
# So the hook classifies THREE ways now, and these two cases are the third: a command carrying
# a push token that matches no recognised shape must SAY SO. The first is round 4's own
# finding, pinned so the behaviour cannot silently revert. The second is a form nobody has
# asked the hook to handle and nobody intends to — a directory arriving from command
# substitution — and it is here precisely because it is not special-cased anywhere: it must be
# announced by being unrecognised, which is the only claim that generalises past this file.
#
# BOTH ASSERT AN EMPTY STDOUT AND A NAMED NOTICE ON STDERR (run_announcing separates the two
# streams), and both assert ZERO reviewer calls — an announcement that also reviewed this tree
# would be the round-3 defect wearing a notice.
run_announcing "a quoted -C path is declined, not silent" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"git -C \"my repo\" push origin main"}}' 0 \
  "NOT REVIEWED — this command carries a push token"
run_announcing "an unrecognised push form is declined" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"git $(cat dir) push origin main"}}' 0 \
  "NOT REVIEWED — this command carries a push token"
# PLAIN PARAMETER EXPANSION, the one shell form neither the trigger nor this branch read until
# round 1 of step 31's review. `$GIT_OPTS` is not option-shaped, so the trigger never reaches
# `push`; it held no `$(`, so the unreadable-token language did not see it either; and the
# command left through the SILENT not-a-push exit. With `GIT_OPTS='-C ../other'` in the
# developer's shell that is a push to another tree, recorded as reviewed, in total silence.
# The case asserts the announcement, so reverting `_unreadable_tok` to `$(`-only fails it.
run_announcing "a \$VAR push form is declined, not silent" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"git $GIT_OPTS push origin main"}}' 0 \
  "NOT REVIEWED — this command carries a push token"

# --- THE PUSH THAT RUNS SOMEWHERE ELSE (2026-09-24, step 31): THE FIRST-TOKEN RULE
#
# The third branch above asks whether the hook can READ the command. These ask the other
# question nothing was asking: whether the push it read happens in the tree this hook stands
# in. `ssh build-host 'git push origin main'` matches the trigger — it always did, before any
# of the option widenings — so the hook diffed THIS checkout and announced `reviewing N
# artifact(s)` about a push executing on another machine. A false review trace is worse than
# silence: silence leaves the developer to look, a trace tells them someone already did.
#
# THE FOUR SHAPES ARE FOUR DIFFERENT PROGRAMS, not one written four ways, and that is the
# argument for the whitelist rather than against it: a remote shell, an interpreter taking the
# command as a `-c` argument, a builtin re-parsing a string, and a privilege wrapper that
# passes its argv straight through. A blacklist has to know all four and the fifth; the rule
# under test knows only `git` and `gh`, so the fifth declines without anyone naming it. The
# four appear in the hook exactly once, inside the notice, as EXAMPLES for the developer
# reading it — nothing branches on them, and mutant E below (the anchor dropped from
# `_local_trigger`) fails all four together, which is what a rule rather than a list looks
# like when it breaks.
#
# EACH ASSERTS ZERO REVIEWER CALLS AND A NOTICE ON STDERR, with an empty stdout, through the
# same runner as every other decline. A shape that announced AND reviewed would be the
# original defect wearing a notice.
run_announcing "ssh 'git push' declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"ssh build-host '"'"'git push origin main'"'"'"}}' 0 \
  "no segment of it is a push this hook can place in its own tree"
run_announcing "bash -c 'git push' declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"bash -c '"'"'git push'"'"'"}}' 0 \
  "no segment of it is a push this hook can place in its own tree"
run_announcing "eval 'git push' declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"eval '"'"'git push'"'"'"}}' 0 \
  "no segment of it is a push this hook can place in its own tree"
run_announcing "sudo git push declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"sudo git push"}}' 0 \
  "no segment of it is a push this hook can place in its own tree"

# WHAT AN EARLIER SEGMENT DOES TO A LATER ONE — round 1 of this step's own review, and the
# first-token rule's own blind spot rather than an inherited one. `cd /path/to/other-repo &&
# git push origin main` HAS a segment whose first token is `git`, so the rule read it as local
# and the hook announced `reviewing N artifact(s)` about this checkout for a push executing in
# a sibling repository. That is the same false review trace the rule replaced, reached through
# the shell's own cwd rather than through a wrapper program.
#
# THE PAIR IS THE POINT, because a fix that declines on any `cd` anywhere would break the
# ordinary `git push && cd ..`: only segments BEFORE the push can move the shell it runs in,
# and after it the push has already happened here. One case per direction, so a fix that
# declines everything passes neither.
run_announcing "cd elsewhere then push declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"cd /path/to/other-repo && git push origin main"}}' 0 \
  "can change the working directory of the shell the push then runs in"
run_reviewing "cd AFTER the push still reviews" \
  '{"tool_name":"Bash","tool_input":{"command":"git push origin main && cd /path/to/other-repo"}}' \
  'benchmark/rubrics/backend-quality.yaml'

# ...AND THE SHAPE THAT IS BOTH AT ONCE — round 2 of this step's own review, and the case whose
# absence is why the defect it pins reached a second review round rather than this suite.
#
# `git push && cd /path/to/other-repo && git push` carries TWO pushes: the first is this
# tree's, the second is not. The pair above is one case per direction and neither can see it —
# the declining case has no push before the `cd`, and the reviewing case has no push after it.
# The scan stopped at the first segment it could place, set `yes`, broke out of the loop, and
# the hook announced `reviewing N artifact(s)`. The second push went to the sibling repository
# UNREVIEWED and, worse, UNANNOUNCED: the relocation gate never got to look at the `cd`,
# because the loop had already left. A developer reading the trace concludes the pushed
# artifacts were seen by the critic, which is this file's oldest failure mode wearing this
# step's own machinery.
#
# IT ASSERTS THE RELOCATION NOTICE, not merely "did not review", and that is deliberate: a
# hook that declined every compound command would also produce zero reviewer calls here, and
# "cd AFTER the push still reviews" directly above is the case that fails against it. The two
# together are the both-directions check — one says a later relocation must decline, the other
# says an earlier push must not make relocation ignorable, and no single wrong rule passes
# both.
run_announcing "a cd and a SECOND push after a local one declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"git push origin main && cd /path/to/other-repo && git push origin main"}}' 0 \
  "can change the working directory of the shell the push then runs in"

# THE SPLIT IS QUOTE-AWARE, and these two are the pair that says so — one in each direction,
# because a splitter that is wrong in either is wrong.
#
# A naive split on `&&` turns `ssh host 'cd /w && git push'` into a second segment reading
# `git push'`, whose first token is `git`: the rule would then call a remote push local and
# reinstate exactly the bug above, with the whitelist as cover. This case fails against that
# splitter and passes against one that lets a quote suspend the separators. It asserts the
# notice's own vocabulary — "the first token of every segment" — rather than the summary
# clause its three neighbours use, so the RULE is pinned somewhere and not just its effect.
run_announcing "a quoted && inside ssh still declines" "$FIXTURE" "$STUB:$PATH" \
  '{"tool_name":"Bash","tool_input":{"command":"ssh host '"'"'cd /w && git push'"'"'"}}' 0 \
  "the first token of every segment"
# ...and the cost of getting quote-awareness wrong the other way: a separator inside a commit
# message must not break the local push that follows it. A splitter that ignored quoting would
# cut this into `git commit -m "a`, `b" `, ` git push` — the last of which is local, so the
# case would still pass; a splitter that treated the opening quote as running to end-of-line
# would swallow the `&& git push` and decline a perfectly ordinary local push. That second
# failure is the one this pins, and it is the failure that would stop reviews silently.
run_reviewing "a quoted separator keeps the push local" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"a;b\" && git push"}}' \
  'benchmark/rubrics/backend-quality.yaml'
# THE NOTICE DID NOT WIDEN INTO EVERY COMMAND. The first-token rule sits INSIDE the trigger's
# yes-branch, so a command with no `git … push` shape in it never reaches the decline. Without
# that placement every `grep push`, `echo "do not push"` and `cat push-notes.md` on this
# machine would announce that the hook could not place their push — a notice on every shell
# command is how a real notice stops being read.
run_silent "a push token with no git stays silent" \
  '{"tool_name":"Bash","tool_input":{"command":"grep push notes.txt"}}'

# --- THE PUSH AIMED SOMEWHERE ELSE (2026-09-23, round 4)
#
# The cost of the widening above, and the reason it needed cases of its own. `git -C <dir>
# push` now MATCHES the trigger — which was the point — but the hook resolves its root from
# ${BASH_SOURCE[0]} and runs `merge-base` and `diff` in THAT tree, never in the directory the
# option names. Left there, a push aimed at a sibling repository is reviewed against this one:
# the developer is told "reviewing 1 artifact" about a file they never pushed, while what they
# did push goes unseen. That is worse than the silence the widening replaced, because it
# leaves a positive trace. The hook declines instead, by name.
#
# FOUR CASES, TWO OUTCOMES, AND THE SEPARATION IS THE POINT. A decline that fires on every
# `-C` would be as wrong as reviewing the wrong tree — `git -C . push` and `git -C tools push`
# are this repository, and a hook that refuses them stops reviewing the ordinary monorepo
# push. So each direction is asserted: two shapes naming a REAL second repository must
# decline, one naming a directory that resolves to no repository at all must say so in its own
# words (unestablished is not the same as different), and two naming THIS tree — through
# `--git-dir` and through a subdirectory — must review it exactly as a bare `git push` does.
#
# THE SECOND REPOSITORY IS A REAL ONE, with its own git directory. The hook compares absolute
# git directories, so a plain directory would land in the unresolvable arm instead and the two
# notices could not separate — the case would pass while proving the other thing.
OTHER="$WORK/other-repo"
mkdir -p "$OTHER"
git -C "$OTHER" init -q -b main
git -C "$OTHER" config user.email t@t; git -C "$OTHER" config user.name t
echo other > "$OTHER/README.md"
git -C "$OTHER" add -A >/dev/null; git -C "$OTHER" commit -qm other

_payload() {  # _payload <command> -> the tool call JSON carrying it
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

run_announcing "git -C <other repo> declines" "$FIXTURE" "$STUB:$PATH" \
  "$(_payload "git -C $OTHER push origin main")" 0 \
  "NOT REVIEWED — this push targets another repository"
run_announcing "git --git-dir=<other> declines" "$FIXTURE" "$STUB:$PATH" \
  "$(_payload "git --git-dir=$OTHER/.git push origin main")" 0 \
  "NOT REVIEWED — this push targets another repository"
# The SEPARATED form, which is a different shape and not the same case written twice: the
# value arrives as its own token, so a parser that only handles `--git-dir=<dir>` reads this
# one as an option with no directory and reviews this tree while the push went elsewhere.
run_announcing "git --git-dir <other> declines" "$FIXTURE" "$STUB:$PATH" \
  "$(_payload "git --git-dir $OTHER/.git push origin main")" 0 \
  "NOT REVIEWED — this push targets another repository"
# The directory that is not a repository at all — the shape that used to live up in the
# trigger section asserting one reviewer call against a fixture that has never contained
# `/srv/mono/.git/`. It declines, and it declines in ITS OWN words: "could not resolve" and
# "targets another repository" are different findings, and a hook that collapsed them would
# tell a developer with a typo that their push went to another repository.
run_announcing "an unresolvable --git-dir declines" "$FIXTURE" "$STUB:$PATH" \
  "$(_payload 'git --git-dir=/srv/mono/.git/ push origin main')" 0 \
  "NOT REVIEWED — this push names a repository directory this hook could not resolve"
# ...and WHY it could not be resolved, which is a second finding inside the first. `git -C
# $dir push` is option-shaped, so it passes the trigger and lands here with `$dir` as four
# literal characters. The old notice told the developer their directory was wrong; the truth
# is that this hook cannot expand a shell variable. The case asserts the expansion wording, so
# collapsing the two reasons back into one fails it.
run_announcing "an unexpandable -C says so, not 'wrong dir'" "$FIXTURE" "$STUB:$PATH" \
  "$(_payload 'git -C $target_dir push origin main')" 0 \
  "written as a shell expansion or quotation, which this hook cannot expand"
# ...and the other direction, twice. `--git-dir` pointing at THIS tree's git directory, and
# `-C` pointing at a subdirectory of it, are both this repository — decided by git directory
# rather than by string prefix, which is what makes the subdirectory case pass and would make
# a submodule under the same prefix fail.
run_reviewing "git --git-dir=<this repo> reviews" \
  "$(_payload "git --git-dir=$FIXTURE/.git push origin main")" \
  'benchmark/rubrics/backend-quality.yaml'
run_reviewing "git -C <a subdirectory> reviews" \
  "$(_payload "git -C $FIXTURE/tools push origin main")" \
  'benchmark/rubrics/backend-quality.yaml'

# --- THE `-n` VALUE IS THE HOOK'S TO COMPUTE, and this is the case that says so.
#
# Every run_reviewing case above wants `-n 1`, which the hook produces from
# `runs="${LAB_REVIEW_RUNS:-1}"`. A hook that ignored the variable and wrote a literal `-n 1`
# would satisfy all of them — the default and the constant are indistinguishable from outside
# until something asks for a different number. This asks for three, and wants `-n` and `3`
# present and ADJACENT in the recorded argv, which is the same claim `-P` has always carried.
# It routes through the same runner as its neighbours (the `--runs` form), so it also inherits
# exit 0, one call, and the exact artifact set rather than restating them in a block.
run_reviewing --runs 3 "LAB_REVIEW_RUNS reaches the reviewer" "$PUSH" \
  'benchmark/rubrics/backend-quality.yaml'

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
# THE HOOK'S EXIT STATUS AND THE REVIEWER'S CALL COUNT ARE ASSERTED BY run_announcing, added
# 2026-09-24 after round 5. This block used to capture neither: it read the notice and the
# argv and said nothing about whether the hook exited 0 or how many times it fired the
# reviewer — so a budget that dropped the right files while invoking the reviewer twice, or
# while exiting 1 on a developer's push, passed here and the tail still read "all cases
# behaved as specified". Every case routed through run() / run_bare_path() / run_silent()
# has asserted both since the file existed; this block is now no different.
#
# LAB_REVIEW_MAX_ARTIFACTS is EXPORTED rather than passed as an argument because
# run_announcing invokes the hook through `env PATH=… ` and therefore hands the whole
# environment through — the same route STUB_REVIEWER_EXIT takes at the end of this file. It is
# unset immediately afterwards, since a budget of 2 leaking into a later case would silently
# shrink a review the case below believes is complete.
export LAB_REVIEW_MAX_ARTIFACTS=2
run_announcing "budget caps the review and says so" "$FIXTURE" "$STUB:$PATH" "$PUSH" 1 \
  'PARTIAL REVIEW — 2 of 7'
unset LAB_REVIEW_MAX_ARTIFACTS
# ...and the same run's output is read again here, from the files run_announcing left behind,
# rather than by pushing a second time. Two claims, two counted cases: "it capped and said so"
# and "it named every single one it dropped" fail for different reasons and a reader should be
# able to tell which.
out="$(cat "$ANNOUNCE_ERR" 2>/dev/null)"
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
if [ -z "$missing" ] && [ -z "$leaked" ] \
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
# Routed through run_announcing 2026-09-24 (round 5). The block already counted the reviewer's
# invocations, but it never captured the hook's EXIT STATUS — a hook that announced the
# deletion and then exited 1 would fail the developer's push while this case stayed green —
# and it merged stdout into stderr, so a notice that migrated to stdout (where it reaches
# Claude Code as tool output instead of the terminal) read the same. The runner asserts exit 0,
# zero calls, the notice on STDERR and an empty stdout, which is four of this block's claims
# expressed once.
run_announcing "a deleted contract is announced" "$FIXTURE" "$STUB:$PATH" "$PUSH" 0 'REMOVED'
# The fifth claim — BY NAME — is its own counted case, read from the same run. "It said
# something about a removal" and "it said which file" fail for different reasons; a notice
# that announces a count and no path is the under-reporting this whole section exists against.
out="$(cat "$ANNOUNCE_ERR" 2>/dev/null)"
if printf '%s' "$out" | grep -qF 'benchmark/rubrics/registered.yaml'; then
  printf 'ok    %-44s the removal names the file\n' "a deleted contract is named"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s\n' "a deleted contract is named" "$out"; FAIL=$((FAIL+1))
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
# Same routing as the block above, and here the call count it gains is load-bearing rather
# than defensive: this is the push where a review DOES happen, so "exactly one reviewer call"
# is the assertion separating a deletion announced beside a review from a deletion announced
# beside two reviews of the same artifact set — the double-fire the step names.
run_announcing "deletion announced beside a review" "$FIXTURE" "$STUB:$PATH" "$PUSH" 1 'REMOVED'
# ...and the argv half, from the same run: the surviving tool handed over as its own whole
# argv element, the deleted path nowhere in the argv at all. The positive claim is whole-line
# (`-Fx`) and the negative one is substring, for the reason given further up — "this path must
# not appear ANYWHERE in the argv" is the stronger thing to say about absence.
out="$(cat "$ANNOUNCE_ERR" 2>/dev/null)"
argv="$(cat "$ARGV" 2>/dev/null)"
if printf '%s' "$out" | grep -qF 'benchmark/rubrics/registered.yaml' \
   && grep -Fxq 'tools/still-here.sh' "$ARGV" \
   && ! printf '%s' "$argv" | grep -qF 'registered.yaml'; then
  printf 'ok    %-44s named in stderr, absent from argv\n' "the deleted path stays out of argv"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s out=%s argv=%s\n' "the deleted path stays out of argv" "$out" "$argv"; FAIL=$((FAIL+1))
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
# THESE TWO STAY BESPOKE, and the reason is `env -i`. Round 5 asked for the five hand-written
# blocks to be routed through the existing runners rather than grow a sixth shape, and three
# of them were; these two cannot be, because every runner in this file invokes the hook
# through `env PATH=… ` — the ambient environment passes straight through. That is exactly
# what these cases must not have. The panel is decided by `command -v codex` and by nothing
# else, so the case that proves it has to hand the hook an environment holding only the PATH
# it was given; routed through a runner, a `codex` reachable some other way, or a stray
# LAB_REVIEW_* left exported by an earlier block, would decide the outcome instead and the
# pair could still separate for the wrong reason.
#
# So they keep the invocation and gain what round 5 actually found missing: the hook's EXIT
# STATUS and the reviewer's INVOCATION COUNT, which neither of them captured. A degraded panel
# that fired the reviewer twice, or exited 1 on the developer's push, was green here.
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
got_exit=$?
argv="$(cat "$ARGV" 2>/dev/null)"
calls="$(wc -l < "$CALLS" | tr -d ' ')"
if [ "$got_exit" = 0 ] && [ "$calls" = 1 ] \
   && printf '%s' "$out" | grep -q "panel reduced to 'deepseek-v4-pro'" \
   && printf '%s' "$out" | grep -q 'ONE-harness review' \
   && argv_has_flag_value "$ARGV" -P 'deepseek-v4-pro'; then
  printf 'ok    %-44s exit 0, 1 call, panel reduced and announced\n' "codex missing degrades the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s exit %s (want 0), %s call(s) (want 1), out=%s argv=%s\n' \
    "codex missing degrades the panel" "$got_exit" "$calls" "$out" "$argv"; FAIL=$((FAIL+1))
fi

printf '#!/usr/bin/env bash\nexit 0\n' > "$PANELBIN/codex"; chmod +x "$PANELBIN/codex"
# The other half of the pair, bespoke for the same `env -i` reason — and additionally the one
# block no runner could carry whatever the environment did, because it asserts the ABSENCE of
# a notice and every runner in this file is built around a string that must be PRESENT. It
# gains exit status and call count in the same shape as its twin above.
: > "$CALLS"; : > "$ARGV"
out="$(printf '%s' "$PUSH" | env -i PATH="$PANELBIN" HOME="$HOME" \
        "$FIXTURE/.claude/hooks/opencode-review.sh" 2>&1)"
got_exit=$?
argv="$(cat "$ARGV" 2>/dev/null)"
calls="$(wc -l < "$CALLS" | tr -d ' ')"
if [ "$got_exit" = 0 ] && [ "$calls" = 1 ] \
   && ! printf '%s' "$out" | grep -q 'panel reduced' \
   && argv_has_flag_value "$ARGV" -P 'deepseek-v4-pro,codex'; then
  printf 'ok    %-44s exit 0, 1 call, full panel, no reduction notice\n' "codex present keeps the panel"; PASS=$((PASS+1))
else
  printf 'FAIL  %-44s exit %s (want 0), %s call(s) (want 1), out=%s argv=%s\n' \
    "codex present keeps the panel" "$got_exit" "$calls" "$out" "$argv"; FAIL=$((FAIL+1))
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
# `run_silent` itself is DEFINED WITH THE OTHER RUNNERS at the top of the file, not here beside
# its first user, because 2026-09-24 gave it users above this point too: the established
# non-push commands are now required to be silent rather than merely reviewless, which is the
# half of the three-way classification that a new announcement could quietly break.
run_silent "empty stdin"                 ''
run_silent "JSON without a command"      '{"tool_name":"Bash"}'
run_silent "JSON, wrong shape"           '{"tool_input":"a string"}'

# A CASE THAT CODIFIED THE DEFECT, CORRECTED RATHER THAN DELETED. This input used to be
# `run_silent "not JSON"`, requiring the hook to say nothing about a payload it could not
# parse — the same silence it produces for a payload it parsed and found no command in. Those
# are the two sides of the header's one rule ("failing to find out is not the same as finding
# nothing"), and the suite was requiring the wrong one: a hook fixed to honour its own rule
# FAILED this case, so the case was the thing keeping the defect in place. It is kept, with
# the same input, asserting the opposite — deleting it would have left the input untested and
# the silence free to come back.
#
# The three cases above are what makes it a distinction rather than a blanket announcement:
# empty stdin is zero JSON values, `{"tool_name":"Bash"}` is JSON with no command, and
# `{"tool_input":"a string"}` is JSON the hook READ and found no command in — all three are
# "found nothing" and stay silent. Only bytes that are not JSON are "could not find out".
run_announcing "a payload that is not JSON is named" "$FIXTURE" "$STUB:$PATH" \
  'not json at all' 0 "NOT REVIEWED — the tool call on stdin is not valid JSON"

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

# IT MATCHES THE WAY THE HOOK MATCHES, OR IT MEASURES SOMETHING ELSE (fixed 2026-09-24, round
# 1 of step 31's review). This started as a bare `[[ "$f" == $glob ]]`, while the hook's
# `select_matching` applies a SLASH-COUNT guard first. Inside `[[ ]]` a `*` crosses `/`, so
# the check was strictly WIDER than the matcher it stands in for: move every depth-1 Python
# tool into a subdirectory (`tools/render-spine-status.py` -> `tools/checkers/…`) and the hook
# selects nothing for `tools/*.py` — Python tools silently leave review scope — while this
# check still reported the glob live, because the nested file matched its wider pattern. A
# coverage check that cannot see the coverage go to zero is the artifact's own named failure
# mode standing inside the control built to catch it. The guard below is `select_matching`'s,
# character for character; the two must stay identical or this check stops speaking about the
# hook.
glob_coverage_failures() {  # <file-list> <array-name> <glob>... -> "<array-name> <glob>" per dead entry
  local list="$1" array="$2"; shift 2
  local glob f matched
  for glob in "$@"; do
    matched=0
    while IFS= read -r f; do
      [ "${f//[^\/]/}" = "${glob//[^\/]/}" ] || continue
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
#
# THE OPENER USED TO BE THE ONE PLACE THAT SENTENCE WAS FALSE (fixed 2026-09-24, round 1 of
# step 30's review). It matched with `$0 == name "=("` — exact string equality, so an array
# indented for any reason (wrapped in a `case` arm, aligned with its surroundings) set
# `inside` never, the reader exited 3, and the trunk-liveness case FAILED with "could not
# read CONTRACT_GLOBS from the hook" — a parser regression wearing a coverage failure's
# words, whose cheapest silencing move is to delete a glob, which is the exact harm the
# required-set case exists to prevent. The entry and closing-paren matchers always tolerated
# indentation; only the opener did not, so the contract and two of its three matchers agreed
# and the third quietly did not. It now matches leading whitespace like its siblings, and
# `[[:space:]]*$` keeps the inline shape (`G=('a' 'b')`) refused: the opener carries nothing
# but the paren. The indented shape is exercised as its own case below, not asserted here.
extract_glob_array() {  # <file> <array-name> -> one entry per line; non-zero if malformed
  awk -v name="$2" -v q="'" '
    $0 ~ "^[[:space:]]*" name "=\\([[:space:]]*$" { inside = 1; next }
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

# THE DEATH THIS CHECK USED TO MISS, and the reason its matcher now carries the hook's depth
# guard (round 1 of step 31's review). A glob does not only die by having its directory
# renamed; it dies just as completely when its files move DEEPER. `select_matching` compares
# slash counts before it matches, so `tools/*.py` selects nothing once every Python tool lives
# at `tools/checkers/…` — Python tools leave review scope entirely. A `[[ $f == $glob ]]` with
# no guard still called the glob live, because `*` crosses `/` inside `[[ ]]`, and the suite
# stayed green over a hook that had narrowed its own scope to zero.
#
# The list here holds ONE file per glob, each nested one level below the glob's own depth. A
# matcher carrying the guard calls every entry dead; a matcher without it calls every entry
# live, so this case fails the moment the guard is removed — which is the mutation, run rather
# than described.
NESTED="$WORK/nested-trunk"
: > "$NESTED"
for _glob in "${CONTRACT_GLOBS[@]}" "${TOOL_GLOBS[@]}"; do
  _filled="${_glob//\*/x}"                                   # tools/*.py -> tools/x.py
  printf '%s\n' "${_filled%/*}/deeper/${_filled##*/}" >> "$NESTED"   # -> tools/deeper/x.py
done
nested_dead="$(glob_coverage_failures "$NESTED" CONTRACT_GLOBS "${CONTRACT_GLOBS[@]}"
               glob_coverage_failures "$NESTED" TOOL_GLOBS "${TOOL_GLOBS[@]}")"
nested_dead_count=$(printf '%s\n' "$nested_dead" | grep -c . || true)
if [ "$nested_dead_count" = "$((CONTRACT_COUNT + TOOL_COUNT))" ]; then
  printf 'ok    %-44s all %s globs dead when their files nest one level deeper\n' \
    "a glob whose files moved deeper is dead" "$nested_dead_count"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s %s of %s globs reported dead; the matcher is wider than the hook'"'"'s select_matching (missing the slash-count guard)\n' \
    "a glob whose files moved deeper is dead" "$nested_dead_count" "$((CONTRACT_COUNT + TOOL_COUNT))"
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
printf "    G=(\n      'a/*.yaml'\n      'b/*.yaml'\n    )\n"      > "$MALFORMED_DIR/indented"
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

# THE OTHER HALF OF THE READER'S CONTRACT, and the half that was prose only until round 1 of
# step 30's review: "Indentation is free; structure is not." The three shapes above are all
# MALFORMED, so every one of them is refused whether the opener tolerates whitespace or not —
# a reader that accepts nothing passes that case perfectly. This is the case that fails when
# the opener is strict: a WELL-FORMED array, indented, must come back as exactly its entries.
# Its mutation is one character-class: restore `$0 == name "=("` and this case FAILs while
# every other case in the suite stays green, which is what the trunk-liveness case's false
# "could not read" failure looked like from the outside.
indented_entries="$(extract_glob_array "$MALFORMED_DIR/indented" G 2>/dev/null || echo REFUSED)"
if [ "$indented_entries" = "$want_entries" ]; then
  printf 'ok    %-44s 2 entries read through a 4-space indent\n' \
    "an indented glob array is still read"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s read as [%s], want [%s] — the opener matcher is the only element that\n' \
    "an indented glob array is still read" "$indented_entries" "$want_entries"
  printf '        ever required column 0, against this file'"'"'s own "indentation is free" rule.\n'
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
  for _c in "no trunk ref is named, not silent" "the trunk notice names its own limit"; do
    printf 'skip  %-44s could not build a trunkless copy of the fixture (cp/git failed)\n' "$_c"
    SKIP=$((SKIP+1))
  done
else
  run_announcing "no trunk ref is named, not silent" "$NOTRUNK" "$STUB:$PATH" "$PUSH" 0 \
    "NOT REVIEWED — git merge-base HEAD origin/main found nothing"
  # ...and the SUBSTANCE of that notice, which is round 4's third finding and the half a
  # fixed-prefix assertion cannot see. The old notice offered "a fork, an unfetched remote,
  # or a renamed default branch" to a reader whose trunk is simply called `origin/master`:
  # none of those is their cause, and every one of them suggests an action that will not
  # work. The decline is PERMANENT there until the hook learns a second ref, so the notice
  # has to say so. Asserted as its own case rather than by lengthening the case above,
  # because "the right door fired" and "the notice told the truth about it" are two claims
  # and a suite that merges them cannot report which one broke.
  run_announcing "the trunk notice names its own limit" "$NOTRUNK" "$STUB:$PATH" "$PUSH" 0 \
    "Only origin/main is tried"
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

# --- THE SWEEP (2026-09-23, round 3): THE CORRIDOR, NOT THE NEXT DOOR
#
# Rounds 1 and 2 each named doors and each got them fixed; round 3 named a fourth, two lines
# below one that had already been fixed. Three rounds of patching the door that was pointed
# at is evidence about the METHOD, not about the doors, so the hook now carries a classified
# list of every site where a status is discarded or the script leaves early (THE SWEEP in its
# header), and the two cases below hold that list to the code:
#
#   - every `exit 0` in the hook is either preceded by its own notice on stderr or carries an
#     inline `# SILENT: <reason>`; a new exit that is neither fails here, whether or not
#     anyone thought to write a behavioural case for it;
#   - the number of SILENT exits is fixed, so a new silent exit fails even when its author
#     remembers the marker — the marker declares an intent, the count forces it past a reader.
#
# This is what makes the two behavioural cases further down a sweep rather than a fourth
# patch. It is a STATIC check and it is weaker than running the path: it proves the notice is
# there, not that it fires. That is exactly the strength the repo-root door can have (its
# failure cannot be constructed — see the proof in the hook) and no more than the strength
# the other two doors need, since those are also tested behaviourally below.
# WHAT "ANNOUNCED" HAS TO MEAN HERE, tightened 2026-09-23 after round 4. This classified any
# `exit 0` whose previous line contained `>&2` as announced, without reading the message — so
# `echo "hook unavailable" >&2; exit 0` passed the sweep while naming neither what went
# unreviewed nor why, which is the whole content of the hook's rule. A structural check that
# accepts the shape of a notice and not its substance is a control reporting success over a
# smaller scope than it claims, in the case that exists to catch exactly that.
#
# So the preceding line must carry the hook's own decline vocabulary — `NOT REVIEWED` — and
# not merely a redirection. That is still weaker than running the path (it proves the notice
# is there, not that it fires), and it is now as strong as a static check can be about this:
# every announced exit in the hook is preceded by its NOT REVIEWED line, and a new door that
# says something vaguer is UNCLASSIFIED rather than quietly counted. The refusal is run rather
# than described, two cases below, over three synthetic shapes.
#
# WHICH TERMINATION FORMS THE SWEEP CLAIMS, stated because round 1 of step 30's review found
# the claim ("every early departure is classified") wider than the matcher. The matcher read
# the literal `exit 0` only, so a door added inside a helper as `command -v x >/dev/null ||
# return 0` — a successful early departure that skips the review exactly like an `exit 0`
# does — was absent from SITES entirely: not UNCLASSIFIED, not counted, invisible. It now
# reads `exit 0` AND `return 0`, and the refusal case below exercises a bare `return 0` as a
# fourth shape. The forms deliberately OUTSIDE the claim are the non-zero ones (`exit 1`,
# `return 1` — those FAIL the tool call, which the header's first promise forbids, so they
# are a different defect and a louder one) and a status computed into a variable, which the
# hook does not do. `return 0` costs nothing to include today: the hook carries none, so this
# is a guard on the next one rather than a re-classification of anything present.
hook_exit_sites() {  # hook_exit_sites <file> — one line per exit 0 / return 0: "<class> <lineno> <text>"
  awk 'BEGIN { prev = "" }
       {
         if ($0 !~ /^[[:space:]]*#/ && ($0 ~ /exit 0/ || $0 ~ /return 0/)) {
           if ($0 ~ /# SILENT:/)                             cls = "silent"
           else if (prev ~ />&2/ && prev ~ /NOT REVIEWED/)    cls = "announced"
           else                                              cls = "UNCLASSIFIED"
           printf "%s %d %s\n", cls, NR, $0
         }
         prev = $0
       }' "$1"
}
# Seven, and each one is a line in THE SWEEP's SILENT list. Raising this number is the moment
# to ask which of the two things the new path is; lowering it means a silent exit became an
# announced one, which is this step's whole direction and also needs a deliberate edit.
#
# STEP 31 ADDED DOORS AND DID NOT MOVE THIS NUMBER, which is the shape to expect from now on.
# The first-token rule declines a push the hook cannot place in its own tree — `ssh host 'git
# push'`, `bash -c`, `eval`, `sudo`, and whatever wrapper nobody has named yet — and it
# declines by ANNOUNCING, so it is an eighth announced exit and the silent count is untouched.
# A first-token rule written as a silent `exit 0` would trip this guard on the next line, and
# that is the guard doing its job: a delegated push that leaves quietly is the same event as
# the one this step replaced, minus the false trace.
#
# ROUND 1 OF ITS REVIEW ADDED A NINTH, and MOVED ONE COMMAND OFF THE SILENT LIST WITHOUT
# CHANGING THE COUNT — worth reading twice, because it is the shape a reader would expect to
# see here and does not. The ninth is the relocation door (`cd /other && git push`). The move
# is `git $GIT_OPTS push`, which used to leave through the "the command is not a push" silent
# exit and now leaves through the third branch's announcement: the SITE is the same site and
# is still silent for the commands it was always right about (`git status`, `git commit -m
# push`), so nothing here moves. A count that watches sites cannot see a command change which
# site it reaches, which is what the behavioural cases above are for.
EXPECTED_SILENT_EXITS=7

SITES="$(hook_exit_sites "$HOOK")"
unclassified="$(printf '%s\n' "$SITES" | grep '^UNCLASSIFIED ' || true)"
if [ -z "$unclassified" ]; then
  printf 'ok    %-44s every exit is announced or marked\n' "no exit in the hook is unclassified"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s these exits neither announce nor carry a "# SILENT:" reason:\n' \
    "no exit in the hook is unclassified"
  printf '        %s\n' "$unclassified"
  printf '        Classify each under the header rule: did the hook ESTABLISH that no review\n'
  printf '        was owed (mark it "# SILENT: <reason>"), or did it merely FAIL TO FIND OUT\n'
  printf '        (print one line naming what went unreviewed, on stderr, then exit 0)?\n'
  FAIL=$((FAIL+1))
fi

# The refusal for the classifier itself, run rather than described. Three one-line shapes: a
# real notice, a generic one that redirects to stderr and names nothing, and a marked silent
# exit. The middle one is the round-4 finding — it must come back UNCLASSIFIED, and it did not
# before the `NOT REVIEWED` half of the rule above was added.
EXITSHAPES="$WORK/exit-shapes"; mkdir -p "$EXITSHAPES"
printf '%s\n' 'echo "opencode-review hook: NOT REVIEWED — a door" >&2' 'exit 0' \
  > "$EXITSHAPES/announced"
printf '%s\n' 'echo "hook unavailable" >&2' 'exit 0'            > "$EXITSHAPES/generic"
printf '%s\n' 'exit 0  # SILENT: nothing was owed'              > "$EXITSHAPES/silent"
# The fourth shape, added with the `return 0` half of the matcher: a helper that departs
# early on success. Under the old matcher this file produced NO line at all — the classifier
# had nothing to say about a door it could not see — so the assertion is that it now comes
# back UNCLASSIFIED, which is what makes the unclassified-site check above fire on it.
printf '%s\n' 'command -v helper >/dev/null || return 0'        > "$EXITSHAPES/returning"
cls_announced="$(hook_exit_sites "$EXITSHAPES/announced" | awk '{print $1}')"
cls_generic="$(hook_exit_sites "$EXITSHAPES/generic"     | awk '{print $1}')"
cls_silent="$(hook_exit_sites "$EXITSHAPES/silent"       | awk '{print $1}')"
cls_return="$(hook_exit_sites "$EXITSHAPES/returning"    | awk '{print $1}')"
if [ "$cls_announced" = announced ] && [ "$cls_generic" = UNCLASSIFIED ] && \
   [ "$cls_silent" = silent ] && [ "$cls_return" = UNCLASSIFIED ]; then
  printf 'ok    %-44s a bare ">&2" line is not an announcement; "return 0" is a door\n' \
    "the exit classifier reads the notice"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s notice=%s generic=%s silent=%s return=%s (want announced/UNCLASSIFIED/silent/UNCLASSIFIED)\n' \
    "the exit classifier reads the notice" "$cls_announced" "$cls_generic" "$cls_silent" \
    "${cls_return:-<not seen at all>}"
  FAIL=$((FAIL+1))
fi

silent_count="$(printf '%s\n' "$SITES" | grep -c '^silent ' || true)"
if [ "$silent_count" = "$EXPECTED_SILENT_EXITS" ]; then
  printf 'ok    %-44s %s of them, as enumerated in THE SWEEP\n' \
    "the hook's silent exits are the enumerated ones" "$silent_count"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s %s silent exit(s), expected %s\n' \
    "the hook's silent exits are the enumerated ones" "$silent_count" "$EXPECTED_SILENT_EXITS"
  printf '        A silent exit was added or removed. Update THE SWEEP in the hook header and\n'
  printf '        EXPECTED_SILENT_EXITS together, or the list stops describing the code.\n'
  FAIL=$((FAIL+1))
fi

# `|| true` is the shape that opened all four doors: it converts a command that FAILED into
# one that produced nothing, and every emptiness check downstream then reads the failure as a
# finding. The hook has none left, and this is what keeps it that way. The idiom that replaced
# it — `status=0; x="$(cmd)" || status=$?` — costs one extra line and makes the difference
# between the two outcomes available to the code that has to choose between them.
#
# `|| :` IS THE SAME SHAPE, and searching for the literal `|| true` missed it — round 4's
# finding. `:` is the null command; it discards the status identically and reads as a typo to
# anyone scanning quickly, which makes it the likelier of the two to arrive unnoticed. The
# claim in this file's own header is that the hook discards NO command status, so the check
# has to cover both spellings or the claim is wider than the check. The refusal below is run
# over a synthetic file rather than described, for the same reason every other refusal here is.
status_discard_sites() {  # <file> -> "<lineno>: <line>" per discarded status, outside comments
  awk '!/^[[:space:]]*#/ && /\|\|[[:space:]]*(true|:)([^[:alnum:]_]|$)/ { printf "%d: %s\n", NR, $0 }' "$1"
}
swallowed="$(status_discard_sites "$HOOK")"
if [ -z "$swallowed" ]; then
  printf 'ok    %-44s neither "|| true" nor "|| :" outside comments\n' "the hook discards no command status"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s a status is discarded here:\n' "the hook discards no command status"
  printf '        %s\n' "$swallowed"
  FAIL=$((FAIL+1))
fi

# The refusal: both spellings caught, on their own lines, and nothing else — `|| continue` is
# control flow rather than a discarded status, and a commented example is not code.
DISCARDSHAPES="$WORK/discard-shapes"
printf '%s\n' 'x="$(cmd)" || true' 'y="$(cmd)" || :' 'z="$(cmd)" || continue' \
  '# an example of || true inside a comment' > "$DISCARDSHAPES"
got_discards="$(status_discard_sites "$DISCARDSHAPES" | awk '{print $1}' | tr '\n' ' ')"
if [ "$got_discards" = "1: 2: " ]; then
  printf 'ok    %-44s "|| true" and "|| :" caught, "|| continue" and comments not\n' \
    "both discard shapes are caught"
  PASS=$((PASS+1))
else
  printf 'FAIL  %-44s reported lines [%s] (want [1: 2: ])\n' \
    "both discard shapes are caught" "$got_discards"
  FAIL=$((FAIL+1))
fi

# (d) `git diff --name-only` FAILS AFTER THE MERGE BASE RESOLVED — round 3's finding, and the
# one the two cases above exist to generalise. A git stub forwards everything to the real git
# except `diff`, which exits 128. The merge base therefore still resolves, so a hook that
# announced the merge-base door instead would fail this case on its fixed string rather than
# pass for the neighbouring reason.
GITSTUB="$WORK/gitstub"; mkdir -p "$GITSTUB"
REALGIT="$(command -v git 2>/dev/null || true)"
if [ -n "$REALGIT" ]; then
  cat > "$GITSTUB/git" <<GITSH
#!/usr/bin/env bash
if [ "\${1:-}" = diff ] && [ "\${STUB_GIT_DIFF_FAILS:-1}" = 1 ]; then
  echo "fatal: simulated git diff failure" >&2
  exit 128
fi
exec "$REALGIT" "\$@"
GITSH
  chmod +x "$GITSTUB/git"
fi

# THE CONTROL FIRST, again, and here it carries more than usual: it proves the stub itself is
# not what produces the zero-call outcome below. Same copy, same stub on $PATH, the failure
# switched off — and the hook reviews. Without it, a stub that broke `git` outright would
# produce a notice and no call, and the case below could not tell that from the diff door.
DIFFAIL="$WORK/repo-difffail"
if [ -z "$REALGIT" ] || ! prepare_copy "$DIFFAIL" difffail; then
  printf 'skip  %-44s no git on PATH, or the fixture copy failed\n' \
    "the git stub alone still reviews"; SKIP=$((SKIP+1))
  printf 'skip  %-44s no git on PATH, or the fixture copy failed\n' \
    "a failing git diff is named, not silent"; SKIP=$((SKIP+1))
else
  export STUB_GIT_DIFF_FAILS=0
  run_announcing "the git stub alone still reviews" "$DIFFAIL" "$GITSTUB:$STUB:$PATH" "$PUSH" 1 \
    "reviewing 1 of 1 changed artifact(s)"
  export STUB_GIT_DIFF_FAILS=1
  run_announcing "a failing git diff is named, not silent" "$DIFFAIL" "$GITSTUB:$STUB:$PATH" \
    "$PUSH" 0 "NOT REVIEWED — git diff --name-only"
  unset STUB_GIT_DIFF_FAILS
fi

# (e) STDIN THAT CANNOT BE READ. `payload="$(cat … || true)"` threw away the read's status, so
# an unreadable stdin produced an empty payload — which is valid JSON by vacuity, holds no
# command, and left through the silent exit reserved for "the call was read and there is no
# command in it". The two are not the same event and no longer print the same way.
#
# fd 0 is handed over OPEN FOR WRITING, which makes `cat` exit 1 on EBADF immediately. The
# distinction this case protects is visible in the suite already: `run_silent "empty stdin"`
# two hundred lines up requires SILENCE for a stdin that was read and was empty.
run_announcing "unreadable stdin is named, not silent" "$FIXTURE" "$STUB:$PATH" '' 0 \
  "NOT REVIEWED — the tool call could not be read from stdin" unreadable

# --- THE REVIEWER'S EXIT CODE IS NOT A BOOLEAN (2026-09-23, round 2)
#
# The hook used to print one string — "reviewer failed" — for every non-zero status, and
# nothing at all for 0. `tools/opencode-review.sh` exits 1 when it could not produce a review
# at all, 3 when `LAB_ACCEPT_STRICT=1` and the acceptance gate said REJECT, and 4 when that
# gate ran on opencode's default agent instead of `lab-acceptance`. Three different events:
# one where nothing was read, one where everything was read and the gate rejected it, one
# where the verdict is not the gate's. A developer reading "reviewer failed" cannot tell a
# REJECT from a reviewer that never started — and this repository already has
# `tools/classify-model-output.sh` because "nothing was five different things wearing one
# word". Each case asserts the sentence for ITS code, so a hook that collapses any two of
# them back together fails here.
#
# The reviewer IS invoked in all three (want-calls 1); what differs is only what it returns.
# STUB_REVIEWER_EXIT is exported because run_announcing passes the environment through `env`.
REVEXIT="$WORK/repo-reviewer-exit"
if ! prepare_copy "$REVEXIT" reviewerexit; then
  printf 'skip  %-44s could not build a copy of the fixture (cp/git failed)\n' \
    "reviewer exit 1 is named as unreviewed"; SKIP=$((SKIP+1))
  printf 'skip  %-44s could not build a copy of the fixture (cp/git failed)\n' \
    "reviewer exit 3 is named as a REJECT"; SKIP=$((SKIP+1))
  printf 'skip  %-44s could not build a copy of the fixture (cp/git failed)\n' \
    "reviewer exit 4 is named as a fallback"; SKIP=$((SKIP+1))
else
  export STUB_REVIEWER_EXIT=1
  run_announcing "reviewer exit 1 is named as unreviewed" "$REVEXIT" "$STUB:$PATH" "$PUSH" 1 \
    "NOT REVIEWED — the reviewer exited 1"
  export STUB_REVIEWER_EXIT=3
  run_announcing "reviewer exit 3 is named as a REJECT" "$REVEXIT" "$STUB:$PATH" "$PUSH" 1 \
    "the review RAN and its acceptance gate returned REJECT"
  export STUB_REVIEWER_EXIT=4
  run_announcing "reviewer exit 4 is named as a fallback" "$REVEXIT" "$STUB:$PATH" "$PUSH" 1 \
    "lab-acceptance was not loaded"
  unset STUB_REVIEWER_EXIT
fi

echo
# The tail line names all three outcomes, always, so a reader never has to infer a skip from
# a total. RAN is PASS+FAIL: a skipped case did not run and is not part of what this run
# verified, which is why the first guard below compares RAN — not RAN+SKIP — against
# EXPECTED_CASES.
#
# TWO COMPARISONS, BECAUSE ONE OF THEM HAD A BLIND SPOT SHAPED EXACTLY LIKE THIS FILE'S OWN
# FAILURE MODE (added 2026-09-24, round 1 of step 30's review). RAN alone catches a suite
# that grew or shrank only when the new case RUNS. A developer who adds a SKIP-capable case —
# the suite already has four skip sites — and forgets to bump EXPECTED_CASES gets, in any
# environment where that case skips, RAN == EXPECTED_CASES and FAIL == 0: exit 0, and the tail
# printing "all N cases ran and behaved as specified" while a case never ran. The sentence is
# false and the guard written to catch exactly that could not see it, because a skip is
# invisible to a comparison that excludes skips. So TOTAL = PASS+FAIL+SKIP is compared too:
# every case that EXISTS is counted once, whatever its outcome, and a case that was added
# without being declared fails the run in the environment where it skips as surely as in the
# one where it runs. The two comparisons answer different questions — "did everything run?"
# and "is everything declared?" — and the suite needs both to make its tail line true.
RAN=$((PASS+FAIL))
TOTAL=$((PASS+FAIL+SKIP))
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
if [ "$TOTAL" -ne "$EXPECTED_CASES" ]; then
  echo "opencode-review.test: ${TOTAL} cases exist (${RAN} ran, ${SKIP} skipped) but EXPECTED_CASES is ${EXPECTED_CASES}." >&2
  echo "  RAN matched the declared count only because a case SKIPPED: an undeclared case was" >&2
  echo "  added, and its skip hid the drift from the comparison above. Bump EXPECTED_CASES to" >&2
  echo "  ${TOTAL} if the case is meant to be there; a suite whose declared size is smaller than" >&2
  echo "  its real one reports a complete pass over a scope it never fixed." >&2
  exit 1
fi
if [ "$FAIL" -eq 0 ]; then
  echo "opencode-review.test: all ${PASS} cases ran and behaved as specified."
  exit 0
fi
echo "opencode-review.test: ${FAIL} of ${RAN} cases misbehaved." >&2
exit 1
