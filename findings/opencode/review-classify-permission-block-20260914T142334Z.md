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
reviewed_utc:    20260914T142334Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: ../agent-observatory/runner/lib/classify-permission-block.sh
    sha:  84e860f76f23
    dirty: false
  - path: ../agent-observatory/runner/verify-permission-block-classifier.sh
    sha:  5b08ed6a0110
    dirty: false
lab_head:        9952c38
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 38s |
| codex | ok | 29s |

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
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 2 — codex

### ../agent-observatory/runner/lib/classify-permission-block.sh
**Verdict:** finding
**Failure:** Input {"behavior":{"permissionDenials":"09","toolCalls":12}} with changed-file count 0 passes the ^[0-9]+$ check, but Bash interprets 09 as invalid octal arithmetic. Both denial comparisons fail, after which the script reports “0 denials” and exits 0 instead of refusing the non-numeric JSON value with exit 3. A reviewer treating numeric-looking strings as valid and one requiring a JSON number will therefore classify the same run differently.
**Layer of the implied fix:** L2
**Anchor:** if ! [[ "$DENIALS" =~ ^[0-9]+$ ]]; then

### ../agent-observatory/runner/verify-permission-block-classifier.sh
**Verdict:** finding
**Failure:** The fixture {"behavior":{"permissionDenials":"some"}} verifies rejection of an obviously non-numeric string, but {"behavior":{"permissionDenials":"09","toolCalls":12}} with changed count 0 is untested and exits 0 through the arithmetic-error path. Thus all 29 cases can pass while the classifier clears malformed permission telemetry as “0 denials.”
**Layer of the implied fix:** L2
**Anchor:** check "non-numeric permissionDenials is refused"         '{"behavior":{"permissionDenials":"some"}}' 0 3 "is not a number"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because the artifacts define no scoring categories. Reviewers would diverge most on the classifier’s permissionDenials type contract: one can accept digit strings because the implementation’s regex does, while another can require the JSON number asserted by its diagnostic; for "09", that divergence is exit 0 versus the intended exit 3. The artifacts needed to specify whether permissionDenials must be a JSON numeric value rather than a numeric-looking string.
**Layer of the implied fix:** L2
**Anchor:** behavior.permissionDenials is not a number (${DENIALS}) — permission block could not be classified


---

## Run 2 of 2 — codex

### ../agent-observatory/runner/lib/classify-permission-block.sh
**Verdict:** finding
**Failure:** Input `{"behavior":{"permissionDenials":9223372036854775808,"toolCalls":1}}` with changed-file count `0` passes the digit-only validation, but Bash evaluates the denial count using fixed-width arithmetic. On a typical 64-bit Bash it wraps beyond the signed range, so `-gt 0` is false and the script returns exit 0 instead of classifying a positive-denial, zero-output run as a permission block. One reviewer may regard every JSON non-negative integer as supported; another may infer an undocumented machine-integer limit.
**Layer of the implied fix:** L2
**Anchor:** if ! [[ "$DENIALS" =~ ^[0-9]+$ ]]; then
  echo "behavior.permissionDenials is not a number (${DENIALS}) — permission block could not be classified"
  exit 3
fi

### ../agent-observatory/runner/verify-permission-block-classifier.sh
**Verdict:** finding
**Failure:** A diff that changes the classifier to accept an out-of-range denial count such as `9223372036854775808` still passes all 29 cases, although the classifier can then return exit 0 for that positive-denial, zero-changed-files input. The verification suite therefore does not enforce the classifier's stated numeric domain or its refusal behavior at the Bash arithmetic boundary. Separately, the section labeled as covering the seven F05 runs instantiates only four run IDs, so a reviewer treating those IDs as individually reproduced evidence reaches a different coverage conclusion from one treating their shared shape as sufficient.
**Layer of the implied fix:** L2
**Anchor:** echo "verify-permission-block-classifier: 29 cases"

...

echo "  -- obs#47's OWN seven F05 runs: the case this fix provably does NOT close --"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail gate is present, so there is no duplication to name. Reviewers are most likely to diverge on `../agent-observatory/runner/lib/classify-permission-block.sh`: for an integer above Bash's signed arithmetic range, one may expect the documented positive-denial rule to apply while another may assume an unstated machine-integer domain; their outcomes differ by exit 2 versus exit 0. The artifacts needed to state the accepted numeric range for `permissionDenials` and `changed-file-count`, or require refusal when either value cannot be evaluated safely.
**Layer of the implied fix:** L2
**Anchor:** if [[ "$DENIALS" -gt 0 && "$CHANGED" -eq 0 ]]; then

