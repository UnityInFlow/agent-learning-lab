# B2 — Plain-prompt baseline

**Track A first:** [Phase 0A](../00a-agent-mechanics/) + [Phase 0B](../00b-observatory/)
**Version:** — (pre-v1.0)
**Spine position:** 4 of 28 · after [B1](../b01-experiment-contract/) · before [Phase 1](../01-instructions/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b2).
> Everything else is yours to fill.

---

## Goal

<!-- TODO: this step builds nothing. The capability that appears is
     a number everything downstream is compared against. Say that in
     one sentence, and say what makes it trustworthy. -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §16.1 keep constant
     BUSINESS-REQUIREMENTS §16.2 repeat runs
     BUSINESS-REQUIREMENTS P2    one main variable per experiment
     BUSINESS-REQUIREMENTS P3    same starting conditions -->

### External — the technique

<!-- TODO. Note: isolation is settled as of 2026-08-10, and not the way
     the curriculum first assumed.

     --strict-mcp-config + --disable-slash-commands do NOT stop hooks:
     21 hooks and 2 plugins loaded on all 20 runs of CLAUDEMD-V2.
     --bare does stop them, and is still the wrong flag — it also
     disables CLAUDE.md discovery, and does not authenticate on a
     subscription account at all.

     Use --setting-sources project (runner: --isolate-user-settings).
     Verified: 0 hook executions, CLAUDE.md still loads, auth works.
     EXP-BE002-NOHOOKS sized what it buys: hooks were ~13% of every run,
     sitting on both arms almost equally. -->

## Extract

<!-- TODO -->

## Build

**Build:** nothing. Measure.

No agent, no skill, no hook, no instructions. Task prompt only. Same provider, same **exact
model ID**, same commit, same verification.

**Three runs minimum, five preferred.** One run is a story.

**Run it isolated** — `--setting-sources project --strict-mcp-config` for Claude (the runner
exposes this as `--isolate-user-settings`), `--no-custom-instructions` for Copilot. Without
that you are measuring your ~21 local hooks, not the baseline.

**Record per run:** which files it inspected · did it understand the architecture · did it
verify its own work · what needed correction · which metrics were even available.

> Everything after this is measured against B2. If B2 is sloppy, nothing downstream means
> anything.

## Predict before you run

<!-- TODO: four predictions, written before the first run.
     Track A 0A's questions are the model. Candidates:
     will it inspect before editing · will it run verification unprompted ·
     will it claim completion without evidence · which metrics will be absent. -->

## Lab B2.1 — establish the baseline

<!-- TODO: ≥3 runs, ideally 5. Same commit, same exact model ID.
     Report median and range. Never an average alone. -->

## Deliberate failure

<!-- TODO: run one deliberately un-isolated (hooks and plugins on) and
     compare. That number is the size of the contamination you are
     avoiding, and it is worth knowing rather than assuming. -->

## Exit gate

**From the build track:** ≥3 run folders with diffs, verification results and completed rubrics ·
a baseline report with **median and range**, never an average alone.

**Plus, for this to count as a learned phase:**

<!-- TODO: what did you learn about the plain agent that you did not
     know from Phase 0A? -->

## Commit

<!-- TODO -->
