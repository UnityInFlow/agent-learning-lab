# Phase 9 — Memory

**Guardrail layer: L3 — untrusted derived state** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🟡 In progress — opened at spine stop 24, 2026-09-29 · **Depends on:** Phase 8

## Goal

Persistence without treating learned state as truth.

> **Memory is untrusted derived state. Reviewed Git configuration remains authoritative.**

## Verified reading

- [ ] ✅ [Copilot Memory](https://docs.github.com/en/copilot/concepts/agents/copilot-memory)
- [ ] ✅ [Claude Code — Memory](https://code.claude.com/docs/en/memory)
- [ ] ↪️ [VS Code — Memory](https://code.visualstudio.com/docs/agents/run/memory) — treat separately from GitHub-hosted Copilot Memory

**Links re-verified 2026-09-29** — `./tools/check-links.sh phases/09-memory/README.md`,
`ok=3 moved=0 blocked=0 unverified=0 broken=0`, exit 0
([`evidence/p09/check-links-20260929T1315Z.txt`](../../evidence/p09/check-links-20260929T1315Z.txt)).
**Quotations re-verified the same day and 5 of 8 did not match** — see *Extract re-verified*
below. The ✅ marks above mean the URL resolves; until 2026-09-29 nothing in this repository
checked that the sentences quoted off it were still there.

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

## Extract re-verified — 2026-09-29, spine stop 24

Everything above this line was written **2026-08-09** and is kept verbatim. Nothing in it is
edited; this section is what re-reading the cited pages on **2026-09-29** returned, 51 days
later. *Written by Opus 5 (claude-opus-5), autonomously, at spine stop 24.*

### Why this section exists at all

Stop 23 (Phase 8) found that a bold display quote in **this project's own August extract** was
no longer on the page it cited, and that **nothing in the repository executed to catch it**.
`check-links.sh` proves a URL resolves; it says nothing about whether the sentence you quoted
off that URL is still there. Stop 23 built a checker for one phase. Stop 24 generalised it into
[`tools/verify-quotes.sh`](../../tools/verify-quotes.sh), which reads its pages and sentences
from a manifest, and pointed it at this phase.

**The existing control was green the whole time.** `./tools/check-links.sh
phases/09-memory/README.md` → `ok=3 moved=0 blocked=0 unverified=0 broken=0`, exit 0
([`evidence/p09/check-links-20260929T1315Z.txt`](../../evidence/p09/check-links-20260929T1315Z.txt)).
Every link this phase cites resolves. Five of its eight quotations do not match the page
behind those links, and one of them is false. A link check and a quote check are not the same
control, and only one of them existed.

### The result: 8 quotations, 3 byte-exact, and the 5 absences split THREE ways

Run: `./tools/verify-quotes.sh --manifest evidence/p09/quotes-p09.tsv` → **found=3 absent=5,
exit 2**
([`evidence/p09/quote-verification-20260929T1105Z.txt`](../../evidence/p09/quote-verification-20260929T1105Z.txt)).

Exit 2 is the checker's code for "a quoted sentence was not found". It is deliberately *not*
a verdict about why, because the checker cannot tell why — and here the five absences are
three different things. **Each was adjudicated by hand against the fetched page text**, which
is the step the instrument cannot do for you:

| # | The August quotation | Verdict | What the page says on 2026-09-29 |
|---|---|---|---|
| 1 | "Claude Code reads `CLAUDE.md`, not `AGENTS.md`." | **CLAIM REVERSED** | "By default, Claude reads AGENTS.md only when you have no CLAUDE.md in your working directory or above it." |
| 2 | "In your next session, run `/context` and confirm `CLAUDE.md` appears under Memory files." | reworded, claim intact | "To confirm the file loaded, run /context in a session and check the list under Memory files" |
| 3 | "Target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." | **never verbatim** | "Size : target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." — lowercase `target`; the workbook capitalised it when lifting it out of a `Size:` list item |
| 4 | "helps organization but doesn't reduce context, since imported files load at launch." | **never verbatim** | identical except the page renders a typographic apostrophe (U+2019) where the workbook typed an ASCII one |
| 5 | "The dialog protects you from files other people commit to a shared project." | reworded, claim intact | "Claude Code shows the dialog to protect you from files other people commit to a shared project." |

Three categories where the workbook asserts one. Its own extract header says **"Quotes
verbatim."** — and for rows 3 and 4 that was **false on the day it was written**, not stale.

### The headline: the sentence that voided Phase 1 has itself expired

Row 1 is not a rewording. The page now carries a whole section, *When Claude Code reads
AGENTS.md*, documenting the opposite behaviour under a stated condition, and a companion
section *When AGENTS.md support is unavailable* whose first listed cause is "You're on a
Claude Code version before v2.1.277". The August sentence was unconditional. The documented
behaviour today is conditional:

> "By default, Claude reads AGENTS.md **only when you have no CLAUDE.md** in your working
> directory or above it."

**Scope, said plainly, because this cuts two ways.** For *this* workspace the August guidance
still produces the right behaviour: there are `CLAUDE.md` files at the root and in every repo,
so `AGENTS.md` would not be read here regardless. The claim that expired is the **general**
one the extract teaches, and the extract teaches it as the load-bearing fact that *voided this
project's Phase 1 experiment*. A reader who takes that sentence at face value today — on a
repository with no `CLAUDE.md` — is wrong about what the agent loads.

**`n` = 1 page, 8 quotations, 1 phase.** This is a property of these eight sentences, not of
the documentation. The comparable stop-23 number is 1 absent of 29 on seven pages.

### What this adds to stop 23, and what it does not

Stop 23's finding was *drift*: a claim survives, its wording does not. Stop 24 finds that at a
second phase the same check returns **three failure modes**, and that only one of the five is
drift of the stop-23 kind. **Two are defects in the quoting, present from day one**, which no
amount of re-checking against a *future* page would ever have separated from drift — a quote
that was never right and a quote that went wrong are byte-identical to `grep -F`. The
adjudication is human and stays human; what the instrument buys is that the five are *found*.

**It does not establish a rate.** Two phases, both checked only after a stop went looking for
them, is not a sample of this repository's extracts. Whether the other extracts carry the same
two defect classes is unmeasured, and is the obvious next thing to point the manifest at.

### Guardrail layer of everything in this section

| Artifact | Layer | Why, applying the rule in order |
|---|---|---|
| `tools/verify-quotes.sh` | **L2** | Something executes and rejects: exit 2 on an absent quote, 3 on a page it could not read, 4 on a manifest it cannot trust. Proved by `tools/verify-quote-checker.sh`, 29 of 29. |
| `evidence/p09/quotes-p09.tsv` | **L1** for the page/quote binding | A quote whose page key names no declared page cannot be written down and still run — it is exit 4, fixture K. The *sentences themselves* are L3: nothing stops a wrong transcription being added, which is exactly how rows 3 and 4 got in. |
| The adjudication table above | **L3** | Words a human read and judged. Nothing executes to distinguish drift from a transcription defect, and on this evidence nothing can. |
| `check-links.sh` over this phase | **L2, and narrower than it looks** | It executes and it rejects — but only URL resolution. Green here while five quotations were wrong. |

That last row is this stop's contribution to `GUARDRAILS.md`: **an L2 control is only L2 over
the thing it actually executes on**, and a reader who sees "links: green" will infer a
guarantee about content that nothing ever checked.

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
