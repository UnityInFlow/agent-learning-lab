# B8 — Run state, repair limits, completion contract

**Track A first:** [Phase 5B](../05b-verification-selfhealing/) · **Layer 2**
**Version:** **v1.1**
**Spine position:** 17 of 28 · after [Phase 5B](../05b-verification-selfhealing/) · before [Phase 6A](../06a-code-intelligence/)
**Status:** 🟨 open — spine stop 17, opened 2026-09-15 on `stop17/b8-run-state-repair-limits`

> Build and Exit gate are quoted from [`build/README.md`](../../build/README.md#b8).
> Everything else is yours to fill.

---

## Goal

Build the three things that turn v1.0's prompts into enforcement — persistent run state, hard
repair limits, a completion contract — and with them the classification fix that makes
**BLOCKED ≠ FAILED**. **v1.1 closes here.**

The gate asks for **no regression** against v1.0, which is a different question from an
improvement, and the track has already answered which of the two to expect. Of the six build
steps measured so far, exactly one moved anything the instrument could see (B6, one skill).
B7's Layer 2 gate executed on 17 of 17 treated runs and changed all four BE-004 rubric deltas by
**0** at **+5.02 %** cost. So the honest shape of this stop is *build the enforcement, measure
it, and expect the measurement to be a null* — and the reason to build it anyway is that a
counter that survives an interruption and a `BLOCKED` that is not a `FAILED` are things the
**instrument** needs in order to be able to say anything at all, not things the agent needs in
order to score better.

Both tasks, per author decision 9: **BE-003 and BE-004**, separate experiment keys, separate
prediction commits, separate concurrent controls, and **no verdict computed across tasks**.

## Required reading

### Internal — the requirement

Opened and quoted, not listed. Line numbers are as of `3a0f61f`.

| Source | Lines | What it gives this stop | Layer of the thing it describes |
|---|---|---|---|
| [`businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md`](../../businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md) §5.1 | 360-386 | `.agent/run-state.json` and its 14-field schema, including `repairAttemptsForCurrentFailure` and `totalRepairAttempts` | **L3** — a schema in a design document; nothing reads it |
| same, §5.2 | 389-416 | the fingerprint formula (failure class + command + normalized primary error + affected module), the limits, and `stop / emit BLOCKED / require human decision` on exceed | **L3** as written; **L2 only where a script enforces it** |
| same, repair-limit constants | 103-104 | `MAX_REPAIR_ATTEMPTS_PER_FAILURE = 3`, `MAX_TOTAL_REPAIR_ATTEMPTS = 7` — the numbers, stated twice in the same document | **L3** — constants in prose |
| [`businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md`](../../businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md) §10.6 | 419-435 | what `DONE` means: acceptance criteria mapped, build passed, required tests passed, static analysis passed, no critical findings, no forbidden files changed, final summary generated. *"Code written is not the same as task completed."* | **L3** — a list of conditions, with nothing that checks them |
| same, NFR-009 | 739-741 | *"A run must continue when exact token data is unavailable."* — degradation is a requirement, so a missing measurement must not become a failure | **L3** |
| same, Risk register | 1788-1790 | *"Risk: Agent grades itself too positively. Mitigation: Deterministic checks, human rubric, optional blinded reviewer."* — this is the completion contract's whole reason | **L3** |

The §10.6 contract is seven clauses and **not one of them executes today**. That is the
distance this stop has to cover, and it is why the build is a script rather than a document.

### Internal — Track A, and the two things it handed over

[Phase 5B](../05b-verification-selfhealing/) closed at stop 16. Its extract is not re-derived
here (§1); two of its lines are load-bearing for every design decision below.

- **The layer rule for a counter**, `05b-verification-selfhealing/README.md:82-86`:
  > *"A limit that lives in a hook is also a suggestion unless that hook writes it down, because
  > the hook is reinvoked with no memory of itself. […] a counter held in a hook's own process is
  > L3 wearing L2's clothes; a counter on disk, read and incremented by a hook that exits 2, is L2."*
- **The trichotomy**, `README.md:156-160`:
  > ```
  > FAILED      it produced a wrong answer
  > BLOCKED     something prevented it from answering        ← not the same thing
  > DONE        it claims success                            ← an assertion, not a fact
  > ```
- **What it left explicitly unbuilt**, `README.md:657-660` — its own Commit block names
  `.agent/run-state.json schema · scripts/verify.sh · fingerprint tests` as the deliverable it
  did not produce. Labs 5B.1–5B.4 are deferred and `lab#15` stays open for them.

### External — the technique

**Nothing new is read for this stop, and that is a decision, not an omission.** Phase 5B's four
external reads are recorded as verified at `05b-verification-selfhealing/README.md:19-31` —
*Building effective agents*, *How Claude Code works*, the *Hooks* reference, and our own §5
design — and its takeaway table at `:137-142` already reports the one thing B8 needs from them:

> | Claude Code hooks | `PermissionRequest` / `PermissionDenied` exist; state is a file keyed by `session_id`; `exit 2` blocks and prevents stopping | **L2 when built** — these execute |

and, of the other three rows, that **no published source gives the evaluator-optimizer loop a
stopping condition**. B8 is the stop that supplies one; there is no external technique left to
read, because the finding of Phase 5B's reading was that the technique is not published. Adding
a fresh citation here would be decoration. `SOURCES.md` therefore gains no new entry at this
step, and `check-links.sh` has nothing new to check.

## Extract

The passage that makes BLOCKED ≠ FAILED explicit is Phase 5B's trichotomy, quoted above. What
follows is not a reading of documents: it is **five facts measured off the repositories at
`3a0f61f`**, each re-derived by hand in the main context after a subagent reported it, because
every one of them constrains what this stop can claim. They are here rather than in the Build
section because three of them change what the build has to be.

### 1. `.agent/run-state.json` does not exist anywhere, in any of the three repositories

`grep -rn "run-state\|runState\|repairAttempt\|totalRepairAttempts"` over the whole of
`agent-observatory` returns **zero hits**. Phase 5B's Commit block listed the schema as unbuilt
at stop 16 and it is still unbuilt. **B8 builds from zero**; there is no prior version to
regress against on this artifact, and the v1.0 comparison the gate asks for is a comparison of
*runs*, not of this file.

### 2. Stop 16's classifier exists, its fixtures execute, and **nothing calls it during a run**

`agent-observatory/runner/lib/classify-permission-block.sh` was merged at stop 16 (obs#77 →
`1376a2ee`). Re-run here: `verify-permission-block-classifier.sh` reports **39 passed, 0
failed**, and its cases include refusals as well as acceptances — absent `permissionDenials` is
rejected as *"absent is not zero"*, and so are malformed JSON, a leading-zero `"08"`, and an
integer overflow. As a **checker it is L2**: something executes and rejects bad input.

But `grep -rn "classify-permission-block"` across `agent-observatory` returns exactly **one
caller — its own verifier**, at `runner/verify-permission-block-classifier.sh:24`.
`run-agent.sh` never invokes it. So **in the run path it is L3**: a correct script that no run
executes cannot classify anything, and B8's gate clause *"a blocked run produces a clear
machine-readable result"* **is not met by it as it stands**.

This is not a defect in stop 16 — obs#77's own PR scope was the classifier and its fixtures, and
E-017 says in terms that obs#47 is left open on purpose. It is B8's inheritance, and naming it
now is what stops this stop from citing stop 16's green fixtures as if they were a run-path
control. *That substitution — a check that passes over a scope smaller than the claim — is the
house failure mode, and it is written down in the workspace `CLAUDE.md` because it has already
cost this project a voided batch.*

### 3. No hash can prove B8's treatment was delivered, and this arrives one stop early

`run-agent.sh:625-629` builds `customization` from exactly three computed values:
`instructionsHash` (one `CLAUDE.md`), `skillsHash` (the sorted set of every `SKILL.md`), and
`agentHash` (the single dispatched `.claude/agents/<name>.md`). The run schema declares five —
`hooksHash` and `mcpHash` are present in `runner/schemas/run.schema.json:60-61`, in
`observatory-web/src/api.ts:36-37`, in the API DTO and in the entity — and **neither is ever
computed**. They are `null` on every run ever recorded.

B8's repair limit is enforced *by a hook or wrapper, never by prompt* — that is the build spec's
own wording — and a hook arrives as `.claude/settings.json` plus a script, copied into the
worktree by the generic overlay copy at `run-agent.sh:338` and force-added at `:371`. **So the
one field that would prove this stop's treatment reached the model is the one field the runner
does not fill.** Author decision 11 item 9 anticipated exactly this shape for B8a and answered
it with a four-condition per-run proof that depends on no hash. The same problem lands here
first, and the delivery proof this stop registers at §4 step 3 has to be built from things that
are actually written down per run — not from the presence of a file in a directory.

### 4. The run record has nowhere to put a per-run artifact

`runner/schemas/run.schema.json` has fourteen top-level properties and none of them is an
artifact or blob; `result` is `{changedFiles, addedLines, deletedLines}` with
`additionalProperties: false`. A `.agent/run-state.json` produced inside a worktree is therefore
**visible only in the kept worktree**, not through the API — and `--keep` worktrees are exactly
the evidence this project has just lost 54 of to the `$TMPDIR` reaper (see
`TRACK-B-STATE.md` `author_notes`, and the decision-11 census, which returned no reading for
that reason). Any §5 row of this stop that cites a run-state file from a worktree is citing
evidence with a **three-day half-life**, and must either copy it somewhere durable at the time
of the run or record a value through a channel that survives.

### 5. `run-agent.sh` emits only two failure classes itself

The enum is fifteen — `F01`–`F15`, defined at `docs/metric-catalog.md:107-113` and re-declared
in `runner/schemas/evaluation.schema.json` — but `run-agent.sh` sets `ABORT_CLASS` to only
`F13` or `F15` (`:1104, :1205, :1215, :1234, :1254, :1356`), writing it at `:1363`. Everything
else in the enum comes from the evaluator. **`BLOCKED` is not in the enum at all.** Whatever
this stop produces as a machine-readable blocked result is therefore a new value in an existing
field or a new field — and either of those is a **registered-variable question** that §6 and §7
govern: an additive field is an instrument PR I merge myself, a changed *meaning* for an
existing exit code is a halt.

### What this stop takes forward

| Fact | What it forces |
|---|---|
| run-state does not exist | build from zero; the v1.0 comparison is between runs, not artifacts |
| the classifier is L3 in the run path | the gate's *machine-readable blocked result* clause is not inherited; it must be built and shown to execute |
| no hash proves a hook overlay | the delivery proof is registered at step 3 from per-run evidence, not from file presence |
| the record has no artifact field | run-state evidence is worktree-only and perishable; copy it, or record a value that survives |
| `BLOCKED` is not in the failure enum | additive field or new enum value = instrument PR; re-meaning an exit code = §7 halt |

## Build

**Build:** the three things that turn v1.0's prompts into enforcement.

**1. Persistent state** — `.agent/run-state.json`: phase, goal, affected files, last failure,
`repairAttemptsForCurrentFailure`, `totalRepairAttempts`. It must survive an interrupted
session.

**2. Hard repair limits**, enforced by hook or wrapper, never by prompt:

```
fingerprint = failure class + command + normalized primary error + affected module
same fingerprint  ≤ 3        total ≤ 7        on exceed → BLOCKED, not FAILED
```

**3. Completion contract** — `DONE` confirmed by a script, not asserted by the agent.

**And the classification fix:** BLOCKED ≠ FAILED. Permission blocks, quota exhaustion and
infrastructure faults are **infrastructure**, never incorrect code. This is harness bug #7,
and it currently voids every cross-model comparison you run.

> **From the observatory, 2026-08-10:** the phrase-matching approach to this failed four
> times — quota→F03, permission block→F05, dropped connection→F03, session limit→F03. The
> rule that finally worked needs no vocabulary: *an agent that changed no file and called no
> tool did not attempt the task.* And `claude_code.tool.blocked_on_user` is a real span that
> fires on a permission gate, so the runtime will tell you directly. See issue #47.

## Design — spine stop 17, 2026-09-15

Written before anything is built, as §4 step 2 requires, and every artifact below is labelled
with the workspace `CLAUDE.md` rule **applied in order, stopping at the first yes**.

### The trap, named from `build/README.md#b8`, and the layer that converts it

The trap is not "the agent retries too often". It is spelled out in the build spec and again in
this workbook's Build block:

> **From the observatory, 2026-08-10:** the phrase-matching approach to this failed four times —
> quota→F03, permission block→F05, dropped connection→F03, session limit→F03. The rule that
> finally worked needs no vocabulary: *an agent that changed no file and called no tool did not
> attempt the task.*

So the trap is **classification by vocabulary** — deciding BLOCKED from the words in an error
string — and the thing that converts it is a rule stated over *facts the record already holds*
(files changed, tools called) rather than over text, **executed by a script**. That is L2.

**And the conversion this stop owes is wiring, not vocabulary.** Stop 16 already wrote the
vocabulary-free script: `classify-permission-block.sh` decides from `permissionDenials` and a
changed-file count, and its 39 fixtures prove it refuses. What it does not have is a caller.
Extract item 2 is the whole gap, and B8's version of *"a blocked run produces a clear
machine-readable result"* is the clause that closes it.

### Three decisions the design does not get to make freely

**1. `.agent/run-state.json` must not live inside the repository under test — and this is
measured, not cautious.** B7's preflight pair of 2026-09-10 wrote the policy hook's log to
`.ai/policy-events.jsonl` inside the worktree. Runs `2077432c` (BE-003) and `88b861f3` (BE-004)
**solved their tasks** — build, existing tests, functional suite, error contract and dependency
guard all pass, 6 of 7 acceptance criteria — and were then scored **exit 21, unrelated
production files changed**, where the single unrelated file was the guardrail's own bookkeeping.
Both controls scored 0. **Checked against the experiment rather than taken from the code comment
that reports it:** `experiments/E-016-verification-policies-BE004.md:227-237` carries both run ids
with `21` in the exit-code column. The comment at `verify-v1.0/.ai/hooks/policy-gate.sh:28-46`
records the rule that came out of it: **a guardrail must not leave artifacts in the repository it guards.**

`run-state.json` is bookkeeping in exactly that sense, and the build spec's path puts it in the
worktree. The evaluator's ignore pattern is a **registered variable** (§7: *"any proposed change
to what the benchmark or evaluator measures"*), so teaching the evaluator to ignore `.agent/` is
not available and is not attempted; nor is a `.gitignore` in the overlay, which achieves the
same thing invisibly and which `run-agent.sh:371`'s `git add -f` would override anyway.

So: **the file keeps its name and its schema and moves its directory**, the way B7's log did —
`${AGENT_RUN_STATE_DIR:-${TMPDIR}}/run-state-$(basename "$CLAUDE_PROJECT_DIR").json`, one per
run, with the run id in its own name because the worktree basename is `observatory-run-<uuid>`.
`.agent/run-state.json` remains the documented production path and is what the schema is named
for. **If this stop instead measured the file in-repo, it would measure the harness again**, and
it would do so having been told in advance what the result would be.

**2. The repair limit will not fire during the batch, and the design says so before the batch
rather than after it.** BE-004 has never failed the evaluator on `claude-haiku-4-5-20251001` —
*9 of 9 before stop 12, 10 of 10 in every arm at B5 and B6, 7 of 7 in both arms at B7*, which is
**author decision 11's own count** (PROMPT §3, *Why (evidence, not preference)*), quoted here as
its author wrote it and not recomputed at this step. BE-003
passes nearly always. A counter that increments on failure will therefore read **0** on almost
every run in both arms, and *"limits technically enforced"* cannot be answered from the batch.

That splits the gate cleanly, and each half gets a different instrument:

| Gate clause | Answered by | Layer of the proof |
|---|---|---|
| counters persist across interruption | the deliberate failure (§4 step 9): kill a run mid-repair, re-read the file | **L2** — a command runs and the value is read off disk |
| limits technically enforced | `tools/verify-repair-limit.sh`, a fixture set that drives the hook to the 3rd and 4th identical failure and to the 7th total | **L2** — it executes and it must refuse |
| a blocked run produces a clear machine-readable result | the classifier wired into a path that runs, plus a fixture proving the emitted value | **L2** |
| **no regression against the v1.0 benchmark** | the batch, both tasks, against `verify-v1.0` as it closed at B7 | **L2** — evaluator exit codes and codex sheets |

**The batch's registered question is therefore "does carrying the machinery cost anything",
not "does the machinery work".** Those are different questions and the second one is not
answerable by benchmark runs on a task the model does not fail.

**3. No hash will prove the treatment arrived, so the delivery proof is an artifact the hook
itself leaves.** `run-agent.sh:625-629` computes `instructionsHash`, `skillsHash` and
`agentHash` and nothing else; `hooksHash` and `mcpHash` are declared in four places and computed
in none (Extract item 3). B7 hit this first and answered it the only way available: its hook
**logs on allow as well as on deny**, because *a hook that logs only denials is
indistinguishable from a hook that never ran*. B8 inherits that answer exactly — the run-state
file exists **if and only if** the hook executed, and it is written on the first tool call, not
on the first failure, for the same reason.

### The artifacts, and their layers

| # | Artifact | What it is | Layer — rule applied in order |
|---|---|---|---|
| 1 | `build/customizations/agent-v1.1/` | the registered treatment: `verify-v1.0`'s overlay plus this stop's three things | — (a directory is not a control) |
| 2 | `.ai/hooks/repair-limit.sh` | `PostToolUse` on `Bash`: computes the fingerprint, reads and increments the counter file, and **on exceed writes stderr and exits 2** | **L2** — can the bad value still be written down after the fix? An over-limit repair cannot proceed, because something executes and refuses |
| 3 | the run-state **file** | JSON on disk carrying phase, goal, affected files, last failure, both counters, `handoff` | **L3.** Applying the rule in order: the bad value *can* still be written down — any process can put anything in a JSON file — so not L1; and the file itself executes nothing. It is data. **A schema is not a control** |
| 4 | `tools/check-run-state.sh` | validates a run-state file against the registered schema and **refuses** a malformed one | **L2** — this is the thing that makes row 3 checkable |
| 5 | `tools/verify-repair-limit.sh` | the fixture set for row 2: every exit code, including the refusals | **L2** — and without it row 2 is a claim |
| 6 | the completion contract | `DONE` confirmed by a script | **L2 only if a `Stop`-class hook runs it and exits non-zero on a failing contract.** Shipped as a markdown checklist the agent is asked to follow, it is **L3** — and §10.6's seven clauses are L3 today precisely because nothing runs them |
| 7 | the `handoff` field | from-agent, to-agent, what was delivered, what remains | **L3, and deliberately.** Nothing executes on it at this stop. Author decision 11 item 7 asks for it written **and marked reserved**, which is a field waiting for a consumer — and calling that L1 would be the exact substitution the workspace `CLAUDE.md` names, *"adding `required:` to a template … none of these run"* |

### One variable, and the honest limit on what a null here can mean

Every prior B step added one named thing. **B8 adds three at once** — state, limits, contract —
because `build/README.md#b8` defines the step that way and the spine gives them one version
between them. The registered treatment is therefore **the v1.1 overlay as a whole**, and this is
registered as a limitation *before* the run rather than discovered in the write-up:

> **A null at this step cannot be attributed to any one of the three.** If v1.1 shows no
> regression and no effect, the finding is *"the v1.1 bundle changed nothing measurable on this
> task"*, and it is not evidence about run state, or about repair limits, or about the
> completion contract separately. Separating them needs three arms, which is a batch this step
> does not have and an author decision this step does not own.

### What this step does not build, and why

- **It does not touch the evaluator's ignore pattern, exit-code mapping, fixtures, or the
  rubric.** All four are registered variables; moving one is a §7 halt, not a design choice.
- **It does not re-mean an existing `F0x` code.** `BLOCKED` is not in the `F01`–`F15` enum
  (Extract item 5). A *new* additive field or enum value is an instrument PR this run merges
  itself under §4 step 14; giving `F03` a new meaning would be a §7 halt, and that is the
  distinction, not a preference.
- **It does not raise `n` to make the repair limit fire.** The limit not firing is a property of
  the task and the model, and the answer to it is a fixture set, not a bigger batch.

### The assumption that gets proved at preflight rather than asserted here

The design above puts the enforcement on a **`PostToolUse` hook on `Bash` exiting 2**. Phase 5B's
extract established that `exit 2` blocks and feeds stderr back to the model, and stop 16's arm H
demonstrated it live on `PreToolUse` — **5 of 5 arm-H runs changed zero files**, against arm D's
`permissions.deny`, which changed 2, 3, 3, 4 and 13. But `PostToolUse` fires *after* the tool has
run, and whether its exit 2 reaches the model the same way is **not something this workbook has
measured**. §4 step 5 proves it on one run before any batch. If it does not hold, the enforcement
point moves to `PreToolUse` on the repair command and the change is recorded there, not here.

## Predict before you run

<!-- TODO -->

## Lab B8.1 — measure against v1.0

<!-- TODO: the gate asks for *no regression*, which is a different test
     from an improvement. Say in advance what regression you would accept. -->

## Deliberate failure

<!-- TODO: interrupt a run mid-repair and confirm the counters survive.
     Then force the same failure four times and confirm it BLOCKS rather
     than looping. -->

## Exit gate

**From the build track:** counters persist across interruption · limits technically enforced ·
a blocked run produces a clear machine-readable result · **no regression against the v1.0
benchmark.**

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
