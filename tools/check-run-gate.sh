#!/usr/bin/env bash
# Did this observatory run clear every gate, and may its output therefore be scored?
#
#   ./tools/check-run-gate.sh <run-or-evaluation.json>
#
# DECISION D, B2, 2026-08-28. The rubric only scores submissions that cleared every gate —
# a score on a gate-failing one is a different measurement wearing these units. For B1 that
# is proved by a NAME: the fixture is in the benchmarks registry. A B2 agent run has no
# fixture name, so the proof is the evaluator's own recorded verdict instead. The invariant
# does not move; only the evidence for it does.
#
# THIS FILE DECIDES; IT DOES NOT FETCH. The caller fetches `GET /api/runs/{id}` and hands
# the document here. That split is what makes the decision testable without a live API and
# without a test-only backdoor — a backdoor would be exactly the L3-worn-as-L2 mistake this
# project keeps paying for.
#
# Accepts either the run document (evaluation nested under `.evaluation`) or a bare
# evaluation document, because the runner writes one shape and the API returns the other.
#
# Exit 0 gate passed, scoring permitted · 1 unreadable, absent, or no evaluation present —
# FAIL CLOSED, an unevaluated run is not a passing one · 2 the evaluator says it failed.
set -uo pipefail

[ $# -eq 1 ] || { echo "usage: $0 <run-or-evaluation.json>" >&2; exit 1; }
DOC="$1"
[ -r "$DOC" ] || { echo "cannot read $DOC" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

# `.evaluation // .` handles both shapes. `// empty` rather than `// false`: a MISSING
# verdict and a FALSE verdict are different, and only the second one is the evaluator
# speaking. Conflating them would let a run with no evaluation read as a failing one, which
# sounds conservative and is not — it hides the far more likely case, a run that was never
# evaluated at all.
eval_present=$(jq -r 'if (.evaluation // .) | type == "object" and has("passed") then "yes" else "no" end' "$DOC" 2>/dev/null)
if [ "$eval_present" != "yes" ]; then
  echo "FATAL: no evaluation in $DOC." >&2
  echo "An unevaluated run is not a passing one. Refusing to score it." >&2
  exit 1
fi

# `has()` and not `//`. In jq the alternative operator treats FALSE as absent, so
# `.passed // empty` returns empty for a genuinely failing run and the checker would report
# "no verdict recorded" for the one case where a verdict is loudest. `evaluation-payload.sh`
# in the observatory documents this same trap one file over — `false // true` evaluates to
# `true` — and these fixtures caught it here anyway, which is the argument for the fixtures.
xf() { jq -r "(.evaluation // .) | $1" "$DOC" 2>/dev/null; }
passed=$( xf 'if has("passed")   then (.passed|tostring)   else "" end')
exitc=$(  xf 'if has("exitCode") then (.exitCode|tostring) else "" end')
fclass=$( xf '.failureClass // "-"')
attempt=$(xf '(.correctness // {}) | if has("taskAttempted") then (.taskAttempted|tostring) else "" end')

if [ -z "$passed" ] || [ -z "$exitc" ]; then
  echo "FATAL: evaluation in $DOC has no passed/exitCode." >&2
  echo "Refusing to infer a verdict that was not recorded." >&2
  exit 1
fi

# taskAttempted false is the run that was BLOCKED rather than wrong — the distinction 0A.3
# exists to teach, and the one that voided the model-tier experiment. It cannot reach here
# with passed=true, but if it ever does, that is a defect in the evaluator and not a
# submission to score.
if [ "$attempt" = "false" ]; then
  echo "REFUSED: the evaluator records the task as NOT ATTEMPTED." >&2
  echo "Blocked is not wrong, and neither is a submission. See $DOC" >&2
  exit 2
fi

if [ "$passed" = "true" ] && [ "$exitc" = "0" ]; then
  echo "ok: gate passed (exitCode 0)"
  exit 0
fi

echo "REFUSED: the evaluator failed this run — passed=$passed exitCode=$exitc class=$fclass" >&2
echo "Scoring a gate-failing submission is a different measurement wearing these units." >&2
exit 2
