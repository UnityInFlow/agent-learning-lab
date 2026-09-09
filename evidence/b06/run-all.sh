#!/usr/bin/env bash
# B6 — the rest of step 5's tail and the whole of steps 6 and 9, chained so nothing waits on a
# human. Sequential on purpose: two concurrent benchmark batches contend for the runtime and
# contaminate durations, and durations are a registered outcome.
set -uo pipefail
cd "/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab" || exit 1

echo "=== waiting for the selection-rate probe to finish ==="
until grep -q "SELECTION RATE DONE" evidence/b06/selection-rate.out 2>/dev/null; do sleep 20; done

echo "=== §4 step 9, the deliberate failure (1 run) ==="
./evidence/b06/run-deliberate-failure.sh || echo "deliberate failure runner exited $?"

echo "=== §4 step 6, BE-003 batch, n=10 per arm ==="
BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-B6-SKILL-BE003 ./evidence/b06/run-b6-batch.sh
be003=$?
echo "BE-003 batch exit $be003"

if [[ $be003 -eq 0 ]]; then
  echo "=== §4 step 6, BE-004 batch, n=10 per arm ==="
  BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-B6-SKILL-BE004 ./evidence/b06/run-b6-batch.sh
  echo "BE-004 batch exit $?"
else
  echo "!! BE-003 aborted with $be003 — BE-004 is NOT started. A batch that aborts is redesigned,"
  echo "!! not resumed, and starting the second task would spend 20 runs on the same defect."
fi
echo "RUN-ALL DONE"
