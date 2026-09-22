#!/usr/bin/env bash
# Is every tracked *.sh in this repository either ShellChecked by CI or exempt for a
# reason someone wrote down?
#
#   ./tools/verify-shellcheck-coverage.sh
#
# WHY THIS EXISTS. CI's two ShellCheck steps scan `./tools` and `./.claude/hooks`. That is
# a fact about two directories, not about the repository, and nothing compared the two sets
# until this script did. A shell file added anywhere else would be unscanned, and unscanned
# looks exactly like clean — the guardrail-layer mistake this project keeps meeting, where
# a control is assumed over a scope wider than the one it runs on.
#
# THE RULE. For every path in `git ls-files '*.sh'`: it sits under a directory named as a
# `scandir:` in .github/workflows/ci.yml, OR it sits under a prefix listed in
# tools/shellcheck-exempt.tsv as `<path-prefix><TAB><why>`. The scandirs are READ OUT OF
# THE WORKFLOW, never restated here, so adding a scanned directory does not need this file
# edited and cannot drift from what CI actually scans.
#
# WHAT IT SAYS, EXACTLY. That each tracked shell file is inside ShellCheck's scan or has a
# written exemption. It says NOTHING about whether any script is correct, whether the
# severity is right, or whether the scan passes — `shellcheck -S warning` in CI answers
# that, and this script would happily admit a repository whose every script is broken.
#
# WHAT "PREFIX" MEANS, because a string prefix is not a path prefix. Every prefix on both
# sides — scandir and exempt row alike — has to end on a PATH COMPONENT BOUNDARY. `evidence`
# covers `evidence/b06/run.sh` and the file `evidence` itself; it does NOT cover
# `evidence2/dump.sh`. The two sides used to be asymmetric — scandirs were normalised to a
# trailing slash and exempt rows were matched verbatim — so a row that merely forgot its
# slash silently exempted a sibling directory nobody had written down. One `covers` answers
# both now, and fixture 10 is the sibling directory proving it.
#
# AND FOUR BOUNDS WORTH SAYING OUT LOUD.
#
#   1. An exempt prefix that is REDUNDANT — one already inside a scandir — is admitted here.
#      The "matches no tracked file" rule does not catch it, because such a prefix does match
#      real files; it is simply a row that claims nothing. Refusing it would be a rule nobody
#      has registered, so this script does not pretend to have one.
#   2. Coverage is only ever read as an EXPLICIT `scandir:` under a step whose `uses:` line
#      names the ShellCheck action. A workflow that omitted the key and leaned on whatever
#      the action defaults to is refused with exit 2 ("names no scandir"), not admitted — a
#      configuration that may well be scanning everything. That is the conservative direction
#      of the two, and deliberately so: this script's whole job is to never call an unscanned
#      file scanned. If the lab ever does lean on the default, this is the line to change, and
#      the change wants its own fixture.
#   3. `severity:` is not read at all. A scandir scanned at a severity that reports nothing
#      still counts as covered here; `shellcheck -S warning` in CI is what makes it mean
#      something.
#   4. The `*` whole-checkout sentinel BELONGS TO THE SCANDIR SIDE and to nothing else. It is
#      minted in one place — `scandir: .` in scandir_prefixes — and honoured in one place,
#      is_under's third argument. The exempt table has no wildcard: a row reading `*` is a
#      path prefix that matches no tracked file, and is refused as one. It did not used to
#      be, and that is fixture 12.
#
# OVERRIDES, which is also how this script proves it REFUSES. Setting any of
#
#     SHELLCHECK_COVERAGE_SCRIPTS   a file, one path per line, instead of `git ls-files`
#     SHELLCHECK_COVERAGE_WORKFLOW  a workflow file instead of .github/workflows/ci.yml
#     SHELLCHECK_COVERAGE_EXEMPT    an exempt table instead of tools/shellcheck-exempt.tsv
#
# puts the script in SINGLE-CHECK mode: it runs that one comparison and exits 0 (covered)
# or 1 (refused, offending paths on stdout). With none of them set it checks the live
# repository as case 1 and then re-invokes ITSELF once per fixture under
# `tools/fixtures/shellcheck-coverage/`, through those same variables, so every refusal
# below is demonstrated by the same code path that guards the repository rather than by a
# second implementation that could drift from it.
#
# Exit 0 every case behaved as registered · 1 SINGLE-CHECK MODE REFUSED · 2 A CASE FAILED,
# or a usage error.
set -uo pipefail
# Resolved BEFORE the cd, because the fixture cases re-invoke this same file and a relative
# $0 stops resolving the moment the working directory moves.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "$(dirname "$0")/.." || exit 2

DEFAULT_WORKFLOW=".github/workflows/ci.yml"
DEFAULT_EXEMPT="tools/shellcheck-exempt.tsv"
FIXTURES="tools/fixtures/shellcheck-coverage"

# Asserted at the END against the cases that actually ran, for the reason
# tools/verify-phase-contract-checker.sh gives: a count announced before any case has
# executed is a count no case has to agree with.
EXPECTED_CASES=13

# --------------------------------------------------------------------------------------
# Reading the scandirs out of the workflow.
#
# ONLY A SHELLCHECK STEP'S scandir COUNTS. The key is read while the most recent `uses:`
# names shellcheck, and a new list item resets that. A `scandir:` input belonging to some
# other action — or left behind in a neighbouring step by an edit — used to be read as a
# ShellCheck scan directory, which would have admitted every script under a directory
# nothing shellchecks. Fixture 11 is that foreign step.
#
# A value of `.` or `./` means the whole checkout; it becomes the sentinel `*`, which no
# path prefix can collide with. A BLANK value is never that sentinel — an empty prefix list
# has to mean "covers nothing", or an empty exempt table would silently cover every script
# in the repository. Blank emits the marker `!blank` instead, which check_coverage names as
# an offender and drops: an empty scandir scans nothing and saying so is the point. Fixture
# 9 is the blank value; before it, `scandir:` with no value read as "scans everything" and
# returned a clean exit over an uncovered repository, in flat contradiction of this comment.
# --------------------------------------------------------------------------------------
scandir_prefixes() {
  local workflow="$1" line dir uses in_shellcheck=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*-[[:space:]] ]] && in_shellcheck=0
    if [[ "$line" =~ uses:[[:space:]]*(.*)$ ]]; then
      uses="${BASH_REMATCH[1]}"
      # A TRAILING YAML COMMENT IS NOT PART OF THE ACTION REFERENCE. The substring test used
      # to see the whole remainder of the line, so
      # `uses: other/analyzer@v1 # replaces shellcheck temporarily` read as a ShellCheck step
      # and its scandir was believed to be scanned — a comment deciding what CI covers.
      # `%%` strips from the FIRST ` #`, so a comment that itself contains a `#` cannot
      # leave half of itself behind. Fixture 13 is that line.
      uses="${uses%%[[:space:]]#*}"
      if [[ "$uses" == *shellcheck* ]]; then in_shellcheck=1; else in_shellcheck=0; fi
      continue
    fi
    [[ "$line" =~ ^[[:space:]]*scandir:[[:space:]]*(.*)$ ]] || continue
    [[ "$in_shellcheck" -eq 1 ]] || continue
    dir="${BASH_REMATCH[1]}"
    dir="${dir%"${dir##*[![:space:]]}"}"          # trailing whitespace
    dir="${dir%\"}"; dir="${dir#\"}"
    dir="${dir%\'}"; dir="${dir#\'}"
    if [[ -z "${dir//[[:space:]]/}" ]]; then
      printf '!blank\n'
      continue
    fi
    dir="${dir#./}"
    dir="${dir%/}"
    if [[ -z "$dir" || "$dir" == "." ]]; then
      printf '*\n'
      continue
    fi
    printf '%s/\n' "$dir"
  done < "$workflow"
}

# covers <path> <prefix> — one answer for both sides of the comparison, and A PURE PATH
# TEST: no wildcard, no sentinel, no meaning that depends on which side supplied the prefix.
# True when the prefix IS the path, or names a directory the path sits under. A prefix that
# does not end in `/` still has to end on a component boundary, so `evidence` never covers
# `evidence2/`.
#
# THE `*` SENTINEL IS DELIBERATELY NOT HONOURED HERE. The first line used to read
# `[[ "$p" == '*' ]] && return 0`, which answered true whichever side handed it the `*` —
# and only the scandir side is documented to mint one (`scandir: .`). A literal `*` row in
# the exempt table therefore matched the first tracked script in Pass 1, so the row was
# admitted, and then covered every script in Pass 2: the script exited 0 over a repository
# nothing scanned, which is precisely the "unscanned looks exactly like clean" failure the
# header says this file exists to prevent. The sentinel now lives only where it is
# documented — is_under's third argument, set for the scandir list and for nothing else —
# and `*` in the exempt table is just a prefix matching no tracked file. Fixture 12 is that
# row, and it is ADMITTED by the version of this script that had the short-circuit.
covers() {
  local path="$1" p="$2"
  [[ "$path" == "$p" ]] && return 0
  if [[ "$p" == */ ]]; then
    [[ "$path" == "$p"* ]] && return 0
    return 1
  fi
  [[ "$path" == "$p"/* ]] && return 0
  return 1
}

# is_under <path> <newline-delimited prefixes> [sentinel_ok]
#
# sentinel_ok=1 marks this list as a SCANDIR list — the one side scandir_prefixes can hand a
# `*`, and so the one side on which `*` means "the whole checkout". Every other list, the
# exempt table above all, is compared as plain paths, where `*` covers nothing.
is_under() {
  local path="$1" prefixes="$2" sentinel_ok="${3:-0}" p
  while IFS= read -r p || [[ -n "$p" ]]; do
    [[ -z "${p//[[:space:]]/}" ]] && continue
    if [[ "$p" == '*' ]]; then
      [[ "$sentinel_ok" -eq 1 ]] && return 0
      continue
    fi
    covers "$path" "$p" && return 0
  done <<< "$prefixes"
  return 1
}

# --------------------------------------------------------------------------------------
# The comparison itself. 0 covered · 1 refused (offenders on stdout) · 2 usage error.
# --------------------------------------------------------------------------------------
check_coverage() {
  local pop="$1" workflow="$2" exempt="$3"
  local line path reason lineno=0 offenders=0
  local scandirs="" ex_prefixes="" pop_paths="" matched p tracked
  local kept="" blanks=0

  [[ -r "$pop" ]]      || { echo "verify-shellcheck-coverage: cannot read script list $pop" >&2; return 2; }
  [[ -r "$workflow" ]] || { echo "verify-shellcheck-coverage: cannot read workflow file $workflow" >&2; return 2; }
  [[ -r "$exempt" ]]   || { echo "verify-shellcheck-coverage: cannot read exempt table $exempt" >&2; return 2; }

  scandirs="$(scandir_prefixes "$workflow")"
  if [[ -z "$scandirs" ]]; then
    echo "verify-shellcheck-coverage: $workflow names no scandir — there is no scan to compare against" >&2
    return 2
  fi

  # A `scandir:` with an empty value is named and then dropped. It is NOT the whole-checkout
  # sentinel and it is not silence either: the workflow claims a scan and hands it nothing.
  # Dropping it can empty the prefix list, which is exactly what "covers nothing" means, so
  # the walk below continues and Pass 2 names every script the workflow no longer reaches.
  while IFS= read -r p || [[ -n "$p" ]]; do
    [[ -z "${p//[[:space:]]/}" ]] && continue
    if [[ "$p" == '!blank' ]]; then
      blanks=$((blanks + 1))
      continue
    fi
    kept="$kept$p"$'\n'
  done <<< "$scandirs"
  if [[ "$blanks" -gt 0 ]]; then
    echo "  $workflow gives $blanks ShellCheck step(s) an empty scandir:, which scans nothing"
    offenders=$((offenders + blanks))
  fi
  scandirs="$kept"

  # Membership is tested with bash pattern matching against newline-delimited lists, NOT
  # with `printf ... | grep -Fxq`: under `set -o pipefail` that pipeline reports failure
  # whenever grep -q exits on the first match before printf has finished writing, and the
  # sibling runner/verify-ci-coverage.sh passed and then failed with nothing changed in
  # between until it stopped doing that.
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    pop_paths="$pop_paths$line"$'\n'
  done < "$pop"

  # Pass 1 — the exempt table. Every row is checked before anything is exempted by it, so
  # a malformed table cannot quietly cover a script.
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ "$line" == "#"* ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue
    path="${line%%$'\t'*}"
    reason=""
    [[ "$line" == *$'\t'* ]] && reason="${line#*$'\t'}"

    if [[ -z "${path//[[:space:]]/}" ]]; then
      echo "  $exempt:$lineno names no path prefix"
      offenders=$((offenders + 1))
      continue
    fi
    if [[ -z "${reason//[[:space:]]/}" ]]; then
      echo "  $exempt:$lineno exempts $path for no stated reason"
      offenders=$((offenders + 1))
    fi
    if [[ $'\n'"$ex_prefixes" == *$'\n'"$path"$'\n'* ]]; then
      echo "  $exempt:$lineno lists $path a second time"
      offenders=$((offenders + 1))
      continue
    fi
    # `tracked`, not `p`: here the loop variable is the SCRIPT and `$path` is the PREFIX,
    # the opposite way round from is_under's loop, and a reader tracing covers() through two
    # call sites should not have to hold that swap in their head.
    matched=0
    while IFS= read -r tracked || [[ -n "$tracked" ]]; do
      [[ -z "${tracked//[[:space:]]/}" ]] && continue
      covers "$tracked" "$path" && { matched=1; break; }
    done <<< "$pop_paths"
    if [[ "$matched" -eq 0 ]]; then
      echo "  $exempt:$lineno exempts $path, which matches no tracked shell script"
      offenders=$((offenders + 1))
    fi
    ex_prefixes="$ex_prefixes$path"$'\n'
  done < "$exempt"

  # Pass 2 — the population. Scanned by neither a scandir nor an exempt prefix is the gap
  # this whole script exists to make visible.
  while IFS= read -r path || [[ -n "$path" ]]; do
    [[ -z "${path//[[:space:]]/}" ]] && continue
    is_under "$path" "$scandirs" 1 && continue
    is_under "$path" "$ex_prefixes" && continue
    echo "  $path is ShellChecked by no scandir in $workflow and exempted in no row of $exempt"
    offenders=$((offenders + 1))
  done < "$pop"

  [[ "$offenders" -eq 0 ]] && return 0
  return 1
}

# --------------------------------------------------------------------------------------
# Single-check mode: any override set means "compare exactly this and tell me the answer".
# --------------------------------------------------------------------------------------
TMP="$(mktemp -d)" || exit 2
trap 'rm -rf "$TMP"' EXIT

scripts_of_this_checkout() {
  git ls-files '*.sh' > "$1" 2>/dev/null || return 2
  [[ -s "$1" ]] || return 2
  return 0
}

if [[ -n "${SHELLCHECK_COVERAGE_SCRIPTS:-}${SHELLCHECK_COVERAGE_WORKFLOW:-}${SHELLCHECK_COVERAGE_EXEMPT:-}" ]]; then
  single_pop="${SHELLCHECK_COVERAGE_SCRIPTS:-}"
  if [[ -z "$single_pop" ]]; then
    single_pop="$TMP/scripts.txt"
    scripts_of_this_checkout "$single_pop" || {
      echo "verify-shellcheck-coverage: git ls-files found no *.sh — is this a checkout?" >&2
      exit 2
    }
  fi
  check_coverage "$single_pop" \
    "${SHELLCHECK_COVERAGE_WORKFLOW:-$DEFAULT_WORKFLOW}" \
    "${SHELLCHECK_COVERAGE_EXEMPT:-$DEFAULT_EXEMPT}"
  exit $?
fi

# --------------------------------------------------------------------------------------
# Full run: the live repository, then every fixture.
# --------------------------------------------------------------------------------------
pass=0
fail=0

echo "verify-shellcheck-coverage: the live repository, then the fixtures that prove it refuses"
echo

LIVE_POP="$TMP/scripts.txt"
if ! scripts_of_this_checkout "$LIVE_POP"; then
  echo "verify-shellcheck-coverage: git ls-files found no *.sh — is this a checkout?" >&2
  exit 2
fi

live_out="$(check_coverage "$LIVE_POP" "$DEFAULT_WORKFLOW" "$DEFAULT_EXEMPT" 2>&1)"
live_rc=$?
if [[ "$live_rc" -eq 0 ]]; then
  echo "  ok   — 1 every tracked *.sh is under a scanned directory or a written exemption ($(grep -c . "$LIVE_POP") scripts)"
  pass=$((pass + 1))
else
  # NOT "(exit $live_rc)". That is check_coverage's internal 1, while this run will exit 2
  # ("a case failed") — and a reader wiring a hook on the number they saw printed would have
  # wired it on a code full mode never returns.
  echo "  FAIL — 1 the live repository is not covered; this run exits 2, not $live_rc:"
  printf '%s\n' "$live_out"
  fail=$((fail + 1))
fi

# fixture_case <number> <directory> <expected exit> <what it proves> [<the offender it names>]
#
# THE FIFTH ARGUMENT IS WHY THE CASE IS TRUSTED. Exit 1 only says that something refused.
# Fixture 10 registers a path-component boundary, but a malformed row added to its table
# would refuse too, and the case would go on reporting the boundary as proven while the
# boundary was broken — a green case standing over a dead control, the shape this project
# keeps meeting. Every refusing case below therefore names the line it expects to see, so a
# refusal for any other reason fails it.
fixture_case() {
  local n="$1" dir="$FIXTURES/$2" want="$3" desc="$4" want_text="${5:-}"
  local out rc

  if [[ ! -d "$dir" ]]; then
    echo "  FAIL — $n $desc: fixture $dir is missing"
    fail=$((fail + 1))
    return
  fi

  out="$(SHELLCHECK_COVERAGE_SCRIPTS="$dir/scripts.txt" \
         SHELLCHECK_COVERAGE_WORKFLOW="$dir/ci.yml" \
         SHELLCHECK_COVERAGE_EXEMPT="$dir/shellcheck-exempt.tsv" \
         "$SELF" 2>&1)"
  rc=$?

  if [[ "$rc" -ne "$want" ]]; then
    echo "  FAIL — $n $desc: expected exit $want, got $rc: $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  if [[ "$want" -eq 1 && -z "${out//[[:space:]]/}" ]]; then
    echo "  FAIL — $n $desc: refused with exit 1 but named no offending path"
    fail=$((fail + 1))
    return
  fi
  if [[ "$want" -eq 0 && -n "${out//[[:space:]]/}" ]]; then
    echo "  FAIL — $n $desc: admitted but still complained: $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  if [[ -n "$want_text" && "$out" != *"$want_text"* ]]; then
    echo "  FAIL — $n $desc: refused, but not for the registered reason —"
    echo "         expected to read \"$want_text\" and got: $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  echo "  ok   — $n $desc"
  pass=$((pass + 1))
}

fixture_case 2 clean                 0 "scripts wholly covered by the scandirs and the table are admitted"
fixture_case 3 uncovered             1 "a script under neither a scandir nor an exempt prefix is refused" \
  "infra/deploy.sh is ShellChecked by no scandir"
fixture_case 4 exempt-unknown-prefix 1 "an exempt prefix matching no tracked script is refused" \
  "exempts archive/, which matches no tracked shell script"
fixture_case 5 exempt-empty-reason   1 "an exempt row whose reason column is empty is refused" \
  "exempts evidence/ for no stated reason"
fixture_case 6 exempt-no-tab         1 "an exempt row with no reason column at all is refused" \
  "exempts evidence/ for no stated reason"
fixture_case 7 exempt-duplicate      1 "a prefix listed twice in the table is refused" \
  "lists evidence/ a second time"
fixture_case 8 all-exempt            0 "NEGATIVE CONTROL: scripts covered only by the table are admitted"
# 9-13 were each written after a reviewer found the script admitting something it should
# not have. Case 9 is the one that mattered: a blank scandir: read as "scans everything".
fixture_case 9  scandir-blank            1 "a scandir: with an empty value covers nothing, and is said so" \
  "empty scandir:, which scans nothing"
fixture_case 10 exempt-prefix-no-boundary 1 "an exempt prefix stops at a path component: evidence never covers evidence2/" \
  "evidence2/dump.sh is ShellChecked by no scandir"
fixture_case 11 scandir-foreign-step      1 "a scandir: on a step that is not ShellCheck is not coverage" \
  "infra/deploy.sh is ShellChecked by no scandir"
# 12 and 13 are round 3 of the same review. Both are cases the PREVIOUS version of this
# script ADMITTED: a `*` exempt row that exempted the whole repository through a sentinel
# only the scandir side is documented to mint, and a foreign action whose trailing comment
# happened to contain the word shellcheck. Each registers the offender it expects, so a
# regression that refuses for some other reason cannot keep the case green.
fixture_case 12 exempt-star-sentinel  1 "a literal * in the exempt table is a prefix matching nothing, not a wildcard" \
  "unscanned/run.sh is ShellChecked by no scandir"
fixture_case 13 uses-comment-shellcheck 1 "the word shellcheck in a trailing comment does not make a step a ShellCheck step" \
  "scripts/deploy.sh is ShellChecked by no scandir"

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-shellcheck-coverage: ${ran} cases ran, ${EXPECTED_CASES} registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  exit 2
fi
echo "verify-shellcheck-coverage: ${pass} passed, ${fail} failed, of ${EXPECTED_CASES} registered cases"
[[ "$fail" -eq 0 ]] || exit 2
