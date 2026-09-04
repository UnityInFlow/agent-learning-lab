#!/usr/bin/env bash
# verify-overlay-parity-checker.sh — prove check-overlay-parity.sh still REFUSES.
#
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing. This one guards the sentence an experiment's validity rests on — "the two
# arms differ in exactly one line" — so every way of breaking that sentence gets a fixture,
# and each asserts BOTH the exit code and the line of output that names the difference.
#
# Case 6 is the one worth reading twice: two arms that are byte-identical PASS every other
# check here and are a broken experiment, because the treatment was never applied.

set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

TOOL=./tools/check-overlay-parity.sh
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0

# Portable in-place sed. §4a round 1 at stop 9: the codex critic pointed out that `sed -i ''`
# is BSD-only -- on GNU sed the '' is read as the script's filename, the call fails, and under
# `set -e` this verifier dies BEFORE its first check, reporting nothing rather than failing.
# A verifier whose outcome depends on which sed is installed is not a control. `-i.bak` plus a
# delete is the spelling both accept.
sedi() { sed -i.bak "$@"; local f="${*: -1}"; rm -f "${f}.bak"; }


skill() { # skill <dir> <description> [body-extra]
  local d="$1" desc="$2" extra="${3:-}"
  mkdir -p "$d/sample-service/.claude/skills/s"
  printf -- '---\nname: s\ndescription: %s\n---\n\n## When this applies\n\nAlways.\n' "$desc" \
    > "$d/sample-service/.claude/skills/s/SKILL.md"
  if [[ -n "$extra" ]]; then
    printf '%s\n' "$extra" >> "$d/sample-service/.claude/skills/s/SKILL.md"
  fi
}

check() { # check <label> <expected-exit> <expected-substring> <args...>
  local label="$1" want="$2" grepfor="$3"; shift 3
  local out rc
  set +e
  out="$($TOOL "$@" 2>&1)"; rc=$?
  set -e
  if [[ "$rc" == "$want" ]] && grep -q -- "$grepfor" <<<"$out"; then
    pass=$((pass+1)); printf '  ok    %-56s exit %s\n' "$label" "$rc"
  else
    fail=$((fail+1)); printf '  FAIL  %-56s exit %s (want %s), missing %q\n' "$label" "$rc" "$want" "$grepfor"
    printf '%s\n' "$out" | sed 's/^/          /'
  fi
}

# --- fixtures ---------------------------------------------------------------
skill "$TMP/a" "matches the task"
skill "$TMP/b" "an unrelated domain"
skill "$TMP/body-differs" "an unrelated domain" "One extra convention."
skill "$TMP/same-desc" "matches the task"
skill "$TMP/extra-file" "an unrelated domain"; printf 'x\n' > "$TMP/extra-file/README.md"
skill "$TMP/shared-differs" "an unrelated domain"; printf 'y\n' > "$TMP/shared-differs/CLAUDE.md"
cp -R "$TMP/a" "$TMP/a-plus"; printf 'x\n' > "$TMP/a-plus/CLAUDE.md"
skill "$TMP/desc-missing" "matches the task"
sedi '/^description: /d' "$TMP/desc-missing/sample-service/.claude/skills/s/SKILL.md"
# --- the three the §4a gate found, all of which PASSED the first version ------
# A symlinked SKILL.md with identical bytes: `open()` follows the link, so byte comparison
# said parity while the two overlays install structurally different things.
mkdir -p "$TMP/symlinked/sample-service/.claude/skills/s"
printf 'x\n' > "$TMP/symlink-target.md"
cp "$TMP/a/sample-service/.claude/skills/s/SKILL.md" "$TMP/real-skill.md"
ln -s "$TMP/real-skill.md" "$TMP/symlinked/sample-service/.claude/skills/s/SKILL.md"
# A comment line carrying a real difference: a dict parse drops every line with no colon.
skill "$TMP/comment-differs" "matches the task"
sedi '2i\
# arm C only: reviewed 2026-09-04
' "$TMP/comment-differs/sample-service/.claude/skills/s/SKILL.md"
# A duplicated key: a dict keeps the LAST one and compares equal on it.
skill "$TMP/dup-key" "matches the task"
sedi 's/^description: matches the task$/description: SOMETHING ELSE ENTIRELY\
description: matches the task/' "$TMP/dup-key/sample-service/.claude/skills/s/SKILL.md"

# §4a round 2 at 2/2: os.walk puts DIRECTORY symlinks in dirnames, not names, so an overlay
# whose skills directory is a link compared as an EMPTY overlay against another empty one.
mkdir -p "$TMP/dirlink-a/sample-service/.claude" "$TMP/dirlink-b/sample-service/.claude"
mkdir -p "$TMP/target-one/s" "$TMP/target-two/s"
printf 'one\n' > "$TMP/target-one/s/SKILL.md"
printf 'two\n' > "$TMP/target-two/s/SKILL.md"
ln -s "$TMP/target-one" "$TMP/dirlink-a/sample-service/.claude/skills"
ln -s "$TMP/target-two" "$TMP/dirlink-b/sample-service/.claude/skills"

# §4a round 3, at 2/2: git records the file mode, so chmod +x is a second difference the setup
# commits carry while a byte comparison stays green.
skill "$TMP/mode-differs" "an unrelated domain"
chmod +x "$TMP/mode-differs/sample-service/.claude/skills/s/SKILL.md"
# §4a round 3: with TWO skills, a difference in one used to satisfy the allowance for BOTH, so
# an unapplied treatment in the second passed silently.
for d in two-a two-b; do
  skill "$TMP/$d" "matches the task"
  mkdir -p "$TMP/$d/sample-service/.claude/skills/second"
  printf -- '---\nname: second\ndescription: identical everywhere\n---\n\nbody\n' \
    > "$TMP/$d/sample-service/.claude/skills/second/SKILL.md"
done
sedi 's/^description: matches the task$/description: an unrelated domain/' \
  "$TMP/two-b/sample-service/.claude/skills/s/SKILL.md"
# CRLF frontmatter must not be reported as a whole-file body difference
for d in crlf-a crlf-b; do
  mkdir -p "$TMP/$d/sample-service/.claude/skills/s"
done
printf -- '---\r\nname: s\r\ndescription: matches the task\r\n---\r\n\r\nbody\r\n' \
  > "$TMP/crlf-a/sample-service/.claude/skills/s/SKILL.md"
printf -- '---\r\nname: s\r\ndescription: an unrelated domain\r\n---\r\n\r\nbody\r\n' \
  > "$TMP/crlf-b/sample-service/.claude/skills/s/SKILL.md"

mkdir -p "$TMP/name-differs/sample-service/.claude/skills/s"
printf -- '---\nname: OTHER\ndescription: an unrelated domain\n---\n\n## When this applies\n\nAlways.\n' \
  > "$TMP/name-differs/sample-service/.claude/skills/s/SKILL.md"

# §4a round 2 at stop 9: this line announced "16 cases" while 26 ran. Two numbers that can
# disagree is exactly what this file exists to refuse, so the count is now ASSERTED at the end
# rather than announced at the start -- a drift between EXPECTED_CASES and the cases actually
# executed FAILS the verifier instead of misinforming its reader.
EXPECTED_CASES=27
echo "verify-overlay-parity-checker: expecting ${EXPECTED_CASES} cases"

check "arms differing only in description are accepted"      0 "parity holds" \
  --allow-differ description "$TMP/a" "$TMP/b"
check "  and the identical body is reported with its sha"    0 "body identical" \
  --allow-differ description "$TMP/a" "$TMP/b"

# THE CASE THE EXPERIMENT'S VALIDITY RESTS ON.
check "a differing BODY is refused"                          2 "BODY differs" \
  --allow-differ description "$TMP/a" "$TMP/body-differs"
check "an undeclared frontmatter key is refused"             2 "'name: OTHER'" \
  --allow-differ description "$TMP/a" "$TMP/name-differs"
check "a file present in only one arm is refused"            2 "only in" \
  --allow-differ description "$TMP/a" "$TMP/extra-file"
check "a differing NON-skill file is refused"                2 "non-skill file differs" \
  --allow-differ description "$TMP/a-plus" "$TMP/shared-differs"

# A treatment that was never applied looks like a working experiment from every other angle.
check "identical arms are refused as treatment-not-applied"  3 "IDENTICAL in both arms" \
  --allow-differ description "$TMP/a" "$TMP/same-desc"

check "a missing overlay directory is a usage error"         1 "not a directory" \
  --allow-differ description "$TMP/a" "$TMP/nope"

# --- §4a round 1, and every one of these passed the first version -------------
check "a SYMLINKED SKILL.md is refused, identical bytes or not" 2 "symlink on one side only" \
  --allow-differ description "$TMP/a" "$TMP/symlinked"
check "a differing frontmatter COMMENT line is refused"      2 "key was not declared" \
  --allow-differ description "$TMP/a" "$TMP/comment-differs"
check "a DUPLICATED frontmatter key is refused, not resolved" 2 "appears 2 times" \
  --allow-differ description "$TMP/a" "$TMP/dup-key"
check "DIRECTORY symlinks to different targets are refused"  2 "symlink targets differ" \
  --allow-differ description "$TMP/dirlink-a" "$TMP/dirlink-b"
check "a differing FILE MODE is refused, bytes or not"       2 "file mode differs" \
  --allow-differ description "$TMP/a" "$TMP/mode-differs"
check "a second skill with the treatment UNAPPLIED is refused" 3 "IDENTICAL in both arms" \
  --allow-differ description "$TMP/two-a" "$TMP/two-b"
check "CRLF frontmatter is not a whole-file body difference"  0 "parity holds" \
  --allow-differ description "$TMP/crlf-a" "$TMP/crlf-b"
# and the duplicate must be caught even when the winning line matches, which is the whole point
check "  even when the last of the duplicates matches"       2 "appears 2 times" \
  --allow-differ description "$TMP/same-desc" "$TMP/dup-key"

# --- agent overlays, added 2026-09-04 at spine stop 9 -------------------------
# Until stop 9 this script proved the checker only on SKILL.md. An agent overlay fell into the
# opaque branch and exited 2 whether or not the declared key was the one that differed, so the
# checker was unusable as a parity control for the customization class Phase 4A is about.
# These six prove the new class BOTH ways: it must pass a correct declaration and it must still
# refuse every way of breaking the one-variable claim.
agent() { # agent <dir> <tools-line-or-empty> <description> [body-extra]
  local d="$1" tools="$2" desc="$3" extra="${4:-}"
  mkdir -p "$d/.claude/agents"
  {
    printf -- '---\nname: repo-reviewer\ndescription: %s\nmodel: claude-haiku-4-5-20251001\n' "$desc"
    if [[ -n "$tools" ]]; then printf 'tools: %s\n' "$tools"; fi
    printf -- '---\n\nYou are a backend reviewer.\n'
    if [[ -n "$extra" ]]; then printf '%s\n' "$extra"; fi
  } > "$d/.claude/agents/repo-reviewer.md"
}
agent "$TMP/ag-narrow"  "Read, Grep, Glob"        "Reviews code."
agent "$TMP/ag-wide"    "Read, Grep, Glob, Bash"  "Reviews code."
agent "$TMP/ag-none"    ""                        "Reviews code."
agent "$TMP/ag-bodydiff" "Read, Grep, Glob, Bash" "Reviews code." "Also never write files."
agent "$TMP/ag-descdiff" "Read, Grep, Glob"       "Reviews code, read-only."
mkdir -p "$TMP/ag-github/.github/agents"
cp "$TMP/ag-narrow/.claude/agents/repo-reviewer.md" "$TMP/ag-github/.github/agents/repo-reviewer.agent.md"
mkdir -p "$TMP/ag-github2/.github/agents"
cp "$TMP/ag-wide/.claude/agents/repo-reviewer.md" "$TMP/ag-github2/.github/agents/repo-reviewer.agent.md"

check "AGENT: a declared 'tools' difference is parity"        0 "parity holds" \
  --allow-differ tools "$TMP/ag-narrow" "$TMP/ag-wide"
check "AGENT: an UNdeclared 'tools' difference is refused"    2 "key was not declared" \
  --allow-differ description "$TMP/ag-narrow" "$TMP/ag-wide"
check "AGENT: a tools line added, declared --allow-added"    0 "parity holds" \
  --allow-added tools "$TMP/ag-none" "$TMP/ag-narrow"
check "AGENT: a differing BODY is refused even if tools ok"   2 "BODY differs" \
  --allow-differ tools "$TMP/ag-wide" "$TMP/ag-bodydiff"
check "AGENT: two differing keys, only one declared, refused" 2 "key was not declared" \
  --allow-differ tools "$TMP/ag-narrow" "$TMP/ag-descdiff"
check "AGENT: identical arms are the unapplied-treatment case" 3 "IDENTICAL in both arms" \
  --allow-differ tools "$TMP/ag-narrow" "$TMP/ag-narrow"
check "AGENT: .github/agents/*.agent.md is the same class"    0 "parity holds" \
  --allow-differ tools "$TMP/ag-github" "$TMP/ag-github2"
# And the default bucket must stay STRICT: a markdown file that is not a recognised class
# must still fail on any byte difference, never be excused by --allow-differ.
mkdir -p "$TMP/ag-plain-a" "$TMP/ag-plain-b"
printf -- '---\ntools: Read\n---\nbody\n' > "$TMP/ag-plain-a/notes.md"
printf -- '---\ntools: Read, Bash\n---\nbody\n' > "$TMP/ag-plain-b/notes.md"
check "an UNRECOGNISED frontmatter file is still opaque"      2 "non-skill file differs" \
  --allow-differ tools "$TMP/ag-plain-a" "$TMP/ag-plain-b"

echo
# --- §4a round 1 at stop 9: the codex critic's missing-key finding, reproduced by hand -----
# A DELETED key is not a CHANGED key. Before the fix, arm A with `description:` and arm B with
# the line removed exited 0 under --allow-differ description, reporting "the arms differ only in
# description" for a pair where one arm has no such field at all.
check "a DELETED declared key is refused, not called a difference" 2 "ABSENT in the other arm" \
  --allow-differ description "$TMP/a" "$TMP/desc-missing"
# ...and the same pair is parity when the caller says the PRESENCE is the treatment, which is
# E-005's actual design: arm C has no `tools:` line and arm T adds one.
check "  ...unless --allow-added says presence IS the treatment" 0 "parity holds" \
  --allow-added description "$TMP/a" "$TMP/desc-missing"

echo
# --- §4a round 2 at stop 9: `---` INSIDE a frontmatter value ----------------------------
# The delimiter search was byte-offset based and took these hyphens for the closing marker,
# so a VALID one-variable pair was rejected with exit 2. Fails closed, still wrong.
mkdir -p "$TMP/dash-a/.claude/agents" "$TMP/dash-b/.claude/agents"
printf -- '---\nname: r\ndescription: reviews --- cautiously\nmodel: m\n---\n\nBody.\n' \
  > "$TMP/dash-a/.claude/agents/r.md"
printf -- '---\nname: r\ndescription: reviews cautiously\nmodel: m\n---\n\nBody.\n' \
  > "$TMP/dash-b/.claude/agents/r.md"
check "a '---' inside a frontmatter VALUE is not the delimiter" 0 "parity holds" \
  --allow-differ description "$TMP/dash-a" "$TMP/dash-b"

echo
echo "verify-overlay-parity-checker: ${pass} passed, ${fail} failed"
ran=$((pass+fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-overlay-parity-checker: FAIL — announced ${EXPECTED_CASES} cases, executed ${ran}." >&2
  echo "  A fixture was added or removed without updating EXPECTED_CASES. The count a reader" >&2
  echo "  trusts and the count that ran must be the same number or this file proves nothing." >&2
  exit 1
fi
[[ "$fail" -eq 0 ]]
