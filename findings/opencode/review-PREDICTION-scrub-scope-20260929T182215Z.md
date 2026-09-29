# opencode review — PREDICTION-scrub-scope

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
reviewed_utc:    20260929T182215Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p10/PREDICTION-scrub-scope.md
    sha:  0600264f7961
    dirty: false
lab_head:        254e4a9
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p10/PREDICTION-scrub-scope.md
  verdict: REJECT
  summary: P1 (the central directional prediction) cannot be unambiguously scored from the probe as specified — the two `user.email` placements share a key with no distinct values, and the only analysis method named is a flat grep, so any single surviving occurrence is unassignable to a level.
  blocking:
    - reason: P1's directional claim (record-level `user.email` deleted, resource-level `user.email` survives) cannot be verified from the probe as specified.
      wrong_action: A reader running the probe gets zero or one `user.email` occurrences in events.jsonl and cannot determine which level produced any surviving occurrence; they either pick a side and report P1 as confirmed (false confidence) or report the probe as inconclusive (wasted run) — the prediction does not get scored either way.
      anchor: "carrying `user.email` **twice** — once as a resource attribute and once as a log-record attribute — plus `gen_ai.prompt` and `tool.arguments` as record attributes, and a unique marker string so the result is greppable. Then grep `infra/telemetry-out/events.jsonl` for each planted key."
      evidence: evidence/p10/PREDICTION-scrub-scope.md:17-20
  non_blocking:
    - reason: P3's mechanism substitutes identity exfiltration for source-code exfiltration — the comment claims to protect "prompt/response/tool bodies" (source code), but the probe plants source-code keys only at record level (the covered channel), so the resource-channel finding about identity never tests source code on the uncovered channel P3 claims is exposed.
      evidence: evidence/p10/PREDICTION-scrub-scope.md:37-43
    - reason: P2 says "four ... keys" but there are only three distinct key names and four placements; a single surviving `user.email` permits scoring either as "2 of 3 distinct names deleted" or "3 of 4 placements deleted" without disambiguating which count is meant.
      evidence: evidence/p10/PREDICTION-scrub-scope.md:33-35
    - reason: The unique marker is named as a positive control but no protocol is specified for the failure case — what the write-up does if the marker does not appear in events.jsonl, so absence of all planted keys remains indistinguishable from ingestion failure.
      evidence: evidence/p10/PREDICTION-scrub-scope.md:17-20
    - reason: P5 claims "Under P1 that is because this project's runs never emit it," but a run that emits record-level `user.email` would also produce zero under P1 (the scrubber removes it); the zero cannot distinguish "runs never emit" from "runs emit and scrubber removes" without evidence at the emission boundary.
      evidence: evidence/p10/PREDICTION-scrub-scope.md:51-54
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |
| ollama-cloud/deepseek-v4-pro | ok | 41s |

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
| Prediction — the collector scrub probe, registered before the probe runs | 1/2 | L2 |
| Predictions, with mechanism | 1/2 | L3 |
| P1 — direction. | 1/2 | L2 |
| P2 — magnitude. | 1/2 | L2 |
| P3 — what it does to the claim. | 1/2 | L2 |
| P4 — the reading if P1 is refuted. | 1/2 | L2 |
| P5 — the zero stays meaningful either way. | 1/2 | L3 |
| Cross-cutting | 1/2 | L2 |
| P3 — what it does to the claim | 1/2 | L3 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### Prediction — the collector scrub probe, registered before the probe runs
**Verdict:** finding
**Failure:** The probe plants `user.email` at both resource and record level but specifies neither distinct values nor a level-aware parser. If the exported file contains one `user.email`, reviewer A can attribute it to the resource and conclude that the record attribute was deleted; reviewer B can attribute it to the record and conclude that the resource attribute was deleted. Grepping the shared key cannot distinguish those outcomes.
**Layer of the implied fix:** L2
**Anchor:** carrying `user.email` **twice** — once as a resource attribute and once as a log-record attribute — plus `gen_ai.prompt` and `tool.arguments` as record attributes, and a unique marker string so the result is greppable. Then grep `infra/telemetry-out/events.jsonl` for each planted key.

### Predictions, with mechanism
**Verdict:** finding
**Failure:** P2 calls the planted items “four ... keys,” although there are only three distinct key names and four placements. A result containing one `user.email` produces incompatible scoring: one reviewer can count three distinct keys and report 2 of 3 deleted, while another can count placements and report 3 of 4 deleted.
**Layer of the implied fix:** L3
**Anchor:** Of the four planted content/identity keys, **3 of 4 are deleted and 1 of 4 survives**

### P1 — direction.
**Verdict:** finding
**Failure:** With the probe as specified, an output containing exactly one `user.email` cannot establish that the record-level copy was deleted and the resource-level copy survived. Two reviewers can assign that surviving occurrence to opposite levels and reach opposite verdicts on P1.
**Layer of the implied fix:** L2
**Anchor:** The **record-level** `user.email` is deleted; the **resource-level** `user.email` **survives into `events.jsonl`**.

### P2 — magnitude.
**Verdict:** finding
**Failure:** Suppose the output contains `user.email` once and neither `gen_ai.prompt` nor `tool.arguments`. The stated grep evidence supports that three placements disappeared only if the surviving `user.email` is known to be resource-level, but the probe does not make that occurrence distinguishable. One reviewer scores 3 of 4; another says the deletion count is indeterminate between 2 and 3.
**Layer of the implied fix:** L2
**Anchor:** **3 of 4 are deleted and 1 of 4 survives**

### P3 — what it does to the claim.
**Verdict:** finding
**Failure:** Set `OTEL_RESOURCE_ATTRIBUTES=user.email=test@example.com` while the runtime also emits a log-record `user.email`. If one occurrence reaches the file, the proposed grep cannot show that it came through the environment-controlled resource channel. One reviewer can therefore accept the claimed house failure mode while another rejects it as unproven.
**Layer of the implied fix:** L2
**Anchor:** The comment would then describe a guard against the one channel the guard does not cover.

### P4 — the reading if P1 is refuted.
**Verdict:** finding
**Failure:** If no `user.email` appears, reviewer A can treat that as proof that the attributes processor deleted the resource attribute; reviewer B can point to ingestion, transformation, routing, or serialization as alternative causes. The probe specifies no positive control demonstrating that the planted record reached `events.jsonl`, so disappearance does not uniquely establish wider processor scope.
**Layer of the implied fix:** L2
**Anchor:** If the resource-level key is also deleted, the processor's scope is wider than the OTel documentation implies for this collector version

### P5 — the zero stays meaningful either way.
**Verdict:** finding
**Failure:** A runtime may emit `user.email` while the collector, pipeline routing, or exporter removes or drops it before persistence. The same zero in `events.jsonl` would then lead one reviewer to say the runs never emitted it and another to say only that persisted collector output never contained it; the artifact asserts the stronger conclusion without evidence at the emission boundary.
**Layer of the implied fix:** L3
**Anchor:** Under P1 that is because this project's runs never emit it, not because the collector removes it

### Cross-cutting
**Verdict:** finding
**Failure:** P1’s directional outcome and P2’s 3-of-4 magnitude duplicate the same pass/fail determination: whether the record-level and resource-level `user.email` copies receive different treatment. Reviewers would diverge most on P1/P2 by one deletion—2 of 4 versus 3 of 4—because the two copies share a key and no distinct values or structural inspection rule is specified. The artifact needed to say how each planted placement is independently identified and how successful ingestion is positively established before absence is attributed to scrubbing.
**Layer of the implied fix:** L2
**Anchor:** Then grep `infra/telemetry-out/events.jsonl` for each planted key.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Prediction — the collector scrub probe, registered before the probe runs

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The intro's framing is sound: a zero that "does not distinguish *the scrubber deleted it* from *nothing ever sent it*" is exactly the right reason to probe. No divergence scenario here.

### P1 — direction

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The directional prediction (record attribute deleted, resource attribute survives) is internally coherent and its mechanism — `attributes` processor touches item attributes, not the resource, and no `resource` processor is wired in `service.pipelines.logs.processors` — is a concrete, checkable claim. The problem is not here; it is what P3 does with this prediction.

### P2 — magnitude

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

P2 restates P1 with arithmetic ("3 of 4 deleted, 1 of 4 survives") rather than adding an independent mechanism. That is a mild redundancy, not a defect — see cross-cutting.

### P3 — what it does to the claim

**Verdict:** finding
**Failure:** The probe plants `user.email` at the resource level, but the claim under test (`config.yaml:5-8`) is about **source-code** exfiltration — "deletes prompt/response/tool bodies… a single wrong env var… cannot exfiltrate **source code**". The source-code keys (`gen_ai.prompt`, `tool.arguments`) are planted **only as record attributes**, the one channel the processor provably covers. So if P1 holds, the surviving value in `events.jsonl` is an *email address*, not source code. Two competent reviewers diverge here: one concludes the comment is "true over a smaller scope" (as P3 claims), the other concludes the comment's actual claim — *source code cannot be exfiltrated* — is **unrefuted**, because the probe never put source code on the resource channel it is showing to be uncovered. P3's mechanism ("`OTEL_RESOURCE_ATTRIBUTES` is the standard way *identity* reaches a resource") establishes the uncovered channel for identity, then silently re-brands that into a refutation of a source-code claim. The house-failure-mode conclusion ("the guard does not cover the channel it describes") rests on that substitution.
**Layer of the implied fix:** L3
**Anchor:** "The misconfiguration it names — 'a single wrong env var on a laptop' — is precisely the class that sets an OTel **resource** attribute, because `OTEL_RESOURCE_ATTRIBUTES` is an env var and is the standard way identity reaches a resource."

### P4 — the reading if P1 is refuted

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Registered as the more likely refutation; coherent and symmetric. No divergence scenario.

### P5 — the zero stays meaningful either way

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Correct that the measured fact about real runs is unchanged, and correct that the write-up must name *which* reading holds. No defect.

### Cross-cutting
- **Duplicate gate/prediction:** P2 duplicates P1's direction and only adds a count. Not a pass/fail gate, but it is a second prediction with no new mechanism — a reviewer scoring "did this probe predict its own outcome" would not know whether to count P1+P2 as two predictions or one.
- **Most divergent section:** P3, by a wide margin — on whether the comment's source-code claim is refuted or merely out of the probe's reach. This is the one place two faithful readers land on opposite conclusions from the same result.
- **What it did not say:** It never states that source code (`gen_ai.prompt`, `tool.arguments`) is *not* planted at the resource level, and never addresses the category mismatch between "identity" (the thing planted on the uncovered channel) and "source code" (the thing the comment claims to protect). The probe also plants no **response**-body key at all, so the comment's "prompt/response/tool bodies" is tested only for two of its three named bodies.
