# opencode review — classify-permission-block

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260914T142155Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: ../agent-observatory/runner/lib/classify-permission-block.sh
    sha:  84e860f76f23
    dirty: false
  - path: ../agent-observatory/runner/verify-permission-block-classifier.sh
    sha:  5b08ed6a0110
    dirty: false
lab_head:        e06e2ae
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: runner/lib/classify-permission-block.sh
  verdict: ACCEPT
  summary: The classifier implements its stated conjunctive rule (denials>0 AND 0 changed files = block) consistently across all 29 verifier cases; the file header documents why the rule is conjunctive and which adjacent shapes it does not close, and the verifier refuses (exit 3) every input shape it cannot reason about.
  blocking: []
  non_blocking:
    - reason: The numeric validator `^[0-9]+$` accepts leading-zero strings ("08", "09") that Bash arithmetic then treats as octal — "08" → block reported with "08 denial(s)", "09" → arithmetic error, silent fall-through to "0 denials" output. The verifier tests only alphabetic non-numbers, not octal-looking numeric strings. The strict-numeric principle the header states is therefore overstated, but the data path (`jq '.behavior.permissionDenials // "MISSING"'` over well-formed telemetry) does not produce leading-zero numbers in practice.
      evidence: runner/lib/classify-permission-block.sh:75
    - reason: A run with denials>0 and 0 changed files is classified as a permission block even if the denial was incidental and the agent succeeded via read-only operations — the rule is consistent with what is documented, but the header only names the abstention shape (denials=0, obs#47) and does not flag this adjacent false-positive surface. No verifier case exercises it.
      evidence: runner/lib/classify-permission-block.sh:89-92
    - reason: The "obs#47's OWN seven F05 runs" section title cites seven EXP-BE002-MODEL-TIER sonnet runs, but only four fixtures (lines 77-80) appear in the case list. The in-file comment ("the case this fix provably does NOT close") signals illustrative scope, but the heading reads as a coverage claim; a reader counting the four fixtures against the seven named runs sees a discrepancy without context.
      evidence: runner/verify-permission-block-classifier.sh:73-80
  disputed:
    - finding: "Running the script executes 28 check/checkargs calls, but its opening output reports '29 cases.'"
      why: The script executes 29 calls: 26 `check` invocations across lines 59-97 (1,2,3,4, 5,6,7,8,9,10,11, 12,13,14,15, 16,17,18, 19,20,21,22,23,24,25,26) and 3 `checkargs` invocations at lines 100-102. The declared "29 cases" matches the executed count. The "28" tally from the line-level pass is incorrect.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 28s |
| codex | ok | 47s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| ../agent-observatory/runner/lib/classify-permission-block.sh | 1/1 | L2 |
| ../agent-observatory/runner/verify-permission-block-classifier.sh | 1/1 | L2 |
| Cross-cutting | 1/1 | n/a |


---

## Run 1 of 2 — codex

### ../agent-observatory/runner/lib/classify-permission-block.sh
**Verdict:** finding
**Failure:** A run receives one denial for an optional command, successfully completes a read-only task, and correctly changes zero files. With telemetry permissionDenials=1 and changed-file-count=0, this script exits 2 and labels the run a permission block. Another reviewer can reasonably treat the same run as successful because neither conjunct establishes that the denial prevented task completion; the classifier converts correlation into causation.
**Layer of the implied fix:** L2
**Anchor:** if [[ "$DENIALS" -gt 0 && "$CHANGED" -eq 0 ]]; then
  echo "permission block: ${DENIALS} denial(s) and 0 changed files (toolCalls ${TOOLCALLS})"
  exit 2
fi

### ../agent-observatory/runner/verify-permission-block-classifier.sh
**Verdict:** finding
**Failure:** Running the script executes 28 check/checkargs calls, but its opening output reports “29 cases.” It can finish with “28 passed, 0 failed” while the declared case count remains 29. The same artifact also says it covers seven F05 runs but supplies only four F05 fixtures, so one reviewer may accept the advertised coverage while another counts the executable cases and rejects it.
**Layer of the implied fix:** L2
**Anchor:** echo "verify-permission-block-classifier: 29 cases"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail gate is present, so there is no duplication to name. Reviewers would diverge most on classify-permission-block.sh: for permissionDenials=1 and changed-file-count=0 after a successfully completed read-only task, one follows the exit-2 rule while another rejects the causal label, producing a full blocked-versus-not-blocked disagreement. The artifacts needed to state which task outcomes legitimately require zero changed files and how a denial is shown to have prevented completion; without that contract, the executable classifier cannot distinguish an actual block from an incidental denial.
**Layer of the implied fix:** n/a
**Anchor:** a denial signal        `.behavior.permissionDenials > 0`
#   AND nothing produced   the changed-file count is 0


---

## Run 2 of 2 — codex

### ../agent-observatory/runner/lib/classify-permission-block.sh
**Verdict:** finding
**Failure:** Input telemetry `{"behavior":{"permissionDenials":"08","toolCalls":12}}` with changed-file count `0` passes the digit-only validation, but Bash arithmetic interprets a leading-zero operand as octal. One reviewer can therefore expect exit 2 because there are eight denials and no changed files, while execution can instead emit an arithmetic error and reach a non-block result or otherwise behave inconsistently. The classifier accepts numeric-looking strings without defining or enforcing a decimal integer domain.
**Layer of the implied fix:** L2
**Anchor:** if ! [[ "$DENIALS" =~ ^[0-9]+$ ]]; then

### ../agent-observatory/runner/verify-permission-block-classifier.sh
**Verdict:** finding
**Failure:** Run the verifier unchanged, then invoke the classifier with `{"behavior":{"permissionDenials":"08","toolCalls":12}}` and changed count `0`. All 29 verification cases can pass even though this accepted input does not reliably produce the required permission-block exit. The suite tests alphabetic non-numbers but omits digit strings whose accepted syntax is incompatible with Bash arithmetic.
**Layer of the implied fix:** L2
**Anchor:** check "non-numeric permissionDenials is refused"         '{"behavior":{"permissionDenials":"some"}}' 0 3 "is not a number"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because the artifacts define no scoring categories. Reviewers are most likely to diverge on `../agent-observatory/runner/lib/classify-permission-block.sh`: for the `"08"` denial input, one will classify it as a block and another as an arithmetic failure or non-block—a full one-classification difference. The artifacts needed to specify and enforce whether counts must be JSON numbers rather than numeric strings, their decimal interpretation, and their supported numeric bounds.
**Layer of the implied fix:** L2
**Anchor:** if ! [[ "$DENIALS" =~ ^[0-9]+$ ]]; then

