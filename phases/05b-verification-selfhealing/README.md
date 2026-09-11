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
