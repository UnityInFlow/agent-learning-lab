# Phase 3 — Agent Skills

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🔬 **RUNNING — stop 8 of the spine.** Reading and extract done 2026-09-04. Lab 3.2
is the stop's closing condition. It was halted at §4 step 5 on 2026-09-04 morning on the
diagnosis that *a Claude Code project skill cannot be delivered to a BE-003 run*; **that
diagnosis was wrong, and the correction is the stop's main finding** — see
[*The block was a flag, not a path*](#the-block-was-a-flag-not-a-path) below and
[`evidence/p03/skill-flag-probe-20260904T102230Z.md`](../../evidence/p03/skill-flag-probe-20260904T102230Z.md).
Delivery is proved on both treated arms and E-004 is batching · **Depends on:** Phase 2

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

## The block was a flag, not a path

**Superseding the section below, 2026-09-04.** That section is left standing because it is the
record of what was believed, and because the *reasoning* in it — why a silent null would have
been worse than a halt — is right and is the reason the correction was found at all.

`agent-observatory/runner/run-agent.sh` passed **`--disable-slash-commands`** on every claude run.
`claude --help` defines it as **"Disable all skills"**. So no skill of any scope could load, at any
path, in any run this project has ever done. Measured rather than read — three repetitions per
cell, detector a `Skill` tool_use in the stream:

| | root `.claude/skills/` | nested `sample-service/.claude/skills/` |
|---|---|---|
| **without** the flag | **3 of 3 activated** | **3 of 3 activated** |
| **with** it | **0 of 3** | **0 of 3** |

Pooled, 6 of 6 against 0 of 6, two-sided Fisher **p = 0.0022**.

**Every claim in the table below is still true, and the conclusion drawn from it was not.**
Root `.claude/skills/` *is* gitignored in the benchmarks repo; the nested path *does* commit; a
nested skill *is* absent from the `/name` registry at session start. What none of it established
is the thing it was used for. **The nested path activates mid-run** — which is what E-004
measures — and the §9 validator's second pass said so before this probe ran.

**Why the first probe could not see it.** Its registration test was run by hand as
`claude --setting-sources project --model … -p "/name"` — the runner's flag set **minus the flag
that decides the outcome**. A reproduction of a harness that drops one of the harness's flags is a
control reporting success over a smaller scope than it claims, which is this project's house
failure mode wearing a probe's clothes.

**And the author's pre-made decision would not have unblocked it either.** Author decision 2 chose
the runner force-add over a `.gitignore` change. The force-add is real and is now in the runner —
but on its own it would have put the file in the setup commit of a run that had skills switched
off, and fifteen runs would have come back with three arms in perfect agreement and a confident
null. **The decision was right about *where* to change a line and could not have been right about
*which* line, because the flag had not been read by anyone.**

### The four instrument defects this stop found, and they are one shape

| # | where | the rule it had | what it did |
|---|---|---|---|
| 1 | `tools/skill-activation.sh` | everything not `bundled` is the installed skill | §4a round 1 |
| 2 | same | everything not `bundled`/empty is | §4a round 2 |
| 3 | same | everything not `bundled`/`plugin` is | §4a round 3 — and `plugin` is the only non-bundled source ever seen here, so a plugin firing on the **control** arm would have recorded an activation in the arm that installs nothing |
| 4 | `run-agent.sh` contamination guard | **every** `Skill` call is a leaked plugin skill | marked the first matched-arm run F15, *"EXCLUDE this run from comparisons"* |

The first three are an open *everything-else-is-mine* bucket, and each fix named one more scope
instead of rejecting the category. **The fourth is the same bucket inverted — *everything is
theirs*** — and it lands on the **treatment** arm instead of the control. Every matched-arm run
loads a skill, so the batch would have ended with arm B at `n = 0` and a report saying the
treatment produced no usable runs. **A guard that excludes the treatment arm does not look like a
bug. It looks like a null result.**

Both categories are now allowlists by name, in files with fixture sets that prove they refuse:
`tools/skill-activation.sh` (28), `tools/check-overlay-parity.sh` (16),
`agent-observatory/runner/lib/classify-skill-contamination.sh` (16),
`agent-observatory/runner/verify-skill-delivery.sh` (7).

### What the instrument now says that it could not say before

**`skill.source` for a project-scope skill is `projectSettings`.** No project-scope skill had ever
been recorded on this instrument, which is why E-004's prediction 2 was registered without a
denominator and said so. Preflight run `46ffad94` is the first, and the value was written into the
prediction before any batch was read.

---

## ~~Lab 3.2 status — BLOCKED at §4 step 5~~ — SUPERSEDED, kept as the record of what was believed

> **⚠️ THIS SECTION IS HISTORICAL AND ITS STATUS CLAIM IS FALSE.** Lab 3.2 ran on 2026-09-04 and
> stop 8 is **CLOSED**; see [*The block was a flag, not a path*](#the-block-was-a-flag-not-a-path)
> and *Validation* below. Nothing in it is edited, because its reasoning — why a silent null would
> have been worse than a halt — is right and is why the real cause was found. Only its conclusion
> was wrong. A reader entering by heading was previously able to leave with the opposite status,
> which the §4a gate found at 2/2.

### Lab 3.2 status as written at the halt — **BLOCKED at §4 step 5, and the block is the result**

Stop 8's closing condition is *"one lab that records skill activation on the observatory —
that lab's evidence on disk"*. The lab was designed, registered
([`E-004`](../../experiments/E-004-skill-activation.md), first committed `5d14182`; **last pre-run edit `5a14711`**, and §9 check 2 applies against that one — see the amendment below),
built, and **stopped at the preflight assertion**, which is the step that exists to stop it.

**The treatment cannot be delivered to a BE-003 run.** Full evidence:
[`evidence/p03/skill-delivery-probe-20260904T072000Z.md`](../../evidence/p03/skill-delivery-probe-20260904T072000Z.md).

| location | runner can commit it? | registered at session start? |
|---|---|---|
| `.claude/skills/<name>/SKILL.md` (root) | **NO** — `.gitignore:19` `.claude/*`; `git add -A` skips it and the setup commit fails | **YES** — `/name` loads it and quotes its body |
| `sample-service/.claude/skills/<name>/` (nested) | **YES** — tracked, in setup commit `8300382` | **NO** — `Unknown command` |

**The two conditions are never satisfied by the same path.** Three runs were spent establishing
this: `16cd4378` (died at setup), `c090f67e` and `d8be2b5f` (both completed, evaluator exit 0,
both `status: measured` with **0 in every source bucket** — an inference that no project-scope
skill activated, not a printed project-scope count; amendment below).

### Why this is worth more than the lab would have been

Had the batch run at the nested path, fifteen runs would have returned zero activations in all
three arms, the arms would have agreed perfectly, and E-004 would have concluded **"the
description does not affect whether a skill loads"** — from fifteen runs in which no skill was
ever registered. Every check the harness has would have passed: the file installs, commits, is
tracked, and the runs evaluate clean.

**That is Phase 1's disaster with a different filename.** Phase 1 spent ~$4 and 20 runs comparing
*file present* with *file absent* and got a real-looking null. §4 step 5 — *prove the treatment
reached the model before you batch* — is the rule written from that, and it is the only reason
this was caught before the batch rather than after.

## ~~Predict before you run — unanswered~~ — SUPERSEDED

> **⚠️ HISTORICAL.** Written at the halt. Predictions 1–5 were subsequently **run and all five
> held**; question 1 (false-trigger rate on an unrelated task) is still unanswered and still needs
> a second task. See *Validation* and [`E-004`](../../experiments/E-004-skill-activation.md).

### As written at the halt — unanswered, and left that way

The three questions stay open. Question 1 (*"what fraction of unrelated tasks falsely trigger
your skill?"*) needs a second task, which §7 reserves for the author. Questions 2 and 3 need the
delivery block lifted. `E-004`'s five predictions are registered and unfalsified — **not
confirmed, not refuted, not run.**

The one behavioural observation available is `n = 1` per condition and is stated as nothing more:
at a location where the skill **was** registered, the model did not choose to load it on the
BE-003 task — neither with a matched description nor with one reading *"REQUIRED … You must load
this skill before editing ShipmentController"*. If that survives contact with `n = 5`, E-004's
prediction 1 is refuted and the vendors' documented mechanism does not reproduce here.

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

- [x] **Design a good description** — answered from the documentation, not from measurement. All
      three vendors state the description is the selector: Copilot *"will decide when to use your
      skills based on your prompt and the skill's description"*; Codex *"can choose a skill when
      your task matches the skill `description`"* and therefore *"write concise descriptions with
      clear scope and boundaries"*; Claude Code uses it *"to decide when to load the skill
      automatically"*. **What "good" costs is also documented**: the description is the always-on
      half, capped at 1,536 characters per skill in Claude Code and at 2 % of context or 8,000
      characters in total in Codex. This is an L3 answer and is labelled as one — three vendors
      asserting a mechanism is not a measurement of it, and this stop's attempt to measure it was
      blocked.
- [x] **Prove the skill triggered** — **MEASURED. 5 of 5 runs of the matched arm**, each carrying
      one `claude_code.skill_activated` event with `skill.source = projectSettings`,
      `skill.name = custom_skill` and `invocation_trigger = claude-proactive` — implicit selection
      from the description, which is the mechanism under test. **L2**: the count comes from
      telemetry through [`tools/skill-activation.sh`](../../tools/skill-activation.sh), which has
      28 fixtures and separates a real zero from a missing measurement and from a damaged one.
      Runs `d6aec246`, `45a70775`, `2cf0c720`, `33a4090d`, `8998ef3b`, experiment
      `EXP-P3-SKILL-DESC`. The delivery path that was "missing" was never missing — the runner was
      passing `--disable-slash-commands`.
- [~] **Prove it did *not* trigger on an unrelated task** — **ANSWERED BY SUBSTITUTION, NOT BY
      THE CLAUSE AS WRITTEN, and marked `[~]` rather than `[x]` for that reason.** E-004 holds the
      task fixed and makes the DESCRIPTION unrelated. The misdescribed
      arm — same skill, same byte-identical body, a description naming CSS keyframe animations —
      recorded **0 activations on 5 of 5**, against 5 of 5 on the matched arm. Two-sided Fisher
      **p = 0.0079**. **L2** for the count; **L2** for delivery, because the skill was proved
      loadable in the arm-C worktrees by explicit `/shipment-service-conventions`, which does not
      consult the description — four of six worktrees loaded it and quoted its body, `Unknown command` came back **zero**
      times, and the other two returned an off-topic answer in a worktree the agent had already
      modified — **inconclusive probes, not refusals**, and counted as neither.
      **What is still not measured:** a genuinely unrelated *task*. §7 still reserves a second
      task for the author, and this substitution is not the same claim.
- [x] **Explain progressive disclosure** — answered, and quantified from two vendors. Name and
      description are always on; the body loads on selection; referenced files load on demand.
      Codex: *"start with each skill's name and description, then load the full `SKILL.md`
      instructions when they decide to use that skill."* Claude Code prices the always-on half
      against `CLAUDE.md`: *"a skill's body loads only when it's used, so long reference material
      costs almost nothing until you need it."* **Unmeasured here, and measurable**: the run
      record already stores prompt tokens, and E-003 has already run the always-on arm at 57 and
      1,455 words. That is the three-arm experiment Phase 2 proposed and it is still unrun.
- [x] **Explain why skill scripts are supply-chain risk** — answered from the vendor's own
      warning: *"Skills are not verified by GitHub and may contain prompt injections, hidden
      instructions, or malicious scripts."* And on execution: pre-approving `shell` or `bash`
      *"removes the confirmation step for running terminal commands and can allow
      attacker-controlled skills or prompt injections to execute arbitrary commands."* Note the
      shape — **the danger is that a permission prompt was the only thing standing there**, which
      is exactly what Phase 2 found behind `allowed-tools`. A skill is a directory-shaped
      dependency: *"Copilot automatically discovers all of the files in the skill's directory."*

**Four answered outright, one answered by substitution and marked `[~]`.** Three are from
documentation and labelled L3; *"prove the skill triggered"* is MEASURED at L2, `n = 5` per arm;
and *"prove it did not trigger on an unrelated task"* is answered for an unrelated **description**
and remains unanswered for an unrelated **task**, which is a different claim and is not ticked. The blocker they waited on turned out not to exist in the form
it was described — see [*The block was a flag, not a path*](#the-block-was-a-flag-not-a-path).

## Learning

```yaml
learning:
  what_was_added: >
    A measured lab (E-004, EXP-P3-SKILL-DESC, 15 runs, three arms interleaved) answering a
    claim three vendors make and none of them measures. Two registered overlays whose
    SKILL.md bodies are byte-identical at d10a2c3988be520e and differ only in `description`.
    Four instrument controls that execute and have fixture sets proving they refuse:
    tools/skill-activation.sh (28), tools/check-overlay-parity.sh (16),
    runner/lib/classify-skill-contamination.sh (16), runner/verify-skill-delivery.sh (7).
    Three runner changes: --enable-skills, a guard that refuses an undeliverable skill
    overlay, and a scoped force-add of the overlay's own paths.
  why_it_exists: >
    Stop 8 halted on the diagnosis that a Claude Code project skill cannot be delivered to a
    BE-003 run. The §9 validator's second pass said the halt proved only that a nested skill
    is absent from the /name registry AT SESSION START, and that E-004 measures MID-RUN
    activation. It was right, and the real cause was one flag nobody had read.
  observed_effect: >
    Matched arm 5 of 5, misdescribed 0 of 5, control 0 of 5. Two-sided Fisher p = 0.0079.
    The description decides whether the skill loads, with the body held byte-identical.
    All five registered predictions held, including the one registered as most likely to be
    wrong (skill.name IS redacted to `custom_skill` for project scope). Cost -7.6% against
    control, which does not reach the registered +25% row and is not a finding at n=5.
  unexpected_effect: >
    Two, and the second is the one that matters. First: the runner passed
    --disable-slash-commands, "Disable all skills", on every claude run ever done here, so
    the block was a flag and not a path - 6 of 6 activated without it, 0 of 6 with it, at
    BOTH paths. Second: the QUALITY co-variate splits control from BOTH treated arms, not
    matched from misdescribed. Arm C scores like arm B (4/5 vs 5/5, p=1.0) and unlike arm A
    (1/5, pooled p=0.017) on maintainability - the one category whose anchor is word-for-word
    the first bullet of the skill body - while never having activated the skill. That is not
    a result, because maintainability was never a registered outcome, and it is a caveat on
    this design: arm C is a clean control for ACTIVATION and is not one for BEHAVIOUR.
  keep_or_remove: >
    Removed one thing, and the removal is a finding: the runner's blanket rule that any
    `Skill` tool call is a leaked plugin skill. It was correct while skills were
    unconditionally disabled and it condemned the treatment arm the moment a skill was the
    treatment - run 46ffad94 was recorded F15 "EXCLUDE from comparisons" for loading the
    skill it was given. Every arm of the matched arm loads a skill, so the batch would have
    ended with arm B at n=0 and a report saying the treatment produced no usable runs.
    Everything else is kept, including skill-v0.1 unedited because a preflight run used it.
  next_question: >
    How CLOSE can the two descriptions get before selection stops? These are at maximal
    semantic distance - a Kotlin shipment backend against CSS keyframe animations - so this
    establishes that the description is the selector without characterising it. And it needs
    a prior fix: skill.name is redacted to `custom_skill`, so with two installed skills this
    instrument cannot attribute an activation to either.
```

## Review — §4a

Subjects: `experiments/E-004-skill-activation.md` and `tools/skill-activation.sh`. Family
`codex`, after `glm-5.2` failed the §0a preflight OFF CONTRACT — its third consecutive failure.

**The gate returned `REJECT` twice, and every blocking finding was correct.** Both rounds found
the same shape of defect, one field apart, and both were in the parts of the work that looked
most rigorous.

| Round | Verdict | Blocking findings | What happened |
|---|---|---|---|
| 1 | **REJECT** | 3 | decision rule contradicted its own MDE; row 4 over-attributed; **the tool counted a source-less event as the installed skill** |
| 2 | **REJECT** | 2 | rows 1–4 enumerated only one direction; **the tool counted a `plugin` event as the installed skill** |
| 3 | **REJECT** | 4 | **one fixed — the deepest — three left OPEN.** A first attempt exited 1 (infrastructure), left a header-only file and was discarded per §4a rather than counted |

**Three rounds, three `REJECT`s. §4a caps the loop at three, and `REJECT` after round three is
recorded as such and is not a pass.** `E-004` carries that verdict in a banner above its own
predictions. **Three of round 3's findings are open and are named there**: arm C's delivery proof
is circular with the prediction it is meant to confirm; nothing mechanically asserts that only
the `description` differs between arms; and the script does not separate partial telemetry
corruption from absent telemetry.

**Round 3's repetition is the finding.** It reported the same defect a third time, and each of my
first two fixes had named one more scope instead of rejecting the category: not-`bundled`, then
not-`bundled`-or-empty, then not-`bundled`-or-`plugin`. Every one of those would have credited a
user-scope or enterprise activation to the treatment **on the control arm**. The tool now reports
a count per `skill.source` and **labels nothing as the installed skill** — there is no number in
it meaning *"my skill loaded"*, and there cannot be until a preflight pins what source a project
skill emits. That is a worse-looking tool and a truer one.

**Round 1, finding 1 — the decision rule disagreed with the MDE in the same file.** Row 1 fired
`CONFIRM` on *"matched ≥ 4/5 and matched − misdescribed ≥ 3"*, while the MDE table called a
4-vs-1 result (`p = 0.206`) **not detectable**. Two readers, identical data, opposite verdicts.
The error was using a **raw difference** as the variable: the same difference is decidable or not
depending where it sits. All twelve cells are now computed in the file and exactly three reach
`p < 0.05`.

**Rounds 1 and 2, the tool — the same bug twice, and it is the bug the tool was written to
prevent.** `skill-activation.sh` exists because a run with no telemetry and a run with no
activation both produce zero. It shipped counting *anything that is not `bundled`* as the
installed skill. Round 1 found a **missing** `skill.source` falling through; round 2 found
**`plugin`** falling through — and `plugin` is the only non-bundled source ever observed on this
instrument, so a plugin skill firing on the **control** arm would have recorded an activation in
the arm that installs nothing. Eleven fixtures passed over both versions. **The fixtures tested
the cases the author thought of, which is exactly what a fixture set cannot fix on its own.**

The counter is now an allowlist by exclusion; `bundled`, `plugin` and source-less events are each
counted and reported separately; ~~the outcome is renamed `installed_scope`~~ — **and then that name
was removed too**, because it still implied the tool knew which activation was ours. No bucket in
the merged tool is named for the installed skill (corrected 2026-09-04, amendment below).
**15 fixtures, and the fix is confirmed against the real stream**: run `899232bb` now reports
`plugin_activations: 2` with every other bucket `0`, where an earlier version would have claimed
those two as the treatment.

## Amendment — 2026-09-04, from the §9 validator's second pass

Source: [`findings/track-b-validation-2026-09-04-2.md`](../../findings/track-b-validation-2026-09-04-2.md).
Verdict on this stop **at the time of that pass**: **NOT CLOSED — and not claimed closed**
(**superseded 2026-09-04: the stop is now CLOSED**, see *Validation*); the block itself **CONFIRMED
by independent reproduction** (a scratch repo, the same binary and model, root path answers with the
body marker and the nested path answers `Unknown command`), with four corrections. Stops 4–7 were
CONFIRMED. Every correction below is applied as an in-place fix carrying a pointer to this
section; no prediction, result, sheet or run folder was rewritten.

**(a) The registration citation was stale.** This workbook said E-004 was *"committed `5d14182`
before any run"*. True of the first commit and of the design, not true of the text a reader sees:
four later commits edited the file — including a rewrite of prediction 2 — all of them **before
any batch run and under the §4a gate's REJECTs**. The last pre-run edit is **`5a14711`**, and §9
check 2 applies against that sha. The full edit table and the superseded text of prediction 2 are
now in [`E-004`](../../experiments/E-004-skill-activation.md) under its own amendment, so the
original wording survives rather than being lost. Corrected in two places above.

**(b) Three citations quoted a field the merged tool does not print.** The validation table and
the §4a review section quoted `installed_scope_activations: null` and `installed_scope 0 /
plugin 2`, and said the outcome had been *"renamed `installed_scope`"*. Those are the **round-2**
tool's names. Round 3 removed that bucket entirely — *no bucket is labelled installed* — so the
merged tool at `049e871` prints only `bundled_activations`, `plugin_activations`,
`unknown_source_activations`, `other_source_activations` and `activations_by_source`. Both facts
behind the citations still reproduce; only the field names were wrong. Re-run 2026-09-04 against
the real 31 MB stream, output pasted rather than paraphrased:

```
$ ./tools/skill-activation.sh ../agent-observatory/infra/telemetry-out/events.jsonl \
    00000000-dead-beef-0000-000000000000
status: UNKNOWN-run-absent-from-telemetry
bundled_activations: null
plugin_activations: null
unknown_source_activations: null
other_source_activations: null            # exit 3

$ ./tools/skill-activation.sh ../agent-observatory/infra/telemetry-out/events.jsonl \
    899232bb-3a66-4326-981e-0aaa38329c09
status: measured
bundled_activations: 0
plugin_activations: 2
unknown_source_activations: 0
other_source_activations: 0
activations_by_source: plugin=2
skill_names: custom_skill=2
invocation_triggers: claude-proactive=1,nested-skill=1     # exit 0
```

**The consequence, which is larger than the wording.** *"0 project-scope activations"* on the two
probe runs is an **inference** from *"0 in every bucket"*, not a number the instrument prints.
The instrument cannot name a project-scope activation, because no project-scope skill has ever
been recorded on it and the value `skill.source` would carry for one is unknown. That is the
same hole prediction 2 records as *"the outcome has no denominator yet"*.

**(c) The run record cannot see a skill treatment at all.** `customization.skillsHash` is `null`
on both treated probe runs — `run-agent.sh:328` hashes `.github/skills.md` and nothing else — so
**§5's independence check for any skill arm cannot use `customization.*Hash` to tell treatment
from control.** It is `null` in both. Delivery proof rests entirely on telemetry. Recorded in
E-004's amendment as a standing constraint on the design, not as a surprise: prediction 4 predicts
exactly this field's blindness.

**(d) Stale fixture count.** `verify-skill-activation.sh` is 15 fixtures and passes 15/15; the
`learning:` block above and `TRACK-B-STATE.md` both said 11, the count before the last two gate
rounds. Corrected in both.

### And the finding this pass exists for — the block may be on the wrong premise

The validator's closing finding, quoted because it changes what happens next:

> **Stop 8's block proves that a nested skill is not in the `/name` registry at session start. It
> does not prove that a nested skill cannot activate during a BE-003 run — and E-004's outcome is
> mid-run activation, not registry membership.**

Two things on disk point the other way, and both are in this workbook's own evidence: the
telemetry stream already carries `invocation_triggers: … nested-skill=1` on run `899232bb`, so the
runtime has a trigger named for exactly this case; and the probe evidence's *"What is not
claimed"* section records a scratch repo where the same binary loaded a nested skill after reading
a file in that subdirectory — which every BE-003 run does.

**The author has decided accordingly** (2026-09-04, adopting the validator's recommendation, with
the adoption recorded so it measures something): probe the nested path at `n = 5` under a **new**
experiment key before any file §7 protects is moved; if it is zero on 5 of 5, take the runner
force-add, **not** the benchmarks `.gitignore` — the evaluator's scope guard reads that file and
changing it changes what the benchmark measures. Stop 8 is reopened at §4 step 5 on that basis.

Applied by Opus 5 (claude-opus-5), autonomous, 2026-09-04

## Validation

Stop 8 is **CLOSED**. Its closing condition — *"one lab that records skill activation on the
observatory — that lab's evidence on disk"* — is met: `EXP-P3-SKILL-DESC`, 15 runs, a registered
prediction that preceded them, a decision rule applied as written, and a co-variate that argues
against part of its own design.

**The layer column is about the PROOF, not the artifact.** Where the only proof is that I say so,
it says L3 and the row does not close a gate.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "Phase 3 skills: reading" | four sources ✅ in `SOURCES.md`; three extracted here 2026-09-04 | **L2** for *the URLs resolve* — `check-links.sh` executes and fails closed. **L3** for *they were read* — nothing executes that | `./tools/check-links.sh` |
| "extract" | three `## Extract` sections, dated, quoting verbatim | **L3** — nothing checks an extract against its source | open the four URLs, search for the quoted sentences |
| **"one lab that records skill activation on the observatory"** | `EXP-P3-SKILL-DESC`, 15 runs 2026-09-04T11:03–11:34Z; [`E-004`](../../experiments/E-004-skill-activation.md) | **L2** — the activation count comes from `claude_code.skill_activated` telemetry per run, not from prose | `curl :8081/api/runs \| jq '[.[]\|select(.experimentKey=="EXP-P3-SKILL-DESC")]\|length'` → 15 |
| …**"that lab's evidence on disk"** — the closing condition | matched `d6aec246 45a70775 2cf0c720 33a4090d 8998ef3b` = **1 activation each**; misdescribed `95f42409 fc3665a7 77c60831 cc41f3f0 946144c3` = **0 each**; control `d671d1b7 7b4428be 394ee79a ff7bffed c51a7a0c` = **0 each** | **L2** | `./tools/skill-activation.sh ../agent-observatory/infra/telemetry-out/events.jsonl <run-id>` on any of the fifteen |
| …the outcome counts only the scope this experiment installed | `skill.source = projectSettings`, **pinned by preflight run `46ffad94` before any batch was read**; every other source excluded by name | **L2** — `skill-activation.sh` counts per source and labels none "mine"; 28 fixtures, each asserting an exit code *and* a stdout line | `./tools/verify-skill-activation.sh` → `28 passed, 0 failed` |
| …a real zero is distinguishable from a missing and from a damaged measurement | statuses `measured` / `UNKNOWN-run-absent-from-telemetry` / `PARTIAL-telemetry-damaged`, exits 0 / 3 / 4. All 15 runs report `measured`, `malformed_lines: 0`, `damaged_records: 0` | **L2** — it executes and refuses | `./tools/verify-skill-activation.sh`; then a fabricated run id → `status: UNKNOWN…`, all counts `null`, exit 3 |
| …the arms differ in exactly one thing | body `sha256:d10a2c3988be520e` equal across both overlays; only `description` differs | **L1** for the bytes — they are identical or they are not. **L2** for the whole comparison — `check-overlay-parity.sh` executes, exits 2 on any undeclared difference and **3 if the arms are identical** | `./tools/check-overlay-parity.sh --allow-differ description build/customizations/skill-v0.2{,-misdescribed}`; `./tools/verify-overlay-parity-checker.sh` → `16 passed` |
| …**the treatment reached the model** | the model *used* it: 5 of 5 matched runs carry an activation with `invocation_trigger = claude-proactive`. Independently for arm C, where the prediction is a zero: explicit `/shipment-service-conventions` in the kept worktrees loaded the skill and quoted its body in **4 of 6** probed, `Unknown command` in **0** | **L2** — both are executions, and arm C's proof does not consult the description, so it is not circular with the prediction it supports | `cd $TMPDIR/observatory-run-95f42409-… && claude --permission-mode acceptEdits --strict-mcp-config --setting-sources project --model claude-haiku-4-5-20251001 -p "/shipment-service-conventions"` |
| …and could not have reached the control | arm A installs no customization; `git ls-files -- .claude` is empty in its worktrees; 0 activations of any source on 5 of 5 | **L2** | `git -C <arm-A worktree> ls-files -- .claude` → nothing |
| …the harness would refuse an undeliverable skill treatment | `run-agent.sh` **dies** when a customization installs a `SKILL.md` and skills would be disabled | **L2** — it executes and exits 1, naming the switch and the files | `./runner/verify-skill-delivery.sh` → `7 passed, 0 failed`; check A is the refusal |
| …and would not credit someone else's skill to the treatment | `classify-skill-contamination.sh`: `bundled` clean, `projectSettings` clean **only if this run installed one**, everything else contaminated, unparseable telemetry **unclassifiable** rather than clean | **L2** — 16 fixtures; and the caller treats exits 2 and 3 alike, so the fix cannot be undone by the line that calls it | `./runner/verify-skill-contamination.sh` → `16 passed, 0 failed` |
| …a scored cell is re-read by hand | `maintainability = 2` on run `45a70775`, written and **committed at `40f38e2` before `codex-score.sh` ran**; the sheet says `2` | **L2** for the ordering — git decides it, not prose. **L3** for the reading itself — a human applied an anchor | `git show 40f38e2` versus the sheet's mtime in `findings/codex/` |
| …no registered variable moved | model `claude-haiku-4-5-20251001`, evaluator `1.0.0`, benchmark `BE-003` at `0448643`, rubric `396e1799eb2b`; `git status --porcelain` in `agent-observatory-benchmarks` is **empty** | **L2** — read from the run records, not from the flags that were passed | `curl :8081/api/runs \| jq '[.[]\|select(.experimentKey=="EXP-P3-SKILL-DESC")]\|{m:([.[].runtime.model]\|unique)}'` |
| …the prediction preceded the runs | corrected design `f8ff084` **10:34:48Z**, pinned source `7cf5adb` 10:40:29Z, contamination finding `35abde7` 10:46:37Z; **first batch run `startedAt` 11:03:44Z** | **L2** — both sides read from git and the API | `git log --format=%cI -1 f8ff084` against the run record's `startedAt` |

**`n` for every number.** Every activation count is `n = 5` per arm and is stated as *true of these
runs*. The cost figures are medians of `n = 5` with their ranges printed, and the −7.6 % is
explicitly **not** offered as a property. The three delivery/registration facts about paths and
flags are structural: a file commits or it does not, a skill is in the registry or it is not.
The flag matrix is `n = 3` per cell, pooled to 6 versus 6.

**Independence check — what else changed between arms?** Confirmed from the run records:
`customization.*Hash` is `null` on **all fifteen runs, control and treated alike**, which is
prediction 4 holding and means those fields **cannot** separate the arms here — delivery rests on
telemetry, and that limitation is registered rather than worked around. `runtime.model`, the
benchmark sha, the evaluator version and the rubric sha are single-valued across all fifteen.
**The one thing that is NOT held equal between control and treated arms is the presence of the
`.claude/` directory itself**, and the co-variate section of `E-004` says so and refuses to
attribute quality to skill selection because of it.

**One run excluded, per the exclusions registered before the data:** `62deb6c5`, arm A, F13,
exit 12, 2 tool calls — it died mid-run on a claude session limit. `check-run-gate.sh` refuses it
by name. It is reported here with its count rather than quietly dropped, and the batch was
re-driven to a full 15.

## Commit

**What shipped:** `E-004` closed with a decision rule applied as written; two registered overlays
at `build/customizations/skill-v0.2{,-misdescribed}`; the evidence file that corrected this
stop's own halt; and four instrument controls with fixture sets that prove they refuse —
`tools/skill-activation.sh` (28), `tools/check-overlay-parity.sh` (16),
`agent-observatory/runner/lib/classify-skill-contamination.sh` (16),
`agent-observatory/runner/verify-skill-delivery.sh` (7).

**What did not ship, and is not pretended to have.** `.agents/skills/kotlin-testing/` and Labs
3.1, 3.3 and 3.4 belong to work this stop did not do. Lab 3.3 — progressive disclosure, the
economics claim — is now cheap on this apparatus and is registered as follow-up rather than
smuggled in. Lab 3.4 needs a disposable repository and a supply-chain scenario, neither of which
exists here.

**The `allowed-tools` question inherited from Phase 2 is still unverified.** Stop 7 found that
`allowed-tools` pre-approves where VS Code's `tools:` restricts, from the documentation, and no
lab here has observed either field behave. This stop installed a skill and measured its
activation; it never gave one a tool list. It stays open.
