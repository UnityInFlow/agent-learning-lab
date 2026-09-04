# Phase 3 — Agent Skills

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ⛔ **BLOCKED — stop 8 of the spine.** Reading and extract done 2026-09-04. Lab 3.2 is
the stop's closing condition and **could not run**: a Claude Code project skill cannot be
delivered to a BE-003 run. Caught at §4 step 5, before the batch. See *Lab 3.2 status* below ·
**Depends on:** Phase 2

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

## Lab 3.2 status — **BLOCKED at §4 step 5, and the block is the result**

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

## Predict before you run — **unanswered, and left that way**

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
- [ ] **Prove the skill triggered** — **NOT MEASURED, and now precisely blocked.** The instrument
      *can* do it: `claude_code.skill_activated` carries `observatory.run.id`, `skill.name`,
      `skill.source` and `invocation_trigger`, and [`tools/skill-activation.sh`](../../tools/skill-activation.sh)
      reads it per run. What is missing is a delivery path, not an instrument.
- [ ] **Prove it did *not* trigger on an unrelated task** — **NOT MEASURED.** Needs a second task
      besides BE-003, which §7 reserves for the author. E-004 routes around this by varying the
      *description* instead of the task, which stays within BE-003 — but that arm cannot run
      until delivery is unblocked.
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

**Three of five answered, all three from documentation and labelled L3. Two not measured, and
both wait on the same blocker.**

## Learning

```yaml
learning:
  what_was_added: >
    An extract of three previously unread sources; a registered experiment (E-004) with five
    predictions, an MDE derived from Fisher's resolving power rather than from its own
    thresholds, and an exhaustive decision rule; two customization overlays whose SKILL.md
    bodies are byte-identical at d10a2c3988be520e and differ only in the description; and
    tools/skill-activation.sh with 15 fixtures (this line said 11, the count before the last two
    gate rounds; corrected 2026-09-04 from the second validator pass). No measured runs.
  why_it_exists: >
    Three vendors state that a skill is selected by matching the task against its description.
    None shows a measurement. The observatory turned out to already record skill activation,
    so the claim looked cheap to test on the instrument this project already has.
  observed_effect: >
    None on the agent under test - the lab never batched. The observed effect is on the
    instrument: a Claude Code project skill cannot be delivered to a BE-003 run at all. The
    location the runner can commit is not registered by the runtime, and the location the
    runtime registers cannot be committed by the runner.
  unexpected_effect: >
    The nested location fails silently in the direction that would have manufactured a
    result. It installs, commits, is tracked, and the runs evaluate clean - and the skill is
    not there. Fifteen runs at that path would have produced three arms agreeing perfectly and
    a confident conclusion that the description does not matter, drawn from runs with no skill
    in them. Also, on two runs at a location where the skill WAS registered, the model did not
    select it even when told it was required - n=1 each, and the reason prediction 1 is worth
    running.
  keep_or_remove: >
    Keep tools/skill-activation.sh - it is proven by 15 fixtures and by hand against the real
    31MB stream, and it is what the lab will use the day it runs. Keep both overlays unedited;
    they are the registered arms. Keep E-004 open and unanswered rather than closing it with
    the n=1 hint, which is the whole discipline. Remove nothing.
  next_question: >
    Which of the two halves does the author want moved - the benchmark's .gitignore, or the
    runner's install step? Both are one line. They are not equivalent: the gitignore change
    alters what the evaluator's scope guard can flag, and the runner change does not, which
    makes the runner the cheaper place to fix a problem the runner created.
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
Verdict on this stop: **NOT CLOSED — and not claimed closed**; the block itself **CONFIRMED by
independent reproduction** (a scratch repo, the same binary and model, root path answers with the
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

Stop 8 is **BLOCKED, not closed.** Its closing condition — *that lab's evidence on disk* — is
not met: the lab produced no measured runs. This table validates what the stop *did* establish,
and the last row states plainly what it did not.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "Phase 3 skills: reading" | Four sources ✅ in `SOURCES.md`; three extracted here for the first time on 2026-09-04 | **L2 for "the URLs resolve"** — `./tools/check-links.sh` executes and fails closed. **L3 for "they were read"** — nothing executes that | `./tools/check-links.sh`; for the reading half, check the quotes against the pages by hand |
| "extract" | Three `## Extract` sections in this file, one per source, each dated and quoting verbatim | **L3** — nothing checks an extract against its source | open the four URLs and search for the quoted sentences |
| "one lab that records skill activation on the observatory" | [`E-004`](../../experiments/E-004-skill-activation.md), registered `5d14182`, last pre-run edit `5a14711` (amendment below); overlays under `build/customizations/skill-v0.1{,-misdescribed}/`; [`tools/skill-activation.sh`](../../tools/skill-activation.sh) | **L2 for the instrument** — 15 fixtures execute and each asserts an exit code *and* a stdout line; `./tools/verify-skill-activation.sh` exits non-zero if any fails | `./tools/verify-skill-activation.sh` → `15 passed, 0 failed` |
| …the tool distinguishes a real zero from a missing measurement | fixtures *"a run ABSENT from telemetry is NOT reported as 0"* (exit 3) and *"its count is null, never 0"* | **L2** — it executes and refuses. Hand-checked against the real 31 MB `events.jsonl`: a fabricated run id returns `status: UNKNOWN-run-absent-from-telemetry` with **all four source counts `null`** — `bundled_activations`, `plugin_activations`, `unknown_source_activations`, `other_source_activations` — exit 3. The merged tool prints no `installed_scope` line at all; corrected 2026-09-04, amendment below | `./tools/skill-activation.sh ../agent-observatory/infra/telemetry-out/events.jsonl 00000000-dead-beef-0000-000000000000` |
| …and every scope this experiment did not install is excluded — ~~the outcome counts only the skill this experiment installed~~, which the merged tool deliberately no longer claims (amendment below) | fixtures *"a bundled skill is NOT the installed skill"*, *"a plugin skill is NOT the installed skill"*, *"an event with NO skill.source is not the installed one"* | **L2** — three separate scopes are excluded by executing code, each reported on its own line. **Both exclusions were added because the §4a gate caught them, not because a fixture did** — 11 fixtures passed over both broken versions | `./tools/verify-skill-activation.sh` → `15 passed`; then `./tools/skill-activation.sh <events.jsonl> 899232bb-3a66-4326-981e-0aaa38329c09` → `plugin_activations: 2` with every other bucket `0` |
| …the treatment differs from its control in exactly one thing | body-only `sha256` `d10a2c3988be520e` **equal** across both overlays; full-file hashes differ | **L1** — the bytes below the frontmatter either are identical or are not; `shasum` decides | `awk 'n>=2{print} /^---$/{n++}' <each SKILL.md> \| shasum -a 256` |
| …**"that lab's evidence on disk"** — the closing condition | **NOT MET.** Zero measured runs. Three runs exist and none is data: `16cd4378` died at setup, `c090f67e` and `d8be2b5f` are preflight probes under `EXP-P3-PREFLIGHT` | **L2 for the blocker itself** — the runner *executed* and refused (`failed to commit the customization overlay`), and `claude -p "/name"` *executed* and answered `Unknown command`. The block is demonstrated, not asserted | [`evidence/p03/skill-delivery-probe-20260904T072000Z.md`](../../evidence/p03/skill-delivery-probe-20260904T072000Z.md) — it lists the commands |

**Independence check.** No arm was compared, so there is nothing to keep independent. Nothing
registered moved: rubric `396e1799eb2b`, evaluator `1.0.0`, benchmark `0448643`, model
`claude-haiku-4-5-20251001` on both completed probe runs. **The benchmark repository was not
touched** — the one-line `.gitignore` change that would unblock this stop was refused under §7
and raised to the author instead.

**`n` for every number here.** The three delivery/registration facts are `n = 1` each and are
**structural** — a file is committed or it is not; `/name` resolves or it does not. The one
behavioural observation (the model not selecting a registered, matched skill) is `n = 1` per
condition and is stated nowhere as a property.

## Commit

**Not produced.** `.agents/skills/kotlin-testing/` and `experiments/B3-skills.md` both belong to
labs that could not run. What shipped instead is `E-004`, two overlays, one tool with its
fixtures, and the evidence file naming the blocker.
