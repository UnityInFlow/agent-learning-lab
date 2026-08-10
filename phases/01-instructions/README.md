# Phase 1 — Custom instructions

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ❌ Attempted, invalidated · **Blocked by:** `agent-observatory` #36, #35, bug #7

## Goal

Learn when always-loaded guidance helps, and when it wastes context or contradicts itself.

## Verified reading

- [ ] ✅ [Copilot — Custom instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support)
      — **the authority.** Which file works on which surface
- [ ] ✅ [Copilot — Customization cheat sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet)
- [ ] ✅ [Copilot CLI — Add custom instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
- [ ] ↪️ [Codex — AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
      — hierarchical discovery; **verify precedence from the live page**
- [ ] ✅ [Claude Code — Memory & instructions](https://code.claude.com/docs/en/memory)
- [ ] ✅ **[Claude Code — the `#agentsmd` section](https://code.claude.com/docs/en/memory#agentsmd)**
      — read this one twice. It is the fact that invalidated our experiment

## The file landscape

| Runtime | Reads |
|---|---|
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/**/*.instructions.md`, `AGENTS.md` |
| Codex | `AGENTS.md`, hierarchical, project + user level |
| Claude Code | **`CLAUDE.md`** · imports `AGENTS.md` only via `@AGENTS.md` · `.claude/rules/` for modular rules · `paths` frontmatter for path scoping |

Concise instructions are explicitly recommended. This is not style advice — see Lab 1.3.

---

## Extract

From the Copilot custom-instructions support matrix, read 2026-08-09.

### The seven file types

```
.github/copilot-instructions.md              repository-wide
.github/instructions/**/*.instructions.md    path-specific
AGENTS.md
CLAUDE.md
GEMINI.md
~/.copilot/copilot-instructions.md           personal, CLI only
~/.copilot/instructions/**/*.instructions.md personal path-specific, CLI only
```

On GitHub.com and JetBrains, personal instructions live in **account settings**, not files.

### Support by surface

| File | GitHub.com | VS Code | Visual Studio | JetBrains | Eclipse | Xcode | **Copilot CLI** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `copilot-instructions.md` | ✓ all | ✓ all | ✓ all | ✓ all | ✓ all | ✓ all | **✓** |
| `*.instructions.md` | ✓ agent, review | ✓ chat, agent | ✓ chat | ✓ all | ✓ agent | ✓ all | **✓** |
| `AGENTS.md` | ✓ review | ✓ chat, agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |
| `CLAUDE.md` | ✓ agent | ✓ agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |
| `GEMINI.md` | ✓ agent | ✓ agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |

### Two things worth stopping on

**1. Copilot CLI reads `CLAUDE.md`.** Every file type, every column, ✓ for the CLI.

That is a design opportunity this project has not used. A single `CLAUDE.md` is read natively
by **both** Claude Code and Copilot CLI — which means a cross-runtime instruction experiment
can hold the *file* constant instead of maintaining two adapters and hoping they are
equivalent. `agent-observatory` #36 has been treated as "port `AGENTS.md` to `CLAUDE.md` for
Claude"; the matrix says `CLAUDE.md` is the portable choice, not the Claude-specific one.

**2. Visual Studio supports none of `AGENTS.md`, `CLAUDE.md` or `GEMINI.md`.** Only the two
`copilot-*` forms. If a team standardises on `AGENTS.md`, Visual Studio users silently get
nothing — no error, no warning. That is the "why didn't my file load" failure the feature
matrix exists to prevent.

### The gap in the documentation itself

> The page contains **no statement about precedence, ordering, or how multiple instruction
> files combine**, and **no nesting or hierarchy rules**.

Verified by reading it. That is a real hole, not an oversight in this extract.

Compare Claude Code, which documents precedence explicitly — managed policy → user →
project → local, concatenated root-down, `CLAUDE.local.md` appended last. For Copilot you
would have to **measure** it.

> **That is a lab.** Put contradictory rules in `copilot-instructions.md` and `AGENTS.md`, run
> the benchmark, and see which one wins. Undocumented precedence is exactly the kind of thing
> an instrument like yours exists to establish.

---

## Predict before you run

1. Does adding one verification rule raise or lower token count? By how much?
2. Will the rule be followed **every** time, or some fraction?
3. Will any agent *claim* tests passed without running them?
4. What is the smallest instruction file that changes measured behavior?

## Lab 1.1 — One measurable instruction

Do not begin with a 150-line standards file. Add **one** rule that your benchmark
previously violated in at least some runs.

```markdown
# Repository rules

- After changing Kotlin production code, run the relevant Maven tests before
  declaring the task complete.
```

Run 5 repetitions. Compare B0 vs B1.

## Lab 1.2 — Path-scoped instruction

```markdown
---
applyTo: "**/*.kt"
---
- Prefer constructor injection.
- Do not use `!!`.
```

Create one Kotlin task and one Markdown-only task. The Kotlin task should receive the rule;
the unrelated one should not pay the same cost — **where the surface supports scoped
loading.** Check the support matrix before concluding the agent ignored you.

## Lab 1.3 — Bloated-instructions failure

An intentionally bad branch: repeated rules, irrelevant framework docs, contradictory
rules, examples copied wholesale. Run the benchmark. Measure tokens, rule adherence,
completion, mistakes. Then revert.

This teaches **context economics** better than any lecture.

## Exit gate

- [ ] What deserves always-on context?
- [ ] What belongs in a skill instead?
- [ ] What is path-scoped?
- [ ] Which Copilot surfaces actually support `AGENTS.md`?
- [ ] Why is an instruction not enforcement?
- [ ] **Can I prove the instruction entered the model's context on a given run?**

That last one is not in the curriculum. It is here because we failed it.

## Commit

```
AGENTS.md · .github/copilot-instructions.md
.github/instructions/kotlin.instructions.md · CLAUDE.md
experiments/B1-instructions.md
```

---

## What we got wrong here

### We measured a file sitting on disk

`EXP-BE002-AGENTSMD-V3` ran a clean 10 + 10 and concluded `INCONCLUSIVE`:

| | B0 baseline | B1 instructions |
|---|---:|---:|
| median cost *(primary)* | $0.1897 | $0.1654 (−12.8%, p=0.04) |
| median tool calls | 19 | 15 |
| pass rate | 80% | 100% |

Every metric moved the same way, and none of it cleared the 24% bar registered before the
B1 arm existed. Then the audit found it: **the treatment was placing `AGENTS.md` in the
repository, and Claude Code reads `CLAUDE.md`.** No `@AGENTS.md` import, no
`--append-system-prompt-file`. Roughly $4 and twenty runs comparing "file present" with
"file absent".

The result is not wrong so much as **not about instructions**.

> **Assert that the independent variable reached the agent.** Not that you wrote it — that
> it arrived. A preflight check that fails loudly costs one assertion and would have caught
> this before the first run.

Deliver the treatment through a mechanism the runtime documents, hash the content, record
the hash as part of the treatment, and run the control through the same isolated harness
with the treatment absent. Tracked as `agent-observatory` **#36**.

### One prediction was specific, mechanistic, and wrong

We predicted BE-001's `jakarta.validation` convention would push the agent off BE-002's
error envelope and produce contract failures (F02). **Zero F02 in either arm.** We also
predicted cost would rise; it fell, and so did cache creation.

One of four predictions held. That is the value of writing them down — an unrecorded
prediction is always retroactively correct.

### The environment was never controlled

Those runs loaded ~21 hooks, 2 plugins and 3–4 MCP connections from the local user
environment, **varying between runs**, while the protocol claimed only the treatment
varied. Tracked as **#35**. Use `--bare` and pin exact model IDs.

## Before re-running

1. **#36** — deliver the treatment through `CLAUDE.md` + `@AGENTS.md` or
   `--append-system-prompt-file`; assert it loaded
2. **#35** — `--bare`, pinned model IDs, environment fingerprint, fail analysis on drift
3. **bug #7** — non-interactive build, and permission-blocked runs classified as
   infrastructure (F13/F15), not incorrect code
4. Preregister `EXP-BE002-INSTRUCTIONS-V4`, 10 + 10, **commit the registration before the
   first run** — check the timestamps, we got this wrong once too
5. Budget ~$4.10
