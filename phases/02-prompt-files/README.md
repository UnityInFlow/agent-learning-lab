# Phase 2 — Prompt files / explicit reusable workflows

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ⬜ Not started · **Depends on:** Phase 1

## Goal

Learn the difference between **always-on context** and an **explicit reusable task**.

This phase is about *repeatability and ergonomics*, not raw model intelligence. Measure it
as such — a prompt file that produces the same five sections every time is winning even if
its per-run quality is identical to a hand-typed prompt.

## Verified reading

- [ ] ✅ [VS Code — Prompt files](https://code.visualstudio.com/docs/agent-customization/prompt-files)
- [ ] ✅ [Copilot — Response customization](https://docs.github.com/en/copilot/concepts/prompting/response-customization)
- [ ] ✅ [Claude Code — Skills](https://code.claude.com/docs/en/skills)
- [ ] ✅ [Copilot feature matrix](https://docs.github.com/en/copilot/reference/copilot-feature-matrix) — prompt-file support differs by IDE

## Current shape

Copilot prompt files are `*.prompt.md`. Frontmatter includes `name`, `description`,
`argument-hint`, `agent`, `model`, `tools`.

> **Do not teach the old `mode:` field as current.**

**Claude Code has merged custom commands into Skills.** `.claude/commands/` still works,
but new reusable workflows should be taught as skills. Same `/something` UX, different
abstraction underneath — which is itself the cross-tool lesson.

**Codex:** prefer Skills for portable reusable workflows rather than forcing a fake
prompt-file equivalence.

---

## Extract

From the VS Code prompt-files documentation, read 2026-08-09. Quotes verbatim.

### What it is

> Prompt files "let you simplify prompting for common tasks by **encoding them as standalone
> Markdown files that you can invoke directly in chat**."

Extension `.prompt.md`. Workspace location `.github/prompts`; also a user-profile location,
and more via the `chat.promptFilesLocations` setting.

### The current frontmatter — all six fields, all optional

| Field | Purpose |
|---|---|
| `description` | "A short description of the prompt" |
| `name` | "The name of the prompt, used after typing `/` in chat" |
| `argument-hint` | "Hint text shown in the chat input field to guide users" |
| `agent` | `ask` · `agent` · `plan` · or a custom agent name |
| `model` | "The language model used when running the prompt" |
| `tools` | "A list of tool or tool set names that are available for this prompt" |

**Confirmed: there is no `mode:` field.** The curriculum's warning holds — do not teach it.

Note `agent` and `tools`: a prompt file can pin **which agent runs it** and **which tools are
available**. That last one is the only Layer-2 thing on this page, and it is how Lab 2.1's
read-only `/review-change` is actually enforced rather than requested.

### The distinction that defines this phase

> "**Unlike custom instructions that are applied automatically, you invoke prompt files
> manually in chat.**"

That is the whole Phase 1 / Phase 2 boundary in one sentence. Instructions are always-on
context you pay for on every task; a prompt file is an explicit invocation you pay for when
you ask.

### Variables

`${input:variableName}` and `${input:variableName:placeholder}` for user input, plus the
built-in `${selection}`.

Parameterisation is what separates a reusable prompt file from a saved snippet — and it is
what Lab 2.2 should measure. If your prompt file takes no arguments, ask whether it is
earning its existence over a paste buffer.

### Cross-tool warning, restated

Same `/name` UX, three different objects: a VS Code **prompt file**, a Claude Code **skill**
(commands were merged into skills — see [Phase 3's extract](../03-skills/README.md#extract)),
and a Codex skill. They differ in where they live, what frontmatter they accept, whether the
model can invoke them on its own, and whether the body loads lazily.

> Do not build a "portable prompt file" abstraction. Build the workflow once as a skill, and
> adapt at the edges.

---

## Predict before you run

1. Will the reusable file produce a *more consistent structure* than a typed prompt, a
   better one, or both?
2. Will it use more or fewer tokens than typing the same thing?
3. How many review categories does a free-form prompt silently drop across 5 runs?

## Lab 2.1 — Build `/review-change`

A prompt file that inspects the current diff, **performs no writes**, and returns:
correctness risk · missing tests · architecture risk · security concern.

Test on three prepared diffs: a correct change, one missing a test, one with an
architecture violation.

## Lab 2.2 — Prompt file vs free-form

Run equivalent requests: **A** manually typed full prompt, **B** the reusable file.

Measure: consistency of output structure · missed review categories · tokens · human effort
to invoke.

## Failure injection

Remove one critical review requirement from the prompt file. **Verify your eval notices the
missing category.** If it does not, your eval is scoring prose fluency.

## Exit gate

- [ ] Instructions vs prompt file
- [ ] Prompt vs skill
- [ ] Why Claude's current custom-command story maps to Skills
- [ ] Why you should not create a slash command for every sentence engineers type twice

## Commit

```
.github/prompts/review-change.prompt.md
experiments/B2-prompt-files.md
```
