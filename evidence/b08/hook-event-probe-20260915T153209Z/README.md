# Which Bash hook events this runner actually delivers — a free mechanism probe

**Run 2026-09-15, before anything of stop 17's overlay was built and before any benchmark
run.** Three `claude -p` sessions, no observatory runner, no benchmark, no evaluator, no
money beyond a few cents of Haiku. Nothing here is a benchmark result and nothing here
enters `n`.

**Why it was run rather than assumed.** The stop-17 design put two jobs on `PostToolUse`
on `Bash` — record the repair fingerprint, and (before its first correction) enforce the
limit — and the workbook's own §Design says the one thing it had *not* measured was
*"that a `PreToolUse` hook on `Bash` is reached at all in this runner's configuration.
Stop 16's arm H proved the mechanism on `Edit|Write|NotebookEdit`, not on `Bash`, and the
matcher is the variable."* It sent that to §4 step 5 preflight. A preflight costs a
benchmark run; this costs a cent, so it was done first.

## Setup

A throwaway project directory outside every tracked tree, with one hook script registered on
both `PreToolUse` and `PostToolUse` with `matcher: "Bash"`. The script appends its entire
stdin to a file and exits 0 — except in probe 3, where it also exits 2 on any command
containing `BLOCKME`.

The launch flags are **the runner's**, copied from `run-agent.sh:757-777` rather than chosen
here, because the flag set is the thing under test:

```
--permission-mode acceptEdits --strict-mcp-config
--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
--disable-slash-commands --setting-sources project
--model claude-haiku-4-5-20251001
```

`claude` **2.1.272 (Claude Code)** — the same version E-018/E-019 register as the controlled
variable, read from `claude --version`, not assumed.

## What happened

Thirteen `Bash` tool calls across three sessions. The table is derived from the saved
payloads in this directory by `jq`, not written from memory:

| Bash call outcome | n | `PreToolUse` fired | `PostToolUse` fired |
|---|---|---|---|
| exited 0 | 6 | 6 | **6** |
| exited non-zero | 6 | 6 | **0** |
| blocked by the hook's own `exit 2` | 1 | 1 | 0 — **and the command never ran** |

Two-sided Fisher on the 6/6 vs 0/6 split: **p = 0.0022**.

## The three findings

**1. `PreToolUse` on `Bash` is reached.** 13 of 13 calls, including the ones that failed and
the one that was blocked. The workbook's open assumption is discharged **without spending a
preflight run on it**, and §4 step 5 is freed to prove the thing that is actually
run-specific — that the overlay arrives and writes its file inside a real worktree.

**2. `PreToolUse` exit 2 genuinely blocks a `Bash` call.** The blocked command was
`touch BLOCKME-blockme-ran.txt`; the file does not exist afterwards. Stop 16 proved exit 2
blocks on `Edit|Write|NotebookEdit`; this proves it on the `Bash` matcher, which is the
matcher the repair limit needs. **L2 on `Bash` is now measured, not inherited.**

**3. `PostToolUse` on `Bash` fires if and only if the command exited 0 — and this breaks the
design that was about to be built.** Two consequences, and the second is the useful one:

- **A `PostToolUse` recorder cannot see a failure.** It never fires for one. The
  `repair-record.sh` the design specified would have computed a fingerprint from failing
  commands it is never handed, and would have reported `totalRepairAttempts: 0` on every run
  of both arms — a counter that reads zero because it is blind, presented as a counter that
  reads zero because the model does not fail. That is this project's house failure mode
  exactly: *a control reporting success over a scope smaller than it claims.*
- **`tool_response` carries no exit code.** Its keys are
  `{stdout, stderr, interrupted, isImage, noOutputExpected}`. So even on the calls where the
  event does fire, the payload cannot classify the outcome.
- **But the event's presence is itself the signal the payload lacks.** `PostToolUse` fired
  for every success and for no failure, so *"`PostToolUse` fired for fingerprint X"* means
  *"X succeeded"*. It is a **success oracle**, and it is the only success signal available
  to a hook in this runtime.

## What this changed, before anything was built

The corrected design is in `phases/b08-run-state-repair-limits/README.md#design`, under the
second dated correction. In one line: **the recorder moves to `PreToolUse`**, where every
attempt is visible, and **`PostToolUse` keeps its place with a different job** — clearing a
fingerprint's consecutive-attempt counter, which is the only thing it is able to say.

**This is the second time in this one stop that a job was placed on `PostToolUse` that
`PostToolUse` cannot do.** The first — enforcement — was caught by re-reading Phase 5A's own
extract, which had already written the answer down. This one could not be: nothing in these
three repositories had ever observed which Bash events arrive. That is the argument for the
probe, and it is the reason this directory exists.

`Probed and written by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-15.`
