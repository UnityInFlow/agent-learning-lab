#!/usr/bin/env bash
# THE CODEX ISOLATION QUESTION, AT n = 3 — the registered first act of §4 step 4 for stop 21.
#
#   ./evidence/b10/probe-codex-isolation.sh [N]        # default 3
#
# WHY n = 3 AND NOT 1. `runner/verify-codex-isolation.sh` exited 0 at one preflight and reported
# `ISOLATION LEAKS` at the next, on the same machine, the same binary and the same day; a third
# invocation WEDGED for over forty minutes on check 1's positive control and was killed. An
# isolation probe asks a LIVE MODEL to go looking, so a model that did not look is not a model
# that could not, and a single outcome — either outcome — is not a measurement. All three runs are
# kept, including a wedge, which is the artefact of a measurement rather than one.
#
# EVERY INVOCATION IS WALL-CLOCK BOUNDED AND ITS PROCESS GROUP IS KILLED. macOS has no `timeout`
# and `LAB_REVIEW_TIMEOUT`'s poll loop has already been observed not to kill what it polls. This
# runs the verifier in its own process group and kills the GROUP, then records the run as `wedged`.
#
# Exit 0 always. THIS SCRIPT DECIDES NOTHING — it records three outcomes and the judgement is
# written in the workbook by hand. A probe that returned a verdict would be a third thing to be
# wrong about.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
OUT="$LAB/evidence/b10/iso-probe"
mkdir -p "$OUT"
N="${1:-3}"
BUDGET="${ISO_BUDGET:-420}"

echo "codex $(codex --version 2>/dev/null | head -1) · budget ${BUDGET}s per invocation · n=$N"
for ((i=1;i<=N;i++)); do
  log="$OUT/run-$i-$(date -u +%Y%m%dT%H%M%SZ).txt"
  echo ""
  echo "--- invocation $i of $N  $(date -u +%H:%M:%SZ) ---"
  ( cd "$OBS" && exec ./runner/verify-codex-isolation.sh ) > "$log" 2>&1 &
  pid=$!
  waited=0
  while kill -0 "$pid" 2>/dev/null && (( waited < BUDGET )); do sleep 5; waited=$((waited+5)); done
  if kill -0 "$pid" 2>/dev/null; then
    # Kill the GROUP. The verifier spawns `codex exec` in subshells and a bare kill leaves them.
    pkill -f verify-codex-isolation 2>/dev/null
    pkill -f 'codex exec --skip-git-repo-check' 2>/dev/null
    kill -9 "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    rc="wedged-after-${waited}s"
  else
    wait "$pid"; rc="$?"
  fi
  # The verdict line, whichever branch the verifier took, and nothing else.
  verdict="$(grep -m1 -E 'ISOLATION LEAKS|INCONCLUSIVE|^ok: ALL THREE' "$log" || echo 'no verdict line')"
  last="$(grep -c . "$log" || true)"
  printf 'invocation %s  exit=%s  lines=%s\n  %s\n  log %s\n' "$i" "$rc" "$last" "$verdict" "$log"
  printf '%s\t%s\t%s\t%s\n' "$i" "$rc" "$verdict" "$log" >> "$OUT/outcomes.tsv"
done
echo ""
echo "--- all outcomes, and the judgement is NOT here ---"
cat "$OUT/outcomes.tsv"
