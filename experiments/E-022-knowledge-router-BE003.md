# Experiment E-022 — the knowledge router, BE-003

**Key:** `EXP-B9-ROUTER-BE003` · **Spine stop 20 (B9)** · **version v1.2** ·
**Workbook:** [`phases/b09-knowledge-router/`](../phases/b09-knowledge-router/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-26T09:20Z; the author did not review
before the run.`

> Everything down to and including **Decision rule** is filled in before the first run, and this
> file is committed before it. The commit timestamp and the first run's `startedAt` are written
> into *Runs* after the batch.

Author decision 9: BE-004 is a **separate** experiment,
[`E-023`](E-023-knowledge-router-BE004.md), with its own prediction commit, its own concurrent
control, its own MDE table and its own decision rule. **No verdict is computed across the two.**

---

## Question

Does a knowledge corpus, reached through a router the agent has to call, change the code a run
produces — on the one rubric dimension where this task has a measured, repeated, untreated
failure?

And separately, because `build/README.md#b9` asks for it and because the answer is not the same
question: can this instrument record that a retrieval happened at all?

## Hypothesis

`maintainability` anchor 2 asks for one `when (shipment.status)` in **expression** position with
no `else`, because Kotlin requires such a `when` to be exhaustive and therefore makes a new enum
constant a compile error at that site (`benchmark/rubrics/backend-quality.yaml:138-161`). Runs
fail it by writing an `if` / `else if` chain, which compiles and routes a new state down the
fallback path unannounced.

**That failure is a missing fact, not a missing capability.** Every treatment this track has
tried since B3 has been a *process* instruction — phases, a verification gate, a run-state file,
a repair limit, an agent boundary — and each moved nothing the instrument could see. A knowledge
router is the first step whose payload can be a technical fact, and the mechanism proposed here
is narrow: the corpus states the Kotlin rule, the router surfaces it, and the run writes the
construct the rule names.

**The mechanism by which this fails is equally specific, and it is the stronger prior.** B6 is
this track's only clean positive and its payload was delivered as a **skill**, which the runtime
*selects* on its description — E-004 measured that the description decides whether a skill loads,
matched arm 5 of 5 against 0 of 5. This stop's payload is a file plus a sentence telling the
agent to go and get it: **no runtime selection mechanism at all**. E-009 measured exactly that
shape — the same prose, delivered as project memory with nothing dispatching it — at **0 of 10**.
So the honest hypothesis is *conditional delivery of a technical fact moves this cell*, and the
honest competing hypothesis is *a sentence asking the agent to fetch something is ignored, and
the corpus is a file nobody opened.*

## Predictions

1. **PRIMARY — one-arm.** The treated arm reaches `maintainability` **anchor 2 on ≥ 8 of 10**
   scored runs. Under the historical rate of 0.3625 (29 of 80 across the eight arms B5–B8
   measured) that is `P(X ≥ 8 | n = 10) = 0.0062`. *Mechanism:* the corpus names the construct
   the anchor scores and the router puts it in front of the agent before it writes the branch.
   **This is the prediction registered as most likely to be wrong**, for the reason the
   hypothesis gives: the delivery has no selection mechanism and the one measured instance of
   that shape returned 0 of 10.
2. **SECONDARY — two-arm, and registered as expected-null.** Treated minus control is **≥ +4
   anchor-2 runs**. The MDE table below shows the two-arm test is decidable at `n = 10` **only if
   the treated arm reaches 10 of 10**, across the control's plausible range of 3–5 of 10. So a
   real effect of the size prediction 1 describes is expected to return **NOT DETECTABLE** on
   this test, and that is registered here rather than explained afterwards.
3. **THE ROUTER IS USED, and this decides whether anything was tested.** `.agent/knowledge-log.jsonl`
   is non-empty on **≥ 7 of 10** treated runs, and on **≥ 5 of 10** its first line is the index
   lookup rather than a direct document read. *Mechanism:* the instruction is L3. E-005's
   read-only description arm made zero write attempts and therefore tested nothing; an L3
   disposition can produce zero uptake, and if it does here the batch has measured an instruction
   nobody followed.
4. **COST — clause (c) of the gate.** `estimatedCost` median rises by **≤ +10 %** against the
   concurrent control. *Mechanism:* the corpus is read conditionally, once, not carried on every
   turn; B7's always-on Layer 2 gate cost +5.02 % and B8's cost delta against its control was
   +2.4 % (`$0.119766` vs `$0.116974`, `E-018:335`).
5. **NOTHING ELSE MOVES.** `architecture-consistency`, `test-quality` and `change-focus` medians
   are each **identical between arms**. *Mechanism:* the corpus names one construct and says
   nothing about tests, scope or service structure.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing: the customization overlay.**

| arm | `--customization` | what it is |
|---|---|---|
| treated | `build/customizations/agent-v1.2-knowledge/` | **v1.1 exactly as it closed at B8**, plus `.ai/knowledge/index.yaml`, `.ai/knowledge/summaries/<topic>.md`, `.ai/knowledge/documents/<topic>.md`, `.ai/knowledge/router.sh`, and one clause in the overlay `CLAUDE.md` naming the router |
| control | `build/customizations/agent-v1.1/` | **v1.1 exactly as it closed at B8**, unmodified — a measured version is never edited (§3 pre-made decision) |

**The control is v1.1, not plain**, and that is the gate's own wording: `build/README.md#b9`
asks for *"context metrics compared against B8"*. This experiment makes **no claim against a
plain baseline**; B7 and B8 own theirs and neither is recomputed here.

**The control is run concurrently, and at this stop that matters more than at any previous one.**
B8's batch ran on CLI `2.1.272` (`E-018:217`); this batch will run on **`2.1.283`** — an
eleven-version move. Comparing against B8's *stored* v1.1 runs would put that move inside the
comparison. The stored numbers are used **only** to transfer the MDE and the cost baseline, and
are labelled as transferred wherever they appear.

**What a null here cannot be attributed to.** The overlay adds the corpus, the router and the
instruction **together**, because that is what a knowledge router is. A third arm carrying the
same text unconditionally would separate routing from prose — and **a new arm is a §7 halt**
(§7, final bullet), so this experiment registers the confound instead of resolving it. E-003 and
E-009's nulls narrow it but do not close it: both delivered generic *process* prose, never a
task-specific technical fact, and Phase 6B's finding 6 carries that narrowing itself at
`phases/06b-knowledge-retrieval/README.md:248-256`.

**What the corpus content may not be.** `run-agent.sh:259-262`'s leak check greps object path
**names** only, so content is uncontrolled by the harness (workbook extract fact 6). Registered
constraint: **nothing in the corpus derives from BE-003's tests, fixtures or evaluator.** Its
source is the rubric's own anchor text plus the Kotlin language rule that anchor depends on, and
it names neither `confirm` nor `ShipmentController`.

**And the limit that choice puts on the claim.** B6's skill body is written from `test-quality`'s
anchor clauses very nearly verbatim, so writing this corpus from `maintainability`'s anchor is
methodologically identical to the track's one clean positive. What it costs is registered here:
**the outcome measures whether routed knowledge reaches the model and is used — never whether
the model could have discovered the construct unaided.** That second question needs a corpus
written from something other than the measuring instrument, and this experiment does not ask it.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.2-knowledge/`, copied into the worktree by `run-agent.sh:338` and force-added at `:371` |
| Content hash | **`knowledgeHash`** — a new run-record field over the **set** of files under `.ai/knowledge/`, written the way `skills_hash()` (`run-agent.sh:616`) hashes the set of `SKILL.md`s and `agents_hash()` (`:631-638`) the set of agent files. **It does not exist yet**: the four fields the runner emits today are `instructionsHash`, `skillsHash`, `agentHash`, `agentsHash` (`:640-645`) and **none covers a corpus** (workbook extract fact 5). Building it is §4 step 4's job, in its own `agent-observatory` PR with a fixture set, exactly as `agentsHash` was built at stop 17a (obs#88) |
| Preflight assertion | one run per arm before the batch: (a) `knowledgeHash` **set** on treated and **`null`** on control; (b) `.agent/knowledge-log.jsonl` present and **≥ 1 line** in the treated kept worktree, **absent** in the control's; (c) the corpus files in the treated worktree hash to the same values as in the overlay directory |
| Control assertion | the control overlay contains no `.ai/knowledge/` path, so `knowledgeHash` is `null` and no log file exists — both read back from the record and the kept worktree, never inferred from the flag |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this — and
> preflight condition (b) is the one that matters here, because a corpus can be delivered
> perfectly and never read. **If (b) fails, the batch does not start.** B6's stop-13 preflight
> and B8's stop-17 preflight both stopped a batch on exactly this check.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` `2fc445d`
- [ ] task + revision — `BE-003-confirm-shipment`, unchanged since B2
- [ ] harness + version — `claude` **`2.1.283 (Claude Code)`**, read back from `runtime.version`
      on every run, never from the flag
- [ ] model — **`claude-haiku-4-5-20251001`**, exact id, the pinned agent under test
- [ ] permissions / permission mode — as B8's batch, unchanged
- [ ] environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1`,
      and **the isolation half that is observable is the only half claimed**: all five
      `customization.*Hash` read back, because the run record has **no hook-execution field**
      (§0a row 6 defect, recorded in `TRACK-B-STATE.md` `preflight:`)
- [ ] runner commit — `agent-observatory` at whatever sha the `knowledgeHash` PR merges to; the
      **same sha for both arms**, recorded per run

## Runs

Repetitions per arm: **10**, interleaved · Total budget: **≤ $3.20** for this task
(20 batch runs at B8's `$0.12` median = `$2.40`, plus 2 preflight runs, plus headroom)

Prediction commit: `<filled after the batch>` · first run `startedAt`: `<filled after the batch>`

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Derived from the measured arms, before any threshold above was written.** The reference
population is `maintainability` anchor-2 counts in every BE-003 arm B5–B8 measured, computed
rather than summed in prose:

| arm | anchor-2 count | source |
|---|---|---|
| B5 treated / control | 3 / 10 · 3 / 10 | `E-010:668` |
| B6 treated / control | 2 / 10 · 5 / 10 | `E-012:659` |
| B7 treated / control | 6 / 10 · 4 / 10 | `E-015:406` |
| B8 treated / control | 3 / 10 · 3 / 10 | `E-018:355` |
| **pooled** | **29 of 80 = 0.3625**; controls alone **15 of 40 = 0.375** | computed |

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: `maintainability` anchor-2 count, one-arm binomial vs `p0 = 0.3625` | the eight arms above | **≥ 7 of 10** already clears `p = 0.0318`; **≥ 8 of 10** is registered, at `p = 0.0062`, for margin | yes |
| secondary: same count, two-arm Fisher vs the concurrent control | the control arms' range, **3 to 5 of 10** | **10 of 10 and nothing less.** `10/10 vs 5/10 → p = 0.0325`; `9/10 vs 5/10 → 0.1409`; `8/10 vs 5/10 → 0.3498`. Against a control at 3 of 10, `9/10 → 0.0198` and `8/10 → 0.0698` | yes |
| secondary: `estimatedCost` median | B8's `$0.119766` [0.102048–0.144211] treated, `$0.116974` [0.101403–0.140168] control (`E-018:335`) — **transferred**, so the concurrent control supersedes it | a shift of about **+18 %** is the width of B8's own treated interval; **+10 % is inside the noise of a stop that moved nothing** and prediction 4 is therefore a *bound*, not a detection | yes |
| reported, decides nothing: hit rate | no prior exists (6B finding 4) | **first measurement**, no MDE | yes |

**Derived against the *interval* of the control, not its point estimate**, which is the whole
reason the two-arm row reads as it does. The control has landed at 3, 3, 4 and 5 of 10 in four
consecutive stops. E-003's lesson applied: asking what `n` keeps an 8-of-10 effect decidable
against a control at 5 of 10 gives roughly **30 per arm** — 60 runs on this task alone, about
`$7.20`, against decision 9's whole-step budget of about `$6` for two tasks. **So `n = 10` is
registered with the two-arm test declared underpowered rather than run and then excused**, and
the primary claim is the one-arm binomial, which the template explicitly provides for and which
needs no control.

| the prediction says | what tests it | what a null means |
|---|---|---|
| P1 *"this arm reaches anchor 2 on ≥ 8 of 10"* | one-arm binomial vs the historical 0.3625 | far from 8 → **refuted** |
| P2 *"the arms differ by ≥ 4"* | two-arm Fisher against the control that occurred | inside the MDE → **not detectable**, never refuted |

Both claims are made and **both are reported**.

## Deterministic evaluation

`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment`'s evaluator decides correctness, by
its exit-code contract, unchanged since B2. `./tools/check-run-gate.sh` admits a run to scoring
only on the evaluator's recorded verdict (Decision D). Rubric scoring is **codex only**
(Decision C) with `benchmark/rubrics/backend-quality.yaml` at sha **`396e1799eb2b`** — the
registered instrument, unmoved. `opencode-score.sh` on the same run ids is the second reader and
is not a vote.

## Exclusions

Registered now, not after seeing the data:

- runs the evaluator failed → excluded from rubric analysis, **counted in the pass-rate line**
- `check-run-gate.sh` refusals → excluded, reason recorded per run
- infrastructure failures of the F13/F15 class, permission blocks, quota exhaustion → excluded,
  and a run excluded for infrastructure is **replaced**, so the scored `n` stays 10 per arm
- a batch that spans a machine sleep → **duration excluded, the run kept** (§4 step 6). B8's
  BE-004 batch was split by a clamshell sleep and that is how it was handled there
- **no run is excluded for its score**, and no run folder, sheet or evidence file is overwritten
  or deleted at any point (§6)

## Decision rule

Registered before data. `M` = treated `maintainability` anchor-2 count out of the scored treated
runs; `C` = the same for the control; `H` = treated runs whose `.agent/knowledge-log.jsonl` is
non-empty.

**The rows are exhaustive over every `(M, H)` pair**, checked by enumeration before this file was
committed:

| # | condition | verdict | disposition (§4 step 10) |
|---|---|---|---|
| 0 | `H ≤ 2` | **VOID — THE TREATMENT WAS NOT TESTED.** An L3 instruction nobody acted on tested nothing; this is E-005's description arm, where a read-only description produced zero write attempts. Not a result about knowledge routing, at any `M` | corpus kept in the repo, **not** promoted; the finding is about the instruction, not the corpus |
| 1 | `H ≥ 3` and `M ≥ 8` | **KEEP — IMPROVED.** P1 held | corpus and router promoted into v1.2 |
| 2 | `H ≥ 3` and `M` is 6 or 7 | **INCONCLUSIVE — SEPARATED FROM HISTORY, NOT FROM ITS OWN CONTROL.** The one-arm test clears at 7 (`p = 0.0318`) and the two-arm test cannot see it at this `n` | not promoted; the `n` this would need is recorded for the author |
| 3 | `H ≥ 3` and `M ≤ 5` | **REJECT.** The corpus reached the model, was consulted, and changed nothing. P1 refuted | **removed** from the overlay, and the removal *is* the finding (§4 step 10) |

And two rows that fire **independently of, and alongside, whichever of 0–3 applies**:

| # | condition | what it adds |
|---|---|---|
| 4 | `Fisher(M, C) > 0.05` | **NOT DETECTABLE on the two-arm reading.** Always reported. Never the verdict on its own, because P2's MDE says this is the expected shape of even a real effect here |
| 5 | `estimatedCost` median delta vs the concurrent control **> +25 %** | **COST OBJECTION.** Its own row, never a second condition on a failure row: *a free useless rule is still a rule someone has to read, trust and maintain*, and an expensive useful one is a separate fact. On row 1 it downgrades the verdict to **KEEP WITH A COST OBJECTION** |

**The combination that reaches no row: there is none, and that is executed rather than asserted.**
`evidence/b09/verify-decision-rule-exhaustive.py` enumerates all 121 `(M, H)` pairs for this rule
and every `(n_t, n_c, M, H, Fisher)` combination for `E-023`'s, exits **1** on a gap and **2** on a
row that can never fire. Unmutated it exits **0**:

```
E-022: 121 combinations, 0 gaps, verdicts reachable = INCONCLUSIVE-hist-only, KEEP, REJECT, VOID
Both rules are exhaustive and neither has a dead row.
```

**And it was shown to refuse**, because a control that has never rejected anything is
indistinguishable from one that rejects nothing (§6). Three mutants, run: narrowing row 3 from
`M ≤ 5` to `M ≤ 4` leaves 8 uncovered combinations and exits **1**; disabling row 2 leaves 16 and
also exits **1** (a disabled row shows up as a gap before it shows up as a dead row, which is
worth knowing); adding an unreachable verdict to the expected set exits **2**. Rows 4 and 5 are
additive by construction and sit outside the partition the script checks.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

<!-- §4 step 6. Pass OTLP_GRPC_PORT and check events.jsonl GROWS before trusting any
     telemetry-sourced number (stop 11's rule). A per-file count is not a per-run count across a
     rotation boundary — one run id already spans two of the three events*.jsonl files on disk
     (stop 19, next_action item 2d). -->

## Results

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | anchor 2 on ≥ 8 of 10 | | |
| 2 | treated − control ≥ +4 | | |
| 3 | router used on ≥ 7 of 10; index first on ≥ 5 | | |
| 4 | cost ≤ +10 % | | |
| 5 | no other category moves | | |

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

**Why it could not be that, read off the evaluator rather than remembered.** BE-003's
evaluator computes its changed-file set as `git diff --name-only "$BASELINE_SHA"` **plus**
`git ls-files --others --exclude-standard`
(`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/evaluator.sh:110-127`), and its
only ignore pattern is
`(^|/)(target/|\.mvn/|\.git/)|\.(log|class|jar)$|^(run|evaluation)\.json$`. Anything outside
`…/shipment/`, `…/api/` and `src/test/` is an AC7 scope violation and the run is scored
**exit 21** (`:279-296`). A `.jsonl` under `.agent/` matches no ignore rule, is untracked, and
would therefore be counted as an unrelated production file **on every treated run**. Making it
tracked in the overlay changes nothing: it would then appear in the `git diff` half instead.

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
