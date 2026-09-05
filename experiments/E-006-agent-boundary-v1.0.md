# Experiment E-006 — `backend-feature-implementer` v1.0 against a concurrent plain baseline

**Spine stop 10 · B4 · version v1.0 begins here**
**Workbook:** [`phases/b04-agent-boundary/README.md`](../phases/b04-agent-boundary/README.md)
**Status:** registered, no runs yet
**Prediction commit:** `2498dc7`, **2026-09-05T06:42:48Z** (`git log --format=%cI -1 2498dc7`). Pushed to `origin/stop10/b4-agent-boundary` before any run existed; the first run's `startedAt` goes beside it here after the batch, and the pair must be in that order.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-05T00:00Z; the author did not review
before the run.` The commit timestamp of this file and the first run's `startedAt` are written
into the Results block after the batch, and must be in that order.

---

## Question

`build/README.md#b4` asks for **3 comparisons vs B3** and one thing specifically: **did the diff
become more focused**, *"since scope discipline is what a boundary buys."*

So: **does a ten-section `backend-feature-implementer` overlay, delivered as the session agent
with an explicit `tools:` allowlist, change what the agent does on BE-003 — and can this
instrument see it if it does?**

The second half of that question is not rhetorical, and §5 of this file answers it before the
first run.

## Hypothesis

**H1.** The overlay changes the *shape* of the change — fewer incidental edits, a tighter diff —
because it names a scope and the scope is what a boundary is for.

**H2 (the competing one, and the one the evidence favours).** It changes nothing measurable,
because (a) the control is already at the floor of what the task admits, (b) the only rubric
category that could register focus is a constant on this task by construction, and (c) B3
already measured that a proved-delivered prose treatment moves nothing — 2/10 vs 3/10 on the
same primary, `p = 1.0`.

**What separates them is not a run, it is arithmetic**, and it is done below before the batch.

## Predictions

Every prediction has a direction, a magnitude and a mechanism. **Wrong predictions stay wrong**
(§4 step 12); nothing here is edited after its run.

### P1 — the gate's own outcome, deterministic. **No change, and none is possible upward.**

**Direction:** none. **Magnitude:** `result.changedFiles` is exactly
`{ApiError.kt, ShipmentController.kt, ShipmentControllerTest.kt}` on **10 of 10** treatment runs,
as it is on **19 of 19** measured controls (B2 `n = 9`, B3 control `n = 10`).

**Mechanism:** all three files are *required*. Acceptance criterion 3 forces
`ShipmentController.kt`; criterion 4 (*"Error responses are consistent with the rest of this
API"*) plus the 409 requirement forces a new `ErrorCode` constant in `ApiError.kt`, because
`ErrorCode` is a **closed enum** with no state-transition code; criterion 5 plus *"tests
required"* forces `ShipmentControllerTest.kt`. **There is no diff below three files that still
passes the gate.** A boundary cannot buy focus that the task has already spent.

**Registered as NOT DETECTABLE in the direction the gate asks.** Harm is detectable: a 4th file
on ≥ 5 of 10 gives Fisher `p = 0.0325` against a control of 0 of 10.

### P2 — the gate's own outcome, rubric. **`change-focus` stays 1 on 10 of 10.**

**Direction:** none. **Magnitude:** `1`, exactly, on every scored treatment run — as on **40 of
40** scored runs across four experiments and three treatments (B2 baseline 5, B3 control 10, B3
instructions 10, skill-desc 15; zero variance).

**Mechanism:** anchor 2 requires *"Only `confirm`, and imports required BY SYMBOL for `confirm`,
differ."* The `ApiError.kt` change P1 shows to be mandatory is a change beyond `confirm`, so
anchor 2 is unreachable. Anchor 0 requires two unnamed **methods** to differ, and none does.
Every run lands on the residual by construction. **The task's acceptance criterion mandates the
change the rubric's top anchor forbids.**

**MDE: none.** If this prediction is refuted the finding is about the scorer, not the agent, and
it will be reported that way.

> **This is E-001's defect surviving into rubric v2 by a second route.** v1 died because an
> anchor restating a gate is a constant across everything the rubric can score — 60 % of the
> weight carrying no information. v2 dropped those categories and kept `change-focus` at
> **weight 15**. On BE-003 that 15 is a constant for every agent run. It is **not** a dead anchor
> in general — the 2026-09-04 preflight scored fixture `good-nested-ifs` at `change-focus = 2` —
> so the anchor discriminates on fixtures and is constant on the task. **Nothing is changed
> about it here**: §6 forbids moving a registered variable mid-experiment, §7 makes any change to
> the rubric's categories or weights a halt, and the rubric sha stays `396e1799eb2b`. It is
> registered as a property of the instrument and handed to the author.

### P3 — quality. **No detectable difference on `maintainability`.**

**Direction:** none. **Magnitude:** treatment lands between **2 and 6 of 10** reaching anchor 2,
against the B3 control's **3 of 10** — inside the MDE, which needs **≥ 9 of 10**.

**Mechanism:** anchor 2 is *"One `when (shipment.status)` in EXPRESSION position, carrying no
`else`"* — a Kotlin construct choice. **The overlay never mentions it.** No tool list touches a
construct. And B3 measured the closest available comparison: a proved-delivered instruction file
moved this exact outcome from 3/10 to 2/10, `p = 1.0`. The one treatment that *did* move it —
skill-desc, 10 of 15 at anchor 2 — carried a body that named the convention. This overlay does
not.

### P4 — cost. **Up, and below the detection threshold.**

**Direction:** up. **Magnitude:** `estimatedCost` median **+3 % to +12 %**, i.e. **below the
registered ≥ +25 % MDE**, so recorded as NOT DETECTABLE unless it clears it.

**Mechanism:** the overlay is ~750 words of system prompt on every request. E-003 measured
1 455 words at **+4.2 %**. Competing upward pressure: the delivered tool set has no `Grep` and no
`Glob` (see delivery, below), so search runs through `Bash`, which costs a round trip per query
rather than a structured result.

### P5 — **registered as the one most likely to be wrong.** `toolCalls` rises in the treatment arm.

**Direction:** up. **Magnitude:** median **+2 to +5** against the B2 arm's median of 17
(range 14–20). The registered threshold is **≥ +5 on the median with non-overlapping quartiles**,
so most of my predicted range is *inside* the MDE and would be recorded as NOT DETECTABLE.

**Mechanism:** `Grep` and `Glob` are not in the delivered set. E-005's arm F, under the same
deletion, searched with `find` on 10 of 10 runs. Shell search is more calls for the same
information.

**Why it may well be wrong, stated before the run:** `sample-service` is 25 files and BE-003's
task text names the module. An agent may never search at all — it can `Read` straight to a path
it guessed correctly — in which case losing `Grep` and `Glob` costs nothing, and a *shorter* tool
schema on every request could push `toolCalls` flat or **down**. E-005's arm F searched because
it was dropped into an unfamiliar scratch repository with no paths given. That is not this task.

**This prediction is registered because it is the one that would teach the most by failing**: if
removing two search tools changes nothing measurable, then the delivered-schema rewrite that row
0a caught is a provenance problem and not a behavioural one, and that is worth knowing before
B6 and B10 inherit it.

## Independent variable

**One thing, and it is compound by design and named as compound:** the presence of
`build/customizations/agent-v1.0/` — the ten-section `backend-feature-implementer` overlay — and
the `--agent backend-feature-implementer` flag that makes it the session agent.

**Why compound, and why that is legal here.** B4's deliverable is a *version*, not a factor.
Stop 9 already separated the parts: `E-005` measured the `tools:` list alone (0/10 vs 10/10,
`p = 0.00001`) and the description alone (0/10, but 0 write attempts, so L3) against a control
with neither. B4 does not re-separate them; it measures **v1.0 as shipped** against the condition
B3 left behind. Any claim about *which section* of the overlay did the work is out of scope of
this experiment and is not made.

**"vs B3" means vs the plain baseline.** B3 closed `REJECT`; `instructions-v0.1` was removed and
not replaced. The condition B3 left behind is the plain prompt. The control arm is run
**concurrently and interleaved**, never read from B3's stored runs, so a drift in harness
version, machine or day lands on both arms equally.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.0`, copied to the worktree root and committed as a setup commit before the agent starts, **plus `--agent backend-feature-implementer`** on the treatment arm only |
| Content hash | `sha256:59c2b5db71f4c01e22a51589a1febdf9` — the first 32 hex characters of the digest, which is what the runner stores. Verify with `shasum -a 256 build/customizations/agent-v1.0/.claude/agents/backend-feature-implementer.md \| cut -c1-32` |
| **Delivered schema** | **`init.tools` = `["Read", "Edit", "Write", "Bash"]`, identical to the overlay's `tools:` line, on 3 of 3 confirmation runs against the shipped file.** `evidence/b04/shipped-overlay-confirm-20260905/` |
| Preflight assertion | one treatment run before the batch whose `init` record carries exactly that array, and whose setup commit tracks the overlay path |
| Control assertion | control runs pass **no** `--customization` and **no** `--agent`. The worktree is built by `git archive` from an allowlist of `sample-service` and `.gitignore` only, so no `.claude/agents/` path can exist on a control run |
| **What cannot be proved from the run record** | **no `customization.*Hash` field tracks a Claude agent overlay.** `run-agent.sh:431` hashes `.github/copilot-instructions.md` for `agentHash` and `.github/skills.md` for `skillsHash`. Both will be `null` on **both** arms. Independence therefore rests on the `init` record and the setup commit, exactly as stop 8's rested on telemetry. Recorded, not worked around |

### Row 0a fired, and this is what it caught

Author decision 8 requires the delivered schema to be read and diffed **before** the prediction
commit. It was, and **the first list this design intended was not the list the runtime
delivers.**

| `tools:` written in the file | delivered `init.tools` | n | verdict |
|---|---|---|---|
| `Read, Grep, Glob, Edit, Write, Bash` ← *the original B4 candidate* | `["Read", "Edit", "Write", "Bash"]` | 3 | **row 0a — Grep and Glob dropped** |
| `Read, Grep, Edit, Write, Bash` | `["Read", "Edit", "Write", "Bash"]` | 3 | Grep dropped |
| `Read, Glob, Edit, Write, Bash` | `["Read", "Edit", "Write", "Bash"]` | 3 | Glob dropped |
| **`Read, Edit, Write, Bash`** ← *the registered list* | `["Read", "Edit", "Write", "Bash"]` | 3 | **verbatim** |
| `Read, Grep, Glob, Edit, Write` *(no Bash)* | `["Read", "Grep", "Glob", "Edit", "Write"]` | 3 | verbatim |
| *(no `tools:` key)* | the full 29-tool set | 3 | verbatim |
| `Read, Grep, Glob, Bash` — E-005 arm F | `["Read", "Bash"]` | 10 | Grep and Glob dropped |
| `Read, Grep, Glob` — E-005 arm T | `["Read", "Grep", "Glob"]` | 17 | verbatim |

**The rule, on 36 observations with no exception: when `Bash` is present in a subagent `tools:`
allowlist, `Grep` and `Glob` are removed from the delivered set. When `Bash` is absent, the list
is delivered verbatim.** 16 of 16 with `Bash` dropped both; 20 of 20 without `Bash` verbatim.

**Stated as true of these runs, on one runtime version.** Claude Code `2.1.260`, model
`claude-haiku-4-5-20251001`, this machine. It is not offered as a documented behaviour and no
documentation was consulted for it; it is what the `init` record says.

**The redesign row 0a forced.** B4 cannot drop `Bash` — BE-003 instructs *"Run `./mvnw test`
from `sample-service/` to verify your work before finishing"*, and an agent that cannot do what
the task instructs is not being measured on the task. So the overlay is written as the runtime
delivers it: `tools: Read, Edit, Write, Bash`, with the omission of `Grep` and `Glob` explained
in the file itself and search routed through `Bash`. **The file and the schema now agree**, which
is the only state in which a `tools:` line is a treatment rather than a claim.

Probe scripts and all 21 transcripts: `evidence/b04/init-schema-probe.sh`,
`evidence/b04/probe2.sh`, `evidence/b04/probe-20260905/`, `evidence/b04/probe2-20260905/`,
`evidence/b04/shipped-overlay-confirm-20260905/`.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `0448643`, the sha B2, E-002, E-003 and E-004 ran on
- [ ] task + revision — BE-003, `evaluator.sh` version `1.0.0`
- [ ] harness + version — one `claude` CLI version for all runs, recorded per run and asserted
      identical across arms after the batch. **Registered `2.1.260` at the prediction commit; batch 1
      ran wholly on it and was aborted; batch 2 runs wholly on `2.1.261`, disclosed as the fifth
      harness move with its schema re-probe on record.** A move mid-batch voids the batch
- [ ] model — `claude-haiku-4-5-20251001`, the id B2's claude arm registered, pinned in **both**
      the overlay frontmatter and the runner's `--model`
- [ ] permission mode and `--allowedTools` — runner default, identical on both arms
- [ ] environment — `ISOLATE_USER_SETTINGS=1` on **every** run of both arms, proved from
      telemetry (`claude_code.hook_execution_start` = 0 per run), not from the flag
- [ ] runner commit — one commit for the whole batch, recorded. **It will not be the commit
      B2/B3 ran on**: B4 adds `--agent` and its guard, disclosed below
- [ ] rubric — `benchmark/rubrics/backend-quality.yaml` v2, sha `396e1799eb2b`, unmoved
- [ ] scorer — `codex-score.sh` (Decision C), `opencode-score.sh` as the second reader

### The harness move, disclosed before the batch — the fourth in this track

`run-agent.sh`'s `CLAUDE_ARGS` has **no `--agent` flag**, so an installed `.claude/agents/*.md`
registers a *subagent the main session may delegate to* and never becomes the agent handling the
task. Measuring that arrangement measures delegation — stop 8's finding — not a boundary. B4
adds `--agent`, together with a guard that **refuses an agent-overlay customization when
`--agent` is not passed**, which is the exact analogue of the existing `SKILL.md` guard and
exists for the same reason: without it, an agent file is copied, committed, hashed and never
made the session agent, every check passes, and the arm is silently a second baseline.

Precedents and provenance: `2.1.251 → 2.1.259` (stop 6), the overlay force-add (author decision
2, stop 8), `2.1.259 → 2.1.260` (stop 8). This is not a §7 halt — it moves no registered
variable and changes nothing the benchmark or evaluator measures.
`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-05.`

**Amended 2026-09-05, before the first batch run, when the change was built.** The harness move
is larger than the paragraph above described, and the extra part is disclosed here rather than
discovered later.

| What moved | Applies to | Why it had to |
|---|---|---|
| `--agent <name>` in `CLAUDE_ARGS` | **treatment arm only** | without it the overlay is a subagent nobody invokes |
| a section-5 guard refusing an agent overlay with no `--agent`, a `--agent` naming no installed file, and `--agent` with no `--customization` | both arms | the control passes none of them, so it can never fire there |
| `--output-format stream-json --verbose` on the non-interactive claude launch | **both arms, identically** | the `system`/`init` record is the only place the delivered tool schema exists |
| an executing check comparing `init.tools` to the overlay's `tools:` line, exit 9 on a mismatch | both arms; **asserted** on the treatment arm, **recorded only** on the control | author decision 8 |
| structural F13 detection from the stream's terminal `result` record | both arms | see below |

**The output-format change is on BOTH arms and that is the point.** Putting it on the treatment
arm alone would make the launch itself a between-arm difference and confound the comparison with
the instrument added to protect it — decision-rule row 0b would fire on this experiment's own
harness.

**It also forced a second change, and skipping that one would have been the quiet failure.**
`INFRA_SIGNATURE` is a list of five phrase groups matched against the agent log, and it is how a
quota exhaustion is recorded as F13 (infrastructure) rather than F03 (incorrect code). Under
`stream-json` a claude failure arrives as a terminal `result` record whose `is_error` is true and
whose `subtype` names the class — words that appear in none of those phrases. Left alone, the
format change would have **weakened F13 detection for the only arm every experiment in this track
uses**, and the damage would have looked like a fact about the agent. `run-agent.sh` now also
reads that record structurally, gated on the run having produced no diff, so it cannot condemn a
run that passed the evaluator.

**What crosses this line.** Nothing inside E-006: both arms run under it, concurrently and
interleaved. What crosses it is any comparison against a **stored** B2 or B3 run, including the
reference populations §5's MDE column is derived from. Those were used to fix thresholds *before*
this batch and are not arms of it; no E-006 verdict is computed against a stored run.

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-05T09:xxZ. Built in agent-observatory
968b498 on branch stop10/b4-agent-delivery, and proved by verify-init-schema-check.sh (17 of 17)
and verify-agent-delivery.sh (9 of 9), the latter also run against a copy of the runner with the
guard deleted, where cases A, B and C go red.`

## Runs — batch 1 ABORTED, 2026-09-05. Recorded, not hidden, and not scored

**Batch 1 ran 08:33:11Z–09:08:29Z on claude `2.1.260` and produced 5 gate-passing runs of the
20 registered.** It is abandoned as a batch. Nothing is deleted: all 20 run records, 20 kept
worktrees and 20 `init` schema verdicts stay on disk and are cited below.

| What happened | Count | Consequence |
|---|---|---|
| gate-passing runs (`evaluation.exitCode 0`) | **3 treatment, 2 control** | valid observations, but far short of the registered `n = 10` per arm |
| **claude session limit**, first hit 09:00:16Z | **15 runs**, 7 treatment + 8 control | every one `taskAttempted=false`, `changedFiles=0`, `failureClass F13`, `infrastructureFailure=true`, ~23 s each. **E-006 exclusion 3 verbatim**: terminated by a session limit, excluded with its count reported |
| **machine idle sleep** at 08:41:58Z, 08:55:03Z, 09:04:11Z | **2 of the 5** gate-passing runs span one | §4 step 6 says do not run across a machine sleep; exclusion 2 costs those runs their *duration*, a registered outcome |

**Why a fresh batch rather than completing the shortfall.** The runtime moved to `2.1.261`
after the batch ended, so any run added now would sit beside 20 runs recorded on `2.1.260`, and
this experiment's own controlled-variable line says *one claude CLI version for all runs* and
*a move mid-batch voids the batch*. Stitching the shortfall on would build exactly the defect
the clause forbids. Batch 2 therefore runs **entirely on one version**, interleaved and
concurrent as registered.

**The failure the harness caught, and the one it did not.** The runner classified all 15 as F13
rather than F03 — a quota failure recorded as infrastructure, not as a fact about the agent —
and that classification came through the structural `result`-record check added with the
output-format move, which is the first thing it has caught. What nothing caught was the idle
sleep: the driver now re-executes under `caffeinate -i`, which is the L2 version of a sentence
telling the operator to disable sleep.

### The fifth harness move, disclosed before batch 2

`2.1.260 → 2.1.261`, an automatic CLI update between batches. Precedents: `2.1.251 → 2.1.259`
(stop 6), the overlay force-add (author decision 2, stop 8), `2.1.259 → 2.1.260` (stop 8), and
the `--agent` + output-format move above.

**Author decision 8 was applied before this was accepted, not after.** The delivered schema was
re-read on the new runtime through the real runner before any batch-2 run existed:
`EXP-B4-PREFLIGHT-2161`, run `fee79c79-d2b8-4db7-a8f1-1bba1b4ed77b`, **`init.tools` =
`["Read","Edit","Write","Bash"]` against the identical declared line, `verdict=match`**,
evaluator exit 0 at 7 of 7. So the overlay is still the treatment on `2.1.261` and row 0a does
not fire. Had it fired, this would have gone to the author instead.

**What stays the author's.** `TRACK-B-STATE.md` reserves *"whether a runtime-version bump should
VOID an open batch"* for the author as a general policy, and that is untouched. This case did
not need it: batch 1 was already aborted by the session limit, and the version rule E-006 itself
registered — one version for all runs of a batch — decides batch 2 without a new judgement.

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-05, before the first batch-2 run.`

## Runs — batch 2, as registered

**10 treatment + 10 control, interleaved.** Deliberate-failure arm registered separately at §4
step 9. Budget ≈ 20 × $0.15 = **$3.00**.

`n = 10` is not a preference: §5 shows it is the smallest `n` at which the outcomes that *can*
move are detectable at all.

## Minimum detectable effect

Derived from the measured baseline **before** any threshold was written, as E-002's follow-up 6
requires — that finding was that E-002 had filled its MDE column with its prediction thresholds.

| Outcome | measured spread it comes from | MDE at `n = 10` per arm | registered before the run? |
|---|---|---|---|
| **P1 `changedFiles` at the required 3** | B2 `n=9` + B3 control `n=10`: **3 files on 19 of 19** | **none upward — the control is at the floor.** Downward (harm) a 4th file on ≥ 5 of 10 gives `p = 0.0325` vs 0 of 10 | yes |
| **P2 `change-focus`** | 40 of 40 scored runs at exactly `1`, four experiments | **none.** Zero variance in the reference population; the anchor is unreachable by construction on this task | yes |
| **P3 `maintainability` anchor 2** | B3 control **3 of 10** | Fisher 10 v 10 against 3/10: **9/10 → p = 0.0198**, 10/10 → `p = 0.0031`. **8/10 → p = 0.0698, not detectable** | yes |
| P4 `estimatedCost` median | B2 arm median $0.149, range $0.108–$0.167 (ratio 1.54) | **≥ +25 %** on the median | yes |
| P5 `toolCalls` median | B2 arm median 17, range 14–20 | **≥ +5** on the median with non-overlapping quartiles | yes |
| duration | B2 arm range 70 s – 3 790 s (ratio 54) | **≥ +40 %** on the median *and* no sleep contamination | yes |

**A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as
refuted.**

**Two of the three gate outcomes have an MDE of `none`.** That is the honest state of this
instrument on this task and it is on record before the first run, not offered afterwards as an
explanation for a null.

### Amended 2026-09-05, after the step-5 preflight and BEFORE the first batch run

**The preflight contradicted P1's mechanism sentence, and the sentence is wrong.** The row above
says `changedFiles` is *"the required 3 on 19 of 19 controls and all three are forced by
acceptance criteria 3, 4 and 5, so no passing diff is smaller — detectable only as HARM."* The
count is right and the reason is not.

| Claim in the registered row | Status | Evidence |
|---|---|---|
| 3 files on **19 of 19** controls | **holds** | `EXP-B2-BASELINE-CLAUDE` 9 of 9 and `EXP-B3-CONTROL-CLAUDE` 10 of 10, all at 3 |
| the three are **forced** by the acceptance criteria | **FALSE** | **11 of 88 passing BE-003 runs changed 2 files**, and the evaluator passed every one at 7 of 7 criteria |
| **no passing diff is smaller** | **FALSE** | `EXP-B3-INSTRUCTIONS-CLAUDE`: **4 of 10 passing runs** changed 2 files, same task, same model, same evaluator. The step-5 **control** did it too |

**What the third file is.** Every 2-file passing run is a run that wrote **no test file**. B3's
control wrote one on 10 of 10; B3's instruction arm on 6 of 10; the step-5 treatment wrote one
(3 files) and the step-5 control did not (2 files). So the floor is **2, not 3**, and the gap
between them is a test, not focus. A treatment that produced 2-file diffs would not be more
focused; it would have stopped writing tests, which `test-quality` carries 25 rubric points for
and which decision-rule row 3 already covers.

**What does not change.** The registered threshold for row 1 — a 4th file on ≥ 5 of 10, `p <
0.05` vs 0 of 10 — is **untouched**, and P1's direction and magnitude stand as registered. The
prediction is not edited. What is corrected is a sentence about the task that was stated more
strongly than the data supported, found before the batch rather than after it.

### P6, registered here, before the first batch run

**Direction.** The treatment arm writes a test file **at least as often** as the concurrent
control. **Magnitude.** Detectable at this `n` only at **≥ 5 of 10 versus 0 of 10**
(`p = 0.0325`); 4 of 10 versus 0 of 10 is `p = 0.087` and is **NOT DETECTABLE**, which is said
now rather than after the count. **Mechanism.** The overlay's mission and completion rules
require tests and verification before finishing, and BE-003's acceptance criteria demonstrably
do not force one — so this is a place the overlay's L3 prose could actually move a measured
outcome, in a task where two of three gate outcomes cannot move at all.

**This is blocked_on_author item B, declared first for once.** That item recorded 4 of 10 treated
runs writing no test against 0 of 10 controls at `p = 0.087` and said it *"was never a registered
outcome, so it is not a result"*, and that making it one needs the outcome declared before the
run. It is now declared before the run. It also says it needs `n ≥ 20` per arm; **this batch is
`n = 10`, so a null here settles nothing** and is reported as not detectable, not as absence.

`Registered by Opus 5 (claude-opus-5), autonomously, 2026-09-05, after the §4 step-5 preflight
(runs 506e41ff treatment, 15c14398 control) and before any EXP-B4-AGENT-BOUNDARY run existed;
the author did not review before the run. Re-derive with the changedFiles query over
GET /api/runs joined on evaluation.exitCode == 0.`

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` version `1.0.0` decides correctness — exit 0 or the
run is not scored. `tools/check-run-gate.sh` enforces that before any sheet is written. Quality
among passing runs is `backend-quality.yaml` v2, sha `396e1799eb2b`, scored by `codex-score.sh`
(the registered number) with `opencode-score.sh` as the second reader on the same run ids.

## Exclusions, registered before the data

1. A run whose evaluator exit code is not 0 is not scored. It is **reported**, per arm, never
   silently dropped — an arm that fails the gate more often is a result.
2. A run spanning a machine sleep has its **duration** excluded, not the run
   (§4 step 6). Detected with `pmset -g log`, as stop 9 did for `toollist-05` and `toollist-07`.
3. A run terminated by the operator, or by a session limit, is excluded with its count reported.
   **Recorded here literally rather than by analogy** — validator pass 10 noted that stop 9
   applied this category to an operator-side kill it did not literally name.
4. A run whose `init.tools` does not equal the overlay's `tools:` line is **void, and voids the
   batch** — row 0a is a redesign condition, not a per-run exclusion.

## Decision rule, fixed before the run

Applied **in order**, stopping at the first row that fires.

| # | Condition | Verdict |
|---|---|---|
| 0a | any treatment run's `init.tools` ≠ the overlay's `tools:` line | **VOID** — redesign, no verdict |
| 0b | the two arms differ in anything but the overlay and `--agent` | **VOID** |
| 1 | a 4th file on ≥ 5 of 10 treatment runs, `p < 0.05` vs 0 of 10 | **REJECT** — the boundary made the diff *less* focused |
| 2 | `maintainability` anchor 2 on ≥ 9 of 10 treatment runs, `p < 0.05` | **KEEP** — v1.0 promotes |
| 3 | evaluator pass rate lower in the treatment arm | **REJECT** — a boundary that costs correctness is not a boundary worth having |
| 4 | cost ≥ +25 % **and** no outcome improved beyond its MDE | **REJECT** |
| 5 | everything lands inside its MDE | **INCONCLUSIVE, and the gate is answered `no` on the evidence available** — with §5's statement that two of three gate outcomes were unmeasurable on this instrument *before* the batch |

**Row 5 is the expected outcome and saying so now is the point.** A rule written after seeing an
undramatic result is not a rule.

## Threats to validity, registered before the run

1. **The compound treatment.** Overlay and `--agent` move together, so nothing here attributes an
   effect to a section of the file. Named as compound above; not a defect, a scope.
2. **`--agent` is a between-arm difference in the launch, not only in the worktree.** The control
   is a plain `claude -p`, the treatment is `claude --agent … -p`. A subagent session may differ
   from a main session in ways beyond its tool list — context handling, system-prompt assembly —
   and **this experiment cannot separate those from the overlay's content.** The `init` record is
   captured on every run so the difference is at least *visible* afterwards.
3. **`agentHash` is null on both arms.** The instrument has no field for this treatment class.
4. **The gate's own outcome is unmeasurable in the direction it asks.** The largest threat to
   B4's *conclusion*, and it is a property of the task-plus-rubric pair, not of the agent.
5. **A single machine, a single day, one runtime version.** As every stop in this track.
