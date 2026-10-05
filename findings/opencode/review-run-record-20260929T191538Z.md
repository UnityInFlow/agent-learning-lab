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
reviewed_utc:    20260929T191538Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        70221a7
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Template is L1 by design but contains four specification gaps where the only instructions are ambiguous enough that two operators filling it in will produce records that silently disagree at the byte level and cannot be aggregated.
  blocking:
    - reason: Six behavior fields (modelCalls, toolCalls, filesRead, retries, approvals, compactions) appear as bare scalar placeholders while three siblings (toolsUsed, filesChanged, commands) are typed as `[]`. Nothing in the template tells the operator whether the scalar fields are integer counts or lists of call records, and both readings fit the artifact.
      wrong_action: Operator A writes `modelCalls: 12` (an integer), Operator B writes `modelCalls:` followed by a list of call dicts. Both files parse; both pass any check named in the artifact; downstream aggregation either fails to parse one form or silently treats both as zero.
      anchor: "behavior:\n  modelCalls:\n  toolCalls:\n  toolsUsed: []\n  filesRead:\n  filesChanged: []\n  commands:\n  retries:\n  approvals:\n  compactions:"
      evidence: templates/run-record.yaml:39-46
    - reason: `fingerprint` is documented as "# hash of the above; arms must match" but "arms" is never defined and "the above" could mean the seven fields immediately above this line, the seven fields plus `configuration`, or some other subset. The field whose entire purpose is to make arms comparable produces incomparable digests.
      wrong_action: Reviewer A hashes only the seven environment fields above the line; Reviewer B hashes those plus `configuration` on the theory that "the treatment is part of the environment the run sits in". The same pair of runs "match" for one reviewer and "diverge" for the other, so the artifact cannot answer its own comparability question.
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `acceptanceScore` has no scale stated anywhere in the block. `0.8` plausibly reads as 80/100 (a percentage) or 0.8/100 (a raw point on a hundred-point scale). Both readings fit the template.
      wrong_action: Reviewer A records0.8 as 80/100, Reviewer B records 0.8 as 0.8/100. The `finalScore` judgments for the same run differ by ~80 points, and nothing in the artifact lets a downstream reader pick the intended reading.
      anchor: "  acceptanceScore:"
      evidence: templates/run-record.yaml:71
    - reason: `cost` records `{value, source, estimated}` but no currency field. Two records with `cost.value: 0.10`, one USD and one EUR, are silently summed as the same unit by anything that adds cost across runs.
      wrong_action: Aggregator adds a USD cost and a EUR cost and returns a numerically valid but wrong total. The provenance triple on lines 51-65 is about tokens and has no slot for currency, so an operator cannot disambiguate the unit even if they want to.
      anchor: "  cost:                { value: null, source: null, estimated: null }"
      evidence: templates/run-record.yaml:65
  non_blocking:
    - reason: `failureClass`, `status`, and `exclusionReason` are constrained only by inline comments ("# F01-F15", "# valid / excluded / pilot / invalidated", "# structured, registered in advance"). No validator rejects a fifth status value or an unregistered reason code, but the comments do name the allowed values, so a careful operator has the guidance; this is an L3 absence, not a wrong instruction.
      evidence: templates/run-record.yaml:73,77,78
    - reason: The efficiency-block provenance comment uses `provider` / `local-tokenizer` as its worked example, which fits token counts but does not literally fit `cost` (cost is derived, not token-counted). The shape extends by analogy but the comment does not say so.
      evidence: templates/run-record.yaml:51-65
    - reason: The cross-cutting claim that the template "needed executable rules for required fields, field types, allowed null states, score scales, cost currency, identifier uniqueness, cross-field consistency, and pre-registered exclusion codes" is a layer choice (L1 vs L2/L3), not a defect. The author chose L1 for the template; the verifier on line 60 is the only L3 check the artifact claims, and it claims it correctly (the script exists per CLAUDE.md).
 evidence: templates/run-record.yaml:60 - reason: The cross-cutting observation that `acceptanceScore` / `finalScore` and `failureClass` overlap with `compile` / `tests` / `hiddenTests` is a design comment, not a wrong-action claim — the template does not promise these are independent, and two reasonable operators can design the relationship differently.
      evidence: templates/run-record.yaml:67-74
  disputed:
    - finding: Round-1 critic flagged twelve "blank field" defects — runId, version, runnerCommit, requested, resolved, fingerprint, instructionsProvenLoaded, modelCalls, toolCalls, benchmarkSha, and exclusionReason — each framed as a reviewer-divergence risk when the field is left empty.
      why: A template's blank fields are placeholders to be filled in. The artifact is a template; placeholder-blankness is correct, not a defect. The genuine ambiguities from this set (fingerprint scope, behavior scalar-vs-list) are already promoted to blocking above with their own anchors. The rest flag that the placeholder is blank, which is the only thing a template can be; the "wrong action" of two reviewers diverging on a placeholder is a filling-in discipline problem, not a template-design defect.
    - finding: Round-2 critic's cross-cutting note that the template "does not identify anything that executes and rejects violations" apart from the bare-number token check.
      why: This is the L1/L2/L3 layering critique, restated as a defect. The artifact is intentionally L1 (template with prose guidance); it does not claim to enforce what it does not enforce; the only enforcement it names — the bare-number check on line 60 — is named correctly and the referenced script exists. The strongest individual defects this critique umbrella-covers have been promoted to blocking with their own anchors; the umbrella claim itself is not a wrong-action finding against the artifact as written.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |
| ollama-cloud/deepseek-v4-pro | ok | 61s |

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
| harness | 1/2 | L2 |
| model | 1/2 | L2 |
| environment | 2/2 | L2 |
| configuration | 1/2 | L2 |
| behavior | 2/2 | L2 |
| efficiency | 2/2 | L2 |
| evaluation | 2/2 | L3 |
| measurement | 2/2 | L2 |
| Cross-cutting | 1/2 | L2 |

> **6 of 11 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### runId
**Verdict:** finding
**Failure:** Two copied records both retain `B0-COPILOT-BE001-001`; one reviewer treats the identifier as illustrative and replaces it, while another accepts it as the actual run ID, causing distinct runs to collide during aggregation.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A run records `id: BE-001` and `revision: 1` but leaves `benchmarkSha` blank after the evaluator changes on the same branch. One reviewer resolves revision 1 using the old evaluator and another uses the new evaluator, producing different scores for the same record.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs both say `github-copilot-cli` but omit `version` and `runnerCommit`; one used a runner before a command-capture fix and the other after it, yet reviewers can treat them as comparable because the record exposes no resolved harness build.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run leaves both model fields blank while the harness silently changes its default from one model release to another. One reviewer groups it with earlier default-model runs; another excludes it because the resolved model is unknown.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Arm A loads no hooks and arm B loads a formatting hook, but both records leave `fingerprint` blank. One reviewer interprets equal blank fingerprints as a match; another compares the lists manually and rejects the arms as environmentally different.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A treatment record sets `instructions` to a custom instruction source while retaining `instructionsProvenLoaded: false`. One reviewer includes the run based on intended configuration; another excludes it because the treatment was never demonstrated to have loaded.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run with unavailable telemetry leaves `modelCalls` blank, while a run with genuinely zero tool calls leaves `toolCalls` blank. One reviewer converts blanks to zero during analysis; another treats them as missing, yielding different behavior and efficiency conclusions.
**Layer of the implied fix:** L2
**Anchor:** modelCalls:
  toolCalls:

### efficiency
**Verdict:** finding
**Failure:** Two records contain `cost.value: 0.10`, one reported in USD and one in EUR, but neither tuple can record currency. An aggregator adds them as the same unit and returns a numerically valid but wrong total cost.
**Layer of the implied fix:** L2
**Anchor:** cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** A record contains `acceptanceScore: 0.8`. One reviewer reads it as 80% and another as 0.8 points on a 100-point scale; both readings fit the artifact, and they can produce radically different `finalScore` judgments.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:

### measurement
**Verdict:** finding
**Failure:** After seeing a poor result, an operator writes `status: excluded` and free-text `exclusionReason: flaky`; one reviewer accepts it as registered in advance, while another rejects it as an unregistered post-hoc exclusion because no reason code or registration reference is represented.
**Layer of the implied fix:** L2
**Anchor:** exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is defined, so no category can be shown to duplicate a pass/fail gate; `compile`, `tests`, and `hiddenTests` may themselves be gates or score inputs, but the artifact does not say. Reviewers would diverge most on `evaluation`: for `acceptanceScore: 0.8`, plausible readings are 80/100 and 0.8/100, a 79.2-point difference. The artifact needed executable rules for required fields, field types, allowed null states, score scales, cost currency, identifier uniqueness, cross-field consistency, and pre-registered exclusion codes; apart from the stated bare-number token check, it does not identify anything that executes and rejects violations.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


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
**Failure:** `fingerprint` is documented as `# hash of the above; arms must match`, but "arms" is never defined and the hash's scope is never fixed. Reviewer A hashes only the seven fields of this block (`bare`, `permissionMode`, `hooks`, `plugins`, `skills`, `mcpServers`, `settingsSources`); Reviewer B hashes those *plus* `configuration` on the theory that "the treatment is part of the environment the run sits in". They produce different digests, so the same pair of runs "match" for one reviewer and "diverge" for the other — the one field whose entire job is to make arms comparable is incomparable. `permissionMode` carries the same shape of problem: `# acceptEdits / plan / default — see harness bug #7` points at an out-of-file bug number, so a reviewer who has not read bug #7 cannot know which of the three values to write, or why it matters.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### behavior
**Verdict:** finding
**Failure:** Six fields are bare empty scalars (`modelCalls`, `toolCalls`, `filesRead`, `retries`, `approvals`, `compactions`) while three sibling fields are typed as lists (`toolsUsed: []`, `filesChanged: []`, `commands: []`). Nothing says whether the scalar fields are *counts* or *lists*. Given a run where the agent read 3 files and called 12 tools, Reviewer A writes `modelCalls: 12` (an integer count) and Reviewer B writes `modelCalls:` followed by a nested list of call records. Both files parse; both validate against anything that only rejects a bare number in the *efficiency* block; the two records are structurally different and silently non-comparable downstream.
**Layer of the implied fix:** L3
**Anchor:** `modelCalls:` / `filesRead:`

### efficiency
**Verdict:** finding
**Failure:** The provenance triple `{ value, source, estimated }` is applied uniformly, but its semantics break on `cost`. The comment's example defines `source` as a token-count provenance (`provider` vs `local-tokenizer`) and `estimated` as "a local tokenizer guessed". Cost is neither counted by a tokenizer nor directly reported by the provider as a token count — it is *derived* from tokens × price. Reviewer A fills `cost: { value: 0.42, source: provider, estimated: false }`; Reviewer B, seeing no sensible `source` for a derived number, leaves `source: null` and marks `estimated: true` because it was computed. The same dollar figure is recorded with contradictory provenance flags, and the block's own comment (`a gap reads as a gap and not as a very efficient run`) fails to cover the case where the field is *filled but the provenance is nonsense*.
**Layer of the implied fix:** L3
**Anchor:** `cost:                { value: null, source: null, estimated: null }`

### evaluation
**Verdict:** finding
**Failure:** `failureClass: # F01-F15` is a free string with an inline comment naming a range, and nothing executes against it. Two concrete divergences. First, a compile failure: Reviewer A records `failureClass: F01` on the theory that F01 is "compile failed", Reviewer B records `failureClass: none` on the theory that a compile failure is already captured by the `compile:` field and failureClass is reserved for crashes/hangs/invalidation. Second, nothing stops either from writing `F16`, `crash`, or a sentence — the enum exists only as a comment, so a bad value can be written down and nothing rejects it. This is the same defect class as the efficiency block, but here the template does not even admit it.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is constrained only by an inline comment (`# valid / excluded / pilot / invalidated`) and `exclusionReason` only by `# structured, registered in advance`. Two divergences. (1) A run the reviewer decides to drop for a broken harness: Reviewer A sets `status: excluded` and writes a prose `exclusionReason`; Reviewer B sets `status: invalidated` and leaves `exclusionReason` empty because "registered in advance" reads, to them, as a requirement that the reason be a pre-registered enum code they do not possess. (2) "structured" names no schema — one reviewer writes `{ code: E01, detail: ... }`, another writes `"harness hung"`. The four status values and the reason format are guidance a human reads and chooses to follow; nothing runs and rejects a fifth value or a free-text reason.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Gate duplication:** `evaluation.failureClass` (F01–F15) overlaps the pass/fail fields it sits beside — `compile`, `tests`, `hiddenTests` are already boolean outcomes, and if any F-code restates "compile failed" or "tests failed", then `failureClass` records the same fact a second time. Nothing in the template rules out that overlap, so a reviewer is left to guess whether `failureClass` *derives from* those booleans or *complements* them. `acceptanceScore` (a 0/1 gate) and `finalScore` (a graded value) are also adjacent with no statement of their relationship; a run that passes acceptance can have `finalScore` and `acceptanceScore` set to the same number by one reviewer and to different numbers by another.
- **Most divergent section:** `behavior` — by the largest margin. Count-vs-list ambiguity on six fields is *structural* (the two reviewers produce different YAML shapes), not merely a value-choice disagreement, so it is the one most likely to yield byte-different records that both still parse and both still validate.
- **What it did not say:** it never types `modelCalls`/`toolCalls`/`filesRead`/`retries`/`approvals`/`compactions` as count-or-list; never defines "arms" or the fingerprint's hash scope; and never names any executing validator for the `failureClass`/`status`/`exclusionReason` enums — the only enforcement named anywhere is `tools/validate-run-record.sh` in the efficiency comment, and even that is cited without a path, as prose.
