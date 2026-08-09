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

- [ ] ✅ [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
  > *What is the **evaluator-optimizer** pattern, and where does it stop?*

  One LLM generates, another critiques, iterate. The article does not say when to stop
  iterating — that is what this phase is about.
- [ ] ✅ [Claude Code — How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works)
  > *Where does verify sit, and what triggers a retry?*
- [ ] ✅ [Claude Code — Hooks](https://code.claude.com/docs/en/hooks)
  > *Which event can carry a persistent counter across tool calls?*
- [ ] Your own `BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §5
  > *Read your own design. It is better than most published material on this.*

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
