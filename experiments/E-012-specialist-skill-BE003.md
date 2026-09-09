# Experiment E-012 — one specialist skill, `testing-and-verification` v1.0, on BE-003

**Spine stop 13 (B6) · task `BE-003-confirm-shipment` · experiment key `EXP-B6-SKILL-BE003`**
**Status:** REGISTERED, no runs yet.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-09T14:3xZ; the author did not review
before the run.`

**Author decision 9 governs.** This experiment covers BE-003 only. Its sibling,
[E-013](E-013-specialist-skill-BE004.md), covers BE-004 under key `EXP-B6-SKILL-BE004`. Separate
prediction commits, separate concurrent controls, separate decision rules, separate §5 rows.
**No verdict is computed across the two files.**

---

## Question

`phases-v1.0` reaches `test-quality` anchor 2 on **1 of 10** BE-003 runs. Both of stop 12's hand
re-reads, on two different tasks, found the same clause missing: **the persisted state is never
re-read through a separate `get(...)` request** — the agent verifies through the repository it has
just written to. **Does a specialist skill, selected and read, remove that habit?**

## Hypothesis

**It does not, and I expect to be right about that.** Two previous deliveries of "write good tests"
as words have moved this dimension very little: [E-009](E-009-fourth-cell-second-registration.md)
reached anchor 2 on **0 of 10** with the procedure as prose, `p = 1.0` against its control; B5's
declared, marker-checked procedure reached **1 of 10**. A skill is a **third delivery of words**,
differing from the second mainly in *when* the words enter the context.

**What would make it different, and it is the only mechanism worth registering:** a skill is
*selected* rather than always present, so its body can be longer and more specific than an agent
definition can afford to be — it can name the exact assertion shape. **If specificity is what was
missing, the skill moves the number. If words were what was missing, nothing moves.**

## Predictions

Every prediction has a direction, a magnitude and a mechanism. `n = 10` per arm. **Both arms carry
`phases-v1.0`**; the only difference is the skill.

**P1 — delivery, and it is a void condition rather than an outcome.** All 10 treated runs carry a
recorded skill activation in the run record (`skill.source = projectSettings`, a non-null
`invocation_trigger`); all 10 controls carry none. *Mechanism:* E-004 measured the description as
the selector at `p = 0.0079`, and stop 8 measured `--disable-slash-commands` silencing skills
entirely at `p = 0.0022`, so this is checked rather than assumed. **Below 9 of 10 activations →
VOID (decision-rule row 0)**, and a void here means *the skill was not delivered*, never *the skill
did not work*.

**P2 — the registered outcome.** `test-quality` anchor 2 count in the treated arm is **≤ 4 of 10**.
*Mechanism:* as above — a third delivery of words. *Magnitude:* the control arm is `phases-v1.0`
alone, measured at **1 of 10** at stop 12, and the MDE below shows **7 of 10 is the smallest
treated count that clears `p < 0.05`** against it. **So a prediction of ≤ 4 is a prediction that
the effect will not be detectable, stated as a count rather than as a hedge.**

**P3 — the clause, named.** Of the treated runs that write a test for `confirm`, **≤ 3 of 10**
re-read persisted state through a separate `get(...)` after the mutating call. *Mechanism:* this is
the specific habit the skill names; P2 is the rubric's verdict, P3 is the behaviour underneath it.
**They can disagree**, and if they do the diff decides, per §4 step 7. *Registered because a skill
that changes the behaviour without moving the anchor is a different result from one that changes
neither.*

**P4 — cost.** `estimatedCost` median in the treated arm is **within ±15 %** of its concurrent
control. *Mechanism:* a skill body is loaded only when selected, so it should cost something on the
runs that select it and nothing on the ones that do not — and at ~400 words against a run that
already reads three files, that is inside the noise. *Prior:* B5's own overlay moved cost by
−20.4 % and the mechanism for that was fewer re-reads, not fewer words.

**P5 — turns.** `modelCalls` median is **within ±3** of its concurrent control. *Mechanism:* the
skill adds no procedure steps; it changes what one existing step writes.

**P6 — correctness floor.** Evaluator pass rate is **10 of 10 in both arms**. *Mechanism:* every
arm ever run on BE-003 in this project has passed 10 of 10, including all four arms of stop 12.
**A break in this floor is the finding**, not a nuisance.

## Independent variable

**One thing changes: whether `skills/testing-and-verification/SKILL.md` is installed.** Both arms
carry `phases-v1.0` (agent `backend-feature-phases`, overlay sha256
`b3450564b6f32d6193e8580db766210e`), the same model, the same benchmark tree and the same
evaluator.

**And the tool-pool confound stop 12's §4a review found does not apply here**, which is the one
methodological improvement this stop gets for free: both arms are the *same agent definition* with
the *same four tools*. The skill is added to a customization that already exists in the control.
**This is the cleanest single-variable comparison this project has registered.**

## How the treatment is delivered — and proved

| | Treated | Control |
|---|---|---|
| Mechanism | `--customization <overlay>` where the overlay carries **both** `.claude/agents/backend-feature-phases.md` and `.claude/skills/testing-and-verification/SKILL.md` | the same overlay **minus the skill directory** |
| Content hash | `SKILL.md` sha256 **`0876025fa451af5f1f2970da67a02f0d`**, 675 words, added at §4 step 4 in commit `b0ca034` — **after** this file's prediction commit `133de65`, which is the order a validator should check | n/a |
| Overlay | `build/customizations/skill-v1.0-testing/` — the phases agent file **byte-identical** to `phases-v1.0` (`diff -q` clean, sha `b3450564b6f32d61`) **plus** `.claude/skills/testing-and-verification/SKILL.md` | `build/customizations/phases-v1.0/`, unchanged |
| Per-run proof | a recorded activation in the run record | **no** activation record on any control run |
| Preflight assertion (§4 step 5, own key, enters no comparison) | one run per arm, asserting the activation on the treated run and its absence on the control, and `agentHash` unchanged on both | as stated |

**The order is deliberate and a validator should check it:** this file is committed **before** the
skill exists, so no prediction here can have been shaped by reading the artifact it predicts about.
The hash is added at step 4 in a separate commit, and the first run starts after that.

## Controlled variables

| Variable | Value |
|---|---|
| Model | `claude-haiku-4-5-20251001` on both arms |
| Runtime | claude, `KEEP=1 ISOLATE_USER_SETTINGS=1` |
| Agent overlay | `phases-v1.0`, `agentHash sha256:b3450564b6f32d61`, **on both arms** |
| `instructionsHash` | `null` on both arms |
| Benchmark | BE-003 tree `eeb15a75` at benchmarks `eea144ef`, evaluator `1.0.0` |
| Rubric | `benchmark/rubrics/backend-quality.yaml`, sha **`396e1799eb2b`** — unmoved since B2 |
| Scorer | codex (Decision C). opencode is the second reader and is not a vote |
| Ports | `API_PORT=18081 OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318` as **make command-line variables**, which override `infra/.env` |

## Runs

`n = 10` per arm, interleaved treated/control pair by pair, one batch, `--keep`.

## Minimum detectable effect

**Derived from the measured reference population before any threshold above was written.** The
reference population is **`phases-v1.0` on BE-003 at stop 12**, `n = 10`:
`test-quality` anchor 2 = **1 of 10**; `modelCalls` median 20.5 (q1 18, q3 23); `estimatedCost`
median $0.1178 (q1 0.1012, q3 0.1217); evaluator 10 of 10.

| treated count | two-sided Fisher vs control 1 of 10 | |
|---|---|---|
| 4 of 10 | `p = 0.3034` | not detectable |
| 5 of 10 | `p = 0.1409` | not detectable |
| 6 of 10 | `p = 0.0573` | **does not clear** |
| **7 of 10** | **`p = 0.0198`** | **the MDE** |
| 8 of 10 | `p = 0.0055` | clears |

**The MDE is 7 of 10, and P2 predicts ≤ 4.** So this design can only return "detected" if the skill
is *dramatically* effective — a sevenfold increase over the control. **That is registered as a
weakness of the design, not hidden in it:** at `n = 10` against a control of 1, nothing subtler
than that is visible, and a result of 4, 5 or 6 will be reported as **not detectable** and never as
refuted.

Continuous outcomes use a registered band on the median (±15 % cost, ±3 turns) rather than a
threshold, because P4 and P5 predict *absence* of an effect and a band is the honest shape for that.

## Deterministic evaluation

BE-003's evaluator, unchanged. `./tools/check-run-gate.sh <path to evaluation.json>` on every run
before any sheet is opened — **a path, not a bare run id, which exits 1 with `cannot read` and at
batch scale looks exactly like twenty legitimate refusals.**

## Exclusions, registered before the data

1. A run `check-run-gate.sh` refuses is excluded and the refusal recorded.
2. A run spanning a machine sleep has `durationMs` excluded, the run kept.
3. **A run in which the model was never reached is excluded and re-run.** *(New at this stop, and
   it is the gap stop 12 disclosed: four runs were lost to a DNS outage and the registered
   exclusion lists had no category for it, while `baseline-report.py` did — it calls them "harness
   failure, not agent behaviour". The test is `taskAttempted: false` **and** an API-unreachable
   error in the run log; both, not either.)*
4. **No run is excluded for failing to activate the skill.** That is decision-rule row 0 for the
   arm, not a per-run exclusion — a treatment that fails to deliver voids the comparison rather
   than shrinking it.
5. No run is excluded for a low rubric score. That is the measurement.

## Decision rule, fixed before the run

Applied **in order**, stopping at the first row that fires.

| # | Condition | Verdict |
|---|---|---|
| 0 | fewer than 9 of 10 treated runs record a skill activation, or any control records one, or a sheet's rubric sha is not `396e1799eb2b` | **VOID** — the skill was not delivered; nothing is claimed about it |
| 1 | `test-quality` anchor 2 in the treated arm is **≥ 7 of 10** | **CONFIRM** — the skill removes the failure, `p ≤ 0.0198` against the control |
| 2 | treated is **≥ 5 and ≤ 6 of 10** | **NOT DETECTABLE, upper** — the direction is right and this `n` cannot resolve it. Report the count, refuse the claim |
| 3 | treated is **≤ 4 of 10** and ≥ the control | **NOT DETECTABLE** — P2 held; a third delivery of words moved nothing this design can see |
| 4 | treated is **strictly below** the control | **REFUTE, and the skill is worse than nothing** — record it and remove the skill under §4 step 10 |
| 5 | evaluator pass differs between arms by ≥ 3 | **CORRECTNESS EFFECT**, recorded beside whichever row fires and never instead of it |
| 6 | anything else | **INCONCLUSIVE**, reported as its combination and never rounded |

**Registered in advance, because stop 12 cost two §4a findings for its absence:** *"improved"* in
this file means **the registered outcome P2 moved in the predicted direction by at least the MDE**.
Cost and turns are bands, not improvements; a cheaper run with the same anchor count is **not** an
improvement for the purpose of any row above.

## Threats to validity, registered before the run

1. **The honest prior is that this fails, and a null will be unsurprising.** That is exactly when a
   delivery proof matters most, which is why P1 is a void condition and why row 0 exists.
2. **`skill.name` is redacted to `custom_skill`.** With one skill installed the activation record is
   unambiguous; **with two this outcome would not be measurable at all**. One is installed.
3. **The skill is longer than the agent definition can afford to be, and that is the treatment.**
   If it works, this experiment cannot separate *"a skill"* from *"more words about tests"*. The arm
   that would separate them puts the same body into the agent definition. It is a new arm and
   therefore the author's under §7; it is named here so the limitation is on record before the run.
4. **The rubric anchor is the outcome and it is coarse.** Anchor 2 needs three clauses on BE-003;
   the skill targets one. A run could improve the targeted clause and still score 1. **P3 exists
   for exactly this**, and where P2 and P3 disagree the diff decides.
5. **Both arms carry `phases-v1.0`, so this stop inherits its defects**, including the `DONE`
   completion contract leaking at 2 in 10. That is a controlled variable here, not a confound.

## Deliberate failure — registered here, run at §4 step 9

Prediction first, committed, then broken. **The failure is a misdescribed skill**: the identical
body with a `description` that names an unrelated domain, `n = 3`. **Prediction:** activation falls
to **0 of 3** while the file remains on disk and readable, and `test-quality` stays at the control's
level. *Mechanism:* E-004 measured exactly this at 5 of 5 against 0 of 5, `p = 0.0079`, with bodies
byte-identical. **If activation survives a misdescription, the description is not the selector on
this task and E-004 does not generalise to a skill delivered inside an agent overlay** — which
would be a more useful finding than anything else this stop could return.

## §4 step 4 — the build

<!-- filled at step 4, including the skill's content hash -->

## §4 step 5 — the preflight pair

<!-- filled at step 5 -->

## §4 step 6 — the batch

<!-- filled at step 6 -->

## Results

<!-- filled at step 8. Median and range, never a mean alone. -->

## Which predictions held

<!-- filled at step 8. Wrong predictions stay wrong. -->

## Decision

<!-- filled at step 10 -->
