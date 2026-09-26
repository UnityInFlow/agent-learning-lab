# opencode review — verify-retrieval-trace-probe

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260926T082141Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/verify-retrieval-trace-probe.sh
    sha:  eda179debdb1
    dirty: false
lab_head:        eb9a0aa
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
| codex | ok | 56s |
| ollama-cloud/deepseek-v4-pro | FAILED | rc=1 85s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| an extensionless target must not be invisible (§4a round 3) | 1/1 | L2 |
| a root-relative single-component path must match STRICT, as the header says | 1/1 | L2 |
| a None inside the attributes array must not CRASH (it used to exit 1) | 1/1 | L2 |
| an EMPTY list under the first known key must not hide runs under the second | 1/1 | L2 |
| the two sensitivities must be DISTINGUISHABLE, by exact line | 1/1 | L2 |
| a hit must be LOCATED within a Read event, at both scopes, by exact line | 1/1 | L2 |
| the parser must match the REAL schema, not only the one its author invented | 1/1 | L2 |
| the flat-attribute branch must be exercised, not merely present | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 2 — codex

### the detector must FIRE. These are the positive controls.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### an extensionless target must not be invisible (§4a round 3)
**Verdict:** finding
**Failure:** Change the probe so consecutive invocations alternate: the first invocation on t-extensionless-path.jsonl exits 3 but prints incorrect PATHY counters; the next two invocations print the expected counter lines but exit 5. All three assertions pass because check verifies only the exit code, while check_line ignores exit status. The script therefore reports success although no single probe execution satisfies the claimed exit-code-and-counter behavior.
**Layer of the implied fix:** L2
**Anchor:** check 3 "an extensionless path is seen at all"  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"
check_line "and it fires PATHY only"           "hits: strict=0 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"
check_line "with exactly one PATHY hit"        "pathy: total=1 distinct_keys=1" \
  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"

### a root-relative single-component path must match STRICT, as the header says
**Verdict:** finding
**Failure:** Make the probe print `hits: strict=1 loose_only=0` and then exit 5 for t-root-relative-path.jsonl. check_line passes because it never examines `$?`, so the script accepts a malformed-input result as proof that STRICT successfully detected the path.
**Layer of the implied fix:** L2
**Anchor:** check_line "a root-relative path matches STRICT" "hits: strict=1 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-root-relative-path.jsonl"

### a None inside the attributes array must not CRASH (it used to exit 1)
**Verdict:** finding
**Failure:** Make the first probe invocation exit 0 while reporting `read_events=0`, and the second invocation report `read_events=1` but exit 5. `check` and `check_field` both pass, although no successful execution both survives the null attribute and recognizes the Read event.
**Layer of the implied fix:** L2
**Anchor:** check 0 "a null inside the attributes array"   "$PROBE" telemetry "$FIX/t-null-attribute.jsonl"
check_field "and the Read event is still seen" read_events 1 \
  "$PROBE" telemetry "$FIX/t-null-attribute.jsonl"

### an EMPTY list under the first known key must not hide runs under the second
**Verdict:** finding
**Failure:** Make the first invocation exit 0 while counting zero records, and the second print `records=1` while exiting 5. The two independent checks pass, despite there being no successful execution in which the run under the second key is counted.
**Layer of the implied fix:** L2
**Anchor:** check 0 "empty first key, runs under the second" "$PROBE" records "$FIX/r-empty-first-key.json"
check_field "and that run is counted"          records 1 \
  "$PROBE" records "$FIX/r-empty-first-key.json"

### the two sensitivities must be DISTINGUISHABLE, by exact line
**Verdict:** finding
**Failure:** Make both fixture invocations print their expected `hits:` lines and exit 5. Both check_line calls pass, so the script claims distinguishable sensitivities even though neither fixture produces a valid detector result.
**Layer of the implied fix:** L2
**Anchor:** check_line "STRICT stays silent where LOOSE fires" "hits: strict=0 loose_only=1" \
  "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check_line "STRICT fires on a separator path"      "hits: strict=1 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-path-body.jsonl"

### a hit must be LOCATED within a Read event, at both scopes, by exact line
**Verdict:** finding
**Failure:** Make the probe print each expected read-scoped line but exit 5 after printing it. Every assertion in this section passes because check_line ignores status, so a parse failure can be accepted as proof of correct scope attribution.
**Layer of the implied fix:** L2
**Anchor:** check_line "a path in a Read ATTRIBUTE is attributed" \
  "read_scoped_attr: strict=1 loose_only=0" "$PROBE" telemetry "$FIX/t-path-attr.jsonl"

### the parser must match the REAL schema, not only the one its author invented
**Verdict:** finding
**Failure:** Have the first invocation exit 0 with `read_events=0`; have the next invocation print `read_events=3` but exit 5; and have the last print the expected zero-hit line but exit 5. All checks pass, although no successful parse of the real excerpt yields the asserted population and hit count together.
**Layer of the implied fix:** L2
**Anchor:** check 0 "a real telemetry excerpt is recognised" "$PROBE" telemetry "$FIX/t-real-sample.jsonl"
check_field "the real excerpt yields 3 Read events" read_events 3 \
  "$PROBE" telemetry "$FIX/t-real-sample.jsonl"
check_line "and names no file, as the result says" "hits: strict=0 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-real-sample.jsonl"

### the flat-attribute branch must be exercised, not merely present
**Verdict:** finding
**Failure:** Have the first invocation exit 0 without recognizing a Read event, then have the second print `read_events=1` and exit 5. Both assertions pass even though the flat-attribute branch is never demonstrated during a successful run.
**Layer of the implied fix:** L2
**Anchor:** check 0 "attribute values as flat strings"    "$PROBE" telemetry "$FIX/t-flat-attrs.jsonl"
check_field "the flat branch yields a Read event" read_events 1 \
  "$PROBE" telemetry "$FIX/t-flat-attrs.jsonl"

### a moved schema must NEVER read as an empty population. Three shapes.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### the detector must stay SILENT only over a non-empty population
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### an empty population must NOT read as a clean negative
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### unparsable input must NOT read as a clean negative, and must NEVER crash
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### PRECEDENCE: a partially unparsable input is not 5, in EITHER argument order
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### usage errors
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### and the claim in this script's own title, made executable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate; the artifact contains no scoring categories. Reviewers would diverge most on `an extensionless target must not be invisible (§4a round 3)`: one can treat three successful assertions as sufficient, while another rejects the result because they come from three separate executions; the divergence is pass versus fail. The artifact needed to state and enforce whether exit status and asserted counters must hold atomically in the same probe invocation.
**Layer of the implied fix:** L2
**Anchor:** Exit 0 when every case returns its registered code, every asserted line matches exactly

