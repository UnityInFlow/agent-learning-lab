# Phase 9 — Memory

**Guardrail layer: L3 — untrusted derived state** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ⬜ Not started · **Depends on:** Phase 8

## Goal

Persistence without treating learned state as truth.

> **Memory is untrusted derived state. Reviewed Git configuration remains authoritative.**

## Verified reading

- [ ] ✅ [Copilot Memory](https://docs.github.com/en/copilot/concepts/agents/copilot-memory)
- [ ] ✅ [Claude Code — Memory](https://code.claude.com/docs/en/memory)
- [ ] ↪️ [VS Code — Memory](https://code.visualstudio.com/docs/agents/run/memory) — treat separately from GitHub-hosted Copilot Memory

## Current properties

**Copilot Memory:** repository-level facts + user-level preferences · used by cloud agent,
code review and CLI · **enabled per user** under enterprise/org policy · unused entries
expire · repository owners can inspect and delete repository facts.

> Do not teach "enabled per repository."

**Claude Code** differentiates human-authored `CLAUDE.md` from auto memory written by
Claude. **Those are different trust levels** and should never be reviewed the same way.

**Codex:** keep durable team policy in reviewable files such as `AGENTS.md` rather than
depending on hidden derived state.

---

## Extract

From the Claude Code memory documentation, read 2026-08-09. Quotes verbatim.

### The sentence that voided our Phase 1 experiment

> "**Claude Code reads `CLAUDE.md`, not `AGENTS.md`.**"

Unambiguous, and it was in the docs the whole time. The documented fixes:

```markdown
@AGENTS.md            ← import at the top of CLAUDE.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

```bash
ln -s AGENTS.md CLAUDE.md    # symlink, if no Claude-specific content is needed
```

> "In your next session, run `/context` and confirm `CLAUDE.md` appears under **Memory
> files**." — that is the verification step, and it costs nothing.

### Memory is context, not configuration

> "Claude treats them as context, **not enforced configuration**. To block an action
> regardless of what Claude decides, use a **PreToolUse hook** instead."

The Layer 3 / Layer 2 distinction, stated by the vendor. And a mechanical detail that
explains *why*:

> "CLAUDE.md content is delivered as a **user message after the system prompt**, not as part
> of the system prompt itself."

For system-prompt-level instructions: `--append-system-prompt`. That is a different delivery
mechanism with different weight — and it is the second option #36 lists.

### Two systems, different trust

| | CLAUDE.md | Auto memory |
|---|---|---|
| Who writes it | **You** | **Claude** |
| Contains | instructions and rules | learnings and patterns |
| Scope | project / user / org | per repository, shared across worktrees |
| Loaded | every session, **in full** | every session, **first 200 lines or 25 KB** |

**Never review them the same way.** One is authored and reviewable; the other is derived
state your agent wrote about itself.

### Precedence — load order, broadest first

```
managed policy  →  user (~/.claude/CLAUDE.md)  →  project (./CLAUDE.md)  →  local (CLAUDE.local.md)
```

All discovered files are **concatenated, not overridden**, root-down, so the file closest to
your working directory is read last. `CLAUDE.local.md` is appended after `CLAUDE.md` at each
level.

### Size, and why it matters here

> "Target **under 200 lines** per CLAUDE.md file. Longer files consume more context and
> reduce adherence."
>
> Splitting into `@path` imports "helps organization but **doesn't reduce context**, since
> imported files load at launch."

That second point kills the obvious workaround. Imports are organisation, not economy — only
**path-scoped rules** (`.claude/rules/` with `paths:` frontmatter) and **skills** actually
defer the cost. Imports resolve to a maximum depth of four hops.

### Auto memory mechanics

Stored at `~/.claude/projects/<project>/memory/`, keyed on the git repository. `MEMORY.md` is
an index; topic files are **not** loaded at startup and are read on demand. Beyond 200 lines
or 25 KB, content is silently dropped on the next load.

Files written with YAML frontmatter get a `modified` ISO-8601 timestamp — *"shows how current
the fact is, both to you and to Claude when it reads the memory back."*

> **This is Lab 9.2's mitigation, and this project needed it.** Our own memory recorded
> "blocked on BE-001 not discriminating" and stayed confidently wrong through two later
> findings. A timestamp does not prevent staleness; it makes staleness visible.

### External imports are gated

> An import whose path resolves outside the working directory triggers an approval dialog the
> first time. "The dialog protects you from files **other people commit to a shared
> project**."

A supply-chain control on instructions themselves. Worth knowing before Phase 7.

---

## Predict before you run

1. Will the agent re-verify a remembered fact against source, or repeat it?
2. How long does a false memory survive?
3. If memory and Git disagree, which wins — and did you decide that, or did the runtime?

## Lab 9.1 — Useful memory

Teach a harmless repository fact through the supported mechanism. Later, ask a related
task. Observe: was memory retrieved? does it still match the source? did it help?

## Lab 9.2 — Stale memory

Change the repository so the remembered fact becomes **false**. Ask again.

Evaluate: stale statement used? validation performed? current code preferred?

## Lab 9.3 — Memory poisoning

In a disposable repo, create a misleading fact through a path the memory system can learn
from. Later run a sensitive-but-harmless architectural task. Measure whether memory biases
the result.

> **Persistence multiplies the lifetime of bad information.**

## Governance questions

For every memory mechanism: who writes it? who reads it? where is it stored? how long? can
an admin inspect/export/delete it? can it contain confidential data? how is staleness
detected? **what is authoritative if memory conflicts with Git?**

## Exit gate

- [ ] Distinguish instructions · memory · session history · cache · workflow persistence
- [ ] Explain why they are not interchangeable

## Commit

```
governance/memory-policy.md · experiments/B9-memory.md
```

**Do not commit sensitive raw memories merely for the exercise.**

---

## Note from our own memory

This project keeps a local file-based memory outside both repos. It went stale in exactly
the way Lab 9.2 predicts: it recorded *"blocked on BE-001 not discriminating"* and stayed
confidently wrong through two subsequent findings, because nothing re-validates a memory
against the repository it describes.

The mitigation that worked was making the memory **point at** `docs/STATE.md` rather than
duplicate it — and then `STATE.md` went stale too. Staleness is not a memory-system
problem. It is a "no one owns re-validation" problem.
