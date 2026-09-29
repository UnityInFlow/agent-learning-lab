# opencode review — run-record

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
reviewed_utc:    20260929T174558Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        b3f046e
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Three semantic gaps let a reader record data the artifact itself cannot verify or aggregate: cost carries no currency, finalScore carries no formula, and failureClass names a range without a mapping.
  blocking:
    - reason: The `cost` field carries a numeric `value` but no currency; a USD-denominated record and an EUR-denominated record look identical and a downstream aggregator would silently conflate them.
      wrong_action: A reader aggregating `cost.value` across records assumes one currency and reports a total that is numerically precise but invalid by the EUR/USD ratio.
      anchor: "  cost:                { value: null, source: null, estimated: null }"
      evidence: templates/run-record.yaml:65
    - reason: `finalScore` is requested as a value but the artifact supplies neither a formula nor a scale; two reviewers scoring the same run produce different finalScore values without either being wrong by the artifact.
      wrong_action: A reader computes finalScore from tests, hiddenTests, and acceptanceScore using a chosen formula, producing a number that does not agree with another reviewer's number for the same run, so runs cannot be compared across reviewers.
      anchor: |-
        evaluation:
          compile:
          tests:
          hiddenTests:
          acceptanceScore:
          unintendedChanges:
          failureClass:            # F01-F15
          finalScore:
      evidence: templates/run-record.yaml:67-74
    - reason: failureClass is described as `F01-F15` (a range) but the mapping from failure types to class numbers is not in the artifact; two reviewers classify the same failure differently because the referent of each F-number is undefined here.
      wrong_action: A reader filling the template assigns a failure to an F-number from their own interpretation; another reviewer assigns a different F-number to the same failure, and the experiment's failure-type tally is unreconcilable.
      anchor: "  failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
  non_blocking:
    - reason: The fingerprint field claims "arms must match" but names no algorithm, canonicalization, or verifier; a reader cannot recompute the value or check the constraint from the artifact.
      evidence: templates/run-record.yaml:26
    - reason: runId has no comment explaining uniqueness semantics; two reruns could legitimately share an ID and a reviewer would not know whether to treat them as replacement or additional observation.
      evidence: templates/run-record.yaml:1
    - reason: task.revision and task.benchmarkSha are both asked for, but the artifact does not state which is authoritative when they conflict (e.g., revision: 1 against a commit where the task is revision 2).
      evidence: templates/run-record.yaml:5-6
    - reason: harness.version and harness.runnerCommit are blank with no warning, while model.requested/resolved carry an explicit "differing is not a detail" comment; the asymmetry under-signals the field that pins instrument identity.
      evidence: templates/run-record.yaml:10-11
    - reason: configuration uses `none` as a sentinel for absent values (instructions: none, skills: none, etc.) while environment uses `[]` for the same idea; a parser distinguishing "absent" from "empty" from "literal string 'none'" misreads `instructions: none` as the literal string.
      evidence: templates/run-record.yaml:29-35
    - reason: Several behavior fields (filesRead, modelCalls, toolCalls, retries, approvals, compactions) are bare while siblings (filesChanged, commands, toolsUsed) use empty-list sentinels; a reader cannot tell count from list, and `filesRead` next to `filesChanged: []` is the canonical example.
      evidence: templates/run-record.yaml:38-46
    - reason: The efficiency block's source and estimated fields can disagree (source: provider, estimated: true is internally contradictory) without the schema catching it; the named validator rejects a bare number but not a contradictory pair.
      evidence: templates/run-record.yaml:61-65
    - reason: The efficiency block's self-label "this block is Layer 3 on its own" (line 60) contradicts the named validator (tools/validate-run-record.sh rejects a bare number); by the lab's own layer model the block is L2, not L3.
      evidence: templates/run-record.yaml:60
    - reason: measurement.status lists allowed values (valid / excluded / pilot / invalidated) in a comment but the template does not enforce them; a reader could write any string and pass.
      evidence: templates/run-record.yaml:77
    - reason: measurement.exclusionReason claims to be "structured, registered in advance" but the structure is unnamed; two reviewers encode the same reason with different strings.
      evidence: templates/run-record.yaml:78
    - reason: measurement.telemetryComplete can be set to true while a token or cost field remains null; the artifact does not state which field is authoritative, so a downstream filter on telemetryComplete == true could silently admit records with missing data.
      evidence: templates/run-record.yaml:79
  disputed:
    - finding: codex flags runId because two reruns could share an ID and reviewers would diverge on replacement vs additional observation.
      why: "runId: B0-COPILOT-BE001-001" is shown as an example value, not a uniqueness claim. The artifact makes no assertion about uniqueness; the finding describes behavior of hypothetical filled records rather than a defect in the template itself.
    - finding: codex classifies the behavior block's tool-call vs command ambiguity as L3 because nothing executes to enforce a single counting convention.
      why: The ambiguity is real, but the counting convention lives in the downstream parser/scoring layer; the template's role is to record data, not to define counting rules. The defect is documentation-style rather than measurement, and a runner can pick a convention without affecting what the template records.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 52s |
| ollama-cloud/deepseek-v4-pro | ok | 56s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/2 | L2 |
| task | 1/2 | L2 |
| harness | 2/2 | L2 |
| model | 1/2 | L2 |
| environment | 2/2 | L2 |
| configuration | 2/2 | L2 |
| behavior | 2/2 | L3 |
| efficiency | 2/2 | L3 |
| evaluation | 2/2 | L3 |
| measurement | 2/2 | L2 |
| Cross-cutting | 1/2 | L3 |

> **4 of 11 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### runId
**Verdict:** finding
**Failure:** Two reruns of BE-001 retain `B0-COPILOT-BE001-001`. One reviewer treats the second record as a replacement; another treats it as an additional observation. Run counts and aggregate scores diverge.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record says `revision: 1` but its `benchmarkSha` points to a commit where BE-001 has revision 2. One reviewer resolves the task by revision; another resolves it from the commit, so they evaluate different task definitions under the same record.
**Layer of the implied fix:** L2
**Anchor:** revision: 1
  benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs use different runner commits but both leave `version` and `runnerCommit` blank. A harness change alters command capture between the runs; one reviewer compares them as equivalent, while another excludes the comparison because harness identity is unknown.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two runs request `haiku` before and after the alias is repointed, and both leave `resolved` blank. One reviewer groups them as the same model using `requested`; another treats the model identity as unverifiable, producing different arm membership.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two semantically identical environments list hooks in opposite orders. One fingerprint implementation hashes serialized YAML and produces different hashes; another sorts list entries and produces matching hashes. The same runs therefore either fail or pass the requirement that arms match.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run loads an instruction file containing only whitespace changes from the registered file. One reviewer hashes raw bytes and marks the treatment mismatched; another normalizes whitespace and marks it matched. `instructionsHash` does not define what representation is hashed.
**Layer of the implied fix:** L2
**Anchor:** instructionsHash:

### behavior
**Verdict:** finding
**Failure:** The agent invokes the shell tool once with `npm test`. One reviewer records `toolCalls: 1` and one command; another counts the shell invocation and the executed command as two tool calls. Both records fit the template, but efficiency comparisons disagree.
**Layer of the implied fix:** L3
**Anchor:** toolCalls:
  toolsUsed: []
  filesRead:
  filesChanged: []
  commands: []

### efficiency
**Verdict:** finding
**Failure:** Two records contain `cost.value: 1.25`; one producer means USD and another means EUR. Both conform to the shown object shape, and reviewers aggregating the values report a numerically precise but invalid cost comparison because no currency is recorded.
**Layer of the implied fix:** L3
**Anchor:** cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** For a run with compile success, 8/10 visible tests, 4/5 hidden tests, and `acceptanceScore: 0.8`, one reviewer computes `finalScore` as 0.8 while another combines the test proportions and reports 0.82. The artifact supplies neither a formula nor a score scale, so both outcomes are defensible.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record sets `telemetryComplete: true` while `cost.value` remains null at Level C. One reviewer accepts the record because the boolean declares completeness; another excludes it because a telemetry field is missing. The fields permit contradictory states without defining which one controls.
**Layer of the implied fix:** L2
**Anchor:** telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** No concrete input or diff makes the explicitly free-form notes field produce a wrong answer by itself.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring-category definitions are present, so duplication with a pass/fail gate cannot be determined; `compile`, `tests`, and `hiddenTests` could either be gates or components of `finalScore`. Reviewers would diverge most on `evaluation`: for the same 8/10 visible and 4/5 hidden results, the undefined formula and scale allow 0.8, 0.82, 80, 82, or another value. The artifact needed to state executable validation coverage and authoritative semantics for identity uniqueness, hash canonicalization, behavioral counting, cost currency, score calculation, and contradictory completeness states.
**Layer of the implied fix:** L3
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** no finding
**Failure:** n/a — an example value, not a claim.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** n/a — `benchmarkSha` is left blank for the run to fill; the comment states its meaning.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### harness
**Verdict:** finding
**Failure:** `version` and `runnerCommit` are blank with no comment, while `model` (two lines down) gets a paragraph explaining why its two fields differ. A run where the harness auto-updated between two arms records `version: 1.2.3` vs `version: 1.2.4`; one reviewer treats that as a harness drift worth excluding, the other treats it as noise because nothing in the template says these fields pin the instrument the way `model.resolved` is flagged to. The asymmetry means the field that matters most for reproducibility (which harness binary ran) is the one with no "differing is not a detail" warning.
**Layer of the implied fix:** L3
**Anchor:** `version:` / `runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a — the requested/resolved split is genuinely explained and the alias re-point hazard is named.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `fingerprint` is described only as "hash of the above; arms must match", but neither the field set, the ordering, nor the serialization is specified. Two arms with byte-identical configs can produce different hashes if one normalizes `permissionMode` to lowercase and the other preserves the author's casing, or if one hashes `settingsSources` before `skills` and the other after. The result is "arms must match" failing spuriously, and two reviewers cannot agree on whether the fingerprint was computed correctly because there is no canonical input to recompute it from. Nothing executes to compute or verify the hash — it is a claim with no named verifier.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** "nothing" is written three different ways across the two treatment/non-treatment blocks: `instructions: none` (bare string), `skills: none`, `customAgent: none`, `hooks: none`, `mcp: none` — while the same idea in `environment` is `hooks: []` (empty list) and in `task` is blank (`benchmarkSha:`). A downstream parser distinguishing "field absent" from "field present and empty" from "field present and equal to the literal string 'none'" reads `instructions: none` as the instruction *text* "none", not as "no instructions", if a run's instruction genuinely began with that word. Two reviewers filling the same record disagree on which sentinel means "unset" and which means "the value is literally that string".
**Layer of the implied fix:** L3
**Anchor:** `instructions: none` / `hooks: none` / `mcp: none`

### behavior
**Verdict:** finding
**Failure:** The list-valued fields (`toolsUsed: []`, `filesChanged: []`, `commands: []`) establish that "collection of things" uses an empty-list sentinel, but `filesRead`, `modelCalls`, `toolCalls`, `retries`, `approvals`, `compactions` are bare — no type, no example, no empty-list sentinel. `filesRead` is unambiguously ambiguous: `filesChanged` is a list of filenames, so `filesRead` is either a count (scalar) or a list (like its sibling), and the template gives no way to tell. Two reviewers record the same run as `filesRead: 7` and `filesRead: [a.ts, b.ts, ...]`; a consumer summing `filesRead` as a count gets `NaN` on the second. The same type ambiguity holds for `modelCalls`/`toolCalls` (count vs call-log) and `approvals` (count vs list of requests).
**Layer of the implied fix:** L3
**Anchor:** `filesRead:` / `filesChanged: []`

### efficiency
**Verdict:** finding (two, reported as the more serious)
**Failure:** The level discriminator is split across two independent free-form fields — `source` (arbitrary string) and `estimated` (bool/null) — and nothing enforces they agree. A record with `inputTokens: { value: 11950, source: provider, estimated: true }` is internally contradictory (provider-reported yet marked "estimated"), and two reviewers classify it differently: one reads `estimated: true` and calls it Level B, the other reads `source: provider` and calls it Level A. The comment's own A/B/C taxonomy names three states but the record has no single field that encodes the level; it is inferred from two fields that can disagree. The validator (if it only rejects a bare number) never sees this contradiction.
**Layer of the implied fix:** L3
**Anchor:** `inputTokens:         { value: null, source: null, estimated: null }` (against comment lines 55–57)

**Secondary, same block:** the comment asserts "this block is Layer 3 on its own" (line 60) while simultaneously naming the thing that executes — `tools/validate-run-record.sh` rejects a bare number. By the lab's own rule, once something executes and rejects the bad state (a bare scalar in place of the three-field object), the block is L2, not L3. Two reviewers applying the layer model land on opposite labels, and the artifact's own self-label is wrong. The structure is enforced; only the internal consistency of `source`/`estimated` remains L3.

### evaluation
**Verdict:** finding
**Failure:** `failureClass: # F01-F15` names a range of fifteen classes but defines none of them here. A run that compiled but produced wrong output — one reviewer records `F07` (logic error), another `F12` (behavioral regression), because F01–F15 are only an interval, not a mapping. The template's own `failureClass` value is unfalsifiable: without the F01–F15 key, two reviewers cannot agree on what a given failure *is*, so the field carries a number with no shared referent. Nothing here or referenced in-line provides the definition.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is a free string whose allowed values (`valid / excluded / pilot / invalidated`) live only in a comment. A run excluded because telemetry was incomplete can be recorded as `status: excluded`, `status: invalidated`, or `status: excluded-incomplete-telemetry`, and nothing executes to reject any of them. Two reviewers, and any downstream filter selecting `status == "invalidated"`, silently miss records that said "excluded" for the same reason. `exclusionReason: # structured, registered in advance` compounds it: "structured" is asserted but the structure is unnamed, so "structured" reason #1 and #2 are whatever each reviewer invents.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a — deliberately free-form, and the instruction to record what flattered the result is sound guidance rather than a claim.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Duplicate pass/fail gate:** `evaluation.acceptanceScore` and `measurement.status` both encode "did this run count." A run with a low `acceptanceScore` but `status: valid` (or the reverse, `status: invalidated` with a passing `acceptanceScore`) is double-encoded, and the template never states which field wins when they conflict. `evaluation.failureClass` and `finalScore` likewise overlap — a reviewer cannot tell whether `failureClass` is an input to `finalScore` or a restatement of it.
- **Most divergent section:** `efficiency` — the `source`/`estimated` two-field level encoding will produce the widest split because two reviewers will disagree not only on the *value* but on the *level* a given pair represents, and the block's own self-label (L3) contradicts the named validator (L2). Second is `configuration` for the three-sentinel "nothing" ambiguity.
- **What it did not say that it needed to say:** the meaning of F01–F15; the canonical input and serialization for `fingerprint`; the type of every bare `behavior` field (scalar count vs list); which field is authoritative when `acceptanceScore` and `status` disagree; and the definition of the `source` value vocabulary so `provider` and `local-tokenizer` are not free-form strings.
