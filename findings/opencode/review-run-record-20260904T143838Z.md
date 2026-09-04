# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260904T143838Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        288ceee
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 2350s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L2 |
| task | 1/1 | L2 |
| harness | 1/1 | L2 |
| model | 1/1 | L2 |
| environment | 1/1 | L2 |
| configuration | 1/1 | L2 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L2 |
| Cross-cutting | 1/1 | n/a |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two completed records both retain `B0-COPILOT-BE001-001`; one reviewer treats the second as a retry, while another treats it as a duplicate and excludes it. A result store keyed by `runId` can also overwrite the first record because neither uniqueness nor identifier semantics are established.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A run leaves `benchmarkSha` blank after BE-001 revision 1 changes in the working tree. One reviewer resolves the task from the current checkout; another resolves revision 1 from the benchmark repository history. They can run different task or evaluator content under the same recorded task identity.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs record `github-copilot-cli` but leave `version` and `runnerCommit` blank; between them, the CLI changes its default permission handling. One reviewer considers the runs comparable by harness name, while another rejects the comparison because the executable and runner implementations cannot be identified.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run requests the `haiku` alias before it is repointed, but both model fields remain blank. One reviewer groups it with later `haiku` runs by requested alias; another excludes it because the resolved model is unknown. The grouped analysis can attribute a model-version change to the treatment.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** For identical environment values, one runner hashes the literal YAML including list order and another hashes a normalized object with sorted lists. They produce different fingerprints, so one reviewer rejects matched arms that another reviewer accepts. Conversely, an unspecified serialization could conceal a meaningful distinction through inconsistent normalization.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run uses a non-empty instructions file but leaves `instructionsHash` blank. The file is edited after execution without changing the record; one reviewer reconstructs the treatment from the current file, while another marks the treatment unidentified. The run can therefore be attributed to instructions it never received.
**Layer of the implied fix:** L2
**Anchor:** instructionsHash:

### behavior
**Verdict:** finding
**Failure:** A telemetry collector fails before recording tool activity and emits the template unchanged: `toolCalls` is blank while `toolsUsed` and `commands` are empty arrays. One reviewer interprets the arrays as observed zero activity; another interprets the blank count as missing telemetry and treats all behavior fields as unknown. The first reviewer can incorrectly score the run as tool-free.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** A record contains `{ value: null, source: provider, estimated: false }`. It is not a bare number, so the only stated rejection rule does not establish that it fails validation. One reviewer treats it as Level A with unavailable usage; another treats the contradictory tuple as invalid. Their efficiency analyses include different runs.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so no scoring category duplicates a pass/fail gate. Reviewers would diverge most on `behavior`: the unchanged empty arrays can be read as measured zeros while adjacent blank scalars indicate missing data, producing a full zero-versus-unknown difference for tool and command activity. The artifact needed to state and enforce required fields, null-versus-zero semantics, canonical fingerprint construction, identifier uniqueness, and validity rules for every provenance tuple—not only rejection of bare numbers.
**Layer of the implied fix:** n/a
**Anchor:** n/a

