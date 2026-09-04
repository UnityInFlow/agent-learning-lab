# opencode review — E-004-skill-activation

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
reviewed_utc:    20260904T074639Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-004-skill-activation.md
    sha:  e4503ac60b37
    dirty: false
  - path: tools/skill-activation.sh
    sha:  3c4db30949fb
    dirty: false
lab_head:        0075565
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/experiments/E-004-skill-activation.md
  verdict: REJECT
  summary: The measurement script counts plugin-scope events as project scope, threatening prediction 2's control assertion, and the decision rule's row 1 enumerates only matched≥misdescribed cells so a reverse-separation result can be classified two ways on identical data.
  blocking:
    - reason: The script counts any skill.source that is not "bundled" and not None/empty as project scope, so a plugin-scope event on the control arm would be recorded as one project-scope activation. Prediction 2's structural claim ("control = 0 project-scope activations") is therefore not self-consistent with the measurement instrument, and prediction 5 itself documents that the only known non-bundled source on this instrument is plugin-scope.
      wrong_action: A reader running the script against telemetry where a plugin event fires on the control arm records prediction 2 as failed when the control is genuinely clean (no installed skill).
      anchor: "Bundled skills (`skill.source = bundled`) may still activate and are excluded from the outcome by definition, because the outcome counts only the installed skill."
      evidence: tools/skill-activation.sh:99-104
    - reason: The decision rule's row 1 enumerates "i.e. (matched, misdescribed) is (5,0), (5,1) or (4,0)" — three cells where matched ≥ misdescribed. By Fisher symmetry the mirror cells (0,5), (1,5), (0,4) also have p < 0.05, but row 1's "i.e." treats them as out of scope. For matched=1/5, misdescribed=5/5 a strict reader falls through to row 4 (REFUTED, no attribution) while a logical reader applies row 1's general "p < 0.05" criterion to the mirror cell.
      wrong_action: Two competent readers reach different experiment-level verdicts on identical data: one says "prediction 1 refuted, no attribution" (row 4), the other says "the pair reaches p < 0.05, CONFIRM" (row 1 by the mirror).
      anchor: "The pair reaches Fisher p < 0.05 — i.e. (matched, misdescribed) is (5,0), (5,1) or (4,0) | CONFIRM"
      evidence: E-004-skill-activation.md:235-246
  non_blocking:
    - reason: The hook-isolation verification claim ("verified by observing hook_execution_start = 0 per run in telemetry") is broader than the actual observation, which only tests hooks and not plugins/MCP/skills/settings sources — and combined with the script's plugin-as-project bug above, this leaves an undocumented leak path for user-level plugins.
      evidence: E-004-skill-activation.md:160
    - reason: The Exclusions section treats permission blocks as infrastructure failures uniformly, without distinguishing treatment-induced from exogenous blocks; a matched-arm run that activates then hits a permission block could be excluded, losing the signal that the skill triggered the block.
      evidence: E-004-skill-activation.md:211-217
    - reason: For matched=3, misdescribed=0, the decision rule labels this NOT DETECTABLE (row 3: matched 2-3) while prediction 3's between-arm conditions ("≤1/5 AND ≥3 lower") are technically satisfied. The artifact's introduction declares the decision rule exhaustive but does not explicitly state that the rule overrides prediction 3's conditions.
      evidence: E-004-skill-activation.md:41-44, 243-251
    - reason: The script silently skips malformed JSON lines, so a file with one parseable generic record for the run plus one malformed activation record exits 0 with proj=0, reporting a measurement of zero for an event whose source and scope are actually unknown.
      evidence: tools/skill-activation.sh:73-74, 106-108
  disputed:
    - finding: "Arm B has frontmatter name: shipment-service-conventions, while arm C has name: generic-conventions; their descriptions also differ and their bodies below frontmatter are byte-identical."
      why: The artifact at lines 60-65 and 277 explicitly states that arms B and C have the same name and that the sanity check passes when "only the frontmatter differs" (most naturally read as "only one frontmatter field differs"). The actual SKILL.md files at build/customizations/skill-v0.1/ and ...-misdescribed/ are not in the attached evidence set, so the reviewer's factual claim about the actual files cannot be verified against the artifact's claim.
    - finding: "A file containing one valid generic record for the run plus a malformed activation record exits 0 and reports a false measured zero instead of the documented parse error."
      why: The reviewer's specific scenario does exit 0 in my trace (parsed_any=True after the first parseable line, present=True because that line matches the run_id, proj=0 because the activation event was malformed and skipped), but the characterization "instead of the documented parse error" misrepresents exit 2's trigger — it fires only when NO lines parse. The underlying concern (silent skipping of malformed activation events producing a false measurement zero) is real and is captured in non_blocking.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 56s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Hypothesis | 1/1 | L3 |
| Predictions | 1/1 | L2 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Controlled variables | 1/1 | L2 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Sanity checks | 1/1 | L2 |
| tools/skill-activation.sh | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete failure scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** Suppose the matched arm produces 5/5 activations and the misdescribed arm 0/5 on this shipment task, but a second task with paraphrased terminology activates both arms equally. One reviewer can accept the stated task-and-model result; another can accept the broader claim that activation is generally “a property of the description text.” The hypothesis does not delimit that general claim to the registered task, model, path, and runtime.
**Layer of the implied fix:** L3
**Anchor:** “Activation is therefore a property of the description text”

### Predictions
**Verdict:** finding
**Failure:** A `claude_code.skill_activated` event with `skill.source = plugin` occurs in the control arm. The supplied evaluator counts every nonempty source other than `bundled` as project scope, so prediction 2 is recorded as failed even though no project skill was installed. Another reviewer using the stated project-scope definition excludes the plugin event and records 0/5, so the prediction’s outcome is not operationally aligned with its instrument.
**Layer of the implied fix:** L2
**Anchor:** “The control arm records 0 project-scope skill activations on 5 of 5.”

### Independent variable
**Verdict:** no finding
**Failure:** No concrete failure scenario identified in the stated variable definition itself.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** In both treated arms the agent completes the task without reading or editing a file under `sample-service/`; therefore the nested skills never become available. The matched arm yields 0/5 and is routed to prediction-1 refutation, while a reviewer treating availability as failed delivery would void the treatment. The preflight rule cannot settle this for a non-activating run because its asserted proof is the outcome being measured.
**Layer of the implied fix:** L3
**Anchor:** “Proof that the skill reached the model is `claude_code.skill_activated` present in telemetry for that run id”

### Controlled variables
**Verdict:** finding
**Failure:** A user-level plugin or MCP server is active on all runs but emits no `hook_execution_start` events. One reviewer accepts zero hook events as verification that hooks, plugins, skills, MCP servers, and settings sources were isolated; another recognizes that the observation tests hooks only. The uncontrolled plugin could emit skill activations that the supplied script counts as project scope.
**Layer of the implied fix:** L2
**Anchor:** “environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1` on every run; verified by observing `hook_execution_start = 0` per run in telemetry”

### Runs
**Verdict:** no finding
**Failure:** No concrete failure scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** Observed counts are matched 3/5 and misdescribed 0/5. The decision rule labels this “NOT DETECTABLE,” but prediction 3 said the misdescribed arm would load on ≤1/5 and be at least three lower, which these data satisfy exactly. One reviewer marks prediction 3 as held descriptively; another refuses to treat it as supported because Fisher p=0.1667. The artifact does not specify how prediction-status reporting distinguishes threshold satisfaction from inferential support.
**Layer of the implied fix:** L3
**Anchor:** “The misdescribed arm loads on ≤ 1 of 5, at least 3 fewer than the matched arm.”

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No concrete failure scenario identified for the stated role of the evaluator and rubric.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** All five matched-arm runs trigger permission blocks after skill activation, while control and misdescribed runs do not. Excluding those five and replacing or rerunning them can erase a treatment-induced failure; retaining them can yield a matched-arm activation result with failed tasks. Competent reviewers can therefore produce different denominators and conclusions because the rule does not distinguish exogenous permission failures from treatment-caused permission behavior.
**Layer of the implied fix:** L3
**Anchor:** “permission blocks and quota exhaustion are excluded from every arm”

### Decision rule
**Verdict:** finding
**Failure:** Counts are matched 1/5 and misdescribed 5/5, producing the same near-total separation in the direction opposite the hypothesis. Row 4 records only that prediction 1 is refuted and says no attribution follows; it does not specify whether the statistically decisive reverse association refutes the description-selection hypothesis. One reviewer reports only one-arm refutation, while another reports evidence that description affects selection in the opposite direction.
**Layer of the implied fix:** L3
**Anchor:** “Matched ≤ 1/5 | prediction 1 REFUTED as a one-arm claim … No attribution follows”

### Observed telemetry
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** finding
**Failure:** Arm B has frontmatter `name: shipment-service-conventions`, while arm C has `name: generic-conventions`; their descriptions also differ and their bodies below frontmatter are byte-identical. Every listed sanity check passes, although two frontmatter fields changed and the independent-variable claim is false. A reviewer trusting the checklist accepts the batch; a reviewer diffing frontmatter rejects it.
**Layer of the implied fix:** L2
**Anchor:** “the two `SKILL.md` bodies are byte-identical; only the frontmatter differs”

### Decision
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** no finding
**Failure:** Not assessable before the runs because this intentionally post-run section is empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** A control-run event has `body = claude_code.skill_activated` and `skill.source = plugin`. The script increments `proj`, reporting one project-scope activation, because every nonempty source other than `bundled` enters that counter. This directly converts the plugin-scope events discussed in the experiment into false evidence that the control loaded an installed project skill. Separately, a malformed JSON line is silently skipped, so a file containing one valid generic record for the run plus a malformed activation record exits 0 and reports a false measured zero instead of the documented parse error.
**Layer of the implied fix:** L2
**Anchor:** “elif src is None or src == "": unknown_source += 1; else: proj += 1”

### Cross-cutting
**Verdict:** finding
**Failure:** The structural control prediction duplicates a pass/fail gate: prediction 2 requires zero project-scope activations, while the control assertion also requires zero project-scope `skill_activated` events. The greatest expected divergence is in “Decision rule”: for the concrete reverse-separation result matched 1/5 versus misdescribed 5/5, reviewers can differ by an entire experiment-level verdict—one-arm refutation only versus refutation of the directional hypothesis. The artifact needed to define the exact accepted `skill.source` value or values for project scope, how malformed telemetry records invalidate a run, how treatment-induced exclusions are handled, and how reverse statistically significant separation is classified.
**Layer of the implied fix:** L2
**Anchor:** “The control arm records 0 project-scope skill activations on 5 of 5” and “Verified per run by … zero project-scope `skill_activated` events”

