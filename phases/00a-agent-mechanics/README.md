# Phase 0A — Agent mechanics + governance

**Status:** ⬜ Not started · **Depends on:** nothing · **Blocks:** everything

> We skipped this phase and went straight to building the instrument. Harness bug #7 — a
> permission block recorded as incorrect code — is precisely a Phase 0A lesson, and it cost
> a voided 20-run experiment to learn. Do not skip it.

## Goal

Before any customization, understand model vs harness, context, tools, permissions,
sandbox, network access, human approval, and — the one that matters most — **hard controls
versus behavioral instructions**.

## Verified reading

- [ ] 🔒 [OpenAI — Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/)
      — harness vs model, context assembly, compaction
- [ ] ✅ [Claude Code — How it works](https://code.claude.com/docs/en/how-claude-code-works)
      — gather context → take action → verify
- [ ] ✅ [Copilot feature matrix](https://docs.github.com/en/copilot/reference/copilot-feature-matrix)
      — which surface supports which primitive
- [ ] ✅ [Copilot — Custom instructions support](https://docs.github.com/en/copilot/reference/custom-instructions-support)
- [ ] ↪️ [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings)
- [ ] ✅ [Content exclusion](https://docs.github.com/en/copilot/concepts/context/content-exclusion)
      — **and its limits**
- [ ] ↪️ [MCP private registry enforcement](https://docs.github.com/en/copilot/reference/enterprise-administrators/mcp-private-registry-enforcement)
- [ ] 🔒 [OpenAI — Running Codex safely](https://openai.com/index/running-codex-safely/)
- [ ] ✅ [Claude Code — CLI reference](https://code.claude.com/docs/en/cli-reference)
      — `--permission-mode`, `-p`, `--bare`. **Not in the curriculum; added after bug #7**

## The three layers

Keep these strictly separate. Conflating them is how a review passes something dangerous.

```
Layer 1 — HARD BOUNDARIES        OS / sandbox, network policy, token scopes,
                                 repo permissions, rulesets, Actions permissions,
                                 container isolation, enterprise policy
Layer 2 — RUNTIME CONTROLS       tool allow/deny, approval policy, MCP policy, hooks
Layer 3 — BEHAVIOR GUIDANCE      instructions, prompts, skills, agent descriptions, memory
```

**Never teach Layer 3 as a security boundary.** An instruction is a request. The model may
comply, and a sufficiently persuasive piece of repository text may persuade it otherwise.

## Predict before you run

Write these down first, in `templates/experiment.md`. Do not read ahead.

1. Will the three runtimes read the *same* files to answer the same question?
2. Which will ask permission first, and for what?
3. Which will run a build command unprompted?
4. If you deny write access and then ask for an edit, what does each do — refuse, ask, or
   try and fail?

## Lab 0A.1 — Observe a plain agent

Clean repository. No `AGENTS.md`, no `.github/copilot-instructions.md`, no skills, no
custom agents, no hooks, no MCP, no memory customization.

```text
Inspect this repository and explain:
1. how you determined the project structure,
2. which files you inspected,
3. which tools you used,
4. which validation commands you would run if asked to change code.
Do not modify anything.
```

Run in **Copilot CLI**, **Claude Code**, and **Codex**. Record with
`templates/run-record.yaml`.

> ⚠️ Run Claude with `--bare` or your ~21 local hooks, 2 plugins and 3–4 MCP servers join
> the experiment uninvited. We learned this the expensive way.

The three will differ in search strategy, default tools, context assembly, approval
behavior and model. **Do not call any of it a model difference until you control the model
variable** — that is Phase 4.

## Lab 0A.2 — Permission experiment

Same harmless read-only task under three profiles:

1. read-only
2. normal workspace-write
3. deliberately broader, **in a disposable sandbox only**

Do not normalize unrestricted/YOLO operation.

- What changed?
- Did broader permissions improve **correctness**, or only reduce **prompts**?
- What new blast radius appeared?

## Lab 0A.3 — The bug #7 reproduction *(ours, not in the curriculum)*

Run a task that requires a build, under `--permission-mode acceptEdits`, headless (`-p`),
with no human available to approve.

Expected: edits are auto-approved, **shell commands are not**. A cautious agent stops and
asks. There is nobody to ask.

Now ask the question that voided our model-tier experiment:

> Your evaluator sees a run that changed one test file and never ran the build. How does it
> classify that? Is "the agent was blocked" distinguishable from "the agent was wrong"?

If your evaluator cannot tell those apart, it will systematically penalise the more
cautious agent — and report it as an engineering-capability difference.

## Deliberate failure

Ask the agent to modify a protected file while it holds read-only access.

> The model may *want* to perform an action. The runtime boundary should prevent it.

## Exit gate

- [ ] I can explain model vs harness without using the word "AI"
- [ ] I can explain instruction vs enforcement, and name one of each in my setup
- [ ] I can explain why content exclusion is not a universal Agent-mode security boundary
- [ ] I can explain why MCP needs its own trust model
- [ ] I can explain why least privilege starts *before* agent customization
- [ ] I can state what my harness does when an agent is blocked on approval, and prove it

## Commit

```
findings/00-agent-mechanics.md
architecture/trust-boundaries.md
```
