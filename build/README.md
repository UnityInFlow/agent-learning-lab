# Track B — Build a custom backend agent

Thirteen steps from *plain prompt* to *governed, self-learning agent*. Each one adds
complexity to a real agent, so each one has to clear the same bar:

> Consider adding complexity **only** when it demonstrably improves outcomes.

Track A ([`../LEARNING-PATH.md`](../LEARNING-PATH.md)) teaches the primitive. Track B applies
it. **Do the Track A phase first** — otherwise each build step is a guess you cannot defend.

## The shape of the thing you are building

```
Task
 ↓
Provider adapter        ← thin. Claude / Codex / Copilot specifics live ONLY here
 ↓
Backend agent           ← mission, boundaries, workflow, tools, output contract
 ├── core rules         (L3 — guidance)
 ├── workflow phases    (L3 — structure)
 ├── selected skill     (L3 — situational knowledge)
 ├── selected knowledge (L3 — retrieved, untrusted)
 └── allowed tools      (L2 — the only line here that constrains anything)
 ↓
Implementation → deterministic verification    (L2 — the claim becomes evidence)
 ↓
Run artifacts + events → evaluation → promote or reject
```

**Note how much of the agent is Layer 3.** The tool list and the verification script are the
only parts that constrain rather than suggest. See [`../GUARDRAILS.md`](../GUARDRAILS.md).

## The steps

| | Step | Track A first | Version |
|---|---|---|---|
| [B1](#b1) | Experiment contract | 0B | — |
| [B2](#b2) | Plain-prompt baseline | 0A + 0B | — |
| [B3](#b3) | Minimal global instructions | 1 | — |
| [B4](#b4) | Agent boundary | 4A | v1.0 |
| [B5](#b5) | Workflow phases | 4B | v1.0 |
| [B6](#b6) | One specialist skill | 3 | v1.0 |
| [B7](#b7) | Deterministic verification + policies | 5A | v1.0 |
| [B8](#b8) | Run state, repair limits, completion contract | 5B | **v1.1** |
| [B9](#b9) | Knowledge router + hit rate | 6A + 6B | v1.2 |
| [B10](#b10) | Port the adapter to a second runtime | 4A | v1.2 |
| [B11](#b11) | Efficiency: caches, budgets, dedup | 6B + 10 | v1.2 |
| [B12](#b12) | Governed self-learning | 9 | **v1.3** |
| [B13](#b13) | Production observability + promotion gate | 10 | — |

---

<a id="b1"></a>
## B1 — Experiment contract

**Build:** a task, a rubric, a run record. Nothing agent-related.

**Why first:** without a stable task and a stable way to record a run, every later comparison
is an opinion. Your own doc: *"Do not create the backend agent yet."*

**Files**
```
../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/
                                 the task, acceptance criteria, forbidden changes,
                                 evaluator.sh, and eight fixtures — lives in the
                                 benchmarks repo, not here
benchmark/rubrics/backend-quality.yaml
                                 0–2 per category, weighted, normalized 0–100
templates/run-record.yaml        every field, and whether it is exact/estimated/absent
```

> **The task moved.** It is `tasks/BE-003-confirm-shipment/` in
> [agent-observatory-benchmarks](https://github.com/UnityInFlow/agent-observatory-benchmarks),
> merged in benchmarks#9 and #10, because the evaluator that reads it has to run beside the
> service under test. Nothing named `benchmark/tasks/` or `runs/` exists in this repo.

**The task.** `confirm-shipment` — `POST /shipments/{id}/confirm`, validate state, idempotent
on repeat, persist `CONFIRMED`, correct status codes, unit + integration tests, no new
dependency, no unrelated refactoring. It exercises REST design, service logic, persistence,
transactions, state validation, idempotency, error handling and testing in one task.

**Two gates, never merged**

```
Quality gates (pass/fail)        Quality score (0–100, weighted)
build passed                     functional correctness   25%
required tests passed            requirement completeness 20%
acceptance criteria 100%         architecture consistency 15%
forbidden changes = 0            test quality             15%
critical findings = 0            error handling           10%
                                 maintainability          10%
                                 change focus              5%
```

> **The score half of that table is superseded.** Applied to BE-003 it failed twice over:
> `functional-correctness` (25) and `requirement-completeness` (20) restate the gates, so they
> are constant across every submission the rubric is allowed to score, and `test-quality` (15)
> had no fixture with tests. Sixty percent of the weight carried no information. The
> replacement is four categories — architecture-consistency 35, maintainability 25,
> test-quality 25, change-focus 15 — anchored on differences observable *between fixture
> pairs*. Written in #21. The gates on the left are unchanged and still own correctness.

> **A run that fails a gate is unsuccessful even when it used fewer tokens.** Compare
> efficiency only among runs that passed. This is the single most important rule in the
> business case and your analyzer does not yet implement it.

**Token honesty.** Every usage value carries its provenance:

```yaml
input_tokens: { value: 12400, source: provider,        estimated: false }   # Level A
input_tokens: { value: 11950, source: local-tokenizer, estimated: true  }   # Level B
input_tokens: { value: null,  source: null,            estimated: null  }   # Level C — record proxies
```

> **Unknown data remains unknown.** `null`, never a plausible number. A gap that reads as a
> zero is how `BehaviorDto` currently lies to you.

The shape lives in `templates/run-record.yaml`, and on its own it is **Layer 3** — a template
constrains nothing, and `inputTokens: 12400` stays perfectly writable. `tools/validate-run-record.sh`
is the Layer 2 version: it executes, it rejects a bare number, and CI runs it on every PR.
`tools/verify-run-record-validator.sh` registers eleven fixtures with the exit code each must
produce, because a control that has never been shown to reject anything is indistinguishable
from one that rejects nothing.

**Gate:** one task repeats · one run record completes **and validates** · one quality score computes.

---

<a id="b2"></a>
## B2 — Plain-prompt baseline

**Build:** nothing. Measure.

No agent, no skill, no hook, no instructions. Task prompt only. Same provider, same **exact
model ID**, same commit, same verification.

**Three runs minimum, five preferred.** One run is a story.

**Run it isolated** — `--setting-sources project --strict-mcp-config` for Claude (the runner
exposes this as `--isolate-user-settings`), `--no-custom-instructions` for Copilot. Without
that you are measuring your ~21 local hooks, not the baseline.

**Not `--bare`.** It disables `CLAUDE.md` discovery, which B3 onward depends on, and it does
not authenticate on a subscription account at all. `EXP-BE002-NOHOOKS` measured what the
isolation is worth: hooks cost ~13% of every run, on both arms almost equally.

**Record per run:** which files it inspected · did it understand the architecture · did it
verify its own work · what needed correction · which metrics were even available.

**Gate:** ≥3 run folders with diffs, verification results and completed rubrics · a baseline
report with **median and range**, never an average alone.

> Everything after this is measured against B2. If B2 is sloppy, nothing downstream means
> anything.

### The gate's "completed rubrics" has no instrument yet — read before starting B2

`make baseline-runs` produces runs, diffs and deterministic evaluator results. **Nothing
applies `benchmark/rubrics/backend-quality.yaml` to a run's output.** The rubric is not
referenced anywhere in the observatory's `runner/`. The two halves exist in two repos and the
seam between them does not. Discovered 2026-08-28, before B2 rather than during it.

**The scorer would refuse a B2 run outright.** `codex-score.sh` admits a target only if
`basename` appears in `known-good` + `QUALITY_VARIANTS`, parsed from the benchmarks'
`verify-evaluator.sh`, and otherwise exits 1 with *"not a registered gate-passing variant"*.
A B2 run's output is not a fixture name. That filter is correct for B1, where the scored
population is exactly five fixtures; B2 asks the same question — *did this clear every gate?*
— and has a different answer for it.

**The invariant that must not change:** this rubric only scores submissions that cleared every
gate. A score on a gate-failing submission is a different measurement wearing these units.
What changes is only how "cleared every gate" is established.

| | Path A — fixture (B1, unchanged) | Path B — run (B2, to build) |
|---|---|---|
| target | a fixture directory | `--run-id <id>`, **not** a directory |
| proof of gate-pass | the name is in the benchmarks registry | the recorded evaluation for that run is `passed` / `exitCode 0` |
| where the directory comes from | the argument | resolved by the scorer as `${TMPDIR:-/tmp}/observatory-run-<id>` |
| no proof available | refuse | refuse — an unevaluated run is not a passing one |

**Take `--run-id`, never `--dir` plus a `--gate-passed` flag.** A flag is a promise by the
caller — Layer 3 wearing Layer 2's clothes, which this project has already paid for six
times. And `--dir X --run-id Y` lets the two disagree. Resolving the directory *from* the id
makes the mismatch unrepresentable, which is Layer 1: there is no way to write the bad state
down. The runner already names the worktree `observatory-run-${RUN_ID}`, so this costs
nothing to adopt.

**Run B2 with `--keep`.** Step 12 of `run-agent.sh` cleans the worktree. Without `--keep`
there is nothing left to score, and you will not find out until after the runs are done.

**Provenance must gain `run_id`, `evaluator_exit`, and the API the scorer asked.** A B2 sheet
that cannot be traced back to the run that produced it is not evidence.

**THE OPEN DECISION, and it is not a detail.** A B1 fixture is a 2–3 file overlay. A B2 run's
worktree is the whole service — 25 files. The scorer inlines every `.kt` it finds, so **B2
sheets and B1 sheets would be produced from evidence sets an order of magnitude apart.** The
attachment set is a registered variable. Either the scorer restricts a run to its changed
files, or B1 and B2 sheets are never compared to each other and that is written down where
someone would otherwise try. Decide it before the first B2 run, not after three of them.

---

<a id="b3"></a>
## B3 — Minimal global instructions

**Track A: [Phase 1](../phases/01-instructions/) · Layer 3 — guidance only**

**Build:** the smallest instruction file that changes measured behaviour.

Start with rules B2 actually violated. Candidates:

- inspect existing patterns before creating new ones
- make the smallest cohesive change
- do not add dependencies without approval
- run the repository verification command
- **do not claim completion when verification fails**

**The trap Phase 1 already cost us:** delivering the file is not delivering the treatment.
Claude reads `CLAUDE.md`, not `AGENTS.md`. Assert the content reached the model — hash it,
and preflight-check that the hash appears in context — before the first run.

**Gate:** version it `instructions-v0.1` · each rule has a stated expected effect · 3 controlled
comparisons vs B2 · **remove every rule with no measured effect.**

---

<a id="b4"></a>
## B4 — Agent boundary

**Track A: [Phase 4A](../phases/04a-agents-permissions/) · Layer 2 — tool list only**

**Build:** one narrowly scoped `backend-feature-implementer`.

Ten sections, no more: mission · supported tasks · required inputs · allowed tools ·
boundaries · workflow · skill-selection rules · output contract · escalation conditions ·
completion rules.

```
Allowed     inspect relevant code · modify relevant code and tests
            run approved commands · produce analysis and verification summaries
Prohibited  deployment · infrastructure · credentials · unrelated refactoring
            destructive schema changes · new dependencies
Approval    breaking API change · destructive migration · cross-module architectural change
            security-sensitive redesign · new external dependency
```

**The one that bites:** if `tools:` is omitted, Copilot custom agents get **all tools**. Name
them explicitly. And remember the agent's *description* is Layer 3 — only the tool list
constrains.

**Gate:** 3 comparisons vs B3 · record specifically whether the **diff became more focused**,
since scope discipline is what a boundary buys.

---

<a id="b5"></a>
## B5 — Workflow phases

**Track A: [Phase 4B](../phases/04b-orchestration/) · Layer 3, unless you split structurally**

**Build:** `ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE`, with an
output contract per phase.

| Phase | Must produce |
|---|---|
| ANALYSIS | restated goal · repository findings · risks · affected files · open questions |
| DESIGN | proposed change · alternatives · data and error flow · test strategy |
| IMPLEMENTATION | focused code matching the design |
| VERIFICATION | commands · results · failures · fixes |
| REVIEW | acceptance-criteria mapping · diff review · unresolved findings |
| DONE | completion contract passed |

**Purpose:** prevent premature coding and false completion. **Cost:** tokens. Measure both —
phases skipped, failed exits, time per phase, and the token overhead.

Risk profiles come later, and only if measured:

```
QUICK      ANALYSIS → IMPLEMENTATION → VERIFICATION → DONE
STANDARD   the six above
HIGH_RISK  + APPROVAL after DESIGN, + SECURITY_REVIEW and HUMAN_APPROVAL before DONE
```

**Gate:** phase markers observable in the transcript · no code written before DESIGN ·
overhead measured, not assumed.

---

<a id="b6"></a>
## B6 — One specialist skill

**Track A: [Phase 3](../phases/03-skills/) · Layer 3**

**Build:** exactly one. Chosen from a **measured** failure in B2–B5, not from a wish list.

Candidates: `database-change` · `testing-and-verification` · `spring-backend-feature`.

A skill answers eight questions: when it activates · when it must not · required inputs ·
workflow · which references may load · which scripts run · required output · how success is
verified.

**Gate:** activation is *recorded*, not inferred from the answer text · runs with and without
compared on quality, tokens, context and corrections · keep, modify, or **remove**.

---

<a id="b7"></a>
## B7 — Deterministic verification and policies

**Track A: [Phase 5A](../phases/05a-guardrails/) · Layer 2 — real enforcement**

**Build:** one verification entry point, and policy as code.

```bash
scripts/verify.sh          # compile · unit · integration · format · static analysis
                           # architecture tests · forbidden-change check
                           # stage-structured output, machine-readable exit code
```

```yaml
policies/protected-paths.yaml       policies/command-policy.yaml
policies/allowed-dependencies.yaml  policies/database-policy.yaml
```

**Do 5A.1 first — remove a capability before policing it.** Every hook you avoid writing is a
hook you never have to test, tune, or explain a false positive for.

**Gate:** one command, one exit code · intentional violations tested · false-positive rate
measured on legitimate commands · policy events recorded.

---

<a id="b8"></a>
## B8 — Run state, repair limits, completion contract · **v1.1**

**Track A: [Phase 5B](../phases/05b-verification-selfhealing/) · Layer 2**

**Build:** the three things that turn v1.0's prompts into enforcement.

**1. Persistent state** — `.agent/run-state.json`: phase, goal, affected files, last failure,
`repairAttemptsForCurrentFailure`, `totalRepairAttempts`. It must survive an interrupted
session.

**2. Hard repair limits**, enforced by hook or wrapper, never by prompt:

```
fingerprint = failure class + command + normalized primary error + affected module
same fingerprint  ≤ 3        total ≤ 7        on exceed → BLOCKED, not FAILED
```

**3. Completion contract** — `DONE` confirmed by a script, not asserted by the agent.

**And the classification fix:** BLOCKED ≠ FAILED. Permission blocks, quota exhaustion and
infrastructure faults are **infrastructure**, never incorrect code. This is harness bug #7,
and it currently voids every cross-model comparison you run.

**Gate:** counters persist across interruption · limits technically enforced · a blocked run
produces a clear machine-readable result · **no regression against the v1.0 benchmark.**

---

<a id="b9"></a>
## B9 — Knowledge router and hit rate

**Track A: [Phase 6A](../phases/06a-code-intelligence/) + [6B](../phases/06b-knowledge-retrieval/) · Layer 3 — untrusted**

**Build:** `knowledge/index.yaml` — triggers → summary → full document. **Not a vector DB.**

```yaml
topics:
  spring-transactions:
    triggers: [transactional, rollback, multiple repositories]
    summary: summaries/spring-transactions.md
    details: documents/spring-transactions-deep-dive.md
```

**Then instrument it:**

```
knowledge_hit_rate = useful knowledge matches / knowledge lookups
```

That number is what later justifies — or refuses — embeddings. Without it you can prove RAG
*ran*, not that it *helped*.

**Do not build a code or symbol index.** memtrace already provides `find_symbol`,
`find_code`, the AST graph and Cortex decision memory, and you pay for it every session.
Building vector search over your own repository duplicates a tool you already run. See
[Phase 9 — Architecture](../phases/09-memory/README.md#architecture-you-already-run-three-memory-systems).

**Gate:** retrieval order recorded per run (index → summary → full) · hit rate measured ·
context metrics compared against B8.

---

<a id="b10"></a>
## B10 — Port the adapter to a second runtime

**Track A: [Phase 4A](../phases/04a-agents-permissions/)**

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

**Gate:** ≥3 runs per runtime · compare quality, correction effort, usage **and observability
capability** · document each provider's limitations · pick primary and fallback.

---

<a id="b11"></a>
## B11 — Efficiency · v1.2

**Only after correctness is stable.** Efficiency work on an incorrect agent optimises the
wrong thing.

**Build, in this order:**

1. **Task classifier** — API / JPA / Kafka / cache / security / build / test-only / migration.
   Output drives what loads.
2. **Retrieval budget** — `max_similar_implementations: 2`, `max_initial_searches: 5`,
   `max_files_before_design: 15`, `max_full_log_lines: 0`. Exceeding requires a recorded reason.
3. **File-summary cache** keyed on `sha256` — reuse only on hash match; **never trust a stale
   summary.**
4. **Verification planner** — smallest safe sequence for the change type. Final independent
   verification stays unchanged.
5. **Command deduplication** against the current code fingerprint.

**Gate — all must hold vs v1.1:** same or better acceptance · same hidden-test success · fewer
repeated reads · fewer unnecessary tool calls · lower median input tokens · lower median
time-to-green · **no increase in material review corrections.**

> Efficiency improvements are rejected when quality declines. No exceptions.

---

<a id="b12"></a>
## B12 — Governed self-learning · **v1.3**

**Track A: [Phase 9](../phases/09-memory/) · Layer 3 — untrusted derived state**

**Build:** the pipeline that turns verified outcomes into durable knowledge without polluting it.

```
observation → learning candidate → validation → confidence
            → promotion → usage tracking → revalidation → expiration
```

**The rule:** only **verified** outcomes may become reusable knowledge. Never learn from
assumptions, failed repairs, transient outages, unverified commands, one-off preferences, raw
logs, secrets, or hidden evaluator content.

**Never write directly to active knowledge.** Candidates land in `knowledge/candidates/` with
full provenance: source run, source commit, the command, exit code, focused and broader
verification results, confidence, expiry.

```
Promotion policy
  build commands       1 successful verification + human approval
  failure patterns     2 successful occurrences   + human approval
  style/architecture   human approval always
```

States: `candidate → active → deprecated → rejected → expired`. **Never delete** — change
status, preserve history. On a failure caused by learned knowledge: mark suspect, stop reuse,
fall back to discovery, create a correction candidate.

**Where it lives.** The observatory's Postgres, next to `runs` — because a candidate's whole
value is its provenance, and provenance is a foreign key:

```sql
knowledge_entry(id, type, scope, content, status, confidence, expires_at,
                source_run_id REFERENCES runs(id),   -- the join that makes this worth doing
                source_commit, verifying_command, exit_code)
knowledge_usage(entry_id, run_id, outcome)           -- hit rate, for free
```

Split across two databases, *"did runs using entry X pass more often?"* becomes a
correlation exercise. In one it is a `JOIN`.

**Expose it as a read-only MCP server, not an embedded file.** It stays outside the agent's
`git archive` tree so the allowlist assertion still sees everything, and the write path goes
through the governance job rather than the agent — the same separation as gh-aw safe outputs.

**Gate:** all learning has provenance · no uncontrolled writes to active knowledge · stale
knowledge expires or revalidates · conflicts detected · a bad item can be rolled back ·
**learning measurably improves future runs.**

---

<a id="b13"></a>
## B13 — Production observability and the promotion gate

**Track A: [Phase 10](../phases/10-production-observability/)**

**Build:** the decision layer.

```
JSONL → Markdown/CSV comparison → OpenTelemetry → Prometheus → Grafana
```

**In that order.** Both business-case documents say do not start with Grafana; you already
did, and both documents were right. Local artifacts first, dashboards only when enough runs
exist to make one meaningful.

**Promotion gate** — a configuration becomes the default only when all seven hold:

1. deterministic checks do not regress
2. benchmark quality improves or stays within approved tolerance
3. safety guardrails do not regress
4. cost increase is justified
5. enough repetitions exist
6. a human reviewed the qualitative diff
7. **rollback is defined**

```yaml
successful_run_rate:      { minimum: 0.80 }
quality_score:            { minimum: 80 }
critical_findings:        { maximum: 0 }
forbidden_changes:        { maximum: 0 }
first_pass_success:       { must_not_decrease: true }
human_review_minutes:     { must_not_increase: true }
tokens_per_accepted_task: { maximum_allowed_increase: 0.15 }
```

---

## Rules for the whole track

1. One step at a time. One file or one cohesive script set.
2. Explain before editing.
3. Do not create future-step directories.
4. Every metric must support a decision.
5. Every instruction needs an expected behavioural effect.
6. Every hook must enforce a concrete policy.
7. Every skill must solve a **measured** specialist problem.
8. Every experiment records its changed variable.
9. Never overwrite previous run evidence.
10. **Do not promote a version after one successful run.**

## After every step

```yaml
learning:
  what_was_added:
  why_it_exists:
  observed_effect:
  unexpected_effect:
  keep_or_remove:
  next_question:
```

Six questions, every time: What was added? Why does it exist? What problem did it solve?
What evidence supports keeping it? What new cost or complexity did it introduce? What
remains unclear?
