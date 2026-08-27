# opencode review — run-record

```yaml
reviewer:        lab-critic
model:           ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
opencode:        1.18.21
agent_sha:       5ae27fa4d5e2
reviewed_utc:    20260824T200929Z
runs:            2           # independent sessions; findings unioned below
artifacts:
  - path: templates/run-record.yaml
    sha:  00c929a0f8d8
lab_head:        9d5cb08
lab_dirty:       true
```

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| environment | 2/2 | L3 |
| configuration | 2/2 | L3 |
| behavior | 1/2 | L3 |
| evaluation | 2/2 | L3 |
| measurement | 2/2 | L3 |
| task | 1/2 | L3 |


---

## Run 1 of 2


> lab-critic · deepseek-v4-pro

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
**Failure:** The `fingerprint` field is annotated "hash of the above; arms must match", but the template has no field that records the *other* arm's fingerprint, nor any field that records the result of the comparison. Concrete scenario: a two-arm run where arm A's environment fingerprint is `abc123` and arm B's is `def456`. Reviewer 1 treats the mismatch as fatal and marks the run `invalidated`; reviewer 2 records only arm A's fingerprint, never notices the mismatch, and marks the run `valid`. The "must match" requirement is unenforceable because there is nowhere to write the comparison down, and nothing executes to reject a mismatch.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is labeled "preflight assertion result", but a `false` value has no defined consequence and no linkage to `measurement.status`. Concrete scenario: the preflight assertion returns `false` (the registered instructions did not load), yet the run is still recorded with `status: valid` and scored. Reviewer 1 treats a false assertion as automatically forcing `excluded`; reviewer 2 treats it as a warning only and scores the run normally. The two reviewers produce different `finalScore` for the same run because the artifact never says what a failed assertion *does*.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is annotated "permission requests — and whether anyone could answer". "whether anyone could answer" is undefined: does it mean whether a human was present to approve, whether the harness could auto-approve, or whether the request was answerable at all? Concrete scenario: a run where the agent made 3 permission requests and the harness auto-approved all of them. Reviewer 1 records `approvals: 3` (requests made); reviewer 2 records `approvals: 0` (nothing required human answer). The two records disagree on a field that downstream aggregation treats as a count.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated "F01-F15", but the F01–F15 taxonomy is not defined anywhere in the artifact and no source for it is referenced. Concrete scenario: a run that fails because the agent edited files outside the task scope. Reviewer 1 assigns `failureClass: F03` (guessing "unintended changes"); reviewer 2 assigns `failureClass: F07` (guessing "wrong file touched"). The field is un-fillable without external knowledge, and two competent reviewers will assign different classes to the same failure, corrupting any downstream failure-mode analysis.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** The `status` enum is `valid / excluded / pilot / invalidated`, but the boundary between `excluded` and `invalidated` (and whether `pilot` counts as a data point) is not defined. Concrete scenario: a run whose telemetry is incomplete. Reviewer 1 marks `status: excluded`; reviewer 2 marks `status: invalidated`. Downstream aggregation either counts them differently or the same, and nobody can tell which is correct. Separately, `exclusionReason` says "structured, registered in advance" but names no registry — a reviewer has no place to look up what reasons were pre-registered.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Scoring duplication:** `evaluation.acceptanceScore` and `evaluation.finalScore` both score the run, and neither is defined relative to the other — a reviewer cannot tell whether `finalScore` is a rollup of `acceptanceScore` plus `unintendedChanges`, or an independent judgment. `measurement.status` (`valid`/`excluded`) is a pass/fail gate that overlaps with `evaluation.failureClass` (a failure implies exclusion, but the artifact never states that linkage).
- **Most divergent section:** `evaluation.failureClass` — the F01–F15 taxonomy is referenced but absent, so two reviewers will assign different classes to the same failure with near-certainty. `measurement.status` is a close second (`excluded` vs `invalidated`).
- **What the artifact did not say:** the F01–F15 failure-class definitions; the exclusion-reason registry and where it lives; the mechanism (or field) that records an environment-fingerprint mismatch between arms; and the consequence of a `false` `instructionsProvenLoaded` assertion. All four are referenced as if they exist elsewhere but are never defined or pointed to.

---

## Run 2 of 2


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** `benchmarkSha` is the reproducibility anchor — the commit the task and evaluator were resolved from — but nothing marks it required. A run record submitted with `benchmarkSha` blank is accepted as-is, and two reviewers cannot determine whether the task was resolved from the same commit. One reviewer treats the run as reproducible, the other as unverifiable; the run's results are silently non-reproducible either way.
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

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
**Failure:** `fingerprint` is described as a hash of the environment with the instruction "arms must match", but nothing in the template computes or validates it. A reviewer can write down a fingerprint that does not match the actual environment (or leave it blank) and nothing rejects it. Two arms that actually differ in `permissionMode`, `hooks`, or `mcpServers` can carry identical fingerprints, and the mismatch is invisible — the exact confound the field exists to catch.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is labeled a "preflight assertion result", but the template does not name the preflight that executes, nor state that a `false` value blocks the run. A reviewer can record `false` (or leave it blank) and the run proceeds. The field records an outcome; it does not enforce one. Two reviewers disagree on whether a `false` value invalidates the run or is merely informational.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` points at a taxonomy ("F01-F15") that is not defined anywhere in the artifact. Two reviewers handed the same run will assign different failure classes because the class boundaries are not anchored — e.g. a run that compiled but failed hidden tests could be F-something to one reviewer and a different F-code to another. The field is a controlled vocabulary with no vocabulary.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` claims to be "registered in advance", but the template provides no mechanism to prove advance registration — no timestamp, no registry reference, no pre-registration artifact. A reviewer can invent an exclusion reason after seeing the result and record it as if it were pre-registered, and nothing distinguishes the two. This is the canonical measurement-integrity failure: post-hoc exclusion dressed as pre-registration. Two reviewers cannot tell whether a run was excluded for a legitimate pre-declared reason or rationalized out after the fact.

Two further problems in the same block: (1) the `status` enum `valid / excluded / pilot / invalidated` does not distinguish `excluded` from `invalidated` — both mean "does not count", and a reviewer can classify the same run either way; (2) `telemetryComplete` carries the warning "a gap must not read as a zero", but nothing enforces it — a blank field reads as false/zero, which is precisely the failure the comment warns against.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Scoring duplication:** `evaluation.acceptanceScore` and `evaluation.finalScore` both read as overall run scores. The artifact does not state whether `finalScore` is an aggregate of `acceptanceScore` (plus `unintendedChanges`/`failureClass` penalties) or an independent measure. Two reviewers will record different values in the two fields for the same run, or treat one as redundant.
- **Most divergent section:** `measurement`, by a wide margin. Three unanchored fields (`status` enum, `exclusionReason` advance-registration, `telemetryComplete` gap-vs-zero) each admit multiple defensible readings, so two reviewers can diverge on all three simultaneously — a run can be `excluded` vs `invalidated`, with a post-hoc vs pre-registered reason, and a missing vs zero telemetry reading, all at once.
- **What it did not say:** the F01-F15 failure taxonomy; the semantics distinguishing `excluded` from `invalidated`; the name of the preflight that asserts `instructionsProvenLoaded` and whether `false` blocks the run; how `fingerprint` is computed and validated; and how "registered in advance" is proven (timestamp/registry). Every one of these is a place where the template asserts a control that no named mechanism enforces.
