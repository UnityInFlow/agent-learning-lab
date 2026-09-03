# Phase 2 — Prompt files / explicit reusable workflows

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ✅ **Extract only, labs deferred by the autonomous run** (stop 7, 2026-09-03) ·
**Depends on:** Phase 1

> **Scope of this closure.** The spine's stop 7 is *required reading and extract only*.
> Labs 2.1 and 2.2, the failure injection and the three "Predict before you run" questions
> need benchmark runs, and a run needs a registered prediction and an arm the author has
> not yet approved for a Track A phase with no B counterpart (◇). They are **deferred, not
> abandoned** — each is marked below with what it still owes. Nothing in this phase is a
> measured result, and nothing below is stated as one.
>
> Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-03

## Goal

Learn the difference between **always-on context** and an **explicit reusable task**.

This phase is about *repeatability and ergonomics*, not raw model intelligence. Measure it
as such — a prompt file that produces the same five sections every time is winning even if
its per-run quality is identical to a hand-typed prompt.

**E-003 makes that sentence the only defensible framing, rather than a stylistic
preference.** [`experiments/E-003-instructions-v0.1.md`](../../experiments/E-003-instructions-v0.1.md)
closed `REJECT`: a 57-word always-on instruction file, proved delivered by hash on 10 of 10
treated runs and absent by structure on 10 of 10 controls, moved no registered construct
(2/10 vs 3/10, p = 1.0), no cost, no duration, no tool count and no rubric category. If
*delivery* of always-on text does not move a quality score, then a phase about the
**explicit** sibling of that text has no business predicting a quality gain either. The
dependent variable Phase 2 already names — *structural consistency of the output* — is the
one E-003 did not test and did not refute.

## Verified reading

All four read 2026-09-03 by the autonomous run; quotes below are from those readings.

- [x] ✅ [VS Code — Prompt files](https://code.visualstudio.com/docs/agent-customization/prompt-files) — first extracted 2026-08-09, **re-verified 2026-09-03**, drift recorded below
- [x] ✅ [Copilot — Response customization](https://docs.github.com/en/copilot/concepts/prompting/response-customization)
- [x] ✅ [Claude Code — Skills](https://code.claude.com/docs/en/skills)
- [x] ✅ [Copilot feature matrix](https://docs.github.com/en/copilot/reference/copilot-feature-matrix) — prompt-file support differs by IDE, **and disagrees with the page above**

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
| `agent` | `ask` · `agent` · `plan` · or a custom agent name — **the page shortened this on 2026-09-03; see [Re-verification](#re-verification-2026-09-03--what-drifted-in-25-days) before citing it as current** |
| `model` | "The language model used when running the prompt" |
| `tools` | "A list of tool or tool set names that are available for this prompt" |

**Confirmed: there is no `mode:` field.** The curriculum's warning holds — do not teach it.

Note `agent` and `tools`: a prompt file can pin **which agent runs it** and **which tools are
available**. That last one is the only Layer-2 thing on this page, and it is how Lab 2.1's
read-only `/review-change` is actually enforced rather than requested.

> **True of VS Code, and it does not port.** Claude Code's similarly-named `allowed-tools`
> does the opposite — see [the reversal table](#the-finding-that-would-have-broken-lab-21--tools-reverses-direction-across-tools).
> Read that before building Lab 2.1 in any runtime other than VS Code.

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

### Re-verification 2026-09-03 — what drifted in 25 days

The page still documents **the same six frontmatter fields**, the same `.prompt.md`
extension, the same `.github/prompts` workspace location and user-profile location, the same
`chat.promptFilesLocations` setting, and the same three variables. **There is still no
`mode:` field.** Every claim above holds. Two things moved:

| Extracted 2026-08-09 | Read 2026-09-03 |
|---|---|
| "let you simplify prompting for common tasks by **encoding them as standalone Markdown files that you can invoke directly in chat**" | "Prompt files, **also known as slash commands**, let you simplify prompting for common tasks by encoding them as standalone Markdown files." |
| `agent` — "`ask` · `agent` · `plan` · or a custom agent name" | `agent` — "The agent used for running the prompt." |

The first is the one that matters, and not because the wording is prettier. **"Also known as
slash commands" is VS Code adopting the same noun Claude Code and Codex already use for
three different objects.** The cross-tool warning below was written when the names differed;
it is now *more* necessary, not less, because the last cue that these are distinct objects
has been removed from the vocabulary. The second row is a shortening, not a contradiction —
the page still lists the agent values elsewhere; the older quote is kept because it is the
more useful form and it was true when taken.

Neither edit changes a layer label or an exit-gate answer.

---

## Extract — Copilot response customization

Read 2026-09-03. Quotes verbatim.

### The three-way split, in the vendor's own words

| | Definition as printed |
|---|---|
| Custom instructions | "automatically add this information for you. The additional information is not displayed, but is available to Copilot" |
| Prompt files | "allow you to save common prompt instructions and relevant context in Markdown files (`*.prompt.md`) that you can then reuse in your chat prompts" |

> "While custom instructions help to add codebase-wide context to each AI workflow, prompt
> files let you add instructions to a specific chat interaction."

That is the same boundary VS Code draws, stated as *scope* rather than as *trigger*:
codebase-wide versus one interaction. Read the two sentences together and the distinction
has two independent axes, not one — **when it loads** (always / on invocation) and **what it
is about** (the codebase / this task). A skill or prompt file that is really codebase-wide
advice wearing a `/name` is on the wrong axis, and that is the honest form of the fourth
exit-gate question.

Agent and chat *modes* are **not defined on this page**; do not cite it for them.

### Precedence — and why it is L3

> "Personal instructions take the highest priority. Repository instructions come next, and
> then organization instructions are prioritized last. **However, all sets of relevant
> instructions are provided to Copilot.**"

Order **as summarised, not as quoted**: personal → path-specific → repository-wide → agent →
organization. The verbatim sentence above names only three of those five — personal,
repository, organization — and the other two come from the page's own list rather than from
a sentence quoted here. *Flagged by the stop-7 review as over-extended, and downgraded from
"as printed" to "as summarised" rather than deleted, because the five-item order is what the
page carries and the three-item quote is what this file can prove.* Anyone leaning on the
positions of `path-specific` or `agent` should go to the page.
Guidance as printed: "try to avoid providing conflicting sets of instructions."

**Apply the layer rule in order.** Can a conflicting instruction still be written down after
the precedence rule exists? Yes — the page asks you not to write one. Does something execute
and reject the lower-priority instruction? **No: the sentence after the ordering says all of
them are provided.** So the ordering is not a resolver; it is a *hint delivered alongside the
conflict it describes*, and the thing resolving it is the model. **L3.** A priority ordering
that ships every losing rule into the same context is guidance, and it is weaker guidance
than a single rule — which E-003 already measured at no effect. Anyone who reads that
ordering as a guarantee has an L2 belief about an L3 object, which is this project's house
failure mode with a documentation page as its host.

### Surface support, as this page states it

> "Prompt files are only available in VS Code, Visual Studio, and JetBrains IDEs."

**Hold that sentence** — the feature matrix contradicts it. See below.

Frontmatter fields and a fixed directory for prompt files are **not on this page**; take
those from the VS Code page only.

---

## Extract — Claude Code Skills

Read 2026-09-03. Quotes verbatim.

### The merge is official, and `.claude/commands/` is not deprecated

> "**Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md`
> and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same
> way. Your existing `.claude/commands/` files keep working. Skills add optional features: a
> directory for supporting files, frontmatter to control whether you or Claude invokes them,
> and the ability for Claude to load them automatically when relevant."

Command files "support the same frontmatter, except `name` and `paths`, which Claude Code
ignores in a command file."

This confirms the curriculum's claim and sharpens it: the merge added **three** capabilities
a prompt file does not have, and the third is the one with no VS Code analogue at all.

### Invocation is two-way, and that is the real difference from a prompt file

> "Claude uses skills when relevant, or you can invoke one directly with `/skill-name`."

A VS Code prompt file has exactly one caller: the human. A Claude skill has two, and the
frontmatter arbitrates between them:

- `disable-model-invocation: true` — "prevent Claude from automatically loading this skill"
- `user-invocable: false` — "only Claude should invoke the skill: Claude Code hides it from
  the `/` menu and doesn't run it when you type `/name`"

So "prompt file" and "skill" are not the same object with different file layouts. **The
prompt file is the degenerate case of a skill with `disable-model-invocation: true`.** That
is the cleanest way to hold the two in one head, and it is the second exit-gate answer.

### Lazy loading — the cost claim, stated by the vendor

> "Unlike CLAUDE.md content, a skill's body loads only when it's used, so long reference
> material costs almost nothing until you need it."

The listing is not free, and the page prices it: `description` plus `when_to_use` is
"truncated at 1,536 characters in the skill listing to reduce context usage." So the standing
cost of a skill is its *description*, and its body is paid on invocation.

**This is a vendor claim, not a measurement, and this repository is the wrong place to
restate it as one.** It is exactly the shape of claim E-003 was built to test and it is
directly measurable here — an always-on file's tokens are in every run record already. It is
written into the deferred labs below as the thing Lab 2.2 should actually measure, because
"fewer tokens than typing the same thing" (the existing question 2) is the weaker version of
it.

### The frontmatter, and which fields are required

**No field is required.** `description` is marked "Recommended"; every other field is "No".
The fields, as listed: `name`, `description`, `when_to_use`, `argument-hint`, `arguments`,
`disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`,
`effort`, `context`, `agent`, `background`, `hooks`, `paths`, `shell`, `metadata`, `license`,
`compatibility`.

Two structural traps on the same page:

1. > "Claude Code reads the frontmatter only when the opening `---` is the file's first line.
   > Otherwise it treats the whole file, `---` markers included, as skill content."

   A leading blank line silently converts every field into prose. Nothing warns. **This is
   the file-format equivalent of a control reporting success over a smaller scope than
   believed** — the skill still loads, still runs, and every restriction you wrote is now
   decoration.

2. Outside Claude Code — "claude.ai skill uploads, the Skills API, and packaging with
   `package_skill.py`" — only `name`, `description`, `license`, `compatibility`, `metadata`
   and `allowed-tools` are accepted. The page shows the failure verbatim:
   `Unexpected key(s) in SKILL.md frontmatter: argument-hint.` So a skill is portable and its
   *frontmatter is not*, which is the same lesson as the `/name` warning one level down.

### The finding that would have broken Lab 2.1 — `tools` reverses direction across tools

This section of the workbook says of the VS Code `tools:` field:

> That last one is the only Layer-2 thing on this page, and it is how Lab 2.1's read-only
> `/review-change` is actually enforced rather than requested.

**That is correct for VS Code and it does not port.** Three fields, two vendors, two
opposite directions:

| Field | Vendor | What it does, verbatim | Direction | Layer |
|---|---|---|---|---|
| `tools` | VS Code prompt file | "A list of tool or tool set names that are available." | **narrows** — a whitelist | L2 for anything routed through a tool |
| `allowed-tools` | Claude Code skill | "Tools Claude can use **without asking permission** during the turn that invokes this skill. The grant clears when you send your next message." | **widens** — pre-approval | **L3 for restriction; it removes a prompt, not a capability** |
| `disallowed-tools` | Claude Code skill | "Tools **removed from Claude's available pool** while this skill is active." | **narrows** | L2 |

Read the middle row again. `allowed-tools` is the field whose *name* matches the VS Code
whitelist and whose *behaviour* is its inverse: it does not restrict the pool, it removes the
permission prompt in front of it. **A `/review-change` skill ported from VS Code by mapping
`tools:` → `allowed-tools:` would not be read-only.** The write tools are not in the list,
so they are not pre-approved — but they were never *removed* either. They stay in the pool,
and the only thing standing between the skill and a write is the ordinary permission prompt:
a human saying yes. The whitelist that was a boundary in VS Code becomes, in Claude Code, a
list of things that skip the prompt, and everything omitted from it is *still available*.
The correct port is `disallowed-tools`, or `allowed-tools` alongside a deny rule that
actually removes the write tools.

*Corrected after the stop-7 review.* This paragraph first said the ported skill would be
"pre-approved to write without asking", which is wrong in the reader's favour and wrong
about the mechanism: omitting a tool from `allowed-tools` withholds pre-approval, it does
not grant it. The conclusion — use `disallowed-tools` — is unchanged, and the reason it is
right has moved from *"the port pre-approves writes"* to *"the port removes the boundary and
leaves only a prompt"*. **An L2 control was replaced by a human decision, which is L3**, and
that is the finding; saying it the first way would have had a reader looking for a
permission grant that is not there.

This is the trap this phase pays for, and it was found by reading, not by running. It is
recorded here so that Lab 2.1 — whenever it runs — starts from the right field.

**Layer caveat on all three rows.** Even `disallowed-tools` and VS Code's `tools:` are L2
only for a write that goes *through a tool*. A model that emits a patch as prose in its
answer has written nothing the runtime can reject. "Performs no writes" is L2 for the
filesystem and L3 for the transcript, and Lab 2.1's eval has to know which one it is
checking.

---

## Extract — Copilot feature matrix

Read 2026-09-03.

| Feature | VS Code | Visual Studio | JetBrains | Xcode | Eclipse | NeoVim |
|---|---|---|---|---|---|---|
| Prompt files | ✓ 1.108.0 | ✓ 18.6.0 | P 1.5.66 | **P 0.46.0** | ✗ | ✗ |
| Custom instructions | ✓ 1.108.0 | ✓ 18.6.0 | P 1.5.66 | P 0.46.0 | P 0.14.0 | ✗ |
| Custom agents | ✓ 1.108.0 | ✓ 18.6.0 | P 1.5.66 | P 0.46.0 | ✓ 0.14.0 | ✗ |
| **Agent Skills** | ✓ 1.108.0 | ✓ 18.6.0 | P 1.5.66 | ✗ | ✗ | ✗ |

GitHub.com, Copilot Chat on the web, Copilot CLI and GitHub Mobile are **not in the matrix**
for any of these rows — an absence, not a "no". Do not record a ✗ for them.

### The two GitHub pages disagree, and the matrix is the one to believe

Response customization: *"Prompt files are only available in VS Code, Visual Studio, and
JetBrains IDEs."*
The matrix: Xcode 0.46.0 is **P**, not ✗.

The workbook already told us to "check this before every lab — it is the single most common
source of *why didn't my file load*". That was advice. It is now **a measured disagreement
between two pages of the same vendor's documentation**, and the concrete rule that follows is
narrower and more useful than the advice: *the prose page is a summary and rounds `P` down to
absent; the matrix carries the minimum version and the partial state, so cite the matrix and
its version number, never the prose sentence.*

A second row moved since this workbook was written: **Copilot now has an "Agent Skills" row
of its own**, distinct from prompt files and from custom agents. The three-object warning
below was written for VS Code / Claude Code / Codex. It is now a four-object warning inside
what used to be one vendor's single column.

---

## Predict before you run

**DEFERRED — no run happened at stop 7, so all three are unanswered.** They are left
unedited and unanswered on purpose: writing a prediction now, with no run scheduled and no
registered arm, would put an unfalsifiable line on the record, and this project has already
paid for that once.

1. Will the reusable file produce a *more consistent structure* than a typed prompt, a
   better one, or both?
2. Will it use more or fewer tokens than typing the same thing?
3. How many review categories does a free-form prompt silently drop across 5 runs?

**What the reading changed about question 2.** As written it compares a prompt file against
typing — two costs paid at invocation, so the difference is small by construction. The
vendor's own claim is the interesting one and it is about the *other* axis: a skill's body
"loads only when it's used", where an always-on instruction file is paid every run. The
version worth registering is therefore **three-armed** — always-on file / invoked file /
typed — and its dependent variable is prompt tokens per run from the run record, which the
observatory already stores. Recorded as a proposal, not a prediction.

## Lab 2.1 — Build `/review-change` · **DEFERRED**

A prompt file that inspects the current diff, **performs no writes**, and returns:
correctness risk · missing tests · architecture risk · security concern.

Test on three prepared diffs: a correct change, one missing a test, one with an
architecture violation.

**What stop 7's reading already owes this lab, before it runs:**

- Build the read-only constraint with **`disallowed-tools`**, never `allowed-tools`. See the
  reversal table above — `allowed-tools` pre-approves and would make the lab's central claim
  false while looking correct.
- Decide, and write down first, whether "performs no writes" is being checked at L2 (the
  filesystem, which a tool restriction does enforce) or at L3 (the transcript, which it does
  not). The eval has to check the one that was claimed.
- The three prepared diffs do not exist yet. `BE-003` fixtures are the natural source; that
  is a new task shape and therefore **the author's call** under §7 of the run prompt.
- **Pick the runtime before writing a line of it.** The Commit block below names
  `.github/prompts/review-change.prompt.md`, which is a VS Code prompt file, while the bullet
  above mandates `disallowed-tools`, which is a Claude Code skill field with no VS Code
  equivalent. **As written the spec cannot be built** — it is half of each object. Flagged by
  the stop-7 review. It is left contradictory rather than silently resolved because choosing
  the runtime decides what the lab measures, and that is not a decision an extract gets to
  make: a VS Code prompt file uses `tools:` and a Claude Code skill uses `disallowed-tools`,
  and the two are not ports of one another, which is the whole finding above.

## Lab 2.2 — Prompt file vs free-form · **DEFERRED**

Run equivalent requests: **A** manually typed full prompt, **B** the reusable file.

Measure: consistency of output structure · missed review categories · tokens · human effort
to invoke.

**Note for whoever runs it.** "Human effort to invoke" has no instrument in this repository
and no run record field. Either drop it or define it as something the record holds
(invocation count, characters typed) before the arm is registered — an unmeasurable column in
a measured table is how a result acquires a claim it never tested.

## Failure injection · **DEFERRED**

Remove one critical review requirement from the prompt file. **Verify your eval notices the
missing category.** If it does not, your eval is scoring prose fluency.

**This is the same shape as `check-sheet-categories.sh`,** which exists precisely because a
sheet that silently dropped a category was indistinguishable from one that scored it. When
this injection runs, the assertion is that the eval *fails*, and a passing eval is the
finding.

## Exit gate

All four answered from the four readings above, 2026-09-03. No run was needed for any of
them; each is a question about what the objects *are*.

- [x] **Instructions vs prompt file.** Two independent axes, not one. *When it loads*:
  instructions are "applied automatically", a prompt file is one "you invoke manually in
  chat". *What it is about*: instructions "add codebase-wide context to each AI workflow",
  a prompt file adds "instructions to a specific chat interaction". The cost follows the
  first axis — always-on text is paid on every task including the ones it is irrelevant to;
  an invoked file is paid when asked. **And the measured caveat is E-003's**: paying that
  always-on cost bought no measured behaviour change at 57 words, so the interesting question
  about instructions is no longer "how short" but "why at all".
- [x] **Prompt vs skill.** A prompt file has one caller, the human. A skill has two — "Claude
  uses skills when relevant, or you can invoke one directly with `/skill-name`" — and the
  frontmatter arbitrates with `disable-model-invocation` and `user-invocable`. The compact
  form: **a prompt file is the degenerate case of a skill with
  `disable-model-invocation: true`.** Everything else a skill adds — a directory of
  supporting files, lazily loaded body, tool fields, `paths` activation — is additive on top
  of that one difference in who may call it.
- [x] **Why Claude's current custom-command story maps to Skills.** Because the vendor merged
  them, in those words: "Custom commands have been merged into skills… both create `/deploy`
  and work the same way. Your existing `.claude/commands/` files keep working." So it is not
  a deprecation to migrate away from; it is one object with two file layouts, where the older
  layout silently drops `name` and `paths`. Teach the skill layout because it is the superset,
  not because the command layout is broken.
- [x] **Why you should not create a slash command for every sentence engineers type twice.**
  Three costs the reading names, none of them the body's tokens:
  1. **The listing is always-on even though the body is not.** `description` + `when_to_use`
     are carried in every session and truncated at 1,536 characters. N skills cost N
     descriptions before any of them is used, so a directory of near-duplicates degrades
     Claude's ability to pick the right one — the scarce resource is *discriminability*, not
     context.
  2. **Two callers means a wrong caller.** Anything model-invocable can fire when you did not
     mean it; that is a failure mode a pasted snippet cannot have.
  3. **It is usually on the wrong axis.** By the vendor's own split, a sentence typed twice is
     often codebase-wide context, which is what instructions are for — and E-003 says that
     path may buy nothing measurable either. Twice is not a pattern. The threshold for
     encoding is *parameterisation*: if it takes no `${input:…}` and no argument, it is a
     paste buffer with a name, and the extract above already says so.

## Learning

```yaml
learning:
  what_was_added: >
    No artifact. Stop 7 is a Track A reading stop with no B counterpart, and what was added
    is an extract of three previously unread sources plus a re-verification of the fourth,
    the four exit-gate answers, and explicit deferral markers on the three labs.
  why_it_exists: >
    To fix the vocabulary before B4 spends runs on it. Phase 2 is the last stop before the
    spine starts building agents, and three of its objects — prompt file, skill, command —
    are the ones B4 and B6 will be made of.
  observed_effect: >
    Reading only, no runs, so no effect on the agent under test and no number. The effect
    on the plan is one corrected field mapping: Lab 2.1's read-only constraint would have
    been built on allowed-tools, which pre-approves rather than restricts, and would have
    produced a write-capable agent that passed its own read-only check.
  unexpected_effect: >
    Two vendor pages from the same vendor disagree about which IDEs support prompt files
    (Xcode: "only available in VS Code, Visual Studio, and JetBrains" versus P 0.46.0 in the
    matrix). And the preflight found that bare pgrep on this machine fails with an illegal
    byte sequence and returns nothing, so the stall check that both CLAUDE.md and the run
    prompt rely on has been answering "no stall" without looking. That one is not about
    Phase 2 at all and is the more expensive of the two. **Fixed at L3 only, and the fix is
    named so a later reader is not left guessing:** `agent-learning-lab/CLAUDE.md`, in the
    section "`opencode run` hangs", now says to use `LC_ALL=C pgrep`. The L2 version — a
    locale-forced stall check inside `opencode-review.sh` that refuses to write a findings
    file while a stray process is live — is **not built**, because a review of this very
    workbook was in flight when the defect was found and *never edit a tool while a run of
    it is in flight* outranks fixing it promptly. It is on record for the author.
  keep_or_remove: >
    Keep the extract. Keep the deferral markers rather than deleting the labs — a deferred
    lab with its debts written down is evidence; a deleted one is a gap that looks like a
    decision. Nothing is removed, because stop 7 built nothing that could have no effect.
  next_question: >
    Does a skill's lazily loaded body actually cost less per run than the same text in an
    always-on file? The observatory already records prompt tokens per run, E-003 already
    measured the always-on arm at 57 and at 1455 words, and the vendor's claim is
    unmeasured here. That is a three-arm experiment this repository could run today, and it
    is the first Phase 2 question with a real instrument behind it.
```

## Commit

**Not produced at stop 7.** Both artifacts belong to the deferred labs:

```
.github/prompts/review-change.prompt.md      # Lab 2.1, deferred
experiments/B2-prompt-files.md               # needs a registered arm; the author's call
```

Per §6 of the run prompt — never create a future step's artifacts early — neither is written.

## Validation

Stop 7 registers no gate of its own; the spine's closing condition is *"extract written"*.
The clauses below are that condition plus the workbook's own exit gate.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "Phase 2 (◇ no B counterpart): required reading and extract only" — required reading | The four sources are ✅ in [`SOURCES.md`](../../SOURCES.md) lines 61, 89, 90, 91. Run 2026-09-03T19:2xZ: `ok=64 moved=8 blocked=2 unverified=0 broken=0`, exit 0 — **and none of the four is among the 8 moved or the 2 blocked**, so all four resolve directly and the redirect warning does not apply to this phase | **L2** — `./tools/check-links.sh` executes and fails closed on a dead link; it is CI job *verified reading is still verified* | `cd agent-learning-lab && ./tools/check-links.sh`, read the counts, then check the MOVED/BLOCKED lines for these four URLs |
| …and extract only | Four `## Extract` sections in this file, one per source, each dated and quoting verbatim | **L3** — nothing executes a check that an extract matches its source. The proof that it was *read* is L2 above; the proof that it was read *correctly* is that the quotes are checkable by hand, which is a human act | Open each of the four URLs and search for the quoted sentence |
| "Mark 'extract only, labs deferred by the autonomous run'" | The status line at the top of this file, and `DEFERRED` on Lab 2.1, Lab 2.2, Failure injection and Predict-before-you-run | **L3** — a marker is words a reader chooses to honour | `grep -n DEFERRED phases/02-prompt-files/README.md` returns 5 lines: four markers (the Predict-before-you-run paragraph and the three lab headings) and this table row citing them |
| Exit gate: "Instructions vs prompt file" | Answered above from two verbatim quotes (VS Code "Unlike custom instructions that are applied automatically…"; Copilot "While custom instructions help to add codebase-wide context…") | **L3** — a written answer | Compare the answer against the two quoted sentences |
| Exit gate: "Prompt vs skill" | Answered above from "Claude uses skills when relevant, or you can invoke one directly with `/skill-name`" plus the `disable-model-invocation` / `user-invocable` rows | **L3** | Read the frontmatter reference table on the Skills page |
| Exit gate: "Why Claude's current custom-command story maps to Skills" | Answered above from "Custom commands have been merged into skills… Your existing `.claude/commands/` files keep working" | **L3** | Read the Note block at the top of the Skills page |
| Exit gate: "Why you should not create a slash command for every sentence engineers type twice" | Answered above from the 1,536-character listing cap, the two-caller model, and the vendor's own axis split | **L3** | Read the `description` row of the frontmatter reference |
| Hand check — one quoted claim re-derived independently of the fetch that produced it | The `allowed-tools` / `disallowed-tools` reversal, re-read off the Skills page frontmatter table: `allowed-tools` = "Tools Claude can use **without asking permission**", `disallowed-tools` = "Tools **removed from Claude's available pool**" | **L3** for the doc claim; the *consequence* is L2 and untested — no lab ran, so this repository has not observed either field behave | Open the Skills page, frontmatter reference, rows `allowed-tools` and `disallowed-tools` |

**Independence check.** Nothing changed between arms because there are no arms: stop 7
launched no benchmark run, wrote no customization overlay, and touched no rubric, evaluator,
fixture or model id. The registered variables are byte-identical to the ones E-003 closed
under. Confirmed by `git diff --stat` on this branch touching only
`phases/02-prompt-files/README.md`, `TRACK-B-STATE.md`, `HANDOFF.md` and this stop's review
file.

**`n` for every number in this file: `n = 0` runs.** Nothing above is stated as a property of
the agent under test. Every claim is a claim about what four documentation pages say on
2026-09-03, and the one claim about measured behaviour is E-003's, quoted with its own `n`.
