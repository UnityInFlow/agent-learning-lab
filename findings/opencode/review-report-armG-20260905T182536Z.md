# opencode review — report-armG

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T182536Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/b04/armG-20260905T172219Z/report-armG.py
    sha:  a6113331d64d
    dirty: false
lab_head:        aa55c23
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 34s |
| codex | ok | 24s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| WHY THIS EXISTS AND NOT `make baseline-report`. | 1/1 | L2 |
| rows = [] | 1/1 | L2 |
| # A registered variable that moved would void the comparison. Assert, do not assume. | 1/1 | L2 |
| for variant in (ARM, CTL): | 1/1 | L2 |
| arm = st.median([r['toolCalls'] for r in rows if r['variant'] == ARM]) | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |
| rows | 1/1 | L2 |
| assert | 1/1 | L2 |
| for variant in (ARM, CTL) | 1/1 | L3 |


---

## Run 1 of 2 — codex

### WHY THIS EXISTS AND NOT `make baseline-report`.
**Verdict:** finding
**Failure:** Delete one ARM record or add a sixth CTL record. The script still prints an arm comparison even though the stated design is `n = 5 per arm`; one reviewer can accept the generated medians as the experiment result while another rejects the comparison as invalid. No executable check enforces either sample size or exact arm membership.
**Layer of the implied fix:** L2
**Anchor:** n = 5 per arm, so nothing here is a property; it is true of these five runs.

### def quartile(xs, p):
**Verdict:** no finding
**Failure:** For the five observations `[1, 2, 3, 4, 100]`, the function deterministically returns Q1=2 and Q3=4 using its stated interpolation calculation; no specific input here produces an internally wrong or reviewer-dependent result.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### rows = []
**Verdict:** finding
**Failure:** Place a valid record for variant `unrelated-arm` in `records/` with a different runtime. The later runtime assertion aborts even if all five ARM and five CTL records are valid and matched. Conversely, extra records using ARM or CTL are silently included, changing registered medians without invalidating the comparison.
**Layer of the implied fix:** L2
**Anchor:** for f in sorted(glob.glob(os.path.join(HERE, 'records', '*.json'))):

### # A registered variable that moved would void the comparison. Assert, do not assume.
**Verdict:** finding
**Failure:** Use five ARM and five CTL records where every `exitCode` is 0 but one record has `evaluation.passed` false. The script accepts the batch and reports it because it checks only `exitCode`; one reviewer can treat exit code 0 as evaluator success while another uses the explicitly loaded `passed` field and voids the run.
**Layer of the implied fix:** L2
**Anchor:** assert all(r['exitCode'] == 0 for r in rows), 'a run did not pass the evaluator'

### for variant in (ARM, CTL):
**Verdict:** finding
**Failure:** Use a group whose first record has `accTotal=10` and `acc=7`, while the remaining four have `accTotal=10` and `acc=10`. The output begins `acceptance 10/10` even though the selected record passed only 7/10 criteria, producing a false reported value. If totals differ between records, the first record's total is also presented as though it describes the whole group.
**Layer of the implied fix:** L2
**Anchor:** print(f'    acceptance {g[0]["accTotal"]}/{g[0]["accTotal"]} on '

### arm = st.median([r['toolCalls'] for r in rows if r['variant'] == ARM])
**Verdict:** finding
**Failure:** Change the band thresholds after observing the records—for example, change `arm <= 22` to `arm <= 24`. The script still prints `registered before the run`, and nothing executes to compare these thresholds with a timestamped registration. One reviewer can accept the label as evidence of preregistration while another cannot.
**Layer of the implied fix:** L3
**Anchor:** band = ('<=22 -> harness' if arm <= 22 else
        '>=25 -> prose'   if arm >= 25 else
        '23-24 -> NEITHER, registered as neither before the run')

### Cross-cutting
**Verdict:** finding
**Failure:** The pass/fail assertion `exitCode == 0` overlaps the reported acceptance outcome, but the two can disagree because `passed` and criterion counts are not enforced. Reviewers would diverge most on `# A registered variable that moved would void the comparison. Assert, do not assume.`: for a record with `exitCode=0`, `passed=false`, and 9/10 criteria, one may retain it and another may void it, changing the usable sample by one run. The artifact does not say or enforce the exact expected record count and variant set, whether `passed` is required, whether acceptance totals must agree, or how the claimed preregistration is authenticated.
**Layer of the implied fix:** L2
**Anchor:** assert all(r['exitCode'] == 0 for r in rows), 'a run did not pass the evaluator'


---

## Run 2 of 2 — codex

### quartile
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### rows
**Verdict:** finding
**Failure:** Add a sixth valid record for `agent-v1.0-notools`, or omit one control record. The script still reports medians and labels the groups with their observed sizes even though the stated design requires n = 5 per arm; one reviewer can accept the output because `n=` is displayed, while another rejects the comparison as protocol-invalid.
**Layer of the implied fix:** L2
**Anchor:** n = 5 per arm, so nothing here is a property; it is true of these five runs.

### assert
**Verdict:** finding
**Failure:** Run `python3 -O report-armG.py` on records containing a changed runtime, changed model, or nonzero evaluator exit. Python removes all three assertions, so the script publishes the comparison; without `-O`, it stops. The registered-variable and evaluator controls therefore depend on invocation mode.
**Layer of the implied fix:** L2
**Anchor:** assert {r['runtime'] for r in rows} == {'2.1.261 (Claude Code)'}, 'runtime moved'

### for variant in (ARM, CTL)
**Verdict:** finding
**Failure:** Give one run `acceptanceCriteriaPassed=2` and `acceptanceCriteriaTotal=3`, while the other four runs pass 3/3. The output says `acceptance 3/3 on 4 of 5`; a reviewer can read the leading ratio as the arm's acceptance result, although one run actually achieved 2/3. A second divergence occurs if totals vary: the displayed ratio comes only from `g[0]`.
**Layer of the implied fix:** L3
**Anchor:** print(f'    acceptance {g[0]["accTotal"]}/{g[0]["accTotal"]} on '

### arm
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### ctl
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### band
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so none duplicates a pass/fail gate. Reviewers would diverge most on `for variant in (ARM, CTL)`: one may treat `acceptance 3/3 on 4 of 5` as adequate aggregate reporting, while another treats the displayed 3/3 as a wrong arm-level answer. The artifact needed to state and enforce record membership and cardinality—exactly five ARM records and five CTL records, with no unexpected variants—because extra, missing, or unrelated records currently alter or silently escape the comparison.
**Layer of the implied fix:** L2
**Anchor:** for variant in (ARM, CTL):

