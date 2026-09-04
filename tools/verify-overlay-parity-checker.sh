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
mkdir -p "$TMP/name-differs/sample-service/.claude/skills/s"
printf -- '---\nname: OTHER\ndescription: an unrelated domain\n---\n\n## When this applies\n\nAlways.\n' \
  > "$TMP/name-differs/sample-service/.claude/skills/s/SKILL.md"

echo "verify-overlay-parity-checker: 8 cases"

check "arms differing only in description are accepted"      0 "parity holds" \
  --allow-differ description "$TMP/a" "$TMP/b"
check "  and the identical body is reported with its sha"    0 "body identical" \
  --allow-differ description "$TMP/a" "$TMP/b"

# THE CASE THE EXPERIMENT'S VALIDITY RESTS ON.
check "a differing BODY is refused"                          2 "BODY differs" \
  --allow-differ description "$TMP/a" "$TMP/body-differs"
check "an undeclared frontmatter key is refused"             2 "frontmatter key 'name' differs" \
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

echo
echo "verify-overlay-parity-checker: ${pass} passed, ${fail} failed"
[[ "$fail" -eq 0 ]]
