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
reviewed_utc:    20260904T080814Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-004-skill-activation.md
    sha:  c015c6b7fce7
    dirty: false
  - path: tools/skill-activation.sh
    sha:  3e877b8a0507
    dirty: false
lab_head:        d169b74
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-004-skill-activation.md
  verdict: REJECT
  summary: Four structural defects would mislead a reader or produce a wrong verdict: the activation script's allowlist lets any non-bundled, non-plugin source count as "installed"; the delivery proof for arm C is circular with the prediction it is supposed to confirm; the sanity check does not mechanically enforce that only the description field differs; and the script conflates partial telemetry corruption with absent telemetry.
  blocking:
    - reason: The activation script's allowlist (lines 116-123) treats any non-bundled, non-plugin, non-empty skill.source as "installed". A user-scope skill firing on the control arm would be misclassified as installed, and the script would manufacture evidence for prediction 2 on the arm that installed nothing.
      wrong_action: A reader would record a control-arm run that fires a user-scope skill as `installed_scope_activations: 1`, fail prediction 2 (control records 0), and attribute the activation to the experiment's treatment rather than to an unpinned source.
      anchor: "`skill.source` for a project skill is still **unknown**; the preflight must pin it, or `installed_scope` is a category with nothing proven to be in it."
      evidence: experiments/E-004-skill-activation.md:46-48
    - reason: The preflight assertion (line 80) requires `claude_code.skill_activated` in telemetry for both treated arms. Arm C is the misdescribed arm — its prediction is non-activation. The delivery proof is therefore impossible to satisfy for arm C without contradicting the prediction it is supposed to confirm.
      wrong_action: A reader running arm C's preflight would see no activation, conclude the treatment was not delivered, and either stop the batch or reinterpret the proof — both inconsistent with the prediction that arm C does not activate on a shipment task.
      anchor: "Proof that the skill reached the model is `claude_code.skill_activated` present in telemetry for that run id"
      evidence: experiments/E-004-skill-activation.md:80
    - reason: The sanity check (line 286) verifies "bodies byte-identical; only the frontmatter differs" but does not mechanically constrain WHICH frontmatter field differs. The independent-variable claim (lines 67-68) is "exactly one thing: the description line", which the check does not enforce.
      wrong_action: A reviewer running the experiment could change arm C's frontmatter `name` as well as `description`, pass every listed hash/body check, and conflate the description-vs-body contrast with a name-vs-no-name contrast — and never know from the sanity checks alone.
      anchor: "the two `SKILL.md` bodies are byte-identical; only the frontmatter differs"
      evidence: experiments/E-004-skill-activation.md:286
    - reason: The script's exit-3 contract (lines 41-42) says "run absent from telemetry" but partial corruption (one valid line followed by a malformed line that should contain the run) is also reported as exit 3, with no warning to stderr. The reader cannot distinguish "telemetry empty" from "telemetry corrupt".
      wrong_action: A reader whose telemetry file was truncated mid-stream would see exit 3 and void the run as instrument failure per decision rule row 5, then re-run the experiment — when the actual cause is a telemetry-pipeline issue that needs investigation, not a runner issue.
      anchor: "3  the run is ABSENT from telemetry entirely — the counts are UNKNOWN, not zero"
      evidence: tools/skill-activation.sh:41-42, 78-83, 125-127, 146
  non_blocking:
    - reason: The controlled-variables check (line 167) verifies hooks via `hook_execution_start = 0` but claims to control "hooks, plugins, skills, MCP servers, settings sources" — broader than what is checked. This is a transparency gap, not a direct wrong-verdict path on its own; the verdict risk compounds with the script-allowlist defect above.
      evidence: experiments/E-004-skill-activation.md:167
  disputed:
    - finding: Competent reviewers can condition the primary outcome differently because the gate admits to scoring after evaluator pass while the primary outcome is activation.
      why: The artifact explicitly separates primary outcome from scoring: line 213-214 says "the primary outcome of this experiment is not a rubric score", and line 222-223 defines the activation-outcome exclusion as telemetry-not-joined (not evaluator-failed). The gate is for scoring, not activation.
    - finding: Evaluator-failed runs should be excluded from activation because evaluator failure is absent from the registered exclusions list.
      why: The exclusions list registers what is excluded from each outcome; the artifact's structure (line 211 + 222-223) is that evaluator failure excludes from scoring, not activation. Evaluator-failed runs with joined telemetry count for activation, which is the artifact's stated design.
    - finding: The decision rule's "`skill.name` = anything else | prediction 5 refuted" is ambiguous when project-scope events mix custom_skill with another name.
      why: Prediction 5 is stated deterministically (lines 57-62): "name IS redacted to custom_skill." The instrument condition naturally reads as universal: any event with a non-custom_skill name refutes. Mixed names refute the prediction; the verdict rule is clear under the natural reading.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 58s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Predictions | 1/1 | L2 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Controlled variables | 1/1 | L2 |
| Deterministic evaluation | 1/1 | L2 |
| Exclusions | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Sanity checks | 1/1 | L2 |
| tools/skill-activation.sh | 1/1 | L2 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 1 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete failure scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; the later decision rule limits attribution when activation is not observed.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** Suppose a control run emits one activation with `skill.source = "user"`, while a treated project skill emits `skill.source = "project"`. The script counts both as `installed_scope_activations` because every non-`bundled`, non-`plugin`, non-empty value falls through to `installed`. One reviewer would apply prediction 2 and fail the control; another would reject the counter because preflight established only that `project` identifies the installed skill. The artifact says preflight must pin the source but never requires the counter to accept only that pinned value.
**Layer of the implied fix:** L2
**Anchor:** “`skill.source` for a project skill is still unknown; the preflight must pin it, or `installed_scope` is a category with nothing proven to be in it.”

### Independent variable
**Verdict:** no finding
**Failure:** No concrete failure scenario identified in the stated treatment contrast.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** In the misdescribed preflight, the file is installed correctly but the description works exactly as predicted and the skill does not activate. The required delivery proof therefore fails even though treatment delivery succeeded. One reviewer would stop the batch for failed delivery; another would proceed because non-activation is the expected behavior of arm C. Requiring activation in both treated-arm preflights makes delivery proof circular with the measured outcome.
**Layer of the implied fix:** L3
**Anchor:** “one run per treated arm before the batch. Proof that the skill reached the model is `claude_code.skill_activated` present in telemetry for that run id”

### Controlled variables
**Verdict:** finding
**Failure:** Suppose an isolated run loads an MCP server or project setting but executes no hooks. The recorded check `hook_execution_start = 0` passes, so one reviewer marks hooks, plugins, skills, MCP servers, and settings sources controlled; another marks only hooks verified. The named observation cannot establish the full environment claim.
**Layer of the implied fix:** L2
**Anchor:** “environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1` on every run; verified by observing `hook_execution_start = 0` per run in telemetry”

### Runs
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; arm size, interleaving, preflights, and budget are distinguishable.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** no finding
**Failure:** No concrete failure scenario identified in the enumerated Fisher thresholds at the registered sample size.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deterministic evaluation
**Verdict:** finding
**Failure:** Suppose all five matched-arm runs activate the skill, but two produce edits that fail `evaluator.sh`; all five misdescribed runs pass and none activates. If the gate excludes failed runs from activation scoring, the matched result becomes 3/3 or requires replacement runs; if activation is scored independently of benchmark admission, it is 5/5. The section says the gate admits a run “to scoring” only after evaluator pass, while the primary outcome is telemetry activation, so competent reviewers can condition the primary outcome differently and reach different verdicts.
**Layer of the implied fix:** L2
**Anchor:** “`./tools/check-run-gate.sh` admits a run to scoring only on the evaluator's recorded pass.”

### Exclusions
**Verdict:** finding
**Failure:** The evaluator-failure scenario above is not classified here. A run can have valid joined telemetry and valid activation data but fail the benchmark evaluator; one reviewer excludes it under the deterministic gate, while another retains it because evaluator failure is absent from the registered exclusions. This changes treated-arm denominators and potentially the experiment verdict.
**Layer of the implied fix:** L3
**Anchor:** “Registered now, not after seeing the data:”

### Decision rule
**Verdict:** finding
**Failure:** Suppose project-scope events contain `skill.name = custom_skill` on four runs and `skill.name = shipment-service-conventions` on one run. Both instrument conditions are true: the first name appears on project-scope events, and a different name also appears. One reviewer records prediction 5 as holding because `custom_skill` occurred; another records it as refuted because “anything else” occurred.
**Layer of the implied fix:** L3
**Anchor:** “`skill.name` = `custom_skill` on project-scope events | prediction 5 holds” and “`skill.name` = anything else | prediction 5 refuted”

### Observed telemetry
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no claim or evidence to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no claim or evidence to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no classification to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no analysis to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** finding
**Failure:** Change arm C's frontmatter `name` as well as `description`, leaving both bodies byte-identical. Every listed hash/body check can pass, yet the treatment no longer changes exactly one thing. One reviewer may rely on the prose assertion that names match; another may require mechanical proof. The claimed independent variable is therefore not enforced by the registered sanity checks.
**Layer of the implied fix:** L2
**Anchor:** “the two `SKILL.md` bodies are byte-identical; only the frontmatter differs”

### Decision
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no decision to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** no finding
**Failure:** Skipped because this explicitly post-run section has not yet been populated; there is no follow-up claim to test.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Give the script a JSONL file containing one valid unrelated telemetry document followed by a malformed/truncated line that should contain the requested run. `parsed_any` becomes true, the malformed line is silently skipped, and the script exits 3 for an absent run. Another parser enforcing the advertised one-JSON-object-per-line contract exits 2. Partial corruption is therefore misclassified as missing telemetry rather than unparseable telemetry.
**Layer of the implied fix:** L2
**Anchor:** “`2` the telemetry file could not be parsed as one JSON object per line”

### Cross-cutting
**Verdict:** finding
**Failure:** The quality rubric is explicitly only a co-variate, so no scoring category is shown duplicating a pass/fail gate; however, `check-run-gate.sh` may duplicate evaluator pass as an admission gate if “scoring” includes activation. The section most likely to diverge is “How the treatment is delivered — and proved”: on an expected zero-activation arm-C preflight, reviewers can differ between stopping the entire 15-run batch and proceeding, changing the usable dataset from zero measured runs to all 15. The artifact needed to say how delivery of a deliberately non-activating treatment is established, whether evaluator failure excludes a run from the primary telemetry outcome, the exact preflight-pinned `skill.source` allowlist, and how mixed `skill.name` values are classified.
**Layer of the implied fix:** L3
**Anchor:** “Proof that the skill reached the model is `claude_code.skill_activated` present in telemetry for that run id”

