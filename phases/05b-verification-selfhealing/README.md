# Phase 5B — Verification loops, bounded self-healing, and completion

**Guardrail layer: L2 — deterministic checks on the agent's claims.**
**Status:** ⬜ Not started · **Depends on:** Phase 5A · **Reference:** [`GUARDRAILS.md`](../../GUARDRAILS.md)

## Goal

What happens **after** the agent fails, and what happens when it says it's done.

This phase does not exist in the original curriculum. It is here because your own backend
agent v1 already designs it — failure classification, `MAX_REPAIR_ATTEMPTS_PER_FAILURE=3`,
`MAX_TOTAL_REPAIR_ATTEMPTS=7`, BLOCKED results — and nothing teaches it.

Two claims an agent makes that must never be taken at face value:

> *"I fixed it."* — Phase 5B.1–5B.3
> *"I'm done."* — Phase 5B.4

## Verified reading

- [x] ✅ [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
  > *What is the **evaluator-optimizer** pattern, and where does it stop?*

  One LLM generates, another critiques, iterate. The article does not say when to stop
  iterating — that is what this phase is about.
- [x] ✅ [Claude Code — How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works)
  > *Where does verify sit, and what triggers a retry?*
- [x] ✅ [Claude Code — Hooks](https://code.claude.com/docs/en/hooks)
  > *Which event can carry a persistent counter across tool calls?*
- [x] Your own `BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §5
  > *Read your own design. It is better than most published material on this.*

## Extract

*Written at spine stop 16, 2026-09-11, from the four sources above, each opened for this stop.
Four questions were asked; three of the four answers are **an absence**, and the absences are
the useful part.*

### The evaluator-optimizer loop has no published stopping condition

*Building effective agents* describes the pattern as *"one LLM call generates a response while
another provides evaluation and feedback in a loop"*, and says it fits where *"clear evaluation
criteria exist"* and *"iterative improvements demonstrably add value"*.

**It states no stopping condition for the pattern.** The only thing it says about stopping is
generic to agents — include *"stopping conditions (such as a maximum number of iterations)"* to
*"maintain control"* — and it is not attached to the evaluator-optimizer section.

So the workbook's premise above survives contact with its source: the bound is not in the
literature, it is yours to invent, and *"iterate until the evaluator is satisfied"* is a loop
with no exit written by someone who has not paid for one.

### "Verify" is a named phase, and nothing published says what makes the loop go round again

*How Claude Code works* names three phases — *"gather context, take action, and verify
results"* — and immediately weakens them: *"these phases blend together."* Verification is
described only as tool use, *"running tests to check its work."*

**No retry trigger is stated.** The nearest sentence is *"Claude decides what each step requires
based on what it learned from the previous step, chaining dozens of actions together and
course-correcting along the way."* That is a description of a model's discretion, not of a
mechanism.

This matters more than it looks. A repair limit bounds a loop; if nothing documented says what
starts the next iteration, then **the loop being bounded is not observable from the outside** —
you cannot count iterations of a thing whose boundary nobody defined. Our own instrument has to
define the iteration before it can limit it, and that definition is ours, not the vendor's.

### No hook event carries a counter. The counter is a file, and `session_id` is its key

The workbook asks *"which event can carry a persistent counter across tool calls?"*. The honest
answer from the reference is **none of them**:

> *"No built-in persistence mechanism is described for hooks across invocations. Each hook
> invocation receives independent JSON input. To maintain state: write to files in the
> scratchpad directory or project."*

What the hooks reference does give is the **correlation key** and the **place to put it**: every
hook receives `session_id`, which *"remains constant throughout a session"*; most receive
`transcript_path`; all receive `cwd`.

So Lab 5B.3's instruction — *"limits that live in a prompt are suggestions; persist them"* — is
understated. **A limit that lives in a hook is also a suggestion unless that hook writes it
down**, because the hook is reinvoked with no memory of itself. Applying the workspace layer
rule in order: a counter held in a hook's own process is L3 wearing L2's clothes; a counter on
disk, read and incremented by a hook that exits 2, is L2.

And the exit-code semantics are the enforcement:

> *"Exit 2 **always blocks** regardless of JSON output"* — blocking tool calls on `PreToolUse`
> and **preventing stopping on `Stop`**.

`Stop` + exit 2 is the completion contract's teeth (Lab 5B.4): the agent does not get to end the
turn while a check says it is not done. Everything else is advice.

### The two events this stop actually needed, and obs#47 does not know they exist

The hooks reference defines **`PermissionRequest`** — fires *"when a tool call needs a permission
decision"*, and a hook *"can return a `permissionDecision` of `allow` or `deny`"* — and
**`PermissionDenied`**, which fires *"when auto mode denies a tool call."*

`agent-observatory` **#47** is open on exactly the gap these two would close: *"the block span
reports that a tool was blocked, not why — `decision` and `source` both come back `unknown`."*
Two named lifecycle events carry the decision and the source, and the runner subscribes to
neither. That is this stop's design input and it is recorded here as a reading result, before
any of it is built.

**It is not a fix on its own, and the distinction is the whole lab.** `PermissionDenied` fires
when a tool call is *refused*. obs#47's original failure was an agent that was never refused
anything — it *asked* and stopped, and *"`permissionDenials` was 0 throughout: nothing was
refused, so no telemetry showed it."* An event that fires on refusal cannot see an abstention.
Any classifier built on these two events is therefore **complete for the denial case and blind
to the abstention case**, and saying so before building it is cheaper than discovering it after.

### Our own design specifies the limits and leaves out the hard part

`businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §5 (lines 354–488) is more
concrete than anything published above. It fixes the constants — *"attempts for same failure
<= 3"* (`:370`), *"total attempts <= 7"* (`:371`) — defines the fingerprint as *"failure class +
command + normalized primary error + affected module"* (`:374-376`), specifies BLOCKED as
*"stop, emit BLOCKED result, require human decision"* (`:378-381`), and names a fourteen-field
run-state schema (`:365-378`): `schemaVersion`, `runId`, `taskId`, `agentVersion`, `phase`,
`goal`, `affectedModule`, `affectedFiles`, `completedSteps`, `openQuestions`, `lastFailure`,
`repairAttemptsForCurrentFailure`, `totalRepairAttempts`, `verification`.

**And it never says what normalization strips.** It names the component — *"normalized primary
error"* — and stops. The workbook one screen above says *"normalization is the whole
difficulty"*, and the design it is quoting leaves precisely that undefined. A fingerprint whose
normalization is unspecified is not a specification; it is a variable name.

This is the layer rule again, applied to a document rather than a control: fourteen field names
and two integer constants are **L3** until something reads them. Nothing in these repositories
reads this schema today.

### What this stop takes forward

| Read | What it gave | Layer of the thing it describes |
|---|---|---|
| Building effective agents | the pattern, and **no** stopping condition for it | L3 — prose |
| How Claude Code works | `verify` is a named phase; **no** retry trigger defined | L3 — prose |
| Claude Code hooks | `PermissionRequest` / `PermissionDenied` exist; state is a file keyed by `session_id`; `exit 2` blocks and prevents stopping | **L2 when built** — these execute |
| Our §5 design | limits 3 and 7, the fingerprint formula, BLOCKED, a 14-field schema, **normalization undefined** | L3 — nothing reads it |

Only one row of that table can enforce anything, and it is the one this stop's lab is built on.


## The problem

An agent that retries without a bound has two failure modes, and both cost real money:

- **the loop** — same fix, same failure, forever
- **the drift** — each repair makes a change further from the original design, and the
  diff grows until nobody can review it

And an agent that stops has three *different* outcomes your evaluator probably conflates:

```
FAILED      it produced a wrong answer
BLOCKED     something prevented it from answering        ← not the same thing
DONE        it claims success                            ← an assertion, not a fact
```

## Predict before you run

1. Left unbounded, how many repair attempts before your agent gives up on its own?
2. Does the diff get smaller or larger with each repair?
3. When it declares DONE, what fraction of the time does an independent check agree?

---

## Lab 5B.1 — Watch an unbounded loop

Give the agent a task with a failure it cannot fix — a test asserting something the spec
forbids, say. No repair limit.

Record: attempts before it stops, tokens consumed, how the diff evolved, and whether the
same fix was tried twice.

> This is the lab that makes the limits feel necessary rather than arbitrary.

## Lab 5B.2 — Failure fingerprints

A counter alone is too blunt — three attempts at *three different* failures is healthy
progress; three at the *same* one is a loop. From your v1 design:

```
fingerprint = failure class + command + normalized primary error + affected module
```

Build it, then test that it groups correctly:

- same error, different line numbers → **same** fingerprint
- same command, genuinely different cause → **different** fingerprint
- transient infrastructure failure → must not count against the budget

Normalization is the whole difficulty. Timestamps, paths, and object hashes must be
stripped, or every failure looks new and the limit never fires.

## Lab 5B.3 — Bounded repair with persistent state

Limits that live in a prompt are suggestions. Persist them:

```json
{
  "runId": "...", "phase": "VERIFICATION",
  "lastFailure": { "fingerprint": "...", "attempts": 2 },
  "totalRepairAttempts": 5
}
```

Enforce with a hook or wrapper, not with instructions:

```
attempts for same fingerprint <= 3
total attempts               <= 7
```

On exceeding: **stop, emit BLOCKED, require a human decision.** Do not fail. Do not
silently continue.

Then verify the counter survives the thing that matters: a session that is interrupted and
resumed.

## Lab 5B.4 — The completion contract

The highest-value guardrail in this phase, and the one your documented problem list asks
for first — *"declaring completion too early"*, *"judging their own output too positively"*.

`DONE` is not a state the agent may assert. It is a state something else confirms:

- [ ] every acceptance criterion mapped to an implementation
- [ ] build passed
- [ ] required tests passed
- [ ] static analysis passed, no critical findings
- [ ] **no forbidden file changed**
- [ ] summary generated

Checked by a script that is not the agent, whose exit code decides.

Then run the honest experiment: **ask the agent to declare DONE on work that fails the
contract.** Measure how often it claims success anyway. That number is why the contract
exists.

## Lab 5B.5 — Blocked is not failed

Harness bug #7, reproduced deliberately and then fixed.

Run a build-requiring task under `--permission-mode acceptEdits`, headless. The agent
stops and asks for approval with nobody there. Now look at what your evaluator recorded.

> Ours recorded **F05, incorrect code** — for seven of ten runs that changed no production
> file at all. It reported the more cautious model as worse at engineering.

Fix it: classify permission blocks, quota exhaustion, and infrastructure faults as
**infrastructure** (F13/F15), never as incorrect code. Then confirm the fix by re-running
the reproduction, not by reading the patch.

---

## Lab 5B.5 — DESIGN, spine stop 16, 2026-09-11

*§4 step 2. Every artifact labelled with the workspace rule applied **in order**, stopping at
the first yes. Nothing below is built yet and no run has been started.*

### Is this a benchmark-running lab? Yes, and that decides the loop

The prompt's §4 says a Track A stop runs the loop minus steps 3–10 *"unless the lab runs the
benchmark, in which case it is the whole loop."* Lab 5B.5 says *"run a build-requiring task
under `--permission-mode acceptEdits`, headless"* and *"confirm the fix by re-running the
reproduction, not by reading the patch."* Both halves are benchmark runs. **Stop 16 runs the
whole loop and has four session boundaries, not two.**

### What is already true of obs#47, read in the code rather than taken from the issue

| obs#47 acceptance criterion | State on 2026-09-11 | Evidence |
|---|---|---|
| the agent can run the build non-interactively *(requirement 1)* | **already met** | `runner/run-agent.sh:757-760` passes `--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"` |
| a permission-blocked run recorded as infrastructure, not as incorrect code | **not met** | see the one condition below |
| `FAILED`, `BLOCKED` and `DONE` distinguishable in the data model | **not met** | `grep -rl 'measurementStatus\|BLOCKED'` across the observatory returns **only the review hook's own test fixtures** — no runner, API, schema or web hit |
| a test proves a blocked run never enters a registered analysis | **not met** | no such fixture exists |
| the model-tier void written up and the experiment marked invalid | **partly** — written up in `docs/preregistration-exp-be002-model-tier.md`; the 20 runs are still in the store with no invalid marker | API, `EXP-BE002-MODEL-TIER` |

### The gap is one condition, and its narrowness is deliberate

`run-agent.sh:1203` is the only guard that can rescue a blocked run before the evaluator's
verdict is posted:

```
if [[ "$PRODUCED_NOTHING" == true && "${TOOL_CALLS_SEEN:-0}" -eq 0 && ... ]]; then
  ABORT_CLASS="F13"   # "the agent changed no file and called no tool — it never acted"
```

Its own comment says why it is narrow:

> *"It stays narrow on purpose. A run that explored and then stalled has tool calls, so it is
> untouched and keeps counting against its arm — which is what must happen when the thing under
> test is what made the agent hesitate."*

**That reasoning is right and it is exactly what makes it miss obs#47.** The sonnet runs had
**11–12 tool calls** and changed `OrderControllerTest.kt`, so `PRODUCED_NOTHING` was false *and*
`toolCalls` was non-zero. Both conjuncts fail, the run falls through to the evaluator's ladder at
`tasks/BE-003-confirm-shipment/evaluator.sh:377-383`, and is recorded `F05`.

The distinction the guard cannot draw is **who made the agent hesitate** — the treatment, or the
harness. It never looks at why, because it was built to need no vocabulary.

### The fix may not live in the evaluator

The evaluator's ladder is a pure worktree function: `F04` if the build fails, else `F05` if tests
fail, else `F03`, `F02`, `F07`. It has no access to the transcript, the telemetry or the
permission state, so it **cannot** distinguish a block from a wrong answer however it is written.
And moving it is a **§7 halt** under *"any proposed change to what the benchmark or evaluator
measures (an exit-code mapping …)"*.

The sanctioned home is the runner's existing `ABORT_CLASS` override at `run-agent.sh:1363`, which
already rewrites `failureClass` without touching the evaluator. **The fix is an addition to a
mechanism that exists, not a new mechanism.**

### Two facts measured from the store before anything was designed

1. **`F10 permission failure` already exists and is not infrastructure.**
   `docs/metric-catalog.md:110` defines it; `runner/reclassify-run.py:33` sets
   `INFRASTRUCTURE = {"F13", "F15"}`. An `F10` run is therefore still counted against the agent
   and still enters every registered analysis. Across **all 550 runs** in the store there are
   **zero F10 runs** (`F13`=51, `F05`=9, `F07`=5, `F15`=2, `F12`=1, `F03`=1, unclassified=481),
   so admitting `F10` to the infrastructure set would retroactively reclassify **nothing**.
2. **A permission denial is not by itself evidence of a block, and this is the fact that keeps
   the fix honest.** Six of 550 runs have `permissionDenials > 0`. **All six passed**
   (`passed: true`, `failureClass: null`), all six from `EXP-4B-ORCH-OVERHEAD`, with 14–25 tool
   calls each. A classifier keying on `permissionDenials > 0` alone would have converted six
   passing runs into discards.

Fact 2 is the trap this step has to convert, and obs#47 names it itself:

> *"(2) is the safety net for (1) — a permission block silently converted into a passing-looking
> dataset is how this class of bug survives."*

**A reclassifier that over-fires is worse than the bug it fixes**, because the bug shows up as a
suspicious failure rate and the over-fire shows up as nothing at all. The layer that converts it
is **L2**: a `verify-*.sh` fixture set that proves the classifier *refuses* each non-block case,
with those six runs' shape as one of the fixtures.

### And the vocabulary rule the runner already paid for

`run-agent.sh:1186-1192` records what happens when this class of bug is fixed per-phrase:

> *"it was extended for `API Error` and the very next batch died on `You've hit your session
> limit`, a phrase it did not contain. **Sixteen runs recorded F03 'incorrect code' for a billing
> state.** That is the fourth costume of the same bug, and the fourth time it was fixed
> per-phrase instead of per-class."*

So **no transcript text matching.** The classifier keys on counted telemetry events and the
changed-file set, both of which are structural. This is a constraint inherited from the
repository, not invented here.

### What the fix covers, and what it provably does not

This is the part to write down **now**, before building, because it is the part that a
confirmation run will otherwise appear to have settled.

| Case | Signal available today | Covered by this design? |
|---|---|---|
| **denial** — the agent called the tool and the harness refused it | `tool_decision` with `decision != "accept"` → `permissionDenials > 0` (`runner/lib/claude-telemetry.sh:68-70,109`) | **yes** — and only when combined with a changed-file set of zero |
| **abstention** — the agent asked a human and stopped without calling the tool | **none.** No tool call means no `tool_decision`, so `permissionDenials` is 0 — which is exactly what obs#47 observed: *"permissionDenials was 0 throughout: nothing was refused"* | **no** |

**obs#47's own observed failure is the abstention case, and this design does not close it.**
Stating that at design time rather than discovering it after a green confirmation run is the
whole point of writing this section before step 3.

Nor would subscribing to the two hook events the Extract found close it: `PermissionDenied` fires
on a refusal, and `PermissionRequest` fires *"when a tool call needs a permission decision"* — an
agent that never calls the tool triggers neither. The only vocabulary-free signal an abstention
leaves is **that the turn ended with the task unattempted**, which is a completion-contract
question (**Lab 5B.4**), not a permission question. That is registered here as the named
remainder and is **not** built at this stop — §6 forbids a future step's artifacts, and §4 step 4
says build the smallest thing.

### The reproduction, and the risk in it

The agent under test is pinned to `claude-haiku-4-5-20251001` (§2, a controlled variable).
**obs#47's bug needs a cautious agent, and haiku asked for build permission in 0 of 10 runs.**
Reproducing by waiting for haiku to hesitate would likely produce zero blocked runs.

So the reproduction is made **deterministic** instead: the treatment withholds the edit
permission, so the block does not depend on the model's disposition at all.

**Delivery is the channel this repository has already proved**, not a new runner flag: a
`--customization` overlay carrying `.claude/settings.json` with deny rules, read because the
runner passes `--setting-sources project` under `ISOLATE_USER_SETTINGS=1`, and proved per run by
`customization.*Hash` — the same mechanism B7 used to land a `PreToolUse` policy hook on 17 of 17
treated runs with zero leakage into the control. **No runner code changes to reproduce.**

Predicted shape of a reproduction run: `toolCalls > 0` (the agent reads before it is stopped),
`PRODUCED_NOTHING == true`, `permissionDenials > 0` — which escapes the narrow guard on the first
conjunct and lands in the uncovered region.

**The one thing that could invalidate the reproduction, named before it runs:** a deny rule in
`settings.json` may block the tool *without emitting a `tool_decision` event*, in which case
`permissionDenials` stays 0 and the reproduction produces no signal. That is what §4 step 5's
preflight is for, and it is a one-run question. If deny rules emit nothing, the fallback is a
`PreToolUse` hook exiting 2 — B7 proved that channel fires once per `Write|Edit` — and the
difference between the two is recorded rather than papered over, because they are not the same
event and the classifier must say which it keys on.

### Artifacts and their layers

Applying the workspace rule in order — *can the bad value still be written down after the fix?
does something execute and reject it? otherwise L3*:

| Artifact | Layer | Why that layer, by the rule |
|---|---|---|
| `runner/lib/classify-permission-block.sh` — exit-code contract over telemetry + changed files | **L2** | The bad value *can* still be written down (the abstention case is untouched), so not L1. Something executes and rejects it for the denial case: the script's exit code sets `ABORT_CLASS`. |
| `runner/verify-permission-block-classifier.sh` — fixtures proving every exit code, including the six passing denial runs | **L2** | It executes in CI and fails the build. This is the control that converts the over-fire trap. |
| Admitting `F10` to `INFRASTRUCTURE`, or reusing `F13`/`F15` — **decision deferred to step 4** | **L2 if built** | `INFRASTRUCTURE` is read at `analyze-experiment.py:160`, `baseline-report.py:134` and `derive-mde.py:77` — three things that execute. |
| A `BLOCKED` value in the run record | **L3 on its own** | Adding an enum value that nothing validates is the schema-note case the workspace CLAUDE.md names explicitly. It becomes L2 only where the API rejects an invalid value, and that is a separate claim to prove, not to assume. |
| The reproduction overlay (`.claude/settings.json` deny rules) | **L2 as delivered** | It executes — the runtime enforces the deny — and delivery is proved per run by `customization.*Hash`, not by the flag being passed. |
| This design section, the Extract, and every gate clause written in prose | **L3** | Words a reader chooses to follow. |

### The independence check this step owes

Between the reproduction arm and its control exactly one thing moves: the overlay. Confirmed per
run from the run records, not from the flags — `customization.*Hash` set on the treated arm and
`null` on the control, `runtime.model` identical, `runtime.version` identical (the mid-batch CLI
move that ended B7's batch is a live risk and the guard that caught it is still in place), and
`repository.commitSha` identical across both arms.


## Metrics

```
repair attempts · repair attempts per fingerprint · repeated fingerprints
blocked runs · first-pass success · time to green
completion-contract failures after a DONE claim     ← the interesting one
```

## Exit gate

- [ ] Why a repair *counter* is not enough without a fingerprint
- [ ] What my normalization strips, and what breaks if it strips too much
- [ ] Where my repair limit is enforced — and why a prompt is not enforcement
- [ ] The difference between FAILED, BLOCKED and DONE, and where each is recorded
- [ ] How often my agent claims DONE against a failing contract — **as a number**
- [ ] Why an environmental block recorded as a capability failure corrupts every comparison

## Commit

```
.agent/run-state.json schema · scripts/verify.sh · fingerprint tests
findings/B5b-selfhealing.md
```

---

## Why this phase is placed here

It needs Phase 5A's deterministic verification to exist before it can bound anything, and
Phase 4B's workflow phases to have something to return to after a repair. It comes before
Phase 9 because **self-learning must never learn from an unverified repair** — 5B is what
makes "verified" mean something.
