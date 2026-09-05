# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260905T080746Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        5393704
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A template whose comments repeatedly promise distinctions the field shapes cannot encode — two reviewers filling the same run produce incomparable records, so the artifact does not function as an experimental data-entry contract.
  blocking:
    - reason: >-
        The comment "arms must match" asserts a control but the field only holds a
        hash; there is no place to record whether the match was actually verified,
        so a downstream reader cannot distinguish "hashed and verified" from "hashed
        and never compared".
      wrong_action: >-
        A reader querying "runs whose environment fingerprint failed to match its
        paired arm" returns zero rows even when the comparison was never performed,
        because the template records the hash but not the match outcome — the control
        was described, not executed.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: >-
        The field name ("proven loaded") describes a state of knowledge while the
        comment ("preflight assertion result") describes a test outcome, and a bare
        `false` cannot encode both "the assertion did not run" and "the assertion ran
        and returned false" — the same value triggers two different exclusion paths.
      wrong_action: >-
        Reviewer A records `false` meaning "preflight unsupported, so unverified";
        Reviewer B records `false` meaning "preflight ran, returned false →
        misconfigured". Downstream exclusion treats one as "needs retry" and the
        other as "confirmed bad configuration", so the same encoded value drives
        opposite actions on the same underlying state.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: >-
        The comment on `approvals` explicitly asks for "whether anyone could answer",
        but the field is a bare scalar that can only hold a count — the answered/
        unanswered dimension has no designated place to live.
      wrong_action: >-
        A reader querying "runs where the agent was blocked by unanswered
        permission requests" finds nothing, because every fill either drops the
        answered-ness entirely (scalar `3`) or invents an ad-hoc structure not
        shared with other reviewers. An entire class of agent-blocking failures
        is structurally invisible to downstream analysis.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: >-
        Five fields in the `evaluation` block (`compile`, `tests`, `hiddenTests`,
        `acceptanceScore`, `finalScore`) and one in `behavior` (`unintendedChanges`)
        have no specified type or scale, so `compile: true` and `compile: 0`,
        `acceptanceScore: 0.85` and `acceptanceScore: 85`, and three plausible
        shapes for `unintendedChanges` (boolean / count / file list) are all
        equally valid fills for the same run.
      wrong_action: >-
        Two reviewers transcribing the same evaluator output produce records no
        downstream tool can compare without first guessing the schema; an
        aggregator summing `acceptanceScore` across runs gets a 100× discrepancy
        that no on-template signal flags. The experiment's primary outcome
        measurement is undefined by the template that introduces it.
      anchor: "compile: / tests: / hiddenTests: / acceptanceScore: / finalScore:"
      evidence: templates/run-record.yaml:68-73
    - reason: >-
        `telemetryComplete` is a bare scalar whose comment ("a gap must not read
        as a zero") points at a real distinction, but the field gives no defined
        value set, so `false` (confirmed incomplete) and `null` (unknown /
        unchecked) collapse onto adjacent states with different downstream
        consequences; `exclusionReason` is commented "structured, registered in
        advance" but shows no structure and names no registry.
      wrong_action: >-
        A run whose telemetry was never inspected and a run whose telemetry was
        inspected and found incomplete are encoded as the same state or as
        adjacent scalars whose interpretation depends on the reviewer's reading
        of the comment; one triggers retry-collection, the other triggers
        exclusion, and the choice is made by whoever filled the form, not by
        the data.
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
  non_blocking:
    - reason: >-
        The evaluation block transcribes gate outputs the evaluator already
        produces. Not a rubric-style constant (the values vary by run), but the
        transcription surface lets a run record contradict the gate with no
        on-template mechanism to detect drift. Worth noting; not the template's
        primary failure mode.
      evidence: templates/run-record.yaml:67-74
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 79s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** Two reviewers filling `fingerprint` for the first time encounter "hash of the above; arms must match." Neither the term "arms" nor what constitutes a match is defined anywhere in the template. Reviewer A, unfamiliar with experimental-design jargon, computes a hash of the environment fields and moves on — no comparison attempted. Reviewer B interprets "arms" as treatment arms and computes matching fingerprints across paired runs, flagging a mismatch when the hashes diverge. The same environment produces a fingerprint that is either checked against something or not, depending on who read the comment.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run where the preflight assertion never executed — the harness does not support it. Reviewer A records `instructionsProvenLoaded: false` meaning "the assertion did not run, so it was not proven." Reviewer B records the same `false` meaning "the assertion ran and returned false — instructions were confirmed not loaded." The identical value triggers two different downstream interpretations: one treats the run as having an unverified-but-possibly-fine configuration; the other treats it as a confirmed configuration failure warranting exclusion. The field name ("proven loaded") and the comment ("preflight assertion result") pull in opposite directions — one describes a state of knowledge, the other describes a test outcome.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** A run where the agent requested permission 3 times during an autonomous session and received no response. The comment says "permission requests — and whether anyone could answer," but the field `approvals:` has no structure. Reviewer A records `approvals: 3` (a count). Reviewer B records `approvals: { count: 3, answered: false }` (structured). The information the comment explicitly asks for — "whether anyone could answer" — has no designated place to live. Downstream, a query for "runs where approvals went unanswered" returns hits for B's records and nothing for A's, even though both captured the same event.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** A run where compilation succeeded with 0 errors and 47 of 50 tests passed. The fields `compile:`, `tests:`, and `hiddenTests:` have no specified type. Reviewer A records `compile: true, tests: 47, hiddenTests: 12`. Reviewer B records `compile: 0, tests: { passed: 47, total: 50 }, hiddenTests: { passed: 12, total: 15 }`. The same run produces records that no downstream tool can compare without first guessing which schema was used. Separately, `acceptanceScore:` and `finalScore:` carry no scale — a reviewer recording `0.85` (0–1) and another recording `85` (0–100) produce a 100× discrepancy that no comment in the template flags. `failureClass` references "F01-F15" without enumerating the classes, so a reviewer who writes `F99` has no on-template signal that the value is wrong.
**Layer of the implied fix:** L3
**Anchor:** `compile:` / `tests:` / `acceptanceScore:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** A run where duration was captured but token usage was not — telemetry is partially complete. The comment on `telemetryComplete` says "a gap must not read as a zero," but the field is a bare scalar with no defined value set. Reviewer A records `telemetryComplete: false` to mean "confirmed incomplete." Reviewer B records `telemetryComplete: null` to mean "unknown / not checked." Downstream, `false` may trigger exclusion logic for "confirmed bad telemetry" while `null` may trigger "retry collection" — two different actions from the same underlying state. Additionally, `exclusionReason` is commented "structured, registered in advance" but shows no structure and names no registry, so two reviewers excluding the same run for the same reason would produce non-comparable records.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- The `evaluation` block records `compile`, `tests`, and `hiddenTests`, which are gate outputs the evaluator already produces. This is not a rubric-level duplication — the run record transcribes evaluator results rather than scoring them — but it creates a transcription-risk surface: if these fields are filled independently of the evaluator's actual verdict, they can contradict the gate with no on-template mechanism to detect the drift.
- `evaluation` is the section two reviewers would diverge on most. Five fields (`compile`, `tests`, `hiddenTests`, `acceptanceScore`, `finalScore`) have no specified type or scale, and `unintendedChanges` could plausibly be a boolean, a count, or a file list. The divergence is not marginal — it is "is this field a boolean or an object" level, which makes downstream comparison undefined until a schema is imposed.
- The artifact did not define "arms" in the `environment.fingerprint` comment. It did not distinguish "assertion did not run" from "assertion ran and failed" for `instructionsProvenLoaded`. It did not specify types or scales for any `evaluation` field. It did not say which value represents a telemetry gap versus confirmed-incomplete telemetry. Each of these is a place where the template's comment points at a real distinction but leaves the encoding to the filler.
