# opencode review — E-004-skill-activation

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
reviewed_utc:    20260904T072705Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-004-skill-activation.md
    sha:  1c2f8cce6409
    dirty: false
  - path: tools/skill-activation.sh
    sha:  958f82c2cfab
    dirty: false
lab_head:        ae42e02
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-004-skill-activation.md
  verdict: REJECT
  summary: Decision rule row 1's CONFIRM threshold contradicts the MDE table on the primary outcome, so two readers reach opposite verdicts on identical data; the amendment's delivery-timing confound is registered but never measured; and the measurement script counts bundled-with-missing-source events as project-scope.
  blocking:
    - reason: Decision rule row 1 fires CONFIRM on matched ≥ 4/5 AND matched − misdescribed ≥ 3, while the MDE table labels the same 4/5-vs-1/5 cell as p = 0.206, NOT detectable. Two sections of the same artifact reach opposite verdicts on the primary outcome.
      wrong_action: A reader applies row 1 to a matched-4/misdescribed-1 result and records CONFIRM ("the description selects, and it is measured here"); another reader applies the MDE and records NOT DETECTABLE.
      anchor: "Matched ≥ 4/5 **and** matched − misdescribed ≥ 3 | **CONFIRM** — the description selects, and it is measured here"
      evidence: experiments/E-004-skill-activation.md:228
    - reason: Decision rule row 4 attributes matched ≤ 1/5 to "the vendors' documented mechanism does not reproduce on this instrument at this model", but the amendment (lines 135–138) explicitly invalidates that attribution by stating a miss can no longer be attributed to description alone because the skill only becomes available after the agent touches sample-service/. Row 4's REFUTED attribution is unsupported without a check the agent reached the subdirectory.
      wrong_action: A reader records REFUTED on matched ≤ 1/5, when the result might just mean the agent never reached sample-service/ and the skill never became available.
      anchor: "**REFUTED** — prediction 1 fails as a one-arm claim, and the vendors' documented mechanism does not reproduce on this instrument at this model"
      evidence: experiments/E-004-skill-activation.md:231
    - reason: Sanity checks have no entry verifying the agent reached sample-service/, which is the amendment's only condition for distinguishing a description-failure from a delivery-timing-failure. The checklist covers commit timestamps, body identity, hook count, model/version identity, and runner identity — but nothing that lets the decision rule's row 4 distinguish what the amendment flags as confounded.
      wrong_action: A reader applies the decision rule without knowing whether the skill was available to the model, so row 4's REFUTED attribution is unsupported on the actual data.
      anchor: "## Sanity checks"
      evidence: experiments/E-004-skill-activation.md:257
    - reason: The measurement script counts any event with `skill.source != "bundled"` as project-scope. `at.get("skill.source")` returns `None` for a missing attribute, `None != "bundled"` evaluates true, and the `else` branch increments `proj`. A bundled activation whose telemetry record has no `skill.source` attribute would be misclassified as project-scope, contradicting the artifact's stated exclusion "Bundled-skill activations (`skill.source = bundled`) are excluded from the outcome by definition" and inflating the primary outcome.
      wrong_action: A reader records a project-scope activation where a bundled activation actually occurred, falsely inflating the matched arm's count.
      anchor: "                    if src == \"bundled\":\n                        bundled += 1\n                    else:\n                        proj += 1"
      evidence: tools/skill-activation.sh:93
  non_blocking:
    - reason: Preflight assertion says "one run per treated arm" but does not specify what task arm C's preflight uses; if it uses BE-003, the stated delivery proof fails because arm C's description does not match. The design is rescuable by reading arm C's delivery as inherited from arm B's preflight + the byte-identical body claim, but the artifact does not state this inheritance explicitly.
      evidence: experiments/E-004-skill-activation.md:71
    - reason: Sanity check "only the frontmatter differs" is ambiguous between "only the description line differs" and "any frontmatter change is permitted"; intent is clear from the Independent variable section's "Exactly one thing: the description: line" but the check could in principle permit a name change the design forbids.
      evidence: experiments/E-004-skill-activation.md:260
    - reason: Exclusions section does not specify replacement, reporting ratio (4/4 vs 4/5), or verdict deferral when an infrastructure failure reduces a treated arm below 5 measured runs. Two readers could compute the matched-arm threshold differently on the same partial data.
      evidence: experiments/E-004-skill-activation.md:213
    - reason: The script's contract says exit 2 for unparseable telemetry but only honours it when no line parses; a single valid line (even for an unrelated run) followed by malformed lines for the target run exits 3 (run absent) instead of 2 (unparseable). Corrupt telemetry would be misclassified as a missing run rather than flagged as instrument failure.
      evidence: tools/skill-activation.sh:73
 disputed:
    - finding: codex claimed the delivery proof is circular because both the primary outcome (activation in the batch) and the prerequisite (delivery proof) reduce to "activation", so for arm C you cannot distinguish "delivery worked, selection failed" from "delivery failed".
      why: The design is sequential, not circular. Arm B's preflight activation on BE-003 proves file placement + body delivery + selection on a matching task; arm C has a byte-identical body at the same path with the same name (Independent variable section), so file placement and body delivery are inherited from arm B's preflight. The preflight section's wording ("one run per treated arm") is ambiguous about arm C's preflight task, but the byte-identical body claim rescues the design — the underlying logic is delivery-then-selection, with arm B's preflight establishing delivery for both arms and the batch measuring selection. Not actually circular.
      evidence: experiments/E-004-skill-activation.md:61
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 53s |
| ollama-cloud/deepseek-v4-pro | ok | 110s |

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
| Predictions | 1/2 | L2 |
| How the treatment is delivered — and proved | 1/2 | L2 |
| Exclusions | 1/2 | L3 |
| Decision rule | 2/2 | L2 |
| Sanity checks | 1/2 | L2 |
| tools/skill-activation.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L3 |

> **6 of 7 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete input or diff makes the stated research question yield divergent interpretations.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete ambiguity found: the hypothesis specifies the proposed mechanism, expected arm behavior, and observable event.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** Prediction 2 calls zero project-scope activations structural, but the supplied counter classifies every source other than `bundled`—including `plugin`, `user`, or a missing source—as project scope. For a control run containing one `skill_activated` event with `skill.source = plugin`, one reviewer will treat prediction 2 as satisfied because no project skill was installed, while the executable reports one project-scope activation and refutes it.
**Layer of the implied fix:** L2
**Anchor:** “The control arm records 0 project-scope skill activations on 5 of 5. Not a statistical claim — no skill is installed, so there is nothing to load.”

### Independent variable
**Verdict:** no finding
**Failure:** No concrete uncontrolled difference is left unspecified between treated arms: path, name, and body are fixed while the frontmatter description varies.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Suppose the misdescribed preflight reaches and edits `sample-service`, makes the nested skill available, but emits no activation because its description does not match—the predicted behavior for arm C. One reviewer will accept that as successful delivery followed by non-selection; another must reject it as failed delivery because this section defines activation itself as the only delivery proof. The primary outcome and its prerequisite therefore cannot be distinguished.
**Layer of the implied fix:** L2
**Anchor:** “Proof that the skill reached the model is `claude_code.skill_activated` present in telemetry for that run id”

### Controlled variables
**Verdict:** no finding
**Failure:** No concrete divergent treatment identified: the relevant revisions, model, isolation setting, and same-runner constraint are stated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Runs
**Verdict:** no finding
**Failure:** No concrete ambiguity found in arm count, repetition count, interleaving, or the stated evidential limitation of five runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** no finding
**Failure:** The table concretely identifies detectable and non-detectable count combinations; the conflicting downstream decision is attributable to the Decision rule rather than this section.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No concrete scenario makes the evaluator gate or quality covariate substitute for the activation outcome as written.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** If one matched-arm run hits quota exhaustion, four matched runs remain. The artifact does not say whether to replace it, report 4/4, encode it as 4/5, or withhold the registered decision. Two reviewers can therefore apply the later `Matched ≥ 4/5` threshold differently and reach CONFIRM versus no decision from the same four activations.
**Layer of the implied fix:** L3
**Anchor:** “Infrastructure failures (F13/F15), permission blocks and quota exhaustion are excluded from every arm and reported with their count.”

### Decision rule
**Verdict:** finding
**Failure:** For matched 4/5 and misdescribed 1/5, row 1 returns CONFIRM because the difference is 3. The registered MDE table says this exact 4/5-versus-1/5 result has p = 0.206 and is NOT detectable. Two competent reviewers following different parts of the same artifact will report CONFIRM versus NOT DETECTABLE.
**Layer of the implied fix:** L2
**Anchor:** “Matched ≥ 4/5 and matched − misdescribed ≥ 3 | CONFIRM”

### Observed telemetry
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** finding
**Failure:** If both treated files have identical bodies but arm C also changes the frontmatter `name` along with `description`, the listed body-identity check passes even though the experiment changed two variables. One reviewer may interpret “only the frontmatter differs” as permitting any frontmatter difference; another will enforce the earlier claim that exactly the description line differs.
**Layer of the implied fix:** L2
**Anchor:** “the two `SKILL.md` bodies are byte-identical; only the frontmatter differs”

### Decision
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** no finding
**Failure:** Skipped because the artifact explicitly marks this post-run section as unfilled; there is no content to evaluate yet.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Given a telemetry file with one valid JSON line for an unrelated run followed by a malformed line containing the target run's truncated record, `parsed_any` becomes true, the malformed line is silently discarded, and the script exits 3 for absent telemetry. Its contract says an unparseable telemetry file exits 2. A caller may exclude the run as missing instead of stopping for corrupt evidence. The same script also counts `plugin`, `user`, and missing sources as project scope because every non-`bundled` event increments `proj`.
**Layer of the implied fix:** L2
**Anchor:** “except json.JSONDecodeError: continue”

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category `Matched ≥ 4/5` duplicates prediction 1's pass/fail gate, while the between-arm CONFIRM category conflicts with the MDE gate for 4/5 versus 1/5. Reviewers are most likely to diverge on Decision rule by a full verdict—CONFIRM versus NOT DETECTABLE. The artifact also needed to specify replacement or denominator handling after exclusions, an independent delivery observation that does not reuse activation, and the exact allowed `skill.source` value for a project skill.
**Layer of the implied fix:** L3
**Anchor:** “Matched ≥ 4/5 and matched − misdescribed ≥ 3 | CONFIRM”


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The question is stated cleanly and the two-level framing (description-vs-body, and "can the observatory record activation at all") is explicit.

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Predictions are numbered, directional, and each carries a one-arm/between-arm/structural/instrument kind. Prediction 5's low-confidence self-flagging is honest. The defect that follows is not in the predictions themselves but in how the decision rule converts prediction 3's "≥ 3 fewer" into a verdict — reported under *Decision rule*.

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The amendment is the strongest part of the artifact: the `.gitignore` failure is diagnosed to the exact line, the L2 guard is named, and the nested-path loading caveat is registered *before* data. The one soft spot — the control assertion's `customization.*Hash all null` clause is a constant across all arms if prediction 4 holds (skillsHash is null in treated arms too), so it carries no discriminating information — is rescued by the second clause (`zero project-scope skill_activated events`), which does discriminate. Not a finding.

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The Fisher-exact numbers are correct (5/5 vs 0/5 → 0.0079; 4/5 vs 0/5 → 0.048; 4/5 vs 1/5 → 0.206) and the "only near-total separation resolves" statement is right. The section is internally sound; the contradiction lives in the decision rule that is supposed to respect it, and is reported there.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** finding
**Failure:** Two independent defects, both in this table.

**(1) The CONFIRM threshold contradicts the MDE the table claims to be derived from.** Row 1 fires on `matched − misdescribed ≥ 3`. That admits `4/5 vs 1/5`, which the MDE section explicitly labels `p = 0.206, NOT detectable`. Concrete scenario: the batch returns matched = 4/5, misdescribed = 1/5. A reviewer applying row 1 writes **CONFIRM** ("the description selects, and it is measured here"). A reviewer applying the MDE writes **NOT DETECTABLE at n=5**. The artifact's own two sections reach opposite verdicts on identical data, and the flip is a full verdict reversal, not a point of shading. The resolving threshold in the MDE is "near-total separation" (difference ≥ 4); the decision rule's `≥ 3` is one looser.

**(2) The amendment's confound is registered but not propagated into row 4.** The amendment states a miss on prediction 1 "can no longer be attributed to the description alone" (the skill only becomes available once the agent touches `sample-service/`). Row 4 still attributes `matched ≤ 1/5` to "the vendors' documented mechanism does not reproduce on this instrument at this model" — exactly the attribution the amendment says is now invalid. Concrete scenario: matched = 1/5, and the agent never touched `sample-service/` (so the skill never became available). Row 4 → **REFUTED**; the amendment → the result is uninterpretable without knowing whether the agent reached the subdirectory. There is no check anywhere (not in *Sanity checks*, not in the decision rule) that measures whether the agent reached `sample-service/`, so the confound is unmeasured and the decision rule cannot condition on it.

**Layer of the implied fix:** L3 — both are prose/table reconciliations; nothing executes the decision rule, so an inconsistent threshold or an unpropagated confound can be written down and nothing rejects it.
**Anchor:** `Matched ≥ 4/5 **and** matched − misdescribed ≥ 3 | **CONFIRM**` (row 1); `4/5 vs 1/5 → p = 0.206, NOT detectable` (MDE); `A miss can no longer be attributed to the description alone.` (amendment); `REFUTED — prediction 1 fails as a one-arm claim, and the vendors' documented mechanism does not reproduce on this instrument at this model` (row 4).

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder, to be filled after runs.

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Failure analysis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The checklist is sound for what it covers, but it has no entry for the amendment's confound — whether the agent reached `sample-service/` — which is the one thing that would let the decision rule's row 4 distinguish a description failure from a delivery-timing failure. This is the same gap as finding (2) under *Decision rule*; reported there, noted here.

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The primary outcome is not rubric-scored (the rubric is a "quality co-variate only"), so the classic gate-duplication defect does not apply to the outcome. But prediction 2 ("control arm records 0 project-scope activations, structural") and the control assertion ("zero project-scope `skill_activated` events") are the *same claim stated twice* — one as a prediction, one as a verification. That is not a defect here (one is a claim, one is a check), but a reviewer should not read the control assertion's success as independent confirmation of prediction 2; they are the same observation.
- **Which single section would two reviewers diverge on most, and by how much?** *Decision rule*, on the `4/5 vs 1/5` cell — a full verdict flip (CONFIRM vs NOT DETECTABLE), driven by the `≥ 3` threshold contradicting the MDE's "near-total separation" resolving power. This is the highest-cost divergence in the artifact because it is a binary verdict on the experiment's headline claim, not a point of shading.
- **What did the artifact not say that it needed to say?** (1) It never specifies how to measure the amendment's confound — whether the agent reached `sample-service/` — despite that confound being the only thing standing between row 4's REFUTED and an uninterpretable result. (2) The measurement tool `tools/skill-activation.sh` defines "project-scope" as `skill.source != "bundled"` (`if src == "bundled": bundled += 1 else: proj += 1`), which is "non-bundled", not "project". Prediction 5 states `skill.source` for a project skill is unknown and unpredicted, and the instrument has previously recorded plugin-scope skills — so a plugin-scope activation (or a bundled event whose `skill.source` attribute is absent, yielding `None`) would be counted into `project_scope_activations`, inflating the primary outcome. The artifact does not reconcile the script's "non-bundled = project" definition with its own statement that the source value is unknown.
