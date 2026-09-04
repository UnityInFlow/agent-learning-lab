# opencode review — run-record

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
reviewed_utc:    20260904T065312Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        28f5ca3
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml
  verdict: REJECT
  summary: The template's inline comments promise controls nothing in the artifact lets a reader verify (fingerprint arms must match; exclusion reasons are registered in advance) and accepts measurements without the units or scale an aggregator would need (cost has no currency, scores have no declared scale), so two faithful recorders can produce records a downstream consumer combines incorrectly.
  blocking:
    - reason: cost carries a numeric value, a source label, and an estimated flag — but no currency or unit — so two provider-supplied `value: 125` entries can mean cents vs dollars and aggregate 100× off with no signal in the template that this is possible.
      wrong_action: an analyst totals two runs that both report `value: 125, source: provider` without realising one provider reports cents and the other dollars; the sum is wrong by a factor of 100 and the template offers no way to detect the mix.
      anchor: "  cost:                { value: null, source: null, estimated: null }"
      evidence: run-record.yaml:65
    - reason: acceptanceScore and finalScore accept any number without a declared scale, so `0.8` (0–1) and `80` (0–100) both fit the template for the same outcome and mean the same thing.
      wrong_action: an aggregator averages a0.8 record and an 80 record into 40.4 instead of treating them as equivalent; rankings and significance tests come out wrong, and the template carries no signal that the two numbers were meant to be the same.
      anchor: "  acceptanceScore:\n  unintendedChanges:\n  failureClass:            # F01-F15\n  finalScore:"
      evidence: run-record.yaml:71-74
    - reason: the fingerprint comment asserts "arms must match" but defines neither what an arm is, what the fingerprint is a hash of, nor whether list ordering matters, so two faithful implementers compute different fingerprints from the same `environment:` block.
      wrong_action: reviewer A hashes the raw YAML of `environment:` so `[a,b]` and `[b,a]` produce different fingerprints and the arms look confounded; reviewer B hashes a canonicalised form where order does not matter and the arms match. The two reviewers disagree on whether the comparison is valid and the artifact offers no in-template way to break the tie.
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: run-record.yaml:26
    - reason: exclusionReason's comment asserts the value is "structured, registered in advance" but names neither the registry, the allowed values, nor where to find them, so any string the runner invents satisfies the field as written.
      wrong_action: one reviewer accepts `timeout` and `network_drop` as valid reasons; another accepts only values they recognise from outside the template. The same record set yields two different analysis populations and a reader has no in-template way to tell which exclusion reasons are real.
      anchor: "  exclusionReason:         # structured, registered in advance"
      evidence: run-record.yaml:78
  non_blocking:
    - reason: the blank lines for benchmarkSha, version, runnerCommit, requested, resolved, and toolCalls document what should go there but do not promise a comparison property; a blank line in a template is correct, and the run-level fix (a validator that refuses a post-execution record with these still null) is downstream.
      evidence: run-record.yaml:6,10,11,14,15,39
    - reason: the Level C token block (`{ value: null, source: null, estimated: null }`) already names its external validator in-line and is shaped accordingly; the remaining gap is the missing currency/unit called out in blocking, not the structure of the block.
      evidence: run-record.yaml:59-65
    - reason: instructionsProvenLoaded: false is paired with instructions: none on the lines above; a reader who reads the block together resolves the field correctly, so the cross-run ambiguity the line-level pass flagged is a downstream aggregation issue rather than a defect of the field as written.
      evidence: run-record.yaml:29-31
  disputed:
    - finding: instructionsProvenLoaded: false is ambiguous between "no instructions to load" (expected) and "preflight failed" (problem)
      why: the template pairs the boolean with `instructions:` on the line above; a reader who reads the block together resolves it correctly. The line-level scenario only arises when comparing runs that did have instructions, where the field's sibling distinguishes the cases.
    - finding: runs leaving benchmarkSha, version, runnerCommit, requested/resolved, or toolCalls blank produce reviewer disagreement about whether the comparison is valid
      why: the template correctly shows these as fields a run must fill; a blank line in a template is not the same defect as a run that leaves the field blank after executing. The template's responsibility ends at documenting what goes there; enforcement belongs to the runner or to validate-run-record.sh, not to the template.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| task | 1/1 | L2 |
| harness | 1/1 | L2 |
| model | 1/1 | L2 |
| environment | 1/1 | L2 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L2 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** Run A resolves BE-001 from commit aaa111 but leaves benchmarkSha blank; Run B resolves it from bbb222 and also leaves it blank. One reviewer compares them as repetitions of the same task, while another excludes them because evaluator equivalence cannot be established.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs use github-copilot-cli versions 1.0 and 1.1 but both leave version and runnerCommit blank. One reviewer pools their results; another treats the harness change as a confound and separates them.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two records both leave requested and resolved blank, although one run used alias haiku resolving to model X and the other resolved to model Y after the alias moved. One reviewer groups them by intended model; another cannot establish model identity and excludes both.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two semantically identical environments list plugins as [a, b] and [b, a]. A hash implementation over raw YAML produces different fingerprints, while an implementation that canonicalizes unordered lists produces the same fingerprint; reviewers therefore disagree whether the arms match.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run has instructions: none and instructionsProvenLoaded: false. One reviewer interprets false as the expected result because there were no instructions to load; another interprets every false value as a failed preflight and invalidates the run.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run makes zero tool calls and leaves toolCalls blank; a telemetry failure also leaves toolCalls blank. One reviewer treats both as zero-tool runs, while another treats both as unknown, changing tool-use and efficiency comparisons.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:

### efficiency
**Verdict:** finding
**Failure:** Two providers report cost.value: 125, one meaning 125 cents and the other meaning 125 dollars. Both satisfy the shown provenance shape, but an analyst combining them produces a 100-fold error because no currency or monetary unit is recorded.
**Layer of the implied fix:** L3
**Anchor:** cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** For the same run, one evaluator records acceptanceScore: 0.8 and finalScore: 0.8 on a 0–1 scale; another records 80 and 80 on a 0–100 scale. Both fit the template, and an aggregate that assumes one scale ranks or averages them incorrectly.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** Two excluded runs use exclusionReason values timeout and infrastructure_failure. One reviewer accepts both as structured preregistered reasons; another accepts only timeout because no allowed structure or registry is identified, producing different analysis populations.
**Layer of the implied fix:** L2
**Anchor:** exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category can be shown to duplicate a pass/fail gate because the artifact defines fields, not scoring categories or gate logic. Reviewers are most likely to diverge on evaluation: the same acceptanceScore or finalScore can differ by a factor of 100 under plausible 0–1 and 0–100 interpretations. The artifact needed executable completeness and consistency rules, canonical fingerprint semantics, score scales, cost units and currency, and an identifiable registry for exclusion reasons; without them, the concrete scenarios above remain representable and are handled differently.
**Layer of the implied fix:** L3
**Anchor:** n/a

