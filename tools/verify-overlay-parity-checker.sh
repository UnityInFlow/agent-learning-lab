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
# --- the three the §4a gate found, all of which PASSED the first version ------
# A symlinked SKILL.md with identical bytes: `open()` follows the link, so byte comparison
# said parity while the two overlays install structurally different things.
mkdir -p "$TMP/symlinked/sample-service/.claude/skills/s"
printf 'x\n' > "$TMP/symlink-target.md"
cp "$TMP/a/sample-service/.claude/skills/s/SKILL.md" "$TMP/real-skill.md"
ln -s "$TMP/real-skill.md" "$TMP/symlinked/sample-service/.claude/skills/s/SKILL.md"
# A comment line carrying a real difference: a dict parse drops every line with no colon.
skill "$TMP/comment-differs" "matches the task"
sed -i '' '2i\
# arm C only: reviewed 2026-09-04
' "$TMP/comment-differs/sample-service/.claude/skills/s/SKILL.md"
# A duplicated key: a dict keeps the LAST one and compares equal on it.
skill "$TMP/dup-key" "matches the task"
sed -i '' 's/^description: matches the task$/description: SOMETHING ELSE ENTIRELY\
description: matches the task/' "$TMP/dup-key/sample-service/.claude/skills/s/SKILL.md"

# §4a round 2 at 2/2: os.walk puts DIRECTORY symlinks in dirnames, not names, so an overlay
# whose skills directory is a link compared as an EMPTY overlay against another empty one.
mkdir -p "$TMP/dirlink-a/sample-service/.claude" "$TMP/dirlink-b/sample-service/.claude"
mkdir -p "$TMP/target-one/s" "$TMP/target-two/s"
printf 'one\n' > "$TMP/target-one/s/SKILL.md"
printf 'two\n' > "$TMP/target-two/s/SKILL.md"
ln -s "$TMP/target-one" "$TMP/dirlink-a/sample-service/.claude/skills"
ln -s "$TMP/target-two" "$TMP/dirlink-b/sample-service/.claude/skills"

mkdir -p "$TMP/name-differs/sample-service/.claude/skills/s"
printf -- '---\nname: OTHER\ndescription: an unrelated domain\n---\n\n## When this applies\n\nAlways.\n' \
  > "$TMP/name-differs/sample-service/.claude/skills/s/SKILL.md"

echo "verify-overlay-parity-checker: 13 cases"

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
# and the duplicate must be caught even when the winning line matches, which is the whole point
check "  even when the last of the duplicates matches"       2 "appears 2 times" \
  --allow-differ description "$TMP/same-desc" "$TMP/dup-key"

echo
echo "verify-overlay-parity-checker: ${pass} passed, ${fail} failed"
[[ "$fail" -eq 0 ]]
