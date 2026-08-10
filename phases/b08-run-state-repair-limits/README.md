# B8 — Run state, repair limits, completion contract

**Track A first:** [Phase 5B](../05b-verification-selfhealing/) · **Layer 2**
**Version:** **v1.1**
**Spine position:** 17 of 28 · after [Phase 5B](../05b-verification-selfhealing/) · before [Phase 6A](../06a-code-intelligence/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b8).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.6 completion-contract.md
     BUSINESS-REQUIREMENTS NFR-009 graceful degradation
     BUSINESS-REQUIREMENTS Risk: agent grades itself too positively
     EFFICIENCY-SELF-LEARNING §  v1.1 reliability and observability -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. The classification point below is not theory for us — it is
     harness bug #2, which returned in four costumes and cost five void
     experiments. Extract the passage that makes BLOCKED ≠ FAILED explicit. -->

## Build

**Build:** the three things that turn v1.0's prompts into enforcement.

**1. Persistent state** — `.agent/run-state.json`: phase, goal, affected files, last failure,
`repairAttemptsForCurrentFailure`, `totalRepairAttempts`. It must survive an interrupted
session.

**2. Hard repair limits**, enforced by hook or wrapper, never by prompt:

```
fingerprint = failure class + command + normalized primary error + affected module
same fingerprint  ≤ 3        total ≤ 7        on exceed → BLOCKED, not FAILED
```

**3. Completion contract** — `DONE` confirmed by a script, not asserted by the agent.

**And the classification fix:** BLOCKED ≠ FAILED. Permission blocks, quota exhaustion and
infrastructure faults are **infrastructure**, never incorrect code. This is harness bug #7,
and it currently voids every cross-model comparison you run.

> **From the observatory, 2026-08-10:** the phrase-matching approach to this failed four
> times — quota→F03, permission block→F05, dropped connection→F03, session limit→F03. The
> rule that finally worked needs no vocabulary: *an agent that changed no file and called no
> tool did not attempt the task.* And `claude_code.tool.blocked_on_user` is a real span that
> fires on a permission gate, so the runtime will tell you directly. See issue #47.

## Predict before you run

<!-- TODO -->

## Lab B8.1 — measure against v1.0

<!-- TODO: the gate asks for *no regression*, which is a different test
     from an improvement. Say in advance what regression you would accept. -->

## Deliberate failure

<!-- TODO: interrupt a run mid-repair and confirm the counters survive.
     Then force the same failure four times and confirm it BLOCKS rather
     than looping. -->

## Exit gate

**From the build track:** counters persist across interruption · limits technically enforced ·
a blocked run produces a clear machine-readable result · **no regression against the v1.0
benchmark.**

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
