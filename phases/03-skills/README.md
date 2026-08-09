# Phase 3 — Agent Skills

**Status:** ⬜ Not started · **Depends on:** Phase 2

## Goal

Learn progressive disclosure and task-scoped knowledge.

## Verified reading

- [ ] ✅ [Copilot — About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) — note the explicit prompt-injection warning
- [ ] ✅ [Copilot — Add skills to the cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)
- [ ] ✅ [Claude Code — Skills](https://code.claude.com/docs/en/skills)
- [ ] ↪️ [Codex — Build skills](https://learn.chatgpt.com/docs/build-skills)

Project locations: `.github/skills/` · `.claude/skills/` · `.agents/skills/`

## The model

```
always visible:   skill name + description
when relevant:    SKILL.md body
when needed:      referenced files / scripts
```

A skill earns its place when the knowledge is detailed, reusable, relevant to *some* tasks,
and too expensive or noisy for global instructions.

**Exact lifecycle varies by runtime. Measure rather than assume identical implementation.**

## Predict before you run

1. What fraction of unrelated tasks will falsely trigger your skill?
2. Does a lean `AGENTS.md` + skill beat a fat `AGENTS.md` on *relevant* tasks? On
   *irrelevant* ones?
3. What does the description have to say for the model to load it reliably?

## Lab 3.1 — Testing convention skill

```
.agents/skills/kotlin-testing/
├── SKILL.md          when it applies, test patterns, fixtures, mocking, verification
├── examples.md
└── scripts/verify-tests.sh
```

Do not copy the whole engineering handbook into it.

## Lab 3.2 — Auto-trigger experiment

Task **A** clearly testing-related · **B** unrelated documentation · **C** ambiguous.
Run each repeatedly and record: invoked? correctly? false positive? false negative? tokens?
quality?

For Copilot CLI, OTel exposes skill invocation lifecycle events — **use them rather than
inferring from the final output.** "The answer mentions our test conventions" is not proof
the skill loaded.

## Lab 3.3 — Progressive disclosure

**A:** everything in `AGENTS.md` · **B:** lean `AGENTS.md` + testing skill.
Run testing tasks and unrelated tasks.

Hypothesis: skill-based disclosure preserves quality on relevant tasks while avoiding
always-on cost. **Do not assume it is true. Measure.**

## Lab 3.4 — Skill supply-chain failure

A benign external skill, **in a disposable training repository only**. Before installing:
inspect `SKILL.md`, inspect scripts, inspect external URLs/commands, check provenance,
identify possible prompt injection.

> Never install unreviewed skills into bank repositories. A skill with a script is an
> executable dependency wearing a markdown hat.

## Exit gate

- [ ] Design a good description
- [ ] Prove the skill triggered
- [ ] Prove it did **not** trigger on an unrelated task
- [ ] Explain progressive disclosure
- [ ] Explain why skill scripts are supply-chain risk

## Commit

```
.agents/skills/kotlin-testing/
experiments/B3-skills.md
```
