# B10 — Port the adapter to a second runtime

**Track A first:** [Phase 4A](../04a-agents-permissions/)
**Version:** **v1.2**
**Spine position:** 21 of 28 · after [B9](../b09-knowledge-router/) · before [Phase 7](../07-plugins/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b10).
> Everything else is yours to fill.
>
> ⚠️ **Placement is provisional.** B10's prerequisite (4A) clears at spine position 9, but its
> version tag (v1.2) holds it to position 21 — twelve stops of cleared prerequisite. See the
> open decision in [`build/README.md`](../../build/README.md) about whether prerequisite order
> or version order is authoritative.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.15 adapters/codex/
     BUSINESS-REQUIREMENTS §10.16 adapters/claude-code/
     BUSINESS-REQUIREMENTS P5     portable core and thin adapters
     BUSINESS-REQUIREMENTS G6     remain provider-neutral where practical
     BUSINESS-REQUIREMENTS NFR-004 low provider coupling -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. The claim under test is P5 itself: "portable core, thin
     adapters". This step is the only thing that can falsify it. -->

## Build

**Build:** the same portable agent behind a second provider adapter.

```
adapters/claude-code/     CLAUDE.md + @AGENTS.md or --append-system-prompt-file, subagent, hooks
adapters/copilot/         .github/agents/*.agent.md, .github/hooks/*.json
adapters/codex/           AGENTS.md, subagents, sandbox flags
```

**This is not optional busywork.** Copilot's quota is exhausted on this account, so v1 is
currently unrunnable as written. The port is forced — and it is the only real test of whether
"portable core, thin adapters" was true or just an aspiration.

**Freeze everything else.** Same task, commit, skill, verification, rubric. Change the adapter
and the model, nothing else.

## Predict before you run

<!-- TODO: predict what fraction of the core survives the port unchanged.
     That number IS the test of P5. Write it down before porting. -->

## Lab B10.1 — same agent, two runtimes

<!-- TODO: ≥3 runs per runtime. Note this is a cross-runtime comparison,
     which agent-observatory #47 currently voids — permission blocks
     recorded as incorrect code. Check that issue is closed before you
     trust the numbers. -->

## Deliberate failure

<!-- TODO -->

## Exit gate

**From the build track:** ≥3 runs per runtime · compare quality, correction effort, usage **and
observability capability** · document each provider's limitations · pick primary and fallback.

**Plus, for this to count as a learned phase:**

<!-- TODO: was "portable core, thin adapters" true? -->

## Commit

<!-- TODO -->
