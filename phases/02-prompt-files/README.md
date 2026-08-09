# Phase 2 — Prompt files / explicit reusable workflows

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
