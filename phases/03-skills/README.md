# Phase 3 — Agent Skills

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🔬 **In progress — stop 8 of the spine.** Reading and extract done 2026-09-04;
Lab 3.2 runs the benchmark and is the stop's closing condition · **Depends on:** Phase 2

## Goal

Learn progressive disclosure and task-scoped knowledge.

## Verified reading

- [x] ✅ [Copilot — About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) — read 2026-09-04. ~~note the explicit prompt-injection warning~~ **the warning is not on this page**; see the correction below
- [x] ✅ [Copilot — Add skills to the cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) — read 2026-09-04, **and this is where the prompt-injection warning actually is**
- [x] ✅ [Claude Code — Skills](https://code.claude.com/docs/en/skills) — extracted 2026-08-09, re-read 2026-09-03 for [Phase 2](../02-prompt-files/README.md#extract--claude-code-skills)
- [x] ↪️ [Codex — Build skills](https://learn.chatgpt.com/docs/build-skills) — read 2026-09-04. `developers.openai.com/codex/skills` returns **308** to this URL; the redirect is real and resolves

> **Correction, 2026-09-04.** The first line of this list carried the instruction *"note the
> explicit prompt-injection warning"* against the **About Agent Skills** page. That page has
> no such warning — it defines skills and lists their locations, and that is all. The warning
> is on the **Add skills** page, quoted in full below. The annotation pointed a reader at the
> wrong page for the one item on this list that is a safety control, which is worth more than
> the correction costs.

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

## Extract — Copilot Agent Skills

Read 2026-09-04. Quotes verbatim, from the two Copilot pages.

### What they are, and the three project locations

> "Agent skills are folders of instructions, scripts, and resources that Copilot can load when
> relevant to improve its performance in specialized tasks."

Project skills load from **`.github/skills`, `.claude/skills`, or `.agents/skills`**; personal
skills from `~/.copilot/skills` or `~/.agents/skills`. The file must be named `SKILL.md`, inside
a subdirectory of one of those folders.

**Copilot reads Claude's directory.** That is the first place in this curriculum where two
runtimes share a customization path rather than each owning one, and it is the opposite of the
Phase 1 lesson — where `CLAUDE.md` versus `AGENTS.md` cost twenty runs. Skills converged where
instruction files did not.

### The frontmatter contract differs by runtime, and this is a portability trap

> `name` — "A unique identifier for the skill. This must be lowercase, using hyphens for spaces."
> `description` — "A description of what the skill does, and when Copilot should use it."

Both are **required** in Copilot. `license` is optional. Codex agrees: its `SKILL.md` "must
include `name` and `description`."

**Claude Code requires neither.** From [Phase 2's extract](../02-prompt-files/README.md#the-frontmatter-and-which-fields-are-required):
no field is required; `name` "defaults to the directory name" and `description` is merely
"Recommended".

| | `name` | `description` | consequence |
|---|---|---|---|
| Claude Code | optional | "Recommended" | a `SKILL.md` with **no frontmatter at all** is legal |
| Copilot | **required**, lowercase-hyphen | **required** | that same file is invalid |
| Codex | **required** | **required** | that same file is invalid |

So the portable direction is one-way: **a skill authored for Copilot or Codex loads under Claude
Code; a skill authored for Claude Code may not load under the other two.** Phase 2 found
`allowed-tools` reversing direction between vendors; this is the same class of defect one level
up — the object is shared, the contract is not.

### The security warning — quoted in full, because this is the one safety control on the list

> "Skills are not verified by GitHub and may contain prompt injections, hidden instructions, or
> malicious scripts. Always inspect the content of a skill before installation using
> `gh skill preview`."

And on pre-approving execution:

> "Only pre-approve the `shell` or `bash` tools if you have reviewed this skill and any
> referenced scripts, and you fully trust their source. Pre-approving `shell` or `bash` removes
> the confirmation step for running terminal commands and can allow attacker-controlled skills
> or prompt injections to execute arbitrary commands in your environment."

Note what the second warning is about: **pre-approval**, the same mechanism Phase 2 found behind
Claude Code's `allowed-tools`. It removes a confirmation step, not a capability. Two vendors,
two field names, one risk — and in both cases the danger is that a *permission prompt* is the
only thing that was ever standing there.

> "When a skill is invoked, Copilot automatically discovers all of the files in the skill's
> directory and makes them available alongside the skill's instructions."

A skill is therefore a **directory-shaped dependency**. Lab 3.4's phrasing — *an executable
dependency wearing a markdown hat* — is the vendor's own model, not a metaphor.

### The description is the selector, and all three vendors say so

> Copilot: "When performing tasks, Copilot will decide when to use your skills **based on your
> prompt and the skill's description**."

---

## Extract — Codex skills

Read 2026-09-04 at `learn.chatgpt.com/docs/build-skills`. Quotes verbatim.

> "A skill is a directory with a `SKILL.md` file plus optional scripts and references."

### Two invocation paths, named

> "**Explicit invocation:** Include the skill directly in your prompt" (via `$skill`)
> "**Implicit invocation:** ChatGPT or Codex can choose a skill when your task matches the skill
> `description`."

This is Phase 2's *"a prompt file is the degenerate case of a skill"* finding arriving from the
other direction: Codex names the two callers explicitly and gives the human one its own syntax.

### Progressive disclosure, and the only place it is quantified

> "ChatGPT and Codex start with each skill's name and description, then load the full `SKILL.md`
> instructions when they decide to use that skill."

The always-on half is **capped**, and Codex is the only one of the three to give the number:

> "at most 2% of the model's context window, or 8,000 characters when the context window is
> unknown" — and "When Codex selects a skill, it still reads the full `SKILL.md` instructions."

Claude Code caps the same thing per skill rather than in total: `description` + `when_to_use`
"truncated at **1,536 characters** in the skill listing to reduce context usage."

**So the model in this workbook's *"The model"* section is right, and now has two vendors'
numbers behind it.** The standing cost of a skill is its description; the body is paid on
selection. What neither vendor says is what this project would need before believing it: how
much the *listing* costs when there are fifty skills, which is the regime a real repository
reaches. That is measurable here and is not measured by this stop.

### And the sentence that makes Lab 3.2 worth running

> "Because implicit matching depends on `description`, write concise descriptions with clear
> scope and boundaries."

All three vendors state that the **description**, not the body, decides whether a skill loads.
None of them shows a measurement. **That claim is the treatment of this stop's lab** — it is
falsifiable on this instrument, on one task, with the body held byte-identical and only the
description changed.

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
