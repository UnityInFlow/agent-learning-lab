# The learning path

One plan, replacing four. Read this before any phase README.

## Why this document exists

Four roadmaps were running in parallel, each numbering its phases from 0 or 1:

| Document | Goal | Benchmark | Runtime |
|---|---|---|---|
| `CURRICULUM.md` | *Understand* agent primitives by measurement | BE-001/BE-002 | Copilot + Claude + Codex |
| `businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md` | *Build* a custom-agent framework | confirm-shipment | "Codex or Claude, Copilot later" |
| `businesscase/BACKEND-AGENT-V1-WHAT-NEXT.md` | *Prove* backend agent v1 works | confirm-shipment | Copilot |
| `businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` | v1.1 → v1.3 evolution | same | Copilot |

**"Phase 4" meant four different things.** This document is the merge.

---

## Two tracks, one instrument

**Track A — Understand.** Why a primitive behaves as it does. Measured in
[`agent-observatory`](https://github.com/UnityInFlow/agent-observatory).

**Track B — Build.** The backend agent, applying those primitives to real work.

They interleave: you learn a primitive, then immediately build with it. Every Track B step
becomes an informed decision instead of a guess.

---

## Track A — Understand

| Phase | Topic | Guardrail layer | Status |
|---|---|---|---|
| [0A](phases/00a-agent-mechanics/) | Agent mechanics + governance | defines all three | ⬜ skipped, should have been first |
| [0B](phases/00b-observatory/) | Observatory + evaluation baseline | L0 observation | ✅ built |
| [1](phases/01-instructions/) | Custom instructions | **L3 only** | ✅ result, `INCONCLUSIVE` |
| [2](phases/02-prompt-files/) | Prompt files / reusable workflows | **L3 only** | ⬜ |
| [3](phases/03-skills/) | Agent Skills | **L3 only** | ⬜ |
| [4A](phases/04a-agents-permissions/) | Custom agents + permissions | L2 | ⬜ |
| [4B](phases/04b-orchestration/) 🆕 | Agent orchestration + multi-layer design | L3, or L1 if structural | ⬜ |
| [5A](phases/05a-guardrails/) 🆕 | **Guardrails: hooks, policies, enforcement** | **L2 — built here** | ⬜ |
| [5B](phases/05b-verification-selfhealing/) 🆕 | Verification loops, bounded self-healing, completion | L2 | ⬜ |
| [6A](phases/06a-code-intelligence/) | Code intelligence: LSP → MCP | L2 policy | ⬜ |
| [6B](phases/06b-knowledge-retrieval/) 🆕 | Knowledge retrieval: router → hybrid → vector | **L3 untrusted** | ⬜ |
| [7](phases/07-plugins/) | Plugins + distribution | L2 + supply chain | ⬜ |
| [8](phases/08-agentic-workflows/) | Unattended agents: event/schedule (gh-aw) | **L1** | ⬜ |
| [9](phases/09-memory/) | Memory **& governed self-learning** | **L3 untrusted** | ⬜ |
| [10](phases/10-production-observability/) | Production observability + impact | L0 observation | ⬜ |

See [`GUARDRAILS.md`](GUARDRAILS.md) for the layer model. **Five of fifteen phases operate
at Layer 3 only** — that is where most customization effort goes, and none of it stops
anything.

## Track B — Build

**Full guide: [`build/README.md`](build/README.md)** — each step with what you build, the
acceptance gate, and the specific trap.

| Step | Build | Needs first | Version |
|---|---|---|---|
| B1 | Experiment contract, rubric, run record | 0B | — |
| B2 | Plain-prompt baseline on confirm-shipment | 0A + 0B | — |
| B3 | Minimal global instructions | 1 | — |
| B4 | Agent boundary — mission, allowed, prohibited, approval | 4A | v1.0 |
| B5 | Workflow phases ANALYSIS→…→DONE | **4B** | v1.0 |
| B6 | One specialist skill | 3 | v1.0 |
| B7 | Deterministic verification + policies | **5A** | v1.0 |
| B8 | Persistent run state, hard repair limits, completion contract | **5B** | **v1.1** |
| B9 | Knowledge router + hit-rate instrumentation | 6A + **6B** | v1.2 |
| B10 | Port the Copilot adapter to Claude | 4A | v1.2 |
| B11 | Efficiency — caches, retrieval budgets, command dedup | 6B + 10 | v1.2 |
| B12 | Governed self-learning — candidate → promotion → expiry | **9** | **v1.3** |
| B13 | Production observability + promotion gate | 10 | — |

Each B step is also a workbook in `phases/`, with the same shape as a Track A phase — goal,
required reading, extract, predictions, a lab, a deliberate failure, an exit gate. The build
guide stays the index and the rationale; the workbook is where the step is *learned* rather
than just executed.

---

## The spine — one ordered journey

The two tables above are the same path seen twice. This is the path.

Ordering obeys three constraints at once: Track A's own sequence, each B step's prerequisite,
and B's numeric order. Track A teaches the primitive; the B step that follows builds with it.

| # | Stop | | # | Stop |
|---|---|---|---|---|
| 1 | [0A — Agent mechanics](phases/00a-agent-mechanics/) | | 15 | [**B7** — Verification + policies](phases/b07-verification-policies/) ⟵ **v1.0** |
| 2 | [0B — Observatory](phases/00b-observatory/) | | 16 | [5B — Verification, self-healing](phases/05b-verification-selfhealing/) |
| 3 | [**B1** — Experiment contract](phases/b01-experiment-contract/) | | 17 | [**B8** — Run state, repair limits](phases/b08-run-state-repair-limits/) ⟵ **v1.1** |
| 4 | [**B2** — Plain-prompt baseline](phases/b02-plain-baseline/) | | 18 | [6A — Code intelligence](phases/06a-code-intelligence/) |
| 5 | [1 — Custom instructions](phases/01-instructions/) | | 19 | [6B — Knowledge retrieval](phases/06b-knowledge-retrieval/) |
| 6 | [**B3** — Minimal global instructions](phases/b03-global-instructions/) | | 20 | [**B9** — Knowledge router](phases/b09-knowledge-router/) |
| 7 | [2 — Prompt files](phases/02-prompt-files/) ◇ | | 21 | [**B10** — Second runtime adapter](phases/b10-second-runtime-adapter/) ‡ |
| 8 | [3 — Agent Skills](phases/03-skills/) | | 22 | [7 — Plugins](phases/07-plugins/) ◇ |
| 9 | [4A — Agents + permissions](phases/04a-agents-permissions/) | | 23 | [8 — Unattended agents](phases/08-agentic-workflows/) ◇ |
| 10 | [**B4** — Agent boundary](phases/b04-agent-boundary/) | | 24 | [9 — Memory](phases/09-memory/) |
| 11 | [4B — Orchestration](phases/04b-orchestration/) | | 25 | [10 — Production observability](phases/10-production-observability/) |
| 12 | [**B5** — Workflow phases](phases/b05-workflow-phases/) | | 26 | [**B11** — Efficiency](phases/b11-efficiency/) ⟵ **v1.2** |
| 13 | [**B6** — One specialist skill](phases/b06-specialist-skill/) | | 27 | [**B12** — Governed self-learning](phases/b12-governed-self-learning/) ‡ ⟵ **v1.3** |
| 14 | [5A — Guardrails](phases/05a-guardrails/) | | 28 | [**B13** — Promotion gate](phases/b13-production-observability/) |

**◇ No build counterpart.** Phases 2, 7 and 8 have no B step depending on them, so the
alternation breaks three times. Either that is deliberate — they are pure-learning phases —
or three B steps are missing. Unresolved.

**‡ Placement is provisional**, because prerequisite order and version order disagree:

- **B10** needs only 4A, which clears at stop 9. Its v1.2 tag holds it to stop 21 — twelve
  stops sitting on a cleared prerequisite.
- **B12** needs 9, which clears at stop 24, but B11 precedes it numerically and B11 needs 10.

Both are placed by **version order** here. If prerequisite order should win instead, B10 moves
to stop 10 and the v1.x blocks stop being contiguous. **Decide this before writing B10 or B12**
— it changes what "v1.2" means.

### Where the versions close

```
stops 3–6     no version yet — the instrument and the baseline
stop  15      v1.0 closes at B7   first end-to-end answer, measured against B2
stop  17      v1.1 closes at B8   reliability
stop  26      v1.2 closes at B11  efficiency
stop  27      v1.3 closes at B12  governed self-learning — do not build early, see decision 5
```

**A step is not done when its files exist.** Track A phases end at an exit gate; so do the B
workbooks, and from B3 onward the gate includes a measured comparison against the previous
version. Thirteen B labs means thirteen more controlled experiments, each ≥3 runs against
BE-003 — which does not exist yet. **B1 is where it gets built.**

---

## Decisions this merge makes

### 1. `confirm-shipment` becomes BE-003

BE-001 and BE-002 stay — they are leak-proofed and the only clean data this project has.
`confirm-shipment` is a **better** task than either (idempotency, optimistic locking,
carrier gateway, 404/422/503 error contract) and fills the cross-module gap that Phase 6A
needs.

### 2. The primary runtime moves from Copilot to Claude

Not a preference. Copilot's quota is exhausted on this account, and every v1 pilot step is
currently unrunnable as written. Porting `.github/agents/*.agent.md` to a Claude subagent
also exercises the *"portable core, thin adapters"* principle the business case argues for.

### 3. `.github/`, not `.ai/`

v1 is already built in `.github/`, and the runtimes discover `.github/` and `.claude/`
natively. `.ai/` is a clean idea that nothing reads.

### 4. Three business-case ideas backport into the observatory now

They are already designed, and two of them close open issues:

| From | Fixes |
|---|---|
| §13.1 quality gates pass **before** efficiency is compared | The analyzer compares cost without this gate |
| §14 token levels A/B/C — every value tagged `source` + `estimated` | **Issue #35**, near-verbatim |
| P7 *"unknown data remains unknown — record `null`, never invent"* | The non-nullable `BehaviorDto` counters in `STATE.md` |

### 5. Do not build v1.3 self-learning yet

The business case says this itself, and it is right. But keep the design — candidate →
validation → confidence → promotion → expiration → rollback is the best thing in the three
documents, and Phase 9 now inherits it.

### 6. 6B's write path is gated by 9

Reading a curated corpus is retrieval. A corpus **the agent writes to** is self-learning,
and needs governance. Ship 6B's read path; do not open the write path until 9 exists.

---

## What blocks the path today

Updated 2026-08-10. **Phase 1 is no longer blocked** — it has two non-void results — and the
gate that stopped Track B has moved from "the instrument is unreliable" to "nobody has run
anything".

### Cleared

| | |
|---|---|
| **#36** | Treatment loads and is hash-asserted per run — `instructionsHash` set on every treatment run, null on every baseline |
| **#48** | Claude *does* emit traces, behind `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`. Fixed and merged |
| **#47** *(partly)* | Environmental stops are classified by class, not phrase: an agent that changed no file and called no tool did not attempt the task. `claude_code.tool.blocked_on_user` is a real span and gives a phrase-free detector |
| **#35** *(isolation half)* | `--setting-sources project` — the runner's `--isolate-user-settings`. Verified 0 hook executions with `CLAUDE.md` still loading. `EXP-BE002-NOHOOKS` sized it: hooks were ~13% of every run, on both arms almost equally |
| **BE-003** | `confirm-shipment` now exists, with a Shipment domain in the fixture |

### Still open

| | |
|---|---|
| `agent-observatory` **#49** | Isolation is **off by default**, so every experiment must state which regime it ran under |
| `agent-observatory` **#35** *(rest)* | The *resolved* model id is in the events but never persisted to the run record. It was checked across 20 runs and did not drift |
| `agent-observatory` **#47** *(rest)* | The block span reports *that* a tool was blocked, not *why* — `decision` and `source` both come back `unknown` |
| `agent-observatory` **#34** | Model-tier experiment not preregistered before its data |

#47 is also **Lab 5B.5**, and #48 is **Lab 10.0** — in both cases the fix and the lesson are
the same work. #48 is now done as engineering and **still unwritten as a lab**, which is the
shape of this whole project's gap.

> **The real blocker is no longer technical.** `findings/` is empty, `experiments/` is empty,
> and 27 of 28 stops have no lab skill. Nothing above prevents Lab 0A.1 from being run today.

### Three findings that shortcut this list

Each came from reading a source rather than debugging:

1. **`InstructionsLoaded` hook** ([5A extract](phases/05a-guardrails/README.md#extract)) — fires
   when a `CLAUDE.md` or rules file loads, and reports *why*. That is the preflight assertion
   #36 has been missing.
2. **`claude_code.tool.blocked_on_user` span** ([10 extract](phases/10-production-observability/README.md#extract))
   — a direct detector for #47, so the fix can be *verified* rather than trusted.
3. **Copilot CLI reads `CLAUDE.md`** ([1 extract](phases/01-instructions/README.md#extract)) — a
   cross-runtime instruction experiment can hold the file constant instead of maintaining two
   adapters.

---

## The rule that governs all of it

> Consider adding complexity **only** when it demonstrably improves outcomes.
> — *Building effective agents*

Every phase in Track A adds a capability. Every step in Track B adds complexity to a real
agent. That sentence is the bar each one has to clear, and it is why `INCONCLUSIVE` is a
legitimate result rather than a failed experiment.
