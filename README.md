# agent-learning-lab

Hands-on workbook for the measurement-first AI coding agent curriculum.
**GitHub Copilot · Claude Code · OpenAI Codex.**

This repo is where you *play*. It holds the labs, the verified reading, the predictions you
make before each run, and the exit gate you have to pass before moving on. It does not hold
the instrument — that lives next door.

| Repo | Role |
|---|---|
| **agent-learning-lab** (here) | Curriculum, labs, verified sources, findings, exit gates |
| [`agent-observatory`](https://github.com/UnityInFlow/agent-observatory) | The instrument — runner, evaluator, analyzer, OTel → Tempo → Grafana |
| [`agent-observatory-benchmarks`](https://github.com/UnityInFlow/agent-observatory-benchmarks) | BE-001, BE-002, acceptance suites, evaluators |

---

## The rule

> **A feature is not learned when the file exists. It is learned when you can explain what
> changed in the agent, prove that it happened, measure its effect, and identify its
> failure mode.**

Every phase runs the same loop. Skipping PREDICT is the most common way to learn nothing:
if you did not write down what you expected, any result feels like it confirms something.

```
LEARN THE MECHANISM → READ VERIFIED DOCS → PREDICT → BUILD THE SMALLEST VERSION
        → RUN A CONTROLLED TASK → OBSERVE → RUN DETERMINISTIC EVALS
        → DELIBERATELY BREAK IT → EXPLAIN THE FAILURE → COMPARE WITH BASELINE
        → COMMIT THE ARTIFACT → PASS EXIT GATE
```

## How to use this repo

1. Open the phase folder. Read its `README.md` top to bottom **before** touching a tool.
2. Work the **Verified reading** list. Links are checked — see [`SOURCES.md`](SOURCES.md).
3. Write your predictions into a copy of [`templates/experiment.md`](templates/experiment.md)
   **before** running anything.
4. Run the labs. Record with [`templates/run-record.yaml`](templates/run-record.yaml).
5. Tick the exit gate. If you cannot answer a gate question out loud, you are not done.
6. Each phase has a tracking issue. Close it only when the gate passes.

```bash
./tools/check-links.sh     # re-verify every source before a cohort
```

---

## Start here

**[`LEARNING-PATH.md`](LEARNING-PATH.md)** — the single plan. It merges the four competing
roadmaps (this curriculum plus the three in [`businesscase/`](businesscase/)) into two
interleaved tracks: **Understand** (phases below) and **Build** (the backend agent, v1→v1.3).

**[`GUARDRAILS.md`](GUARDRAILS.md)** — the layer model every phase points back to. Read it
before Phase 5A.

## Progress

| Phase | Topic | Layer | Status |
|---|---|---|---|
| [0A](phases/00a-agent-mechanics/) | Agent mechanics + governance | all three | ⬜ **skipped — should have been first** |
| [0B](phases/00b-observatory/) | Observatory + evaluation baseline | L0 | ✅ **Built** in `agent-observatory` |
| [1](phases/01-instructions/) | Custom instructions | **L3** | ❌ **Attempted, invalidated** |
| [2](phases/02-prompt-files/) | Prompt files / reusable workflows | **L3** | ⬜ |
| [3](phases/03-skills/) | Agent Skills | **L3** | ⬜ |
| [4A](phases/04a-agents-permissions/) | Custom agents + permissions | L2 | ⬜ |
| [4B](phases/04b-orchestration/) 🆕 | Agent orchestration + multi-layer design | L3/L1 | ⬜ |
| [5A](phases/05a-guardrails/) 🆕 | **Guardrails: hooks, policies, enforcement** | **L2** | ⬜ |
| [5B](phases/05b-verification-selfhealing/) 🆕 | Verification, bounded self-healing, completion | L2 | ⬜ |
| [6A](phases/06a-code-intelligence/) | Code intelligence: LSP → MCP | L2 | ⬜ |
| [6B](phases/06b-knowledge-retrieval/) 🆕 | Knowledge retrieval: router → hybrid → vector | **L3** | ⬜ |
| [7](phases/07-plugins/) | Plugins + distribution | L2 | ⬜ |
| [8](phases/08-agentic-workflows/) | Unattended agents (gh-aw) | **L1** | ⬜ |
| [9](phases/09-memory/) | Memory & governed self-learning | **L3** | ⬜ |
| [10](phases/10-production-observability/) | Production observability + impact | L0 | ⬜ |

**Five of fifteen phases operate at Layer 3 only** — instructions, prompt files, skills,
knowledge retrieval, memory. That is where most customization effort goes, and none of it
can stop anything. See [`GUARDRAILS.md`](GUARDRAILS.md).

**Zero experiments have produced a defensible result yet.** That is not a failure of the
project; it is what the first honest pass through a measurement problem looks like. See
[Findings](#findings-so-far).

---

## Findings so far

These are ours, earned on real runs. They are not in `CURRICULUM.md` and they are the most
valuable thing in this repo.

### Seven harness bugs made the instrument measure something other than the agent

| # | Bug | Direction |
|---|---|---|
| 1 | `AGENTS.md`, installed by the runner, counted as an agent scope violation | pessimistic |
| 2 | An exhausted Copilot quota recorded as **F03, incorrect code** | pessimistic |
| 3 | A background daemon's `.memdb/` files counted as unrelated production changes | pessimistic |
| 4 | An acceptance suite's compiled classes in gitignored `target/` ran as "the existing tests" | pessimistic |
| 5 | **The answer key shipped in the agent's worktree** | **flattering** |
| 6 | **The answer key stayed in git history after 5 was "fixed"** | **flattering** |
| 7 | **A permission block recorded as incorrect code** — 7/10 sonnet runs changed no file | pessimistic |

**The lesson is in the direction column.** The five pessimistic bugs were all caught
quickly, because a bad result invites investigation. The two flattering ones survived every
review the project had. *Nobody investigates a pass.*

### An explained symptom stops being evidence

A 35% drop in tool calls was written up as proof of the worktree leak. It was still there
after the leak was fixed — and nobody looked, because the drop already had a name. The real
cause was mundane: the tree got smaller, so exploring it took fewer calls.

> A fix is not confirmed by the story that motivated it. It is confirmed by the symptom
> disappearing, or by an assertion that fails loudly when the leak returns.

### The file being present is not the treatment being loaded

Phase 1 ran 10 + 10 clean runs comparing "with `AGENTS.md`" against "without", and
concluded `INCONCLUSIVE`. Claude Code reads **`CLAUDE.md`**, not `AGENTS.md`. The treatment
arm probably never received its treatment. Twenty runs, roughly $4, measuring a file
sitting on disk.

> Before an experiment, assert that the independent variable reached the agent. Not that
> you wrote it — that it *arrived*.

### Alias ≠ model, and environment is a variable

Runs invoked as `--model haiku` loaded ~21 hooks, 2 plugins and 3–4 MCP connections from
the local user environment, varying run to run, while the protocol claimed only the model
varied. Pin exact model IDs. Use `--bare`. Fingerprint what actually loaded.

---

## Local environment

Ports overridden in `agent-observatory/infra/.env` (gitignored — a fresh clone will not
have these):

```
GRAFANA_PORT=3001    API_PORT=8081    WEB_PORT=5174
```

- Copilot quota exhausted 2026-08-08. Use Claude Code. Cheapest Copilot model is
  `gpt-5.4-mini` (0 premium requests, verified by probing — the CLI will not list models).
- BE-002 on Claude/haiku, clean tree: median **$0.190**, ~82–167 s. Budget **~$4.10** per
  10 + 10 experiment.
- `gh issue view` fails here with a Projects-classic GraphQL error. Use
  `gh api repos/OWNER/REPO/issues/N --jq '.title, .body'`.

## Layout

```
phases/          one folder per curriculum phase — read the README first
templates/       experiment pre-registration, run record, lab notes
tools/           check-links.sh
SOURCES.md       every source, verified, with what to take from each
CURRICULUM.md    the source curriculum, unmodified
```
