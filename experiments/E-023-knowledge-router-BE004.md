# Experiment E-023 — the knowledge router, BE-004

**Key:** `EXP-B9-ROUTER-BE004` · **Spine stop 20 (B9)** · **version v1.2** ·
**Workbook:** [`phases/b09-knowledge-router/`](../phases/b09-knowledge-router/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-26T09:20Z; the author did not review
before the run.`

> Everything down to and including **Decision rule** is filled in before the first run, and this
> file is committed before it.

Author decision 9: BE-003 is a **separate** experiment,
[`E-022`](E-022-knowledge-router-BE003.md). Separate key, separate prediction commit, separate
concurrent control, separate MDE table, separate decision rule. **No verdict is computed across
the two**, and the one-variable rule applies within this task only.

The design reasoning, the layer labels, the confound this stop registers rather than resolves,
and the constraint on what the corpus may contain are in the workbook's *Design* section and in
`E-022`; they are not restated here. **What differs on this task is the baseline, and it differs
completely** — which changes the test, the thresholds and the decision rule.

---

## Question

Same question as `E-022`, on a task where the outcome is not bimodal but **floored**: does routed
knowledge move `maintainability` off an anchor-2 rate of zero that has held across every arm ever
measured on BE-004?

## Hypothesis

BE-004's `maintainability` anchor 2 is reachable — `E-011:344` records the `known-good` fixture
deciding on *"an exhaustive `when (order.status)` in expression position"*, and the variant it
separates from is *"an `if`/`else if`/`else` chain on the same values"*. So the construct exists
on this task, the rubric can see it, and the pinned model has never produced it in 36 recorded
runs.

A floor is a better test than a spread, for one reason and against one risk. The reason: **any
movement is unambiguous**, and the two-arm test is decidable at `n = 10` where on BE-003 it is
not. The risk: a floor can be a floor because the task makes the construct *harder to reach*
rather than because the model lacks the fact — BE-004 is a cross-module cancel with an
all-or-nothing cascade and a guard on shipment creation, so status dispatch is one clause of a
larger ticket and may simply get less of the model's attention. **If that is why the floor
exists, knowledge will not lift it**, and the null is about the task's shape rather than about
retrieval. Registered here so it is not discovered in the write-up.

## Predictions

1. **PRIMARY — two-arm.** The treated arm reaches `maintainability` **anchor 2 on ≥ 5 of 10**
   scored runs against a control at or near 0, `Fisher p ≤ 0.0325`. *Mechanism:* as `E-022` —
   the corpus states the Kotlin exhaustiveness rule and the router surfaces it before the branch
   is written. The threshold is the MDE itself, which is what a floored baseline buys.
2. **SECONDARY — one-arm, and decidable lower.** The treated arm reaches anchor 2 on **≥ 3 of
   10**, tested against `p0 = 0.0798`, the 95 % one-sided upper bound on the rate after 0 of 36:
   `P(X ≥ 3 | n = 10) = 0.0399`. So a smaller effect than prediction 1 is still separable from
   the historical floor even though it is not separable from a concurrent control.
3. **THE ROUTER IS USED.** `.agent/knowledge-log.jsonl` is non-empty on **≥ 7 of 10** treated
   runs. *Mechanism and consequence:* identical to `E-022` prediction 3 — an L3 instruction can
   produce zero uptake, and if it does, this batch measured an instruction nobody followed.
   **Registered as the most likely of the five to be wrong on this task specifically**: BE-004's
   ticket is longer and has more clauses competing for attention than BE-003's.
4. **COST.** `estimatedCost` median rises by **≤ +10 %** against the concurrent control. B8's
   BE-004 medians were `$0.209355` treated and `$0.200527` control, +4.4 % (`E-019:337`).
5. **NOTHING ELSE MOVES**, with one carve-out that is not mine to make: `architecture-consistency`
   and `test-quality` medians are identical between arms. **`change-focus` is not predicted**,
   because `E-019` declared it unmeasurable on this task and author decision 10.3 already carves
   it out of the fallback scorer; it is reported with that label and enters no row of the
   decision rule.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing: the customization overlay** — the same two overlays as `E-022`, treated
`build/customizations/agent-v1.2-knowledge/` against control `build/customizations/agent-v1.1/`,
v1.1 unmodified. **The corpus is byte-identical between the two tasks**: it names a language
rule, not a ticket, so nothing in it is BE-004-specific and its `knowledgeHash` is the same value
on both. That is a property worth stating because it makes the two tasks' arms comparable in
delivery even though **no verdict is computed across them**.

The control is v1.1 and is run **concurrently**, for the same reason as `E-022`: B8's BE-004
batch ran on CLI `2.1.272` and this one runs on `2.1.283`. B8's stored numbers transfer the MDE
and the cost baseline and nothing else.

## How the treatment is delivered — and proved

Identical to `E-022`'s table — `--customization`, the new `knowledgeHash` over the set of files
under `.ai/knowledge/`, and the three preflight conditions — run **again, under this experiment's
own key**, because author decision 9 requires a per-arm preflight on BE-004 with the `init.tools`
read-back before any batch, exactly as author decision 8 requires for an overlay on BE-003.

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.2-knowledge/` (`run-agent.sh:338`, force-added at `:371`), found by the runner with `BENCHMARK=BE-004` |
| Content hash | `knowledgeHash`, to be built at §4 step 4; the same value as on BE-003, asserted rather than assumed |
| Preflight assertion | one run per arm under `EXP-B9-ROUTER-BE004`: `knowledgeHash` set / `null`; `.agent/knowledge-log.jsonl` ≥ 1 line on treated and absent on control; corpus shas match the overlay; plus the `init.tools` read-back (decision 8) |
| Control assertion | no `.ai/knowledge/` path in the control overlay → `knowledgeHash: null`, no log file, both read back from the record and the kept worktree |

**If the preflight's log condition fails, the batch does not start.** The scorers read BE-004's
own `QUALITY_VARIANTS` line from its `verify-evaluator.sh`; that is unchanged.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` `2fc445d`
- [ ] task + revision — `BE-004-cancel-order`, on `main` since benchmarks#29 → `eea144ef`
- [ ] harness + version — `claude` **`2.1.283 (Claude Code)`**, read back from `runtime.version`
- [ ] model — **`claude-haiku-4-5-20251001`**
- [ ] permissions / permission mode — as B8's BE-004 batch
- [ ] environment — `ISOLATE_USER_SETTINGS=1`, with only the observable half of the isolation
      claimed (the record has no hook-execution field)
- [ ] runner commit — the same `agent-observatory` sha on both arms, recorded per run

## Runs

Repetitions per arm: **10**, interleaved · Total budget: **≤ $5.20** for this task
(20 batch runs at B8's `$0.21` median = `$4.20`, plus 2 preflight runs, plus headroom).
BE-004 runs take 2–4 minutes each (decision 9).

Prediction commit: `<filled after the batch>` · first run `startedAt`: `<filled after the batch>`

## Minimum detectable effect

**Derived from the measured arms first.** The reference population is every BE-004 arm whose
per-run `maintainability` values are recorded:

| arm | anchor-2 count | source |
|---|---|---|
| B6 treated / control | 0 / 10 · 0 / 10 — *"floored at 0 on 20 of 20"* | `E-013:601` |
| B8 treated / control | 0 / 9 · 0 / 7 — treated values `[0 ×8, 1]`, and **the single non-zero is a 1, the residual, not anchor 2** | `E-019:353` |
| **pooled, per-run values only** | **0 of 36** | computed |
| B7 treated / control | medians 0 and 0 at `n = 7` each, per-run values not tabulated (`E-016:481`) | **consistent with the floor and not counted into it** |
| B5 | recorded as floored at stop 12, cited forward at `E-013:601` | not counted |

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: `maintainability` anchor-2 count, two-arm Fisher vs the concurrent control | 0 of 36 → a control expected at 0 of 10 | **5 of 10.** `5/10 vs 0/10 → p = 0.0325`; `4/10 → 0.0867`; `3/10 → 0.2105`; `2/10 → 0.4737` | yes |
| secondary: same count, one-arm binomial vs `p0 = 0.0798` (Clopper–Pearson 95 % upper bound after 0 of 36) | the 36 runs above | **3 of 10**, at `p = 0.0399`; `4 of 10 → 0.0058` | yes |
| secondary: `estimatedCost` median | B8's `$0.209355` [0.195181–0.257077] treated, `$0.200527` [0.191364–0.208626] control (`E-019:337`) — **transferred** | B8's treated interval is about **±15 %** wide, so +10 % is a *bound*, not a detection | yes |
| reported, decides nothing: hit rate | no prior (6B finding 4) | first measurement | yes |
| **not predicted, reported with its label:** `change-focus` | `E-019:466` declared it unmeasurable on this task | none — it enters no row | yes |

**Derived against the interval, not the point estimate**, and on this task the interval is the
useful part: the control's plausible range is `0` to about `1` of 10, since the only non-zero in
36 runs was a 1 at anchor 1. **The 5-of-10 threshold survives a reduced scored population**,
which decision 9 requires be registered before the run because BE-004's pass rate is a result
rather than a nuisance: at `n = 8` per arm `5/8 vs 0/8 → p = 0.0256`, and at `n = 7`
`5/7 vs 0/7 → p = 0.0210`. So **prediction 1's threshold is stated as a count, 5, and holds down
to `n = 7` per arm.** Below 7 scored runs in either arm the primary is reported as
`NOT COMPUTED — population below the registered floor`.

| the prediction says | what tests it | what a null means |
|---|---|---|
| P1 *"the arms differ, ≥ 5 of 10 against ~0"* | two-arm Fisher against the control that occurred | inside the MDE → **not detectable** |
| P2 *"this arm reaches anchor 2 on ≥ 3 of 10"* | one-arm binomial vs the historical floor | far from 3 → **refuted** |

## Deterministic evaluation

`BE-004-cancel-order`'s own deterministic evaluator, BE-003's exit-code contract, two
evaluator-owned suites, proved by `verify-evaluator.sh` — re-run on a clean `main` at 12 of 12
when benchmarks#29 merged. `./tools/check-run-gate.sh` admits a run on the evaluator's recorded
verdict. Rubric scoring is **codex only** (Decision C, and author decision 10.2 makes codex the
*only* admissible proof on this task) with `benchmark/rubrics/backend-quality-be004.yaml` at sha
**`6252778b8472`** — registered and unmoved. `opencode-score.sh` on the same ids is the second
reader; on `change-focus` the two harnesses agree only 18 of 34 (lab#70), which is one more
reason that category enters no row here.

## Exclusions

As `E-022`, and one addition this task needs: **an evaluator failure is a result on BE-004, not
an exclusion from the report.** BE-004 is built so a capable model can fail it (decision 9).
Failed runs are excluded from *rubric* analysis, counted in the pass-rate line, and if the scored
population falls below **7 per arm** the primary is `NOT COMPUTED` rather than computed on a
smaller population than the MDE was registered against.

## Decision rule

Registered before data. `M` = treated anchor-2 count out of the scored treated runs; `C` = the
control's; `H` = treated runs with a non-empty `.agent/knowledge-log.jsonl`; `n_t`, `n_c` = the
scored populations.

| # | condition | verdict | disposition (§4 step 10) |
|---|---|---|---|
| 0 | `n_t < 7` or `n_c < 7` | **NOT COMPUTED — population below the registered floor.** The batch is reported, the pass rate is the finding, and no verdict is claimed | corpus unchanged, pending |
| 1 | `H ≤ 2` | **VOID — THE TREATMENT WAS NOT TESTED**, at any `M`. E-005's description arm | not promoted; the finding is about the instruction |
| 2 | `H ≥ 3` and `M ≥ 5` and `Fisher(M,C) ≤ 0.05` | **KEEP — IMPROVED.** P1 held | promoted into v1.2 on this task |
| 3 | `H ≥ 3` and `M ≥ 5` and `Fisher(M,C) > 0.05` | **INCONCLUSIVE — THE CONTROL MOVED OFF ITS FLOOR.** A control above 0 after 36 runs at 0 means something other than the treatment changed between B8 and now; the historical floor is then not this batch's comparator and must not be substituted for it | not promoted; the control's move is investigated before anything is claimed |
| 4 | `H ≥ 3` and `M` is 3 or 4 | **INCONCLUSIVE — SEPARATED FROM THE HISTORICAL FLOOR, NOT FROM ITS OWN CONTROL.** P2 held, P1 refuted | not promoted; the `n` it would need is recorded |
| 5 | `H ≥ 3` and `M ≤ 2` | **REJECT.** Consulted and changed nothing. P1 and P2 both refuted | **removed**, and the removal is the finding |

And one row that fires **alongside** whichever of 0–5 applies:

| # | condition | what it adds |
|---|---|---|
| 6 | `estimatedCost` median delta vs the concurrent control **> +25 %** | **COST OBJECTION**, its own row and never a second condition on a failure row. On row 2 it downgrades to **KEEP WITH A COST OBJECTION** |

**The combination that reaches no row: none, and it is executed rather than asserted.**
Population first, then `H`, then `M` partitioned into `≥ 5`, `{3,4}`, `≤ 2`, with `≥ 5` split by
the Fisher result. `evidence/b09/verify-decision-rule-exhaustive.py` enumerates every
`(n_t, n_c, M, H, Fisher)` combination, exits 1 on a gap and 2 on a dead row, and exits 0 here:

```
E-023: every (nt,nc,M,H,fisher) combination, 0 gaps, verdicts reachable =
       INCONCLUSIVE-control-moved, INCONCLUSIVE-floor-only, KEEP, NOT-COMPUTED, REJECT, VOID
```

Its three exit codes were each provoked by a mutant before this file was committed; the mutant
list is in `E-022`'s decision rule. Row 6 is additive and sits outside the partition.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

## Results

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | anchor 2 on ≥ 5 of 10, two-arm | | |
| 2 | anchor 2 on ≥ 3 of 10, one-arm | | |
| 3 | router used on ≥ 7 of 10 | | |
| 4 | cost ≤ +10 % | | |
| 5 | `architecture-consistency` and `test-quality` unmoved | | |

## Failure analysis

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

## Follow-up

---

## Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at §4 step 4 — **after the
prediction commit `ef2c6c0` and before any run of this experiment exists.** Nothing above is
rewritten; this section is the whole change.*

**What was registered.** The delivery proof and prediction 3 name
`.agent/knowledge-log.jsonl` — a file the router writes **inside the worktree under test**.

**Why it could not be that, read off BE-004's own evaluator rather than transferred from
BE-003's.** `tasks/BE-004-cancel-order/evaluator.sh` computes its changed-file set as
`git diff --name-only "$BASELINE_SHA"` **plus** `git ls-files --others --exclude-standard`
(`:124`), and its only ignore pattern is
`(^|/)(target/|\.mvn/|\.git/)|\.(log|class|jar)$|^(run|evaluation)\.json$` (`:119`) — the same
expression byte for byte as BE-003's. Its allowed production prefixes are
`…/order/`, `…/shipment/` and `…/api/` (`:98-102`), test sources are always allowed, and
anything else is an AC7 scope violation counted at `:296-302` and scored **exit 21** (`:39`).
A `.jsonl` under `.agent/` matches no ignore rule, is untracked, and would therefore be counted
as an unrelated production file **on every treated run of this task too**. Making it tracked in
the overlay changes nothing: it would then appear in the `git diff` half instead.

**This is not a new discovery; it is a repeat.** B7's preflight pair `2077432c` (BE-003) and
`88b861f3` (BE-004) **solved their tasks** — build, existing tests, functional suite, error
contract and dependency guard all passed — and were both scored exit 21 because the single
unrelated file was the guardrail's own log (`E-016-verification-policies-BE004.md:227-237`).
v1.1 carries the consequence in its own source: `policy-gate.sh:27-47` and
`repair-limit.sh:30-37` both write **outside** the worktree, under
`${TMPDIR}/…-$(basename "$CLAUDE_PROJECT_DIR")`, and both say why in the file. **The treatment
this stop adds inherits that convention rather than re-learning it at the cost of a batch.**

**What changes, and what deliberately does not.**

| | registered at `ef2c6c0` | as built |
|---|---|---|
| log path | `.agent/knowledge-log.jsonl`, inside the worktree | `${KNOWLEDGE_EVENT_LOG:-${TMPDIR:-/tmp}/knowledge-log-$(basename "$ROOT").jsonl}`, outside it, with the run id in the file's own name — the worktree basename is `observatory-run-<runId>` |
| what the log contains | one JSON line per lookup, on a hit **and** a miss | unchanged |
| `H` in the decision rule | treated runs whose log is non-empty | unchanged in every respect but where the file is read from |
| prediction 3's thresholds | ≥ 7 of 10 non-empty; ≥ 5 of 10 with the index lookup first | unchanged |
| preflight assertion (b) | present with ≥ 1 line on treated, absent on control | unchanged, read at the new path |

**Why this is not a §7 halt and not a registered-variable edit.** §6 forbids editing a
registered variable *mid-experiment*; this experiment has no runs, no run ids and no sheets —
`TRACK-B-STATE.md` records `NOTHING HAS RUN` at the boundary this amendment is written on. The
independent variable (corpus + router + instruction, present or absent), the outcome
(`maintainability` anchor 2), the rubric sha, the model, the evaluator and the decision rule are
all untouched. What moved is the filesystem location of the treatment's own bookkeeping, in the
direction that stops the instrument from measuring itself. Had it been found *after* the batch,
the batch would have been the finding.

**The claim this amendment gives up.** Preflight condition (b) no longer proves anything about
the worktree's contents, so *"the log is in the run's own tree"* — which would have made the
retrieval record an artifact of the run rather than of `$TMPDIR` — is not available at this
stop. Phase 6B's finding 3 named that as one of the two routes to a retrieval record the
harness does not have; **neither route is built here**, and the workbook's §5 layer column says
so in the row it applies to.

---

## Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at §4 step 5. The four preflight runs
below are kept as evidence and are **not** part of any population. Nothing above is rewritten.*

### What the preflight found

`evidence/b09/preflight-20260926T124800Z/` — four runs, one per arm per task, exit **2**.

| task | arm | run id | eval | `knowledgeHash` | corpus in worktree | router log | cost |
|---|---|---|---|---|---|---|---|
| BE-003 | treated | `fbdebf75` | **0** | `sha256:0770219ae7f4281a80071d78dadea285` | MATCH | **ABSENT** | $0.1499 |
| BE-003 | control | `ff1f8d03` | **0** | `null` | absent as registered | absent as registered | $0.110291 |
| BE-004 | treated | `5a16fd3e` | **0** | `sha256:0770219ae7f4281a80071d78dadea285` | MATCH | **ABSENT** | $0.227893 |
| BE-004 | control | `5ea203ac` | **0** | `null` | absent as registered | absent as registered | $0.289222 |

**Conditions (i) and (iii) held on every run.** The corpus was delivered, hashed, and proved present
in the treated worktrees and absent in the controls. The `init.tools` read-back author decision 8
requires returned `n=4 ["Read","Edit","Write","Bash"]` with verdict `match` on **all four** runs — so
unlike E-005's arm F, the runtime did not rewrite the tool list. All four runs **solved their task**.

**Condition (ii) failed on both treated arms**, and that is why no batch was started.

### The cause, and it is not what an absent log looks like

On `fbdebf75` the agent called the router **on its own initiative, at its first opportunity**:

```
.ai/knowledge/router.sh "state transition validation error codes"
```

and that call is in the run's **`permission_denials`** array. The treatment's own hooks did not
refuse it — `repair-limit.sh` recorded **nine allows and zero blocks** on the same run, and its
run-state file carries them. What refused it was `run-agent.sh`'s own allowlist: with
`--permission-mode acceptEdits` and `--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`, **every Bash
command that is not mvn is denied**, and in `claude -p` there is no human to approve one.

**So the batch, had it run, would have recorded `H = 0`, fired **this file's decision-rule row 1**
(`H <= 2`), and reported `VOID — an L3 instruction nobody acted on` about an agent that acted on it
immediately.** That is a harness refusal read as a null result, which is this project's house
failure mode, and it is the same shape as stop 8's `--disable-slash-commands`.

**The two absences are not the same absence, and the instrument now separates them.** On
`5a16fd3e` (BE-004) the agent never mentioned the router at all — no attempt, no denial. Same
`ABSENT`, opposite meanings: one is a refused instruction, the other is an unfollowed one, and only
the second is what the VOID row is about. Both drivers now record `router_mentions` and
`router_denied` per run, hand-checked against these four logs (BE-003 treated 3 mentions / denied
`yes`; the other three 0 / `no`), and a treated denial now prints *"do NOT report this as the
decision rule's VOID row"*. **`n = 1` per arm per task: the BE-004 non-attempt is true of that run
and is not a property of the task** (§5).

### The fix, chosen by probe rather than by reasoning

Three arms, one model call each, `evidence/b09/router-permission-probe-20260926T130051Z/`:

| arm | `permission_denials` | router log |
|---|---|---|
| overlay settings as shipped | non-empty, names the router | none |
| **overlay `permissions.allow`** for the router | non-empty — **the entry was ignored** | none |
| **runner `--allowedTools` entry** | **`[]`** | **`{"status":"hit","topic":"kotlin-exhaustive-when",…}`** |

The overlay route was tried **first**, because a treatment's precondition belongs in the treatment.
The runtime refuses it and says why: *"Ignoring 1 permissions.allow entry from
.claude/settings.json: this workspace has not been trusted … or set
`projects[...].hasTrustDialogAccepted: true` in `~/.claude.json`."* Every benchmark worktree is a new
temp directory, untrusted by construction, and the remedy offered is a user-scope mutation that
`--isolate-user-settings` exists to prevent. **A treatment in this harness cannot grant itself a Bash
permission** — a finding worth more than this stop.

So the fix is in the runner (obs#90): `Bash(.ai/knowledge/router.sh:*)` added to `--allowedTools`,
**unconditionally, on every claude run of every arm**, for the reason the runner's own stream-json
comment gives about itself — a flag passed to the treatment arm only makes the launch a between-arm
difference. An allow rule for a path that does not exist cannot change a control run's behaviour.

### What it costs this experiment, stated rather than left to be inferred

- **Every run of this stop executes under a three-entry allowlist where every earlier stop's runs
  had two.** Both arms move together and the registered comparison is against a **concurrent**
  control, so the change is inside the comparison, not across it.
- **Every number transferred from a stored run was measured under the two-entry list.** That is the
  MDE inputs, the historical `maintainability` anchor-2 floor on this task (0 of 36 runs with
  recorded per-run values) and B8's cost baseline. They are still the registered MDE — they are what was on
  record before this batch — and every place they appear now carries this sentence.
- The four preflight runs above were made under the **two**-entry list. They are the evidence of the
  defect. They are not a population, they set no MDE, and the decision-13 pair cost is taken from
  the **re-run** preflight under the fixed runner, not from them.
- Nothing else moved: model, rubric sha, evaluator, benchmark sha (`2fc445d`), overlays, corpus,
  decision rules and every prediction are exactly as committed at `ef2c6c0`.
