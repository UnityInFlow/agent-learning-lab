#!/usr/bin/env bash
# Is every tracked *.sh in this repository either ShellChecked by CI or exempt for a
# named reason — judged against a workflow block that is PINNED, not parsed?
#
#   ./tools/verify-shellcheck-coverage.sh
#
# WHY THIS EXISTS. A script nothing lints looks exactly like a script that lints clean:
# both produce a green CI run and no output. Nothing here recorded that `evidence/` and
# `build/customizations/` sit outside ShellCheck's scan, or why, so the difference between
# "deliberately out of scope" and "quietly missed" was not written down anywhere.
#
# WHY IT DOES NOT READ ci.yml AS YAML. The first attempt at this check (lab#109) scanned
# ci.yml line by line for `uses:` and `scandir:` values. Three review rounds produced three
# separate ways that answered wrongly while looking right: an action whose name merely
# contained "shellcheck" was admitted as the gating step, a scandir written above its own
# `uses:` line was dropped, and a trailing comment on a scandir value became part of the
# directory name. So this script parses no YAML at all. tools/shellcheck-scanned.txt holds
# the ShellCheck steps byte-for-byte, and the only question asked of ci.yml is whether it
# contains that block verbatim, exactly once, as a fixed string. When it does not, this
# script refuses and says the block must be re-pinned deliberately.
#
# THE SCANDIRS LINE IS A HUMAN ASSERTION, ON PURPOSE. The directories are read from the
# `scandirs:` line of the pinned file, not extracted from the block. It is deliberately NOT
# cross-checked against the block, because cross-checking it would be exactly the YAML
# parsing above. Pinning is what makes it reviewable: the block and the claim about it sit
# in one file, and neither can change without the other being looked at in the same commit.
#
# NO WILDCARD, NO SENTINEL. An empty scandirs entry and an empty exempt prefix are errors,
# never "covers everything"; a literal `*` in either file is just a path that matches
# nothing. Globbing is disabled below so the shell cannot expand one behind your back.
#
# BOUNDARY MATCHING. Directories and prefixes are normalised the same way (leading `./` and
# trailing `/` stripped) and matched on a path-component boundary: a path is covered by `d`
# when it IS `d` or begins with `d/`. So `evidence` never covers `evidence2/x.sh`, and
# `build/customizations` never covers `build/customizations-old/x.sh`.
#
# WHAT IT SAYS, AND WHAT IT DOES NOT. It says only that each tracked *.sh is scanned or
# exempt. It never says a script is CORRECT — ShellCheck's own job — and it says nothing
# about shell files without a .sh extension, which `git ls-files '*.sh'` does not see. It
# never invents an exempt row: a prefix matching no tracked file, carrying no reason,
# repeated, or naming something a scandir already covers is refused rather than accepted.
#
# OVERRIDES, which is also how this script proves it REFUSES. Setting any of
#
#     SHELLCHECK_CI_FILE        a workflow file instead of .github/workflows/ci.yml
#     SHELLCHECK_PINNED_FILE    a pinned block instead of tools/shellcheck-scanned.txt
#     SHELLCHECK_EXEMPT_FILE    an exempt table instead of tools/shellcheck-exempt.tsv
#     SHELLCHECK_TRACKED_FILE   a path list instead of `git ls-files '*.sh'`
#
# puts the script in SINGLE-CHECK mode: it runs that one comparison and nothing else. With
# none set it runs the live repository as case 1 and then re-invokes ITSELF once per fixture
# under tools/fixtures/shellcheck-coverage/, through those same variables — so every refusal
# below is demonstrated by the same code path that guards the repository, and each case
# asserts the specific message, not merely a non-zero exit.
#
# EXIT CODES, one contract, obeyed in every path:
#     0  every check this invocation ran passed
#     1  a coverage check refused (single-check mode), or a registered case did not behave
#        as registered, or the number of cases that ran is not the number registered
#     2  usage error, or an input file that could not be read
set -uo pipefail
# Globbing off: a `*` in the pinned file or the exempt table must stay a literal path that
# matches nothing, rather than expanding against the working directory.
set -f
# Resolved BEFORE the cd, because the fixture cases re-invoke this same file and a relative
# $0 stops resolving the moment the working directory moves.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "$(dirname "$0")/.." || exit 2

DEFAULT_CI=".github/workflows/ci.yml"
DEFAULT_PINNED="tools/shellcheck-scanned.txt"
DEFAULT_EXEMPT="tools/shellcheck-exempt.tsv"
FIXTURES="tools/fixtures/shellcheck-coverage"

# Asserted at the END against the cases that actually ran: a count announced before any case
# has executed is a number no case has to agree with.
EXPECTED_CASES=11

if [[ "$#" -gt 0 ]]; then
  echo "verify-shellcheck-coverage: takes no arguments; see the header for the four overrides" >&2
  exit 2
fi

# --------------------------------------------------------------------------------------
# Path helpers. One normalisation, one boundary rule, used for scandirs and prefixes alike.
# --------------------------------------------------------------------------------------
normalise_path() { # normalise_path <path> -> strips leading ./ and trailing /
  local p="$1"
  while [[ "$p" == ./* ]]; do p="${p#./}"; done
  while [[ "$p" == */ ]]; do p="${p%/}"; done
  printf '%s' "$p"
}

covers_path() { # covers_path <normalised dir> <normalised path>
  [[ "$2" == "$1" || "$2" == "$1"/* ]]
}

covered_by_any() { # covered_by_any <normalised path> <newline-separated normalised dirs>
  local p="$1" list="$2" d
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    covers_path "$d" "$p" && return 0
  done <<< "$list"
  return 1
}

# --------------------------------------------------------------------------------------
# The comparison itself. 0 covered · 1 refused (offenders on stdout) · 2 unreadable input.
# --------------------------------------------------------------------------------------
check_coverage() { # check_coverage <ci file> <pinned file> <exempt file> <tracked list file>
  local ci="$1" pinned="$2" exempt="$3" tracked="$4"
  local offenders=0

  [[ -r "$ci" ]]      || { echo "verify-shellcheck-coverage: cannot read workflow file $ci" >&2; return 2; }
  [[ -r "$pinned" ]]  || { echo "verify-shellcheck-coverage: cannot read pinned file $pinned" >&2; return 2; }
  [[ -r "$exempt" ]]  || { echo "verify-shellcheck-coverage: cannot read exempt table $exempt" >&2; return 2; }
  [[ -r "$tracked" ]] || { echo "verify-shellcheck-coverage: cannot read tracked list $tracked" >&2; return 2; }

  # --- the pinned file ------------------------------------------------------------------
  # Leading column-0 '#' lines are documentation. The block runs from the first line that is
  # not one of those to the line before the single column-0 'scandirs:' line.
  local line block="" started=0 seen_scandirs=0 scandirs_value="" trailing=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "scandirs:"* ]]; then
      seen_scandirs=$((seen_scandirs + 1))
      scandirs_value="${line#scandirs:}"
      continue
    fi
    if [[ "$seen_scandirs" -gt 0 ]]; then
      [[ -n "${line//[[:space:]]/}" ]] && trailing=$((trailing + 1))
      continue
    fi
    if [[ "$started" -eq 0 ]]; then
      [[ "$line" == "#"* ]] && continue
      started=1
      block="$line"
      continue
    fi
    block="$block"$'\n'"$line"
  done < "$pinned"

  if [[ "$seen_scandirs" -ne 1 ]]; then
    echo "  $pinned must hold exactly one column-0 'scandirs:' line, found $seen_scandirs"
    offenders=$((offenders + 1))
  fi
  if [[ "$trailing" -gt 0 ]]; then
    echo "  $pinned holds $trailing line(s) after its scandirs: line; the block ends there"
    offenders=$((offenders + 1))
  fi

  # --- (a) ci.yml must contain the pinned block verbatim, exactly once ------------------
  if [[ -z "${block//[[:space:]]/}" ]]; then
    echo "  $pinned holds no pinned block — nothing to compare $ci against"
    offenders=$((offenders + 1))
  else
    local ci_text rest count=0
    ci_text="$(cat "$ci")"
    rest="$ci_text"
    while [[ "$rest" == *"$block"* ]]; do
      count=$((count + 1))
      rest="${rest#*"$block"}"
    done
    if [[ "$count" -eq 0 ]]; then
      echo "  the ShellCheck steps pinned in $pinned are not in $ci verbatim"
      echo "  --- pinned ---"
      printf '%s\n' "$block" | sed 's/^/  | /'
      # The region below is located ONLY so this message can show it, by fixed-string search
      # for the block's first line. Nothing decides anything from it — that would be the
      # YAML reading this script exists not to do.
      local first lines at
      first="${block%%$'\n'*}"
      lines="$(printf '%s\n' "$block" | wc -l | tr -d ' ')"
      at="$(grep -Fn -- "$first" "$ci" | head -1 | cut -d: -f1)"
      if [[ -n "$at" ]]; then
        echo "  --- $ci from line $at (found by fixed-string search, for this message only) ---"
        sed -n "${at},$((at + lines - 1))p" "$ci" | sed 's/^/  | /'
      else
        echo "  --- $ci holds no line equal to the pinned block's first line ---"
      fi
      echo "  if that change was intended the block must be re-pinned deliberately: copy the"
      echo "  steps out of $ci into $pinned in the same commit, where a reviewer sees both."
      offenders=$((offenders + 1))
    elif [[ "$count" -gt 1 ]]; then
      echo "  the pinned block appears $count times in $ci; exactly once is required"
      offenders=$((offenders + 1))
    fi
  fi

  # --- (b) the scandirs -----------------------------------------------------------------
  local scandirs="" d entries=0
  for d in $scandirs_value; do
    entries=$((entries + 1))
    d="$(normalise_path "$d")"
    if [[ -z "$d" ]]; then
      echo "  $pinned: the scandirs: line holds an empty entry, which covers nothing"
      offenders=$((offenders + 1))
      continue
    fi
    if [[ ! -d "$d" ]]; then
      echo "  $pinned: scandirs entry '$d' is not an existing directory"
      offenders=$((offenders + 1))
      continue
    fi
    scandirs="$scandirs$d"$'\n'
  done
  if [[ "$entries" -eq 0 ]]; then
    echo "  $pinned: the scandirs: line names no directory"
    offenders=$((offenders + 1))
  fi

  # --- the tracked population -----------------------------------------------------------
  local p tracked_paths=""
  while IFS= read -r p || [[ -n "$p" ]]; do
    [[ -z "${p//[[:space:]]/}" ]] && continue
    tracked_paths="$tracked_paths$(normalise_path "$p")"$'\n'
  done < "$tracked"

  # --- (c) the exempt table -------------------------------------------------------------
  # Every row is judged before anything is exempted by it, so a malformed table cannot
  # quietly cover a script.
  local lineno=0 raw prefix reason prefixes="" matched also_scanned
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ "$line" == "#"* ]] && continue
    if [[ -z "${line//[[:space:]]/}" ]]; then
      echo "  $exempt:$lineno is blank; every line is a comment or a row"
      offenders=$((offenders + 1))
      continue
    fi
    raw="${line%%$'\t'*}"
    reason=""
    [[ "$line" == *$'\t'* ]] && reason="${line#*$'\t'}"
    prefix="$(normalise_path "$raw")"

    if [[ -z "${prefix//[[:space:]]/}" ]]; then
      echo "  $exempt:$lineno names no path prefix; an empty prefix covers nothing, never everything"
      offenders=$((offenders + 1))
      continue
    fi
    if [[ -z "${reason//[[:space:]]/}" ]]; then
      echo "  $exempt:$lineno exempts '$raw' for no stated reason"
      offenders=$((offenders + 1))
    fi
    if [[ $'\n'"$prefixes" == *$'\n'"$prefix"$'\n'* ]]; then
      echo "  $exempt:$lineno lists prefix '$raw' a second time"
      offenders=$((offenders + 1))
      continue
    fi
    prefixes="$prefixes$prefix"$'\n'

    matched=0
    also_scanned=0
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      covers_path "$prefix" "$p" || continue
      matched=1
      covered_by_any "$p" "$scandirs" && also_scanned=1
    done <<< "$tracked_paths"
    if [[ "$matched" -eq 0 ]]; then
      echo "  $exempt:$lineno exempts '$raw', which matches no tracked *.sh"
      offenders=$((offenders + 1))
    elif [[ "$also_scanned" -eq 1 ]]; then
      echo "  $exempt:$lineno exempts '$raw', which the scandirs already cover"
      offenders=$((offenders + 1))
    fi
  done < "$exempt"

  # --- (d) every tracked script is scanned or exempt ------------------------------------
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    covered_by_any "$p" "$scandirs" && continue
    covered_by_any "$p" "$prefixes" && continue
    echo "  $p is neither scanned nor exempt"
    offenders=$((offenders + 1))
  done <<< "$tracked_paths"

  [[ "$offenders" -eq 0 ]] && return 0
  return 1
}

TMP="$(mktemp -d)" || exit 2
trap 'rm -rf "$TMP"' EXIT

tracked_of_this_checkout() { # tracked_of_this_checkout <destination file>
  git ls-files '*.sh' > "$1" 2>/dev/null || return 2
  [[ -s "$1" ]] || return 2
  return 0
}

# --------------------------------------------------------------------------------------
# Single-check mode: any override set means "compare exactly this and tell me the answer".
# --------------------------------------------------------------------------------------
if [[ -n "${SHELLCHECK_CI_FILE:-}${SHELLCHECK_PINNED_FILE:-}${SHELLCHECK_EXEMPT_FILE:-}${SHELLCHECK_TRACKED_FILE:-}" ]]; then
  single_tracked="${SHELLCHECK_TRACKED_FILE:-}"
  if [[ -z "$single_tracked" ]]; then
    single_tracked="$TMP/tracked.txt"
    tracked_of_this_checkout "$single_tracked" || {
      echo "verify-shellcheck-coverage: git ls-files found no *.sh — is this a checkout?" >&2
      exit 2
    }
  fi
  check_coverage "${SHELLCHECK_CI_FILE:-$DEFAULT_CI}" \
                 "${SHELLCHECK_PINNED_FILE:-$DEFAULT_PINNED}" \
                 "${SHELLCHECK_EXEMPT_FILE:-$DEFAULT_EXEMPT}" \
                 "$single_tracked"
  exit $?
fi

# --------------------------------------------------------------------------------------
# Full run: the live repository, then every fixture, each asserted by its message.
# --------------------------------------------------------------------------------------
pass=0
fail=0

echo "verify-shellcheck-coverage: the live repository, then the fixtures that prove it refuses"
echo

LIVE_TRACKED="$TMP/tracked.txt"
if ! tracked_of_this_checkout "$LIVE_TRACKED"; then
  echo "verify-shellcheck-coverage: git ls-files found no *.sh — is this a checkout?" >&2
  exit 2
fi

live_out="$(check_coverage "$DEFAULT_CI" "$DEFAULT_PINNED" "$DEFAULT_EXEMPT" "$LIVE_TRACKED" 2>&1)"
live_rc=$?
if [[ "$live_rc" -eq 0 ]]; then
  echo "  ok   — 1 every tracked *.sh is scanned by the pinned steps or exempt for a named reason ($(grep -c . "$LIVE_TRACKED") scripts)"
  pass=$((pass + 1))
else
  echo "  FAIL — 1 the live repository is not covered (exited $live_rc):"
  printf '%s\n' "$live_out"
  fail=$((fail + 1))
fi

fixture_case() { # fixture_case <n> <dir> <expected exit> <expected message> <description>
  local n="$1" dir="$FIXTURES/$2" want="$3" msg="$4" desc="$5"
  local out rc

  if [[ ! -d "$dir" ]]; then
    echo "  FAIL — $n $desc: fixture $dir is missing"
    fail=$((fail + 1))
    return
  fi

  out="$(SHELLCHECK_CI_FILE="$dir/ci.yml" \
         SHELLCHECK_PINNED_FILE="$dir/pinned.txt" \
         SHELLCHECK_EXEMPT_FILE="$dir/exempt.tsv" \
         SHELLCHECK_TRACKED_FILE="$dir/tracked.txt" \
         "$SELF" 2>&1)"
  rc=$?

  if [[ "$rc" -ne "$want" ]]; then
    echo "  FAIL — $n $desc: expected exit $want, exited $rc: $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  if [[ -n "$msg" ]] && ! grep -qF -- "$msg" <<<"$out"; then
    echo "  FAIL — $n $desc: exited $rc but never said '$msg': $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  if [[ "$want" -eq 0 && -n "${out//[[:space:]]/}" ]]; then
    echo "  FAIL — $n $desc: admitted but still complained: $(tr '\n' '|' <<<"$out")"
    fail=$((fail + 1))
    return
  fi
  echo "  ok   — $n $desc"
  pass=$((pass + 1))
}

fixture_case  2 clean            0 "" \
  "a population wholly scanned or exempt is admitted"
fixture_case  3 uncovered        1 "other/loose.sh is neither scanned nor exempt" \
  "a tracked script under neither a scandir nor a prefix is refused, by name"
fixture_case  4 prefix-matches-nothing 1 "exempts 'docs/', which matches no tracked *.sh" \
  "an exempt prefix matching no tracked file is refused"
fixture_case  5 empty-reason     1 "exempts 'evidence/' for no stated reason" \
  "an exempt row whose reason column is empty is refused"
fixture_case  6 duplicate-prefix 1 "lists prefix 'evidence/' a second time" \
  "a prefix listed twice is refused"
fixture_case  7 ci-drift         1 "re-pinned deliberately" \
  "a ci.yml that has drifted from the pinned block is refused"
fixture_case  8 scandir-missing  1 "scandirs entry 'no-such-dir' is not an existing directory" \
  "a scandirs entry naming no existing directory is refused"
fixture_case  9 prefix-scanned   1 "which the scandirs already cover" \
  "an exempt prefix the scandirs already cover is refused"
fixture_case 10 prefix-boundary  1 "evidence2/x.sh is neither scanned nor exempt" \
  "'evidence' does not cover 'evidence2/x.sh' — the boundary is a path component"
fixture_case 11 wildcard-prefix  1 "exempts '*', which matches no tracked *.sh" \
  "a literal '*' prefix is a path that matches nothing, not a sentinel"

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-shellcheck-coverage: $ran cases ran, $EXPECTED_CASES registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  echo "verify-shellcheck-coverage: exiting 1"
  exit 1
fi
echo "verify-shellcheck-coverage: $pass passed, $fail failed, of $EXPECTED_CASES registered cases"
if [[ "$fail" -ne 0 ]]; then
  echo "verify-shellcheck-coverage: exiting 1"
  exit 1
fi
