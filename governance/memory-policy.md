# Memory policy

Spine stop 24 (Phase 9 — Memory). Written from **Lab 9.4**, the audit the phase README asks
for, and not from preference. The measurement behind every number here is frozen in
[`../evidence/p09/memory-audit-20260929T1119Z.md`](../evidence/p09/memory-audit-20260929T1119Z.md);
that file records the corpus as found, before any correction.

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-29.` The author did not review this
before it was written. Every row is reversible; none of it moves a registered variable.

---

## 1. Ownership — who owns what, and what "owns" means

Taken from the phase README's split and kept, because the audit gave no reason to change it.
**Ownership here means: if two systems disagree, this one is right and the other is derived.**

```
Git                   → authoritative. Everything below is derived state.
memtrace              → code. Symbols, call graphs, "why is this here", decisions.
Claude auto memory    → this machine's session preferences. Nothing authoritative.
Observatory Postgres  → runs, evaluations, and (not yet built) learned knowledge.
```

Verified live at audit time rather than assumed: `~/.claude/projects/…/memory/` holds 16 files
(15 memories + the index); `~/.memtrace/` holds `cortex-store` and `embed-cache`; the
observatory API answers on `127.0.0.1:8081` with **742** run records.

## 2. The governance questions, answered

The README asks nine questions of every memory mechanism. Answering them per system is the
point of the exercise; an unanswered row is a real gap and is written as one.

| | Claude auto memory | memtrace | Observatory Postgres |
|---|---|---|---|
| **who writes** | the agent, unprompted, during a session | `memtrace index` / the file watcher | `run-agent.sh`, per run |
| **who reads** | every session in this project directory, automatically, before the first user turn | any agent with the MCP server attached | the API, the web UI, the lab's scorers |
| **where stored** | `~/.claude/projects/<slug>/memory/` — machine-local, outside both repos | `~/.memtrace/` — machine-local | a container volume, machine-local |
| **how long** | **forever.** No expiry field exists | until re-indexed | forever |
| **admin inspect / export / delete** | inspect and delete yes (plain files); export is `cp` | yes | yes, SQL |
| **can it hold confidential data** | **yes, and nothing prevents it** — it is free text written by an agent that has read the repo | code only | run records only |
| **how is staleness detected** | **it is not.** No checker, no schema, no expiry, no CI job reads these files | re-index overwrites | run records are immutable facts about a past event and cannot go stale |
| **authoritative vs Git** | Git wins, always | Git wins | the run record wins about what happened; Git wins about what the code is |

Three rows in that table are the finding: *forever*, *yes and nothing prevents it*, and
*it is not*. They are properties of the same column.

## 3. Lab 9.4's three questions

**"How many of these facts are still true?"** — of the **25** assertions the memory index
advertises, **11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided by
running anything.** Five of the seven false claims are duplicates of a value that lives
authoritatively elsewhere and moved; two do not reproduce as written and are
indistinguishable from claims that were wrong when written. `n = 25 assertions, 15 memories,
1 machine` — a property of these twenty-five sentences, not of agent memory.

**"Which system would you consult first for *why is this code like this*?"** — memtrace's
Cortex tools (`why_is_this_here`, `recall_decision`, `governing_contracts`), and the project
already routes there by rule. Not the auto memory: the audit found its index line for this very
project telling a reader **never to trust a spine position written in memory**, which is a
memory whose own headline is a warning about memory.

**"Has anything ever *removed* a stale fact?"** — **no.** Not once in the 21 days the corpus
has existed. The seven false claims were corrected on 2026-09-29 after the audit file was
frozen, and that is the first removal this corpus has had. It was triggered by a lab, not by
anything that runs.

## 4. Layers — applied in order, stopping at the first yes

| Thing | Layer | Why, applied in order |
|---|---|---|
| This file | **L3** | Nothing in it executes. A future session can contradict every row of it and no command objects. It is words a human reads and chooses to follow. |
| The frozen audit | **L3 as a control, L1 as a record** | It stops nothing from being written down. But it is append-only evidence of a past state, and no later session can make it say otherwise without rewriting a committed file — which §6 forbids. |
| `Git wins over memory` | **L3** | It is a sentence. Nothing rejects a memory that contradicts the repository. |
| The absence of any staleness check | **not a layer at all** | This is the row that matters. A narrow L2 control lies to a reader; **no control does not.** They are different failure modes and only the first one produces false assurance. |

## 5. What is not built, and the reason

**No memory-staleness checker lives in this repository.** The measured case for one covers only
the five "superseded by a recorded event" rows, every one machine-checkable. It is refused
because the corpus is **machine-local**: `~/.claude/projects/…/memory/` is in neither
repository, is in no CI checkout, and exists in **354** copies on this laptop alone. A
`verify-*.sh` here would be green on one machine and vacuous everywhere else — a control
reporting success over a scope smaller than it claims, which is this project's house failure
mode and has already been paid for four times.

**What would change that decision:** a memory corpus that lives inside a repository. The
observatory's Postgres learning store (phase README §"Why the learning store belongs in the
observatory's Postgres") is exactly that, and it is B9's subject, not this stop's. When it
exists, `expires_at` and `verifying_command` are already in its proposed schema, and a checker
over it would be L2 over the thing it actually executes on.

**Do not commit raw memories.** This file and the audit record claims, verdicts and the
commands that decided them. No memory file's contents are reproduced beyond the fragment a
verdict needs.
