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

---

## Lab 9.4 executed — 2026-09-29, spine stop 24

The lab this phase asks for, run once, on this machine, for no money and no benchmark runs.
Frozen evidence: [`../../evidence/p09/memory-audit-20260929T1119Z.md`](../../evidence/p09/memory-audit-20260929T1119Z.md).
Policy written from it: [`../../governance/memory-policy.md`](../../governance/memory-policy.md).

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-29; the author did not review before
the lab ran.`

### Why 9.4 and not 9.1–9.3

§3 of the run's prompt owes this stop **one lab with evidence on disk**. Labs 9.1–9.3 all
measure whether the *agent under test* uses a remembered fact, which needs a benchmark batch
and therefore a prediction commit before the first run (§4 step 3) — a whole second boundary
of work for a Track A stop registered at two. 9.4 is the phase's own first lab, its commit
target `governance/memory-policy.md` is the one named in this README's Commit block, and its
subject is the corpus this same stop just proved goes stale unchecked. It was chosen for
continuity of measurement, not for cheapness, and the cheapness is stated so a reader can
discount it.

### The result: 7 of 25 advertised claims are false, and nothing executes over any of them

The audited unit is the claim each memory advertises in its `MEMORY.md` index line — **15
memories, 25 individually decidable assertions**, each with the command that decided it in the
evidence file.

| Verdict | n |
|---|---|
| true and load-bearing | 10 |
| true but **obsolete** — serves an arm Decision G removed | 1 |
| false, **superseded by a recorded event** | 5 |
| false, **does not reproduce as written** | 2 |
| **undecidable by command** | 7 |
| | **25** |

`n = 25 assertions, 15 memories, 1 corpus, 1 machine.` A property of these twenty-five
sentences, **not** of agent memory. The seven undecidable rows are not a shortfall: two are
about a habitual state one probe cannot settle, two would require performing the destructive
act they warn about, one needs the corpus to be a day older, one is about a person, one has no
live trigger. Saying "undecidable" is a measurement; guessing would not be.

### The sharpest row: the corpus has **no** control, which is not the same defect as a narrow one

The extract verification earlier at this stop found `check-links.sh` **green** — ok=3, broken=0,
exit 0 — while five of eight quotations taken off those links did not match: an L2 control
narrower than a reader assumes. The memory corpus has no checker, no schema, no expiry field
and no CI job at all.

**These are different failure modes and must not be reported as one.** A narrow green control
produces false assurance. An absent control produces none. Only the first one lies to you. The
repository-level lesson from this stop is therefore two-sided, and the workbook says so rather
than collapsing it into a single slogan.

### The three-way split reproduces on a second, independent corpus

The extract verification recorded that a quotation that was **never right** and one that **went
wrong** are byte-identical to any checker. The same split appears in the memory corpus — no
shared authorship, subject or format, measured 21 days later:

- **superseded by an event the memory could not know** — 5 of 7. Every one duplicates a value
  that is authoritative elsewhere (`blocked_on_author`, the prompt sha, `author_decisions`, a
  gate result) and that moved.
- **does not reproduce as written** — 2 of 7 (`rtk git diff` returning empty; it returns 8 987
  and 2 398 bytes of real diff). Indistinguishable by command from a claim that was wrong the
  day it was written.
- **true but obsolete** — 1. The category an external page cannot show, because a documentation
  page cannot become obsolete *to you* while staying true.

One corpus is an anecdote. Two is the beginning of a pattern, and the second one added a
category the first could not.

### What was decided (§4 step 10)

**No memory-staleness checker is built.** The measured case covers only the five
superseded-by-event rows, all machine-checkable. It is refused because the corpus is
**machine-local** — `~/.claude/projects/…/memory/` is in neither repository, in no CI checkout,
and exists in **355** copies on this laptop (354 twenty minutes earlier in the same audit). A `verify-*.sh` here would be green on one machine
and vacuous everywhere else: a control reporting success over a scope smaller than it claims,
which is this project's house failure mode. Building it would add a green check and no coverage.
What would reverse this: a memory corpus that lives inside a repository — the observatory's
Postgres learning store, which is **B9's** subject and not this stop's.

**Instead, the seven false claims were corrected**, additively and after the audit was frozen.
That is the answer to the lab's own third question: *has anything ever removed a stale fact?* —
**no, not once in the 52 days the corpus has existed, until this lab.**

### Guardrail layer of everything in this section

| Thing | Layer | Rule applied in order |
|---|---|---|
| `governance/memory-policy.md` | **L3** | Nothing in it executes; a later session can contradict every row and no command objects. |
| The ownership split (`Git wins over memory`) | **L3** | A sentence. Nothing rejects a memory that contradicts the repository. |
| The frozen audit file | **L3 as a control, L1 as a record** | It prevents nothing from being written. But it is committed append-only evidence, and §6 forbids rewriting it. |
| The seven corrections | **L3** | Words in files nothing reads mechanically. They fix these seven; they stop no eighth. |
| The *absence* of a staleness check | **not a layer** | Named explicitly, because "no control" is a different finding from "a narrow control", and only the narrow one produces false assurance. |
| `check-links.sh` over this phase | **L2, narrower than it looks** | It executes and it rejects; it executes on **URLs**, never on the sentences quoted off them. Already recorded earlier at this stop. |

### learning

```yaml
learning:
  what_was_added: >
    governance/memory-policy.md (L3), a frozen per-assertion audit of the 25 claims this
    machine's agent memory advertises for this project, and seven additive corrections to
    the memory store itself. No tool, no runs, no money.
  why_it_exists: >
    Phase 9's Lab 9.4 asks three questions of the live memory systems and only the first is a
    number. The stop had just measured an external corpus going stale unchecked; the internal
    corpus is the one the project actually depends on and had never been measured at all.
  observed_effect: >
    7 of 25 advertised claims false, 11 true, 1 true-but-obsolete, 7 undecidable by command.
    Zero were found by anything that executes, because nothing executes over this corpus.
    The extract audit's three-way split reproduced on a second, independent corpus and gained
    a fourth category (true but obsolete).
  unexpected_effect: >
    Two, and the second is bigger than the lab. (1) The stale claims cluster on values that are
    authoritative somewhere else — the prompt sha, blocked_on_author, author_decisions — which
    is the duplication failure this README's own closing note already described and said the
    obvious mitigation does not fix. (2) The same session's preflight ran
    verify-codex-isolation.sh three times in thirty minutes on a file unchanged since
    2026-09-03 and got ok, INCONCLUSIVE and ISOLATION LEAKS. A check whose verdict depends on
    whether a model chose to go looking is one sample of behaviour, not a control, and a
    preflight row that is a coin flip cannot gate anything.
  keep_or_remove: >
    Keep the policy file and the frozen audit. Do NOT build the checker: the corpus is
    machine-local, so the control would be green on one machine and vacuous everywhere else.
    Reverse that only when the corpus moves into a repository — B9's learning store.
  next_question: >
    The measured staleness rate is 7 of 25 at a corpus age of 52 days with zero controls. Does
    a corpus with an expires_at column and a verifying_command do better, or does it just move
    the unowned re-validation one level down? B9 can answer that, and this is the baseline it
    would have to beat.
```

### Exit gate — Phase 9

- [x] **Distinguish instructions · memory · session history · cache · workflow persistence.**
      Done from measurement, not definition: instructions are delivered per run and *proved* by
      `customization.instructionsHash` (null on all seven keys of run
      `feb68170-395a-49a8-afb1-b7222b81e4c6` under `ISOLATE_USER_SETTINGS=1`); memory is
      machine-local free text with **no** hash, no expiry and no reader that executes, measured
      here at 7 of 25 false; session history dies with the session, which is why §0 of this
      run's prompt puts everything in `TRACK-B-STATE.md`; cache (`~/.memtrace/embed-cache`,
      `parse-cache`) is derived and regenerable by re-indexing; workflow persistence is
      `.agent/run-state.json`, written by B8 and carrying a reserved `handoff` field.
- [x] **Explain why they are not interchangeable.** Because they differ on the only two axes
      that decide behaviour: **who may write** and **what proves delivery**. Instructions have a
      per-run delivery proof and memory has none — which is why E-003 could reject a 57-word
      instruction file on evidence, and why nothing in this repository can make the same kind of
      claim about a memory. Substituting one for the other silently changes which of those is
      true, and this project has already voided runs over exactly that confusion.

**Was this the agent, or the harness?** **Neither, and that is the honest answer.** No
benchmark run belongs to this lab; the agent under test was never invoked for it. It measured a
*corpus*, with commands, by hand. The one place the harness did intrude is recorded above as an
unexpected effect: `verify-codex-isolation.sh` returned three different verdicts in thirty
minutes, which is a property of that harness and of nothing this lab set out to measure.

### Validation table (§5)

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| §3 row 24: *"Phase 9 memory: reading, extract, one lab"* — **reading** | `phases/09-memory/README.md` §"Verified reading" + §"Extract re-verified — 2026-09-29" (commit `cb10974`) | L1 — committed file, §6 forbids rewriting it | `git show cb10974 -- phases/09-memory/README.md` |
| §3 row 24 — **extract** | same commit; `evidence/p09/quote-verification-20260929T1105Z.txt` (found=3 absent=5, exit 2) | L2 — `tools/verify-quotes.sh` executes and exits non-zero | `./tools/verify-quotes.sh evidence/p09/quotes-p09.tsv` |
| §3 row 24 — **one lab** | `evidence/p09/memory-audit-20260929T1119Z.md` (25 assertions, verdicts, deciding commands) + `governance/memory-policy.md` | L3 as a control, L1 as a record | open the audit file; re-run any row's command from its own cell |
| §3 row 24 closes when — **evidence on disk** | the two files above, plus `evidence/p09/codex-isolation-20260929T1125Z-handrun.txt` and `evidence/p09/smoke-20260929T1114Z.txt` | L1 | `ls evidence/p09/` |
| Phase 9 exit gate clause 1 — *distinguish the five* | run `feb68170-395a-49a8-afb1-b7222b81e4c6`, `.customization` = 7 keys, **all null**. **This is §0a preflight row 6b, not a run of this lab** — it enters no comparison and is cited only as an example of what a delivery proof looks like | **L1** — the API record is written by the runner, not asserted | `curl -s 127.0.0.1:8081/api/runs/feb68170-395a-49a8-afb1-b7222b81e4c6 \| jq '.customization'` |
| Phase 9 exit gate clause 2 — *why not interchangeable* | `experiments/E-003-instructions-v0.1.md` (the rejection that a delivery proof made possible) vs the absence of any hash over the memory corpus | L3 — an argument, not a control; labelled L3 for that reason | read E-003's delivery section, then `grep -c Hash` over any memory file: zero |
| §4 step 10 — *decision recorded from measurement* | §"What was decided" above; the 5-of-7 machine-checkable class and the 354-copy scope argument | L3 | count `ls -d ~/.claude/projects/*/memory` → 355, and again an hour later |
| §5 — *at least one scored cell re-read by hand* | preflight row 6b re-derived **by me off the API**, not taken from the subagent: 7 keys, all null, model `claude-haiku-4-5-20251001`, evalExit 0 | **L1** | the `curl … \| jq` above |
| §5 — *every number quoted has its `n`* | `n = 25 assertions, 15 memories, 1 machine`, stated at every occurrence | L3 | read the section |
| §5 — *re-run every verification command immediately before writing done* | §0a re-run in full this session; row 6a re-run **by hand** and its output saved | L1 for the saved output, L3 for the claim that it was the last act | `cat evidence/p09/codex-isolation-20260929T1125Z-handrun.txt` |

**One row deliberately not claimed.** There is no independence check between arms, because
there are no arms: this lab has `n = 0` benchmark runs and compares no populations. Writing an
independence row here would be a control reporting success over a scope it does not have.
