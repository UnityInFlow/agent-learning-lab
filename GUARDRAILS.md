# Guardrails

The reference every phase points back to. **Guardrails are not a phase you complete** —
they are a property every phase either has or lacks. Phase 5A is where you build them;
this document is how you judge them.

## The one rule

> **Layer 3 is never a boundary.**

Instructions, prompt files, skills, agent descriptions and memory all influence a model.
None of them constrains a process. If your answer to *"what stops this?"* names a Markdown
file, you have no control — you have a preference.

```
Layer 1 — HARD BOUNDARY      OS sandbox, network policy, token scopes, repo permissions,
                             rulesets, Actions permissions, container isolation
Layer 2 — RUNTIME CONTROL    tool allow/deny, approval policy, MCP policy, hooks,
                             deterministic checks
Layer 3 — BEHAVIOR GUIDANCE  instructions, prompts, skills, agent descriptions, memory
```

## Three kinds, and they are not equal

### Structural — strongest

The dangerous action is **impossible**, not discouraged. No detection step, so nothing to
evade.

- read-only agent job → validated structured output → *separate* scoped write job
- an agent with no network cannot exfiltrate, whatever it is persuaded to do
- a branch it cannot push to

> Prefer this. If a structural option exists, the other two kinds are a fallback, not a
> choice.

### Deterministic — trust within its stated scope

Testable, with a measurable false-positive and false-negative rate.

- protected-path check, forbidden-command denylist
- exit-code gate on the build
- schema validation of the agent's output
- dependency-change detection

These are code. They need tests, versions, and owners. **A guardrail without a test is a
guardrail you assume works.**

### Model-based — never the only control

A classifier judging "is this prompt injection?", or an LLM reviewing another LLM's output.

Useful as a *signal*. Never as the boundary. From the Phase 0A reading — on guardrail
products advertising 95% detection rates:

> For security, 95% is **"a failing grade."**

An attacker only needs the 5%.

## What happens when it fires

The question almost nobody designs for. Answer all five, per control:

| | |
|---|---|
| **Block, warn, or escalate?** | And who decides — the hook, the agent, or a human? |
| **Fail open or fail closed?** | Per control. Copilot hook **timeouts fail open**, including policy hooks |
| **Is blocked distinguishable from failed?** | See below. This is harness bug #7 |
| **What does a false positive cost?** | A guardrail that blocks legitimate work gets disabled — and then you have none |
| **Is the firing recorded?** | If not, you will never know its real rate |

### Blocked is not failed

An agent stopped by a control has not produced a wrong answer. It has produced *no*
answer.

This project recorded a permission-blocked run as **F05, incorrect code** — seven of ten
runs changed no production file, and the instrument reported it as the model being worse at
engineering. That is harness bug #7, and it is bug #2 (exhausted quota recorded as F03)
repeating.

> An environmental block recorded as a capability failure is the single most common way a
> guardrail corrupts a measurement.

Classify blocked runs as **infrastructure** — never as incorrect code.

## Measure them or lose them

From the business case, §13.6 — these are guardrail telemetry, not agent telemetry:

```
workflow phases skipped        forbidden command attempts
protected file attempts        unauthorized dependency attempts
verification skipped           missing approval
```

Plus, per control:

```
invocation count    block count    false positives    false negatives
duration            error count    timeout count
```

**A guardrail you do not measure is a guardrail you will disable the first time it annoys
you.** The false-positive count is the number that decides whether it survives contact
with a team.

## Completion is a guardrail

"The agent says DONE" is an assertion, not a fact. This project's own problem list opens
with *declaring completion too early* and *judging their own output too positively*.

A completion contract is the deterministic check on that claim:

- acceptance criteria mapped to implementation
- build passed
- required tests passed
- static analysis passed, no critical findings
- **no forbidden files changed**
- final summary generated

Checked by something that is not the agent. See Phase 5B.

## Reviewing a guardrail

Six questions. Any "no" is a finding.

1. Which layer is it? If the answer is 3, it is not a guardrail.
2. Is there a structural alternative that makes the action impossible?
3. What is its false-positive rate on legitimate work?
4. Does it fail open or closed, and was that deliberate?
5. Does a firing get recorded, and can a blocked run be told apart from a failed one?
6. Is it tested — including malformed input, crash, and timeout?

## Layer by phase

| Phase | Primary layer |
|---|---|
| 0A Agent mechanics | defines all three |
| 0B Observatory | L0 — observation |
| 1 Instructions · 2 Prompt files · 3 Skills | **L3 — guidance only** |
| 4A Agents + permissions | L2 (tool lists) — but the agent's *description* is L3 |
| 4B Orchestration | L3, unless the split is structural — then L1 |
| **5A Guardrails: hooks, policies, enforcement** | **L2 — this is where you build them** |
| **5B Verification & completion** | L2 — deterministic checks on the agent's claims |
| 6A LSP / MCP | L2 policy; retrieved content is an L3 risk |
| 6B Knowledge retrieval | **L3 — retrieved chunks are untrusted content** |
| 7 Plugins | L2 distribution control + supply chain |
| 8 Unattended agents | **L1 — token scopes and safe-output separation** |
| 9 Memory & self-learning | **L3 — untrusted derived state** |
| 10 Production observability | L0 — observation |

Read that table as a warning. **Five of the fifteen phases operate at Layer 3 only.** Those
five are where most customization effort goes, and none of them can stop anything.
