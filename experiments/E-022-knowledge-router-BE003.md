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

**So the batch, had it run, would have recorded `H = 0`, fired decision-rule row 0 (E-022) / row 1
(E-023), and reported `VOID — an L3 instruction nobody acted on` about an agent that acted on it
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
  MDE inputs, the historical `maintainability` anchor-2 rates (BE-003 pooled 29 of 80; BE-004's
  floor 0 of 36) and B8's cost baseline. They are still the registered MDE — they are what was on
  record before this batch — and every place they appear now carries this sentence.
- The four preflight runs above were made under the **two**-entry list. They are the evidence of the
  defect. They are not a population, they set no MDE, and the decision-13 pair cost is taken from
  the **re-run** preflight under the fixed runner, not from them.
- Nothing else moved: model, rubric sha, evaluator, benchmark sha (`2fc445d`), overlays, corpus,
  decision rules and every prediction are exactly as committed at `ef2c6c0`.

---

## Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-26, **before the batch started**. The
decision it resolves is a contradiction inside the workbook's own design section, which is the
builder's text from the previous session, not an author gate. Nothing above is rewritten.*

### The second preflight: the harness no longer refuses, and the agent no longer asks

`evidence/b09/preflight-20260926T131746Z/`, four runs, exit **2**, $0.7103, under the fixed runner
(obs#90 → `dfe5f02`, and the flag list is now echoed into each run's log:
`--allowedTools Bash(./mvnw:*) Bash(mvn:*) Bash(.ai/knowledge/router.sh:*)`).

| task | arm | run id | eval | `knowledgeHash` | corpus | router log | `router_denied` | cost |
|---|---|---|---|---|---|---|---|---|
| BE-003 | treated | `8f61203e` | 0 | registered | MATCH | ABSENT | **no** | $0.149849 |
| BE-003 | control | `9e3060de` | 0 | `null` | absent as registered | absent | no | $0.131132 |
| BE-004 | treated | `863f4436` | 0 | registered | MATCH | ABSENT | **no** | $0.218369 |
| BE-004 | control | `b1d0e311` | 0 | `null` | absent as registered | absent | no | $0.211 |

All four solved their task. Conditions (i) and (iii) held again; the `init.tools` read-back was
`n=4 ["Read","Edit","Write","Bash"]` / `match` on all four. **No denial on any run, and no attempt
on either treated run.** So the cause of the absent log has changed: it was a refusal, and now it
is a non-attempt.

**`router_mentions` reads 1 on every row of this manifest and that 1 is the runner's own echo, not
the agent.** The detector counts the string in the whole log and the runner now prints its flag
list, which contains the router's path. Corrected in both drivers after this preflight — never
during it (§4 step 4 forbids editing a tool while a run of it is in flight) — and stated here so no
reader takes `1` for an attempt.

**Uptake across both preflights: 1 attempt in 4 treated runs, and the one attempt was refused.**
`n = 4`. Under §5 that is *true of those runs* and is **not** a property of the treatment.

### The mechanism is proven in a real worktree, which is what the gate was protecting

`evidence/b09/inworktree-permission-probe-20260926T132958Z/`: a **copy of treated run
`863f4436`'s own kept worktree**, placed in a fresh temp directory so it is untrusted exactly as a
benchmark worktree is, driven by `claude -p` with the runner's exact flag set. Result:
`permission_denials":[]`, the router **executed**, it wrote
`{"status":"hit","topic":"kotlin-exhaustive-when",…}`, and the model reported both absolute paths.
Nothing of the evidence was touched — the probe's log went to a path of its own.

So: the corpus is delivered (condition i, iii, twice), and the router **can** be executed by the
agent under the registered harness (this probe). What remains unmeasured is only whether the agent
**chooses** to call it.

### The contradiction, and how it is resolved

The workbook's design section says both of these:

> *"If it never does, the hit rate is `0 / 0`, the corpus is a file nobody opened, and the
> experiment has measured an instruction nobody followed — **which is a result**, and the same shape
> as E-005's description arm."*

> *"A preflight that fails (2) is reported and the batch is **not** started until the instruction is
> the thing being tested rather than the thing being hoped for."*

The first calls zero uptake a result; the second forbids the batch that would measure it. Both are
the builder's own words from the previous session. **The resolution taken, with its reasons:**

1. **The gate exists to stop a batch that cannot test the treatment.** Deliverability is now proven
   in-harness by the probe above, so the batch can test it. Before obs#90 it could not, and the gate
   was right to fire — it saved $8 and it saved a VOID report about an agent that had obeyed.
2. **What remains is a registered outcome, not an unknown.** Prediction 3 registers uptake at
   **≥ 7 of 10** treated runs with the mechanism *"an L3 disposition can produce zero uptake"*, and
   E-022 row 0 / E-023 row 1 give `H ≤ 2` its own verdict. E-005's description arm — the case the
   design compares this to — **was run at `n = 10` and reported**, not skipped.
3. **At `n = 4` nothing can be said as a property (§5).** The batch is the only way to answer a
   prediction that is already on record.
4. **The spend is bounded by a control, not by optimism.** Author decision 13's ceilings, computed
   by the driver from this preflight's pairs: BE-003 `$0.280981 × 11 = $3.0908`, BE-004
   `$0.429369 × 11 = $4.7231`.

**The argument against, recorded because it may well be the right one.** If uptake is ~0 the treated
arm is v1.1 plus an unread corpus plus one unread `CLAUDE.md` section — and *that* comparison is
E-003's, already `REJECT` at `n = 10` per arm. On that reading the batch spends about $7.81 to
re-measure E-003 and returns `VOID`, which the rule itself says is *"not a result about knowledge
routing, at any M"*. If it lands there, this amendment is the record that the cost was known in
advance and accepted for one reason only: prediction 3 is on record and `n = 4` cannot answer it.

**What was deliberately *not* done.** The `CLAUDE.md` clause was **not** rewritten to make uptake
more likely. That would be tuning the treatment's own content against an outcome already observed,
after the prediction commit — the one move this project's method exists to prevent. Its sha stays
`sha256:ebf489800a60a156986f98ea4f127848`, the guards still assert it, and if a later version wants
a stronger instruction it is a new treatment with a new prediction commit.
