# Phase 9 — Memory

**Guardrail layer: L3 — untrusted derived state** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🟡 In progress — opened at spine stop 24, 2026-09-29 · **Depends on:** Phase 8

## Goal

Persistence without treating learned state as truth.

> **Memory is untrusted derived state. Reviewed Git configuration remains authoritative.**

## Verified reading

> ⚠️ **A ✅ here means the URL resolves and nothing more.** It is not a statement that any
> sentence quoted from that page still appears there — the §“Extract re-verified” pass found **five
> of eight** that do not, with every link green. The scoping sentence has always been a few lines
> below; a round-2 panel pointed out that the ticks reach the reader first, which is **the same
> false-assurance shape this workbook names for `check-links.sh`, applied one level up to its own
> heading.**

**Two marks, two meanings, and nothing in this file said so until now** — a round-5 finding at
**2 of 2 runs**, the only one of that round both families raised. The **checkbox** is the August
template's *"has a human read this?"* and **no session has ever ticked one**; the **tick** is
*"the URL resolved when `check-links.sh` last ran"*. An unticked box beside a green tick was
readable as either *unread* or *not verified*, which are opposite claims about opposite things.

- [ ] ✅ [Copilot Memory](https://docs.github.com/en/copilot/concepts/agents/copilot-memory)
- [ ] ✅ [Claude Code — Memory](https://code.claude.com/docs/en/memory)
- [ ] ↪️ [VS Code — Memory](https://code.visualstudio.com/docs/agents/run/memory) — treat separately from GitHub-hosted Copilot Memory

`[ ]` = **the human-read box, never ticked by any session of this run.** ✅ = **URL resolves.**
↪️ = **read separately, different product.** The boxes are left unticked rather than ticked,
because ticking them would be this run asserting a human act it cannot observe.

**Links re-verified 2026-09-29** — `./tools/check-links.sh phases/09-memory/README.md`,
`ok=3 moved=0 blocked=0 unverified=0 broken=0`, exit 0
([`evidence/p09/check-links-20260929T1315Z.txt`](../../evidence/p09/check-links-20260929T1315Z.txt)).
**Quotations re-verified the same day and 5 of 8 did not match** — see *Extract re-verified*
below. The ✅ marks above mean the URL resolves; until 2026-09-29 nothing in this repository
checked that the sentences quoted off it were still there.

## Current properties

> ⚠️ **Everything in this section is undated and unverified.** It was written 2026-08-09 and
> **none of it was re-checked** by the 2026-09-29 pass, which covered the eight quotations of
> §"Extract" and nothing else. In a workbook whose finding is that vendor claims drift unnoticed,
> an unmarked block of vendor claims is the same defect one level up — raised by this workbook's
> own §4a review, and marked rather than re-checked because re-checking it is a measurement this
> stop did not make.

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

From the Claude Code memory documentation, read 2026-08-09. ~~Quotes verbatim.~~

> ⚠️ **"Quotes verbatim" was FALSE ON THE DAY THIS WAS WRITTEN for two of the eight
> quotations** — rows 3 and 4 of §"Extract re-verified" (a capital "Target" lifted out of a
> `Size : target …` list item; an ASCII apostrophe where the page renders U+2019). Struck rather
> than deleted. **Three of the eight are still byte-exact; five are not**, and the five split
> three ways.

### The sentence that voided our Phase 1 experiment

> ⚠️ **THIS QUOTATION NO LONGER MATCHES THE PAGE IT CITES — re-checked 2026-09-29, see
> [§"Extract re-verified"](#extract-re-verified--2026-09-29-spine-stop-24) row 1.** It is kept
> verbatim because it is what the extract said on 2026-08-09, and a prediction or a reading is
> not edited after the fact. The marker is here rather than only 160 lines below because the
> §4a review of this workbook found that a reader meets the reversed claim first and the
> correction second, which is the wrong order for the one sentence in this file that voided an
> experiment. **The marker covers the paragraph after the quotation too**, added at the close
> from a round-3 finding: the word *"Unambiguous"* below reads the August quotation as settled,
> and on the page today it is not — it is conditional on whether a `CLAUDE.md` exists.

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

> ⚠️ **The paraphrased claims in the rest of this Extract were NOT re-checked.** The 2026-09-29
> pass covered **eight quotations** and nothing else. The trust table, the precedence chain and
> the auto-memory mechanics below are from 2026-08-09, carry no per-claim staleness marker, and
> are marked here as a block for the same reason §“Current properties” is.
> ~~the size figures~~ → **struck at the close from a round-5 finding, and the strike matters.**
> One of the eight **is** a size figure — *“Target under 200 lines per `CLAUDE.md` file…”*, row 3
> of the adjudication, found **never verbatim**: a capital *“Target”* lifted out of a
> *“Size : target …”* list item. Listing size figures among the un-re-checked told a reader the
> opposite of what the pass had found about the one that was checked.
> The two round-2 panels disagreed about whether this needed saying — one raised it, the other
> disputed it as already covered by the dated header — and it is said, because the cheaper error
> is the one that over-marks.

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

> ⚠️ **None of the lab designs below carries a decision rule, and none may be run until it
> does.** Added at the close, 2026-09-29, from four round-3 findings (§"Predict before you run",
> Labs 9.1, 9.2 and 9.3, each at 1 of 2 runs). The panel's objection is the same one each time and
> it is correct: *"re-verify or repeat"*, *"did it help?"* and *"measure whether memory biases the
> result"* name no observation boundary, no exclusive outcomes and no combining rule, so one trace
> can be scored either way after the fact. **That is not a defect this stop repairs — it is what
> §4 step 3 of the run prompt exists to force**: a prediction with a direction, a magnitude and a
> mechanism, committed before the first run, and the commit timestamp checked against the run's
> `startedAt` afterwards. These labs are **deferred**; `n = 0` runs belong to any of them; nothing
> here has been scored, so nothing here has been scored ambiguously. The marker is the guard
> against a later session treating an August sketch as a registered design.

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

Everything above this line was written **2026-08-09**. **No sentence of it is edited** — but it
is no longer true that nothing above this line is dated 2026-09-29, and a round-3 panel was right
to say the earlier wording claimed otherwise. **Dated marker blocks have been *added* above**, at
the three places where a reader meets a claim this section later refutes. Adding a marker beside
a sentence and editing the sentence are different acts: the first leaves the measured object
intact and the second destroys it, which is why §6 forbids only the second. This section is what
re-reading the cited pages on **2026-09-29** returned, 51 days later.
*Written by Opus 5 (claude-opus-5), autonomously, at spine stop 24; the wording above corrected
at the close, same day, from the round-3 review.*

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
| `evidence/p09/quotes-p09.tsv` | ~~**L1** for the page/quote binding~~ → **L2**, corrected 2026-09-29 | **The original label was wrong and this workbook's own §4a review caught it at 2 of 2 runs.** Applied in order: *can the bad value still be written down after the fix?* — **yes.** An undeclared page key can be typed into the TSV and saved; what happens next is that `verify-quotes.sh` **executes and refuses it** at exit 4, fixture K. Something runs and rejects it, so it is **L2**, not L1. L1 would require the row to be unwritable. ~~The *sentences themselves* stay **L3**: nothing stops a wrong transcription being added, which is exactly how rows 3 and 4 got in.~~ → **corrected 2026-09-29, round 4**, and the struck text is kept. That sentence refutes itself: rows 3 and 4 are two of the five the checker **reported absent**, so something did execute and did reject them. Applying the rule in order to the sentence splits it in two. *Sentence ↔ page* is **L2**: a transcription that is not byte-present on the fetched page is refused at exit 2, which is how rows 3 and 4 were found. *Sentence ↔ claim* is **L3**: a sentence that **is** byte-present but does not support the claim the extract hangs on it passes the checker silently, and nothing here executes on that. Row 1 — the reversed claim — needed the hand adjudication for exactly this reason. The struck label is kept, not deleted — and note that this is the same error the workspace `CLAUDE.md` warns about (*“a schema note is L3, not L1”*), made in the direction it does not name. |
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
  embedding vector(768),                  -- only at step 4 below   ⚠️ see note under the table
  tsv tsvector
)
knowledge_usage(entry_id, run_id, outcome)
```

> ⚠️ **`-- only at step 4 below` does not resolve to a step that adds embeddings, and the §4a
> round-2 gate was right to block on it.** Counting the ladder from Lab 9.4, step 4 is **Lab 9.7**,
> which says in as many words *“Do not add embeddings yet — `tsvector` and exact lookup first, so
> you have a baseline the embeddings have to beat.”* Counting only the build labs, step 4 is **Lab
> 9.8**, which wraps the store in MCP and also adds none. **No lab in this ladder adds the
> `embedding` column.** The August text is kept verbatim and marked rather than rewritten, as the
> three round-1 findings of the same shape were. Whoever eventually adds embeddings is adding a
> step that does not yet exist, and should say so.

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

> ⚠️ **That block is not valid YAML and anyone who copies it loses four of the six fields.**
> Found by the round-3 panel at the close, 2026-09-29. Three `key: value` pairs on one line parse
> as a **single scalar**: `source_run_id` takes the string `…      source_commit: …
> verifying_command: …`, and `source_commit`, `verifying_command`, `verified_at` and
> `expires_after_days` never exist as keys — so the very lab whose point is *provenance you can
> check* ships frontmatter whose provenance fields silently are not there. **The August block is
> kept above, unedited, because it is the artifact; the parseable form is here.**

```yaml
source_run_id: …
source_commit: …
verifying_command: …
exit_code: 0
verified_at: …
expires_after_days: 90
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

**Answered at spine stop 24, 2026-09-29 — the boxes are ticked here and the answers are below**,
under [“Exit gate — Phase 9”](#exit-gate--phase-9). The two clauses are the same two clauses;
a round-4 §4a finding was right that leaving them unticked 166 lines above the answers reads as an
open gate to anyone who stops at this heading.

- [x] Distinguish instructions · memory · session history · cache · workflow persistence
- [x] Explain why they are not interchangeable

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

### The result: 7 of 25 advertised claims are false, and no control executes over the corpus

The audited unit is the claim each memory advertises in its `MEMORY.md` index line — **15
memories, 25 assertions**.

~~25 individually decidable assertions, each with the command that decided it in the evidence
file.~~ → **corrected 2026-09-29 at the close; the struck text is kept.** It is false on this
section's own numbers, six lines below it: **7 of the 25 are `undecidable by command`.** The
split, which the validation table below already carried and this sentence did not:

| | n | what it means |
|---|---|---|
| decided by running a command | **18** | the command and its output are in the evidence file |
| command exists, **deliberately not run** | **2** | running it *is* the destructive act the memory warns about |
| **no command at all** | **5** | judged by reading; nothing executes on them |
| | **25** | |

**This is the stop's own failure mode committed against the stop's own artifact.** The 18/2/5
split was added to the validation table after a round-2 panel pressed on it; the head claim
eighty lines upstream — *where a reader meets it first* — was left saying something else. That is
exactly the defect an earlier round of this same review caught in this same file and that its
fix was supposed to be general: **mark the upstream text, do not only correct the narration.**
Caught here by the acceptance gate of the codex + `deepseek-v4-pro` panel, blocking entry (1).

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
shared authorship, subject or format, and measured on the same day as the extract, so the two
results are contemporaneous and differ only in what they are about:

- **superseded by an event the memory could not know** — 5 of 7. Every one duplicates a value
  that is authoritative elsewhere (`blocked_on_author`, the prompt sha, `author_decisions`, a
  gate result) and that moved.
- **does not reproduce as written** — 2 of 7 (`rtk git diff` returning empty; it returns 8 987
  and 2 398 bytes of real diff). Indistinguishable by command from a claim that was wrong the
  day it was written.
- **true but obsolete** — 1. The category an external page cannot show, because a documentation
  page cannot become obsolete *to you* while staying true.

**The mapping, written out, because a round-5 finding was right that “reproduces” was doing
work no stated rule supported.** The two corpora do not share a vocabulary, so *reproduces* has
to name which class answers which:

| Extract class (8 quotations vs a vendor page) | Memory class (25 assertions vs this machine) | What the two share |
|---|---|---|
| **claim reversed / reworded** — the page moved under a sentence that was right when written | **superseded by a recorded event** — 5 of 7 | The artifact was **true and the world changed**. Only a re-check against the world finds it |
| **never verbatim** — false on the day it was written | **does not reproduce as written** — 2 of 7 | The artifact was **wrong from the start**. A re-check finds it, and cannot tell you it was never right |
| *— no counterpart —* | **true but obsolete** — 1 | The category the external corpus **cannot** produce: a documentation page cannot go obsolete *to you* while staying true |

**What is claimed is the first two rows and nothing more:** in both corpora the failures split
into *was-true-and-drifted* and *was-never-true*, the two are byte-indistinguishable to the
checker each corpus has or lacks, and separating them took a human both times. **The counts are
not compared and no rate is transferred** — 8 quotations and 25 assertions are different units
against different referents.

One corpus is an anecdote. Two is the beginning of a pattern, and the second one added a
category the first could not. Stated with its limit: **two corpora, one observer, one day** —
that is a pattern worth looking for again, not a rate.

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
| The frozen audit file | **L3** | Applied in order: can a bad value still be written down after it exists? Yes — it prevents nothing. So L3, flatly. It is *also* append-only evidence, but “append-only” here is §6, a rule no command enforces, so that does not raise the label. Calling it **L1 as a record** — as this row did in its first draft — would be using the layer model on something that is not a control, which is the mistake stop 22's review caught pointing the other way. |
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
    7 of 25 advertised claims false, 10 true and load-bearing, 1 true-but-obsolete, 7
    undecidable by command. FIVE disjoint classes: 10 true + 1 true-but-obsolete + 5
    false-by-event + 2 false-because-they-do-not-reproduce + 7 undecidable = 25. An earlier
    draft wrote `10 + 1 + 7 + 7`, four addends for five classes, collapsing the two false
    subcategories — caught by BOTH round-2 panels.
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
      `customization.instructionsHash`. **The run cited here proves the control half, not the
      treated half** — a round-2 panel was right that an all-null record cannot demonstrate
      delivery: `feb68170-395a-49a8-afb1-b7222b81e4c6` under `ISOLATE_USER_SETTINGS=1` has all
      seven keys `null`, which is what a *control* must look like. The treated half is
      [`experiments/E-003-instructions-v0.1.md`](../../experiments/E-003-instructions-v0.1.md),
      where `instructionsHash` equals the registered sha of a 57-word file on every treated run.
      The pair is the point: **instructions have both assertions and memory has neither.** Memory is
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
| §3 row 24: *"Phase 9 memory: reading, extract, one lab"* — **reading** | `phases/09-memory/README.md` §"Verified reading" + §"Extract re-verified — 2026-09-29" (commit `cb10974`) | ~~L1 — committed file, §6 forbids rewriting it~~ → **L3**, corrected at the close. Applied in order: a wrong sentence *can* still be written into this file, and §6 is prose no command enforces. Nothing executes, so **L3** — the same answer this workbook gives the frozen audit file eighty lines above, and the gate was right that the two rows disagreed | `git show cb10974 -- phases/09-memory/README.md` |
| §3 row 24 — **extract** | same commit; `evidence/p09/quote-verification-20260929T1105Z.txt` (found=3 absent=5, exit 2), re-run at the close as `…-20260929T1210Z-close.txt` with the same cells | L2 — `tools/verify-quotes.sh` executes and exits non-zero. **`absent` means `grep -qF` found no byte-exact occurrence of the sentence in the stripped page text** (`tools/verify-quotes.sh:173`) — not normalised, not semantic. That is precisely why the instrument cannot separate *reworded* from *reversed* from *never verbatim*, and why the three-way split had to be adjudicated by hand | `./tools/verify-quotes.sh evidence/p09/quotes-p09.tsv` |
| §3 row 24 — **one lab** | `evidence/p09/memory-audit-20260929T1119Z.md` (25 assertions, verdicts, deciding commands) + `governance/memory-policy.md` | **L2 for the 18 rows a command actually decided; L3 for the adjudication of which category a failure falls into.** Both round-2 panels pressed on this number and it is worth being exact: **18** rows were decided by running a command; **2 more have a command that exists and was deliberately not run**, because running it *is* the destructive act the memory warns about; **5 have no command at all.** 18 + 2 + 5 = 25. “Rows a command decides” reads as 18 or 20 depending on whether you count the two refusals, so the artifact states all three numbers instead of choosing one | open the audit file; re-run any row's command from its own cell |
| §3 row 24 closes when — **evidence on disk** | the two files above, plus `evidence/p09/codex-isolation-20260929T1125Z-handrun.txt` and `evidence/p09/smoke-20260929T1114Z.txt` | ~~L1~~ → **L3**, corrected at the close. `ls` *runs*, but nothing **rejects**: a claim that evidence exists when it does not is written down freely and is caught only by a human reading the listing | `ls evidence/p09/` |
| Phase 9 exit gate clause 1 — *distinguish the five* | run `feb68170-395a-49a8-afb1-b7222b81e4c6`, `.customization` = 7 keys, **all null**. **This is §0a preflight row 6b, not a run of this lab** — it enters no comparison and is cited only as an example of what a delivery proof looks like | **L1** — and this is the one sense of L1 that survives the regrade: the `customization` block is written by the runner into the API and **cannot be typed by hand into a workbook and made true**. The bad value is unwritable at the source, which is what L1 means | `curl -s 127.0.0.1:8081/api/runs/feb68170-395a-49a8-afb1-b7222b81e4c6 \| jq '.customization'` |
| Phase 9 exit gate clause 2 — *why not interchangeable* | `experiments/E-003-instructions-v0.1.md` (the rejection that a delivery proof made possible) vs the absence of any hash over the memory corpus | L3 — an argument, not a control; labelled L3 for that reason | read E-003's delivery section, then `grep -c Hash` over any memory file: zero |
| *"nothing executes over this corpus"* — the stop's sharpest claim | `evidence/p09/no-control-over-memory-20260929T1150Z.txt` — three searches, zero matches: no CI workflow in any of the three repositories, no hook in `~/.claude/settings.json`, no tool under `tools/` | **L2** — three commands execute over enumerable sets and return zero matches; a reader re-runs them. Not L1: nothing prevents someone adding a checker tomorrow, and L1 is about what cannot be written down. **The rule that separates this from the guardrail table's “not a layer” row**, which a round-2 panel asked for: this column grades **the proof of a claim**, and this claim is proved by commands that run — L2. The guardrail table grades **a control over the corpus**, and there is none, so “not a layer”: you cannot grade a thing that does not exist. Two different objects, one of which is the *absence* of the other | re-run the three commands in that file; each must print no matches |
| §4 step 10 — *decision recorded from measurement* | §"What was decided" above; the 5-of-7 machine-checkable class and the 354-copy scope argument | L3 | `ls -d ~/.claude/projects/*/memory \| wc -l` — **expect a number in the mid-300s that is not 355.** It read 354 at 11:1xZ and 355 at 11:4xZ; a stranger re-deriving it should get a *different* value and that is the point. What is re-derivable is the **order of magnitude and the direction**: hundreds of stores, growing |
| §5 — *at least one scored cell re-read by hand* | preflight row 6b re-derived **by me off the API**, not taken from the subagent: 7 keys, all null, model `claude-haiku-4-5-20251001`, evalExit 0 | **L1**, same sense as the row above — an API record, not a hand-written value | the `curl … \| jq` above |
| §5 — *every number quoted has its `n`* | `n = 25 assertions, 15 memories, 1 machine`, stated at every occurrence | L3 | read the section |
| §5 — *re-run every verification command immediately before writing done* | §0a re-run in full this session; row 6a re-run **by hand** and its output saved | ~~L1 for the saved output~~ → **L3 throughout**, corrected at the close. A saved stdout file is as editable as any other file and nothing re-runs it; the ordering claim was already L3 | `cat evidence/p09/codex-isolation-20260929T1125Z-handrun.txt` |

**What this column grades, added at the close because the gate proved it was not obvious.**
It grades **the proof of the clause**, never the artifact the clause is about (§5 says so; it is
easy to read past). The acceptance gate of the codex + `deepseek-v4-pro` panel blocked on the
table using **L1 in three incompatible senses** and it was right. The three, separated:

| Sense in which the table said "L1" | Verdict on regrade |
|---|---|
| *a value nothing can hand-write* — the runner writes `customization` into the API record | **This is L1.** Two rows keep it |
| *a committed file, which §6 forbids rewriting* | **L3.** §6 is prose; nothing executes on it |
| *the file exists and `ls` shows it* | **L3.** `ls` runs, but nothing rejects — a human reads the listing |

**That is four layer mislabels at this one stop, in four different artifacts, every one of them
over-claiming**, and three of the four were caught by the review rather than by me — after I had
written a section about the layer rule and corrected three of my own. The rule is four sentences
at the top of the workspace `CLAUDE.md`. **Reading it is not the failure mode; applying it to a
whole table at once instead of to one binding at a time is.** Every correction here came from
asking the two questions again, in order, about *one* row.

**One row deliberately not claimed.** There is no independence check between arms, because
there are no arms: this lab has `n = 0` benchmark runs and compares no populations. Writing an
independence row here would be a control reporting success over a scope it does not have.

### §4a review — round 1, and what was done with each finding

Two artifacts, `-n 2` each, critic `ollama-cloud/glm-5.2`, acceptance gate
`ollama-cloud/minimax-m3`. Harness exit 0 on both, no stall, no process left running.

| Artifact | Findings file | Gate |
|---|---|---|
| `governance/memory-policy.md` | `findings/opencode/review-memory-policy-20260929T112646Z.md` | **REJECT** |
| this workbook | `findings/opencode/review-README-20260929T113345Z.md` | **ACCEPT** |

The policy file's nine findings and their dispositions are tabled in that file's own §6 — seven
fixed, one already fixed before the review returned, one disputed. This workbook's six:

| # | Rec. | Finding | Action |
|---|---|---|---|
| 9 | **2/2** | `quotes-p09.tsv` labelled **L1** where an undeclared page key *can* be written and only `verify-quotes.sh` rejects it | **fixed — this is the sharpest of the six.** Relabelled **L2**, struck not deleted, with the rule applied in order beside it. Same error the workspace `CLAUDE.md` warns about, made in the direction it does not name |
| 10 | **2/2** | `learning.observed_effect` summed to **26** against `n = 25` | **fixed** — 10 + 1 + 7 + 7, five disjoint classes, stated |
| 11 | 1/2 | §"Current properties" makes undated vendor claims **in a workbook whose finding is that such claims drift** | **fixed by marking, not by re-checking.** A warning block now says the section is from 2026-08-09 and that the 2026-09-29 pass covered the eight quotations and nothing else. Re-checking it is a measurement this stop did not make, and pretending otherwise would be the defect the stop is about |
| 12 | 1/2 | The reversed claim *"Claude Code reads `CLAUDE.md`, not `AGENTS.md`"* sits ~160 lines from its correction, unmarked | **fixed** — an inline warning beside the quotation, linking to the row that refutes it. The quotation itself is **not** edited |
| 13 | 1/2 | The extract header *"Quotes verbatim."* was **false on the day it was written** for rows 3 and 4, and was retained unmarked | **fixed** — struck through with the two defects named |
| 14 | 1/2 | The workbook never says whether `absent` means byte-exact, normalised or semantic matching | **fixed** — `grep -qF`, byte-exact, `tools/verify-quotes.sh:173`, and that is exactly *why* the three-way split needed a human |

**Findings 11, 12 and 13 are one finding in three places, and it is the review's best work.** All
three say the same thing: *this workbook narrates a staleness problem in its newest section while
leaving the stale text upstream unmarked, where a reader meets it first.* None of them is fixed
by rewriting the August text — §6 and this project's whole method forbid that. All three are
fixed by **marking**, which is the only move that is both honest and additive.

**The acceptance gate returned `ACCEPT` on this workbook and the six findings were fixed anyway.**
§4a stops at `ACCEPT`; it does not say to ignore line-level findings that an accepting gate still
raised.

### §4a review — round 2, and the accident that measured the gate itself

`governance/memory-policy.md` round 2: **`ACCEPT`, `blocking: []`** — the nine round-1 findings do
not recur. Its five new findings are tabled in that file's §7.

**This workbook's round 2 ran TWICE, by accident, and the two panels disagreed at the gate.** I
asked a delegated agent for a status check and then started the same review myself before its
reply arrived. Both completed, on byte-identical text:

| Run | File | Gate | Blocking |
|---|---|---|---|
| mine | `findings/opencode/review-README-20260929T114922Z.md` | **REJECT** | 1 |
| the subagent's | `findings/opencode/review-README-20260929T115059Z.md` | **ACCEPT** | 0 |

**That is a free measurement nobody designed, and it is the most useful thing in the round.**
Two runs of the same gate model on the same bytes returned opposite verdicts. It does not make
either wrong — the REJECT's blocking finding is real and is fixed below — but it does mean **an
`ACCEPT` from one run is a sample, not a property**, which is exactly what this session concluded
about `verify-codex-isolation.sh` from the other direction. `n = 2` runs, 1 artifact, 1 gate
model: true of these two runs, and not a rate.

**The blocking finding, and it is inherited August text rather than mine.** The learning-store
schema carries `embedding vector(768), -- only at step 4 below`, and **no step of this ladder adds
embeddings**: counting from Lab 9.4, step 4 is Lab 9.7, which says *"Do not add embeddings yet"*;
counting only the build labs, step 4 is Lab 9.8, which wraps the store in MCP. Marked, not
rewritten — the same resolution as round 1's findings 11–13.

The seven non-blocking findings across both panels, and what was done:

| Finding | Rec. | Action |
|---|---|---|
| `10 + 1 + 7 + 7 = 25, five disjoint classes` — **four addends for five classes** | **2/2** | **fixed** — 10 + 1 + 5 + 2 + 7, with the superseded form kept so the error is visible |
| Exit gate clause 1 cited a run with **all-null hashes** as proof that instructions *are* delivered | 1/2 | **fixed** — that run is a control; a null hash proves the control assertion, and E-003's treated run is what proves delivery |
| The §4a section ended *"Round 2 was run"* with **no outcome** | 2/2 | **fixed** — this section |
| The validation table gave a **time-varying count** as a re-derivation instruction | 1/2 | **fixed** — a stranger should get a *different* number; what re-derives is the order of magnitude and the direction |
| *"...nothing executes over any of **them**"* — the pronoun attaches to the 25 or the 7 | 1/2 | **fixed** — the heading now says *no control executes over the corpus* |
| `L2` here vs *"not a layer"* in the guardrail table, **both about absence**, with no stated rule separating them | 1/2 | **fixed** — this column grades *the proof of a claim*; that table grades *a control over the corpus*. Two objects, one of which is the absence of the other |
| *"18 rows a command decides"* **should be 20** | 1/2 | **fixed by stating all three numbers**: 18 decided by running a command, 2 with a command that exists and was deliberately not run, 5 with no command at all |
| The `## Verified reading` **✅ marks** prime a broader expectation than *the URL resolves* | 1/2 (gate-disputed in the other panel) | **fixed by marking** — and the panel's own words are the reason: it is *"the same false-assurance shape this workbook names for `check-links.sh`, applied one level up to its own heading"* |
| The Extract's **paraphrased** vendor claims carry no staleness marker | 1/2 (gate-disputed in the other panel) | **fixed by marking.** The two panels disagreed about whether the dated header already covered it; marked anyway, because the cheaper error is over-marking |

**Two of the nine were disputed by one panel's own gate and raised by the other's.** Both were
fixed rather than arbitrated, which is the only disposition that costs nothing when the reviewers
disagree.

### §4a review of the two gate scripts — the round that changed an instrument

The previous session left the instruction *"review the workbook, the manifest and **both
scripts**"*. §4a says *"every tool under `tools/`"*, and `tools/verify-quotes.sh` is a gate
script, so it got the `-P` panel §4a asks for on a registered variable.

| Script | Panel | Findings file | Gate |
|---|---|---|---|
| `tools/verify-quotes.sh` | **`codex` + `ollama-cloud/deepseek-v4-pro`**, both ok (30 s, 315 s) | `findings/opencode/review-verify-quotes-20260929T115705Z.md` | **REJECT**, 6 findings |
| `tools/verify-quote-checker.sh` | `ollama-cloud/glm-5.2`, `-n 2` | `findings/opencode/review-verify-quote-checker-20260929T120325Z.md` | **REJECT**, 5 findings |

**This is the round that justified running it.** The fixture set was green at 29 of 29 and
ShellCheck was clean, and the panel still found six defects in the checker — because *the
fixture set is the review that executes and the harness is the one that reads, and they do not
catch the same class.*

| # | Defect in `verify-quotes.sh` | Disposition |
|---|---|---|
| 1 | **Path traversal.** A page key containing `../` makes every `cp`/`curl` write to `"$TMP/$key.html"` — *outside* the mktemp directory, so the `EXIT` trap never removes it and the verifier writes into the tree | **fixed** — keys are `[A-Za-z0-9_-]+`, exit 4, before any fetch. Fixture **R** |
| 2 | **`\|` is the split delimiter.** A key containing `\|` breaks `key=${entry%%\|*}`, so the URL silently becomes the wrong string and **the page fetched is not the page declared** — whose quotes then report `ABSENT` at exit 2, indistinguishable from real drift | **fixed** — same grammar. Fixture **S** |
| 3 | **Tab disagreement.** The manifest parser keeps every tab after the first; the matcher's `IFS=$'\t' read` does not. A quote carrying a tab was **silently different in the two places** | **fixed** — refused at exit 4 rather than truncated somewhere else. Fixture **T** |
| 4 | **A cached page was indistinguishable from a live fetch** — byte-identical result line, same exit code, nothing saying whether the network was touched | **fixed** — every line and the summary now carry the source (`claude=live`). Fixture **U** |
| 5 | `strip()` removes only `<script>`/`<style>`, so CSS-hidden body text counts as present | **disputed as a scoped limitation** — the same disposition stop 23 gave the same finding. A sentence *in the DOM* is on the page; whether it is *visible* is a different question this instrument does not claim to answer, and the header says so |
| 6 | The matcher is an unanchored `grep -qF`, so a deleted sentence that survives as a substring of another reports `FOUND` | **disputed, with the direction stated** — the defense is that the manifest carries full sentences. Both 5 and 6 bias toward `FOUND`, i.e. toward **under**-reporting staleness, so if they bit at all the true absent count is **higher than 5 of 8**, never lower. The headline is safe in the direction that matters |

**And then the fixed instrument was re-run against the recorded measurement, because a fix to a
gate script after that script produced a result is exactly where this project has been burned.**

```
pre-fix   manifest=quotes-p09 found=3 absent=5
post-fix  manifest=quotes-p09 found=3 absent=5 sources=claude=live
```

**Identical, cell for cell** (`diff` over both, `evidence/p09/quote-verification-20260929T1215Z-postfix.txt`).
The stop-23 parity check reproduces too: `found=28 absent=1`, seven pages, all `live`. **None of
the six defects touched this stop's result**, and that is now a measurement rather than an
argument. The fixture suite goes **29 → 37 cases**, ShellCheck clean.

**The fixture set's own review was REJECT, and its central claim is refuted by observation.**
It held that cases K, L and M *determinately fail on macOS* because BSD `sed` treats `\t`
literally and BSD `grep` lacks `\|`. Both were checked byte-exactly **on macOS**:
`od -c` shows the substitution emitting real tabs on both sides, and the `grep` alternation
matches its target while still refusing a non-matching string — its own negative control.
Recorded in `evidence/p09/dispute-bsd-sed-grep-20260929T1213Z.txt`. **The finding deserved an
observation rather than an argument**, because its failure mode would have been the house one:
three cases green while testing nothing — which `29/29` alone would never have caught.

Its two real findings were fixed: the suite **checked for none of the four external commands it
depends on**, so a missing `python3` could have looked like a test failure, and the header did
not name the platform semantics the fixtures rely on. There is now a dependency preflight that
exits **2** — distinct from a case failure's **1** — and it is **proved against a real absence**:
run with `python3` removed from `PATH`, the suite exits 2 and names it.


### The gate script's round 2 found a regression **I** had just introduced, and it is the best finding of the stop

`findings/opencode/review-verify-quotes-20260929T121637Z.md`, same `codex + deepseek-v4-pro`
panel. **`REJECT`, and it was right.** The page-source fix of round 1 used `declare -A`.

```
$ /bin/bash --version          GNU bash, version 3.2.57(1)-release   ← what /bin/bash IS here
$ bash --version               GNU bash, version 5.3.15(1)-release   ← what `env bash` resolved to
$ /bin/bash -c 'declare -A x'  declare: -A: invalid option
```

**The script's own header, four lines above the code I wrote, says
*"Bash 3.2 ships on this machine, so this is a string membership test and not an associative
array."*** I added one anyway. It passed the 37-case suite, ShellCheck, and two manifest re-runs
— **because every one of those ran under the 5.x Homebrew build the shebang resolved to.**

**This is the house failure mode with nothing left out:** green everywhere, on a platform the
artifact itself names, invisible to a fixture set *because every fixture ran under the same wrong
interpreter*. No amount of adding cases would have caught it. The fix is a newline-delimited
string with a tab separator — the same idiom the header prescribes — and it also removes the
non-deterministic `sources=` ordering the same finding named, because the order is now the
manifest's rather than a hash's.

**Case V pins the interpreter instead of the behaviour**, which is the only kind of fixture that
could have caught this: it runs the checker under `/bin/bash` explicitly. Suite **37 → 39**.

And the measurement is unmoved for the third time:

```
original (pre-review)   found=3 absent=5
post round-1 fix        found=3 absent=5 sources=claude=live
post bash-3.2 fix       found=3 absent=5 sources=claude=live      ← under BOTH 3.2 and 5.3
p08 parity              found=28 absent=1, seven pages, all live
```

`diff` against the original: **identical, cell for cell.**

---

### §4a review — round 4 on the workbook, and a stall that still found something

The gate-script rounds above added two sections to this file after its round-3 `ACCEPT`, so §4a
step 3 owes a re-run on the revised artifact. That run is
[`findings/opencode/review-README-20260929T122628Z.md`](../../findings/opencode/review-README-20260929T122628Z.md)
and it is **not a clean review**: run 1 completed (glm-5.2, 243 s), run 2 **failed `rc=1`** at
461 s, and the acceptance gate then failed to run — `The gate failed to run (opencode exit 1).`
§4a step 1 classes exit 1 as infrastructure to discard and re-run.

**A stall and a defect are different things, and this file is both.** It is not header-only:
run 1 produced two line-level findings, at 1/1 recurrence because the denominator collapsed with
run 2. §4a's own rule says recurrence is a detection threshold and not a truth value, so both
were read on their merits. Both were right.

| # | Finding | Disposition |
|---|---|---|
| 1 | The TSV row's *"the sentences themselves stay **L3**"* contradicts the layer rule the same row had just applied | **Fixed**, additively, struck text kept |
| 2 | `## Exit gate` carries two **unchecked** boxes while the identical two clauses are ticked and answered 166 lines below | **Fixed** — boxes ticked, with a pointer to the answers |

**Finding 1 is the better one, and it refutes a sentence I wrote while correcting a different
mislabel in the same row.** The struck sentence said nothing stops a wrong transcription being
added, *"which is exactly how rows 3 and 4 got in"* — but rows 3 and 4 are two of the five the
checker **reported absent**. Something executed and rejected them; that is L2 by the rule, and
the sentence cited the checker's own catch as evidence that nothing catches it.

The corrected label splits the sentence in two, which is what the rule produces when applied in
order rather than to the artifact as a whole:

- **sentence ↔ page: L2.** A transcription that is not byte-present on the fetched page is
  refused at exit 2.
- **sentence ↔ claim: L3.** A sentence that *is* byte-present but does not support the claim the
  extract hangs on it passes silently. Row 1 — the reversed claim — is that case, and it is why
  the three-way split had to be adjudicated by hand.

**This is the third time at this stop that the layer rule came out differently when applied in
order to one binding at a time instead of to the artifact**, and all three moved in the direction
`CLAUDE.md` does not warn about: not a schema note mistaken for a control, but a control mistaken
for absent.

---

### §4a round 4, third attempt — the panel that two stalls had been hiding, and it was right twice

Two attempts on the default `glm-5.2` critic failed: one completed run 1 and lost the gate
(`exit 1`), one produced a 762-byte header and nothing else. Both files are committed. The third
attempt used **`-P codex,deepseek-v4-pro`** — the panel §4a reserves for registered variables, and
the route around this machine's known stall mode — and both families returned: codex in **48 s**,
`deepseek-v4-pro` in **107 s**, against 243 s and a 461 s failure from the stalling critic.

**Verdict `REJECT`, `blocking:` with two entries, and both were contradictions inside text this
stop wrote.** Not in the August material, which has been marked five times over; in the September
sections.

| | Blocking finding | Disposition |
|---|---|---|
| 1 | The §"Lab 9.4 executed" head claim said **"25 individually decidable assertions, each with the command that decided it"** — six lines above its own table reading `undecidable by command: 7` | **Fixed.** The 18 / 2 / 5 split is now at the head claim, where a reader meets it, and the struck sentence is kept |
| 2 | The validation table graded **`L1` in three incompatible senses**, one of which the workbook's own layer table refutes eighty lines earlier | **Fixed.** Five rows regraded, two keep `L1` with the sense named, and the three senses are tabled |

**Blocking 1 is this stop's own lesson failing against this stop's own artifact.** The 18/2/5
split was added to the validation table because a round-2 panel pressed on it. The head claim
upstream was left saying something else — which is *precisely* the defect an earlier round caught
in this same file, whose fix was supposed to be general: **mark the upstream text, do not only
correct the narration.** It was not general. It was one edit.

**Blocking 2 makes four layer mislabels at one stop, in four artifacts, every one over-claiming**
— and three of the four were found by the review, after I had written a section about the layer
rule and corrected three of my own labels inside it. The regrade note under the validation table
states the rule that came out of it: **apply the two questions to one binding at a time, not to a
table.**

**The ten line-level findings, every one at 1 of 2 runs, and what each got.** §4a's rule that
recurrence is a detection threshold and not a truth value is doing real work here: nine of these
ten were raised by exactly one of two families, and eight of them were right.

| # | Finding | Disposition |
|---|---|---|
| 1 | *"Unambiguous, and it was in the docs the whole time"* still reads the reversed August quotation as settled, below a marker that covers only the quotation | **Fixed** — the marker now names the paragraph too |
| 2–5 | §"Predict before you run" and Labs 9.1–9.3 define no observation boundary, no exclusive outcomes and no combining rule, so one trace scores either way | **Fixed by marker, and disputed in part.** These labs are **deferred at `n = 0` runs**, so nothing has been scored ambiguously. Writing their decision rules is §4 step 3 of the stop that runs them, not of the stop that reads the phase. The marker is the guard against a later session mistaking an August sketch for a registered design |
| 6 | *"Everything above this line was written 2026-08-09 and is kept verbatim. Nothing in it is edited"* — contradicted by the dated markers since **added** above it | **Fixed.** No sentence of the August text is edited; markers were added beside it. The wording now separates the two acts and says why §6 forbids only one of them |
| 7 | The schema's `embedding vector(768) -- only at step 4 below` resolves to no step that adds embeddings | **Already fixed at round 2**, by the marker directly under the block; this is a recurrence against a fix the critic did not read as one. No further change |
| 8 | Lab 9.5's frontmatter block is **not valid YAML** — three pairs on a line parse as one scalar, so four of six fields do not exist | **Fixed.** August block kept unedited, parseable form added beside it. The lab whose point is checkable provenance was shipping frontmatter whose provenance fields silently were not there |
| 9a / 9b | The same two contradictions the gate blocked on | **Fixed**, above |
| 10 | Cross-cutting: exit-gate clauses duplicated as validation gates; labs define no trial boundaries; the layer rule is applied inconsistently to evidence records | **Half fixed, half disputed.** The layer half is the regrade. The duplication half is **disputed**: §5 of the run prompt requires the validation table to carry each gate clause *verbatim* and answer it from evidence, so the clause appearing in both places is the instrument's design and not a defect in the artifact |

**Nothing in the audit's numbers moved.** The two blocking findings were about sentences that
described the measurement, not about the measurement: `found=3 absent=5` on the extract and
10 / 1 / 5 / 2 / 7 on the memory corpus are the same before and after, and the evidence files
they were read from are untouched.

---

### The gate script's round 3: two blocking defects, and one of them could have inflated the headline

`findings/opencode/review-verify-quotes-20260929T143000Z.md`, the `codex + deepseek-v4-pro` panel
again, against `tools/verify-quotes.sh` at sha `7b8eebaadddc`. **`REJECT`, two blocking entries,
four line-level findings, and every one of them new** — none is a repeat of the two disputed in
round 1 or the `declare -A` regression of round 2.

| | Defect | Disposition |
|---|---|---|
| **blocking 1** | The cache filename was `<manifest-slug>-<key>.html` — basename plus page key, **and not the url**. Two manifests sharing a basename and a key but declaring different urls collided; the second read the first's page and printed `sources=<key>=cached` for a url it never fetched | **Fixed.** The name carries a 12-char sha of the url. Fixtures **X** and **Y** |
| **blocking 2** | The `<script>` / `<style>` strip was **case-sensitive**, so a `<SCRIPT>` block survived and a sentence living only inside it reported `FOUND` | **Fixed** (`re.I`). Fixture **W** |
| line 3 | deepseek: a literal space after the tab in the manifest parse would put a leading space in every quote | **Refuted by observation, not argument.** `od -c` on the line shows `QUOTES="$QUOTES$key \t $val \n` — tab, value, newline, no space. The acceptance gate also disputed it, for a different and wrong reason |
| line 4 | `strip()` collapses every whitespace run in the **page**; the matcher searched the **quote** raw. A quote carrying a double space could never match text that was present | **Fixed.** The quote is collapsed by the same rule. Fixture **Z** |

**Blocking 2 is the house failure mode again, in the one place this stop had already named it.**
The file's registered limitation reads *"`strip` removes `<script>` and `<style>`"*. It removed
lowercase. A reader building a fixture to prove script content is excluded would have got `FOUND`
and trusted it — **a control reporting over a scope smaller than it claims**, written into a
script whose own workbook section is about that exact sentence.

**Line 4 is the only finding at this stop that could have moved a number, and it moves it in the
direction nobody checks.** Every previously disputed defect biased toward `FOUND` — toward
*under*-reporting staleness, so the headline was safe. This one biases toward `ABSENT`: a false
absence **inflates** a staleness count. `5 of 8` is the stop's headline. So it was checked rather
than argued: `awk` over both manifests finds **no quote carrying a double space, a tab or a
trailing run**, and the re-run after the fix returns the same cells. It did not bite. It is fixed
because the next manifest is not protected by that fact.

**Every new case fails against the pre-fix script**
(`evidence/p09/prefix-refusal-proof-20260929T1439Z-round3.txt`) — W `0`, X `0`, Y `3`, Z `2`,
against post-fix `2`, `3`, `0`, `0`. **Y is the negative control for X**: without it, X would pass
just as well against a checker whose cache never worked at all. Suite **39 → 47** cases,
ShellCheck clean on both scripts, and the pre-fix bytes stay recoverable as
`git show 06851b5:tools/verify-quotes.sh` — verified to hash to `7b8eebaadddc`, the same sha the
review header recorded.

**And the measurement is unmoved for the fourth time**, cell for cell by `diff`, on both corpora:

```
p09   pre-round-3   found=3  absent=5  sources=claude=live
p09   post-round-3  found=3  absent=5  sources=claude=live
p08   pre-round-3   found=28 absent=1  seven pages, all live
p08   post-round-3  found=28 absent=1  seven pages, all live
```

**Eleven defects have now been found in this instrument across three review rounds and none of
them changed a single cell of its output.** That is worth saying plainly rather than as a boast:
the review harness is finding real defects in a tool whose *result* has been right the whole time,
which means its value here is not in correcting this stop's number but in the next manifest, the
next phase and the next reader — and none of that is measured by anything at this stop.

---

### Past the round cap: two more rounds, sixteen more findings, and a real orphan in real evidence

§4a caps the revision loop at **three rounds per artifact**. This stop ran **five** on the
workbook and **four** on the gate script, because each round kept returning findings that were
right. What follows is the record of the rounds past the cap and, more importantly, **the reason
the loop stopped where it did: the cap, not convergence.**

**Round 5 on the workbook — the gate never ran.** `findings/opencode/review-README-20260929T144108Z.md`:
codex `ok` 49 s, `deepseek-v4-pro` `ok` 128 s, and then *"The gate failed to run (opencode exit
1)"* on `minimax-m3` — **the third acceptance failure of the day on that model**, and the second
that sat wedged past its own 600 s stall budget. Line-level findings were kept: **12 sections,
1 at 2 of 2, 11 at 1 of 2.**

| # | Finding | Disposition |
|---|---|---|
| 1 | `- [ ] ✅` — an **unticked box beside a green tick**, and nothing in the file said what either mark meant. Readable as *unread* or as *not verified*, which are opposite claims about opposite things. **The only 2-of-2 finding of the round** | **Fixed.** Both marks defined where they appear; the boxes are left unticked because ticking them would be this run asserting a human act it cannot observe |
| 9 | *"the three-way split reproduces"* rests on an **unstated mapping** between the extract's classes and the memory corpus's | **Fixed.** The mapping is now a table, and it states that **only the first two rows are claimed** — counts are not compared and no rate is transferred between corpora |
| 12 | The block marker listed **"the size figures"** among what was *not* re-checked — while **one of the eight quotations is a size figure**, row 3, found *never verbatim* | **Fixed**, struck not deleted. The marker told a reader the opposite of what the pass had found about the one it checked |
| 6 | `verify-quotes.sh` passes a byte-exact sentence whose surrounding qualifier changes the claim, with no adjudication rule | **Already fixed at round 4** — that is the *sentence ↔ claim is L3* split, added because the same defect was found from the other direction. No further change |
| 2–5, 7, 8, 10, 11 | Eight findings against the **August material**: labs with no scored boundary, *"live right now"* unobserved, a *"2 occurrences"* rule with no independence condition, a vendor-claims banner covering the project's own normative lines | **Recorded, not acted on — see below.** Findings 2–5 are already covered by the deferred-labs marker added at round 4 |

**Round 4 on the gate script — `REJECT`, one blocking, four line-level, and it found something
real on its first run.** `findings/opencode/review-verify-quotes-20260929T172331Z.md`. Two of the
four are **repeats of findings already disputed in writing** (markup text counting as present;
the unanchored `grep -qF`), which is the expected behaviour of a dispute and not a new defect.
**None of the three round-3 fixes reappeared**, which is the only evidence available that they
did not regress.

**The blocking one: a declared page that no quote references.** The validator asked *"does every
quote name a declared page"* and nothing asked the inverse, so an orphan see-also page was
fetched anyway — and a dead URL on it would kill the **whole** manifest at exit 3, *"nothing was
proved either way"*, with every verifiable quote lost behind an exit code indistinguishable from
a fetch failure on the page that carried the drift signal.

**It was written as a refusal first, and the refusal rejected real evidence on its first run.**
`evidence/p08/quotes-p08.tsv` declares page key `home` — `https://github.github.com/gh-aw/` —
and quotes it **nowhere**. So does stop 23's own script, at
[`evidence/p08/verify-quotes.sh`](../../evidence/p08/verify-quotes.sh) line 40, from which that
manifest was transcribed mechanically. **Stop 23's instrument has been fetching a page it never
used, and had that URL 404'd, its entire 29-quote result would have died with nothing reported.**
That stop is closed and its script produced a measured result, so §6 keeps it untouched and this
is recorded rather than repaired.

**So the fix is a skip, not a refusal, and that is not a softening.** An orphan page can never
add a quote and can only abort a run. It is no longer fetched, it is named on stderr **and in the
summary line** — `skipped-orphan-pages=home` — because stderr is discarded by every caller that
redirects, and a page silently not fetched is precisely the narrowed scope this stop spent its
review budget on. Fixtures **AA** (the orphan's URL is the unreachable `example.invalid`, so the
case fails at exit 3 if the skip does not happen) and **AB**, its negative control: without AB
the check would pass equally against a checker that skipped every extra page, and `quotes-p08.tsv`
has seven. Suite **47 → 52**.

**And for the fifth time the measurement does not move**, cell for cell by `diff`:

```
p09   found=3  absent=5   sources=claude=live
p08   found=28 absent=1   sources=… skipped-orphan-pages=home     ← the skip is the only new text
```

#### What was NOT acted on, and why that is the honest end of step 13a

Eight round-5 findings against the August material are **recorded and left**. Every one targets a
lab design or a claim this stop **deferred**: `n = 0` runs belong to Labs 9.1–9.3, nothing here
has been scored, so nothing here has been scored ambiguously, and §4 step 3 is the thing that
forces a decision rule — before the first run of the stop that runs them, not at the close of the
stop that reads the phase. The round-4 marker above the labs says so in the file.

**The reason to stop is the cap, and it should be said plainly rather than dressed as
convergence.** Across five rounds on the workbook and four on the gate script the review returned
**four blocking contradictions — all four mine — and eleven distinct defects in one instrument**,
and the rate had not flattened when the rounds ran out. **Not one of them changed a cell of any
measurement.** Whether a review that keeps finding real defects in a tool whose *result* never
moves is worth its cost is the question this stop most wants answered and cannot answer: §4a's
three-round cap exists precisely so the loop terminates, and here the cap did the deciding.
