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

---

## Architecture: you already run three memory systems

Before building anything, the decision that matters is **ownership**. Three systems are live
on this machine right now, they overlap, and none of them owns anything definitively — which
is why this project's own memory sat two findings out of date.

| System | Where | Good at | Bad at |
|---|---|---|---|
| **Claude auto memory** | `~/.claude/projects/<project>/memory/` | session preferences, corrections | machine-local, not shared, no query beyond file reads |
| **memtrace** | `~/.memtrace/` — `embed-cache`, `cortex-store` | code symbols, semantic code search, **decision memory** | not a prose corpus |
| **Observatory Postgres** | `postgres:16.6-alpine` | run records, evaluations | knows nothing about knowledge |

### The ownership split to write down

```
memtrace              → code. Symbols, call graphs, "why is this here", decisions
Claude auto memory    → this machine's session preferences. Nothing authoritative
Observatory Postgres  → runs, evaluations, AND learned knowledge
Git                   → authoritative. Everything above is derived state
```

**Do not build a file or symbol index.** memtrace has one and you pay for it every session.
**Do not build decision memory.** Cortex has `recall_decision`, `why_is_this_here`,
`governing_contracts`, `verify_intent`.

**Do build the governed learning store.** Nothing has it.

### Why the learning store belongs in the observatory's Postgres

Not to save a container — because a learning candidate's entire value is its **provenance**,
and provenance is a foreign key:

```sql
knowledge_entry(
  id, type, scope, content,
  status,              -- candidate | active | deprecated | rejected | expired
  confidence, expires_at,
  source_run_id  REFERENCES runs(id),     -- ← the join that makes this worth doing
  source_commit, verifying_command, exit_code,
  embedding vector(768),                  -- only at step 4 below
  tsv tsvector
)
knowledge_usage(entry_id, run_id, outcome)
```

That schema answers the only two questions that matter:

```sql
-- knowledge_hit_rate, for free
SELECT count(*) FILTER (WHERE outcome='used')::float / count(*) FROM knowledge_usage;

-- did knowledge actually help?
SELECT u.entry_id, avg(r.passed::int) FROM knowledge_usage u
  JOIN runs r ON r.id = u.run_id GROUP BY 1;
```

In two databases those are correlation exercises you will get wrong.

### Expose it as read-only MCP, never as an embedded file

Three reasons, and the second is specific to this project:

1. **Portable** across Claude, Codex and Copilot — one server, thin adapters
2. **It stays outside the agent's `git archive` tree**, so your allowlist assertion still
   works. An embedded SQLite file is opaque to that check — see [Lab 6B.5](../06b-knowledge-retrieval/README.md)
3. **Read-only by construction.** The write path goes through the governance job, not the
   agent — the same shape as [gh-aw safe outputs](../08-agentic-workflows/README.md#extract)

---

## Labs — try it in this order

Each step is useful on its own, and **none of the first three needs a vector database.**

### Lab 9.4 — Audit what you already have *(30 min, no code)*

```bash
ls -la ~/.claude/projects/*/memory/          # what has Claude written about you?
wc -l ~/.claude/projects/*/memory/MEMORY.md  # under the 200-line load limit?
ls ~/.memtrace/                              # cortex-store, embed-cache
```

Then the honest questions: how many of these facts are still true? Which system would you
consult first for "why is this code like this"? Has anything ever *removed* a stale fact?

Write the ownership table above into `governance/memory-policy.md` with your answers.

### Lab 9.5 — Provenance without a database *(1 day)*

Add frontmatter to every entry in `knowledge/failure-patterns.md`:

```yaml
source_run_id: …      source_commit: …     verifying_command: …
exit_code: 0          verified_at: …       expires_after_days: 90
```

Then check: **how many existing entries can you actually fill in?** The ones you cannot are
knowledge you have no evidence for. That count is the finding.

### Lab 9.6 — The candidate pipeline, as files *(2 days)*

`knowledge/candidates/` + a promotion script. Still no database.

```
build commands       1 verification + human approval
failure patterns     2 occurrences   + human approval
style / architecture human approval always
```

Then deliberately promote something wrong, use it, and **exercise the rollback**: mark
suspect, stop reuse, fall back to discovery, create a correction candidate. A rollback path
you have never run is a rollback path you do not have.

### Lab 9.7 — Move it into Postgres *(when the files creak)*

`postgres:16.6-alpine` → `pgvector/pgvector:pg16` is a one-line compose change. Port the
schema above. **Do not add embeddings yet** — `tsvector` and exact lookup first, so you have
a baseline the embeddings have to beat.

### Lab 9.8 — Wrap it in MCP

One read-only tool: `lookup_knowledge(topic)`. Then run [Lab 6B.4](../06b-knowledge-retrieval/README.md)
against it — put an injection string in an entry and confirm your hard controls hold when the
model complies.

---

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
