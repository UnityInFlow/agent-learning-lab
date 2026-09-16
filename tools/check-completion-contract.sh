#!/usr/bin/env bash
#
# check-completion-contract — decides §10.6's seven clauses over a FINISHED worktree, at
# SCORING time.
#
# §10.6 (businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md:419-431) names these seven:
#   1 acceptance criteria mapped to implementation   5 no critical findings
#   2 build passed                                   6 no forbidden files changed
#   3 required tests passed                          7 final summary generated
#   4 static analysis passed
#
# IT IS L2 AS A CHECKER AND EXPLICITLY NOT AN IN-RUN CONTROL. No `Stop`-class hook is built at
# stop 17, and E-018/E-019 P6 say why before the run rather than after it: a Stop hook deciding
# these clauses would have to run the build and both suites INSIDE the run — minutes per
# invocation on BE-004 — which is a new registered variable in the cost column, in the same
# batch whose only registered question is what the machinery costs. Nothing in this project has
# ever observed whether this runner reaches a Stop hook at all.
#
# WHAT IT REFUSES TO PRETEND. Three of the seven clauses are not mechanically decidable from a
# finished worktree, and this script reports them as UNDECIDABLE rather than passing them:
# "acceptance criteria mapped" needs the ticket read against the diff; "static analysis passed"
# needs a static analyser the benchmark does not configure; "no critical findings" is a
# judgement. A checker that green-ticked those would be a control reporting success over a
# scope smaller than it claims — this project's house failure mode, and the reason
# `tools/skill-activation.sh` had to be rewritten three times.
#
# UNDECIDABLE IS NOT PASS. The exit code below distinguishes them.
#
# EXIT CODES:
#   0   every DECIDABLE clause passes, and the undecidable ones are listed
#   1   at least one decidable clause FAILS
#   2   nothing could be decided at all (no baseline, no summary, no evaluator result), OR the
#       policy file parsed to zero deny patterns so clause 6 would have passed having read nothing
#   30  usage / unreadable worktree / a --baseline that does not resolve to a commit
#
# Usage: tools/check-completion-contract.sh <worktree> [--baseline <sha>] [--evaluator-exit <n>]
#                                           [--summary <file>] [--policy <protected-paths.yaml>]
set -uo pipefail

WORKTREE=""; BASELINE=""; EVAL_EXIT=""; SUMMARY=""; POLICY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --baseline)       BASELINE="$2"; shift 2 ;;
    --evaluator-exit) EVAL_EXIT="$2"; shift 2 ;;
    --summary)        SUMMARY="$2"; shift 2 ;;
    --policy)         POLICY="$2"; shift 2 ;;
    -*) echo "check-completion-contract: unknown flag $1" >&2; exit 30 ;;
    *)  WORKTREE="$1"; shift ;;
  esac
done
[[ -n "$WORKTREE" && -d "$WORKTREE" ]] || { echo "usage: check-completion-contract.sh <worktree> [flags]" >&2; exit 30; }
git -C "$WORKTREE" rev-parse --git-dir >/dev/null 2>&1 || { echo "check-completion-contract: $WORKTREE is not a git worktree" >&2; exit 30; }

# A BASELINE THAT DOES NOT RESOLVE IS A USAGE ERROR, NOT AN EMPTY DIFF. Until §4a round 1 every
# `git diff "$BASELINE"` below sent stderr to /dev/null, so a typo'd or unreachable sha produced
# an EMPTY diff and clauses 5 and 6 then PASSED having compared nothing — a control reporting
# success over a scope of zero, which is this project's house failure mode and the exact reason
# `tools/skill-activation.sh` was rewritten three times. Found by codex + deepseek, 1/2
# recurrence. Resolved once, here, rather than at each use site.
if [[ -n "$BASELINE" ]]; then
  git -C "$WORKTREE" rev-parse --verify --quiet "${BASELINE}^{commit}" >/dev/null 2>&1 \
    || { echo "check-completion-contract: --baseline $BASELINE does not resolve to a commit in $WORKTREE" >&2; exit 30; }
fi

DECIDED=0; FAILED=0; SHARED_23=0; ZERO_PATTERNS=0; GUARD_EXIT=""
pass()  { DECIDED=$((DECIDED+1)); printf '  PASS        %d. %-42s %s\n' "$1" "$2" "$3"; }
fail()  { DECIDED=$((DECIDED+1)); FAILED=$((FAILED+1)); printf '  FAIL        %d. %-42s %s\n' "$1" "$2" "$3"; }
undec() { printf '  UNDECIDABLE %d. %-42s %s\n' "$1" "$2" "$3"; }

echo "check-completion-contract: §10.6 over $WORKTREE"
echo

# --- 1. acceptance criteria mapped -----------------------------------------------------------
undec 1 "acceptance criteria mapped" "needs the ticket read against the diff; no script decides it"

# --- 2 and 3. build and required tests --------------------------------------------------------
# Taken from the EVALUATOR's exit code rather than re-run here. The evaluator is the registered
# instrument for both clauses; a second, differently-configured build in this script could
# disagree with it, and then two controls would be claiming the same thing in two voices.
if [[ -n "$EVAL_EXIT" ]]; then
  if [[ "$EVAL_EXIT" == "0" ]]; then
    pass 2 "build passed"          "evaluator exit 0 (shared source, see note)"
    pass 3 "required tests passed" "evaluator exit 0 (shared source, see note)"
    SHARED_23=1
  else
    # A NON-ZERO EVALUATOR EXIT DOES NOT MEAN THE BUILD FAILED, AND SAYING SO WAS WRONG.
    # The benchmark's contract (BE-004 verify-evaluator.sh:5-16) maps 21 to the SCOPE GUARD and
    # 20 to the DEPENDENCY GUARD — a run that BUILT and whose tests PASSED, and then touched an
    # unrelated production file or added a Maven dependency. Until §4a round 2 this branch
    # printed `FAIL 2. build passed` for exit 21, which is a checker asserting a fact the
    # instrument never reported. 12 and 13 ARE functional and contract failures, so those two
    # are attributed; everything else is reported as the guard it is, with the attribution
    # between build and tests left UNDECIDABLE rather than guessed.
    case "$EVAL_EXIT" in
      12|13)
        fail 2 "build passed"          "evaluator exit $EVAL_EXIT — functional/contract failure (shared source)"
        fail 3 "required tests passed" "evaluator exit $EVAL_EXIT — functional/contract failure (shared source)"
        SHARED_23=1 ;;
      20|21)
        undec 2 "build passed"          "evaluator exit $EVAL_EXIT is a GUARD (scope/dependency); it reports nothing about the build"
        undec 3 "required tests passed" "evaluator exit $EVAL_EXIT is a GUARD; the suites are not what it failed on"
        GUARD_EXIT="$EVAL_EXIT" ;;
      *)
        undec 2 "build passed"          "evaluator exit $EVAL_EXIT is unmapped here; attribution not guessed"
        undec 3 "required tests passed" "evaluator exit $EVAL_EXIT is unmapped here; attribution not guessed" ;;
    esac
  fi
else
  undec 2 "build passed"          "no --evaluator-exit given; not re-run here on purpose"
  undec 3 "required tests passed" "no --evaluator-exit given; not re-run here on purpose"
fi

# --- 4. static analysis ------------------------------------------------------------------------
undec 4 "static analysis passed" "the benchmark configures no static analyser; nothing to read"

# --- 5. no critical findings -------------------------------------------------------------------
# PARTIALLY decidable, and the part that is decidable is stated as exactly that. A leftover
# stub or TODO *added by this run* is a critical finding anyone would accept; the absence of one
# is not proof there are no others, so a clean result is reported as "none of the mechanical
# kind" and never as "no critical findings".
if [[ -n "$BASELINE" ]]; then
  ADDED="$(git -C "$WORKTREE" diff "$BASELINE" -- . 2>/dev/null | grep -c '^+.*\(TODO\|FIXME\|XXX\|not implemented\|NotImplemented\)' || true)"
  if [[ "${ADDED:-0}" -gt 0 ]]; then
    fail 5 "no critical findings" "$ADDED added line(s) hold TODO/FIXME/not-implemented"
  else
    pass 5 "no critical findings" "none of the mechanical kind added (not proof of none)"
  fi
else
  undec 5 "no critical findings" "no --baseline given; nothing to diff against"
fi

# --- 6. no forbidden files changed -------------------------------------------------------------
# Fully decidable, and the one clause this script is genuinely authoritative on. The deny list
# is READ OUT OF THE POLICY FILE, never restated here: a second copy of the rules in the code is
# a rule that can disagree with the file it claims to enforce (policy-gate.sh's own comment).
if [[ -n "$BASELINE" ]]; then
  if [[ -z "$POLICY" ]]; then
    HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    POLICY="$HERE/build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml"
  fi
  if [[ -r "$POLICY" ]]; then
    # THE DENY LIST IS EXTRACTED FIRST AND COUNTED, AND ZERO PATTERNS IS UNDECIDABLE, NOT PASS.
    # The `sed` below is format-dependent: reindent the YAML, switch to unquoted scalars, or
    # rename the key and it yields NOTHING — and clause 6, the one clause this script calls
    # itself authoritative on, then passed having read no rules at all. Found by codex +
    # deepseek at §4a round 1, 1/2 recurrence. The count is now printed on the PASS line so a
    # reader can see how many rules were actually applied.
    PATTERNS="$(sed -n '/^deny:/,/^[a-z]/p' "$POLICY" | sed -n 's/^  - "\(.*\)".*/\1/p')"
    NPAT="$(printf '%s\n' "$PATTERNS" | grep -c . || true)"
    CHANGED="$(git -C "$WORKTREE" diff --name-only "$BASELINE" -- .)"
    HITS=""
    while IFS= read -r pat; do
      # shellcheck disable=SC2317
      [[ -z "$pat" ]] && continue
      while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        case "$pat" in
          '**/'*) # shellcheck disable=SC2053
                  [[ "$(basename "$f")" == ${pat#'**/'} ]] && HITS="$HITS $f" ;;
        esac
        # shellcheck disable=SC2254
        case "$f" in ${pat}) HITS="$HITS $f" ;; esac
      done <<<"$CHANGED"
    done < <(printf '%s\n' "$PATTERNS")
    HITS="$(printf '%s' "$HITS" | tr ' ' '\n' | grep -c . || true)"
    if [[ "${NPAT:-0}" -eq 0 ]]; then
      # ZERO RULES READ IS UNDECIDABLE ON THE CLAUSE, NOT A PASS ON IT. The first fix for this
      # (2026-09-16, earlier today) set the exit code to 2 and LEFT THE `PASS 6` LINE ON STDOUT,
      # so a reader parsing per-clause output saw PASS while the process said 2. §4a round 2
      # caught that at 1/2 and the acceptance gate blocked on it — my own fix wearing the same
      # defect it fixed. The line itself is what a reader reads, so the line is what changes.
      undec 6 "no forbidden files changed" "the policy parsed to ZERO deny patterns — no rules were read"
    elif [[ "${HITS:-0}" -gt 0 ]]; then
      fail 6 "no forbidden files changed" "$HITS path(s) match the deny list ($NPAT pattern(s) read)"
    else
      pass 6 "no forbidden files changed" "$NPAT deny pattern(s) read; no changed path matches"
    fi
  else
    undec 6 "no forbidden files changed" "policy file unreadable: $POLICY"
  fi
  if [[ -r "$POLICY" && "${NPAT:-0}" -eq 0 ]]; then
    ZERO_PATTERNS=1
  fi
else
  undec 6 "no forbidden files changed" "no --baseline given; nothing to diff against"
fi

# --- 7. final summary generated -----------------------------------------------------------------
if [[ -n "$SUMMARY" ]]; then
  if [[ -s "$SUMMARY" ]]; then
    pass 7 "final summary generated" "$(wc -c <"$SUMMARY" | tr -d ' ') bytes"
  else
    fail 7 "final summary generated" "empty or missing: $SUMMARY"
  fi
else
  undec 7 "final summary generated" "no --summary given"
fi

echo
echo "  decidable clauses: $DECIDED of 7   failing: $FAILED"
[[ "$SHARED_23" -eq 1 ]] && echo "  NOTE: clauses 2 and 3 are TWO LINES FROM ONE INSTRUMENT (the evaluator's exit code). They are not two independent decisions."
[[ -n "$GUARD_EXIT" ]] && echo "  NOTE: evaluator exit $GUARD_EXIT is a guard, not a build or test failure — clauses 2 and 3 are UNDECIDABLE on it, not failed."
if [[ "$ZERO_PATTERNS" -eq 1 ]]; then
  echo "  the policy file parsed to ZERO deny patterns — clause 6 read no rules" >&2
  exit 2
fi
if [[ "$DECIDED" -eq 0 ]]; then
  echo "  nothing could be decided — this is NOT a pass" >&2
  exit 2
fi
if [[ $((7 - DECIDED)) -ge 4 ]]; then
  echo "  WARNING: $((7 - DECIDED)) of 7 clauses were UNDECIDABLE. Exit 0 here means \"no decidable clause failed\", NOT \"the contract is satisfied\"."
fi
[[ "$FAILED" -eq 0 ]] || exit 1
exit 0
