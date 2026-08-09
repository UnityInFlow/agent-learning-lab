# Phase 3 — Agent Skills

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
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

---

## Extract

From the Claude Code Skills documentation, read 2026-08-09. Quotes verbatim.

### What a skill is, and when to make one

> "Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude
> adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly
> with `/skill-name`."

The trigger for creating one is specific and useful:

> "Create a skill when you keep pasting the same instructions, checklist, or multi-step
> procedure into chat, **or when a section of CLAUDE.md has grown into a procedure rather
> than a fact.**"

That second clause is the dividing line between Phase 1 and Phase 3. **CLAUDE.md holds
facts. A skill holds a procedure.** If your instruction file has started describing *steps*,
it is a skill in the wrong place — and it is being loaded on every task.

### The economics — why progressive disclosure matters

> "Unlike CLAUDE.md content, **a skill's body loads only when it's used**, so long reference
> material costs almost nothing until you need it."

This is the whole argument for Lab 3.3. Always-on context is paid on every task; a skill body
is paid only on the tasks that need it. The name and description stay visible so Claude can
decide.

### Commands and skills are now the same thing

> "**Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md`
> and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same
> way. Your existing `.claude/commands/` files keep working."

What skills add over legacy commands:

- a **directory** for supporting files
- **frontmatter** controlling whether you or Claude invokes them
- **automatic loading** when Claude judges them relevant

> This is the cross-tool lesson from Phase 2 landing: same `/something` UX, different
> abstraction underneath. Copilot prompt files and Claude skills are not the same object.

### For your build track

B6 says "one specialist skill, chosen from a measured failure." The doc's own trigger —
*a section of CLAUDE.md that became a procedure* — is the cheapest way to find that
candidate. Look at what B3's instruction file grew into.

---

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
