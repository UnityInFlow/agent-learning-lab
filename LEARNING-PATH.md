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
| [1](phases/01-instructions/) | Custom instructions | **L3 only** | ❌ attempted, invalidated |
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

Track A cannot progress past Phase 1, and Track B cannot start B3, until these clear:

| | |
|---|---|
| `agent-observatory` **#36** | The instruction treatment was never loaded — Claude reads `CLAUDE.md`, not `AGENTS.md` |
| `agent-observatory` **#35** | Runs not isolated: ~21 hooks, 2 plugins, 3–4 MCP servers varied between runs |
| **harness bug #7** | *No issue filed.* Permission blocks recorded as incorrect code. Voids every cross-model comparison |
| `agent-observatory` **#34** | Model-tier experiment not preregistered before its data |

Bug #7 is also **Lab 5B.5** — the fix and the lesson are the same work.

---

## The rule that governs all of it

> Consider adding complexity **only** when it demonstrably improves outcomes.
> — *Building effective agents*

Every phase in Track A adds a capability. Every step in Track B adds complexity to a real
agent. That sentence is the bar each one has to clear, and it is why `INCONCLUSIVE` is a
legitimate result rather than a failed experiment.
