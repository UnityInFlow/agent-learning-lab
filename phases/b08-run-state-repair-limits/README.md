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

> **Rows 2 and 3 of this table were written before either correction below and are left as
> written.** Row 2 still says `repair-limit.sh` runs on `PostToolUse`; it runs on `PreToolUse`,
> for two separately measured reasons — `PostToolUse` exit 2 does not enforce (first
> correction, from Phase 5A's extract) and `PostToolUse` on `Bash` never fires for a failing
> command at all (second correction, from the probe). **The layer labels in rows 2, 3, 6 and 7
> are unaffected** — what moved is which event does the work, not what kind of control it is.
> Read the two corrections at the end of this section as the operative design.

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

*(Original text, kept — it was wrong, and the correction below is the reason this section
exists at all.)*

> The design above puts the enforcement on a **`PostToolUse` hook on `Bash` exiting 2**. Phase 5B's
> extract established that `exit 2` blocks and feeds stderr back to the model, and stop 16's arm H
> demonstrated it live on `PreToolUse` — **5 of 5 arm-H runs changed zero files**, against arm D's
> `permissions.deny`, which changed 2, 3, 3, 4 and 13. But `PostToolUse` fires *after* the tool has
> run, and whether its exit 2 reaches the model the same way is **not something this workbook has
> measured**. §4 step 5 proves it on one run before any batch. If it does not hold, the enforcement
> point moves to `PreToolUse` on the repair command and the change is recorded there, not here.

**CORRECTED the same day, before the build and before any prediction, 2026-09-15.** It did not
need a preflight run, because **Phase 5A had already extracted the answer** and this design did
not apply it. `phases/05a-guardrails/README.md:58-60`:

> *"Exit 2's meaning is per-event: `PreToolUse` blocks the tool call, `UserPromptSubmit` rejects
> the prompt, `PermissionRequest` denies it, **`PostToolUse` merely shows stderr because the tool
> already ran**."*

So a `PostToolUse` hook exiting 2 **does not enforce anything**. The command has run; the model
is merely told about it. By the layer rule applied in order, a repair limit built that way is
**L3 wearing L2's clothes** — the exact phrase Phase 5B uses for a counter held in a hook's own
process, now earned a second way. Shipping it would have put an L2 label on the step's only
control and left the gate clause *"limits technically enforced"* answered by a message.

**The corrected design uses both events, and each does only what its exit code permits:**

| Hook | Event | Job | Exit code that matters | Layer |
|---|---|---|---|---|
| `repair-record.sh` | `PostToolUse` on `Bash` | compute the fingerprint from the command and its result, write/increment the counters in the run-state file | **0 always** — it records, it never decides | **L2 as a recorder** (it executes and writes), **not** a control |
| `repair-limit.sh` | `PreToolUse` on `Bash` | read the counters; if this call would exceed `≤ 3` for the current fingerprint or `≤ 7` total, **write the BLOCKED reason to stderr and exit 2** | **2 — and here it genuinely blocks** | **L2** — the bad value cannot be written down after the fix, because the tool call does not happen |

The two-hook split is not decoration. **Recording and enforcing need different events**, because
the fingerprint is only knowable *after* a command fails and the block must happen *before* the
next one runs. A single-hook design has to choose one of those and silently loses the other.

**What is still unproven and does go to preflight:** that a `PreToolUse` hook on `Bash` is
reached at all in this runner's configuration. Stop 16's arm H proved the mechanism on
`Edit|Write|NotebookEdit`, not on `Bash`, and the matcher is the variable. §4 step 5 proves it
on one run per task before any batch, and a failure there moves the enforcement point again
rather than being written up as a null.

**CORRECTED A SECOND TIME, 2026-09-15, still before the build and still before any run — and
this one needed a measurement, because nothing in these repositories had made it.** The
paragraph above sent one assumption to preflight. A preflight costs a benchmark run, so the
assumption was probed first for a few cents: three `claude -p` sessions in a throwaway
directory, the runner's own flag set from `run-agent.sh:757-777`, CLI `2.1.272`, model
`claude-haiku-4-5-20251001`, thirteen `Bash` tool calls, one hook registered on both events.
Payloads and derivation:
[`evidence/b08/hook-event-probe-20260915T153209Z/`](../../evidence/b08/hook-event-probe-20260915T153209Z/README.md).

| Bash call outcome | n | `PreToolUse` fired | `PostToolUse` fired |
|---|---|---|---|
| exited 0 | 6 | 6 | **6** |
| exited non-zero | 6 | 6 | **0** |
| blocked by the hook's own `exit 2` | 1 | 1 | 0 — **and the command never ran** |

Two-sided Fisher on 6/6 vs 0/6: **p = 0.0022**.

**The good news first, because it discharges this section's own open item.** `PreToolUse` on
`Bash` **is** reached — 13 of 13 — and its `exit 2` **genuinely blocks a `Bash` call**: the
blocked `touch` left no file. Stop 16 proved exit 2 on `Edit|Write|NotebookEdit`; the matcher
was the variable, and the variable is now measured. **The L2 row in the table above is
earned on `Bash` rather than inherited**, and it was earned without spending a preflight run.

**The bad news is that the corrected design was still wrong, in the same place, for a second
reason.** `PostToolUse` on `Bash` fires **if and only if the command exited 0**. So:

- **`repair-record.sh` as specified above cannot see a single failure.** It is registered as
  the recorder that *"computes the fingerprint from the command and its result"* — and it is
  never handed a failing command at all. Built as designed, it would have reported
  `totalRepairAttempts: 0` on every run of both arms, and that zero would have been read as
  *the model does not fail these tasks* when it in fact meant *the counter is blind*. That is
  the house failure mode verbatim: a control reporting success over a scope smaller than it
  claims. **It would not have looked like a bug. It would have looked like P2 holding.**
- **`tool_response` carries no exit code** either — its keys are
  `{stdout, stderr, interrupted, isImage, noOutputExpected}` — so the event could not have
  classified the outcome even where it does fire.
- **But the event's presence is the signal its payload lacks.** Fired for every success and
  for no failure, *"`PostToolUse` fired for fingerprint X"* means *"X succeeded"*. It is a
  **success oracle**, and it is the only one a hook has in this runtime.

**So both hooks stay, both jobs move, and the split is now load-bearing for a reason the
first correction got backwards.** That correction said *"the fingerprint is only knowable
after a command fails"*. It is not: a fingerprint is knowable **before** the call, from the
command text, and whether the call is a *repeat* is knowable from the history the hook itself
wrote. The failure is the part that is not observable. The counter therefore stops trying to
count failures — which cannot be done — and counts what can: **consecutive attempts at the
same fingerprint, cleared by a success.**

| Hook | Event | Job | Exit code that matters | Layer |
|---|---|---|---|---|
| `repair-limit.sh` | **`PreToolUse` on `Bash`** | fingerprint the command; increment its consecutive-attempt counter and the run total; **write the state file on every call, allow or block**; if this call would exceed `≤ 3` for the fingerprint or `≤ 7` in total, write the BLOCKED reason to stderr and **exit 2** | **2 — measured to block on `Bash`** | **L2** — the bad value cannot be written down after the fix, because the tool call does not happen |
| `repair-record.sh` | **`PostToolUse` on `Bash`** | the **success oracle**: its firing means that fingerprint's last attempt succeeded, so **clear** that fingerprint's consecutive counter | **0 always** — it records, it never decides | **L2 as a recorder**, **not** a control |

**Why the oracle is not optional.** Without it no success is ever observable, so a
fingerprint's counter could only ever rise, and a run that legitimately ran `./mvnw test`
four times — passing each time — would be blocked on the fourth. The limit the build spec
asks for is `MAX_REPAIR_ATTEMPTS_PER_FAILURE`, and *per failure* is exactly what the reset
buys. **One hook cannot do this**, which is what the first correction meant and did not
establish.

**What is still unproven, and what §4 step 5 is now for.** Not the mechanism — that is
settled above. What a probe in a throwaway directory cannot show is that **the overlay
arrives inside a real observatory worktree and writes its file there**: that
`run-agent.sh:338` copies it, that `--setting-sources project` loads *this* `settings.json`,
that `$CLAUDE_PROJECT_DIR` resolves inside the worktree, and that the state file lands
**outside** it. That is one preflight run per task, and it is a smaller and better-aimed
question than the one this section started with.

## Built — §4 step 4, 2026-09-15

Everything below exists on `stop17/b8-run-state-repair-limits` and every fixture set in it was
run before this section was written. Hashes are registered in E-018 and E-019.

### The overlay, `build/customizations/agent-v1.1/`

| file | what it is | layer |
|---|---|---|
| `.claude/agents/backend-feature-phases.md` | **v1.0's, byte-identical** (`b3450564b6f32d61`) | — |
| `.ai/hooks/policy-gate.sh` | **v1.0's, byte-identical** (`f432abbcbf1f3b90`) | L2, inherited from B7 |
| `.ai/policies/protected-paths.yaml` | **v1.0's, byte-identical** (`76c4c34c0f4ca5eb`) | L3 — data the gate reads |
| `.claude/settings.json` | v1.0's `Edit\|Write\|NotebookEdit` entry **unchanged**, plus `PreToolUse`/`Bash` and `PostToolUse`/`Bash` | — |
| `.ai/hooks/repair-limit.sh` | `PreToolUse`/`Bash`: fingerprint, count, **refuse at the limit with exit 2** | **L2** |
| `.ai/hooks/repair-record.sh` | `PostToolUse`/`Bash`: the success oracle; clears a fingerprint; **always exits 0** | **L2 as a recorder**, not a control |
| `CLAUDE.md` | the run-state note and §10.6's seven clauses as prose | **L3** |

`verify-v1.0` itself is untouched — `git status --porcelain build/customizations/verify-v1.0`
is empty — because *a measured version is never edited*.

### One deviation from the Build spec above, and it is forced rather than chosen

The spec's fingerprint is `failure class + command + normalized primary error + affected
module`. **Three of those four are not observable to a hook in this runtime**, and the probe
that established it is
[`evidence/b08/hook-event-probe-20260915T153209Z/`](../../evidence/b08/hook-event-probe-20260915T153209Z/README.md):
`PostToolUse` on `Bash` never fires for a failing command (0 of 6; 6 of 6 for successes;
p = 0.0022), and where it does fire `tool_response` carries no exit code. There is no event
that hands a hook a failure class, an error string, or the module a failure landed in.

**So the fingerprint is the normalized command text alone**, and the counter counts repeat
attempts rather than failures, with a success clearing the fingerprint. This is not a
weakening dressed up as a simplification — it is the same move the observatory made in 2026-08
when phrase-matching failure classes failed four times and *"an agent that changed no file and
called no tool did not attempt the task"* worked: **a rule over facts the record already
holds, needing no vocabulary.** The spec's version needs a vocabulary, and this runtime does
not supply one.

**What it costs, said plainly:** two genuinely different failures of the same command are one
fingerprint, and the same failure reached by two differently-typed commands is two. The limit
is therefore coarser than the spec's. It is still `≤ 3` and `≤ 7`, still enforced by something
that executes, and it is the finest rule the available events can support.

### The checkers, and what each one is allowed to claim

| tool | claims | fixtures | result |
|---|---|---|---|
| `tools/verify-repair-limit.sh` | the limit **refuses**: 4th identical attempt and 8th total, both exit 2; a success resets; a refusal does not inflate the counters; the two hooks agree on the fingerprint; it fails open **and records that it did**; it writes outside the worktree | 30 | **30 of 30 pass** |
| `tools/check-run-state.sh` + `tools/verify-run-state-checker.sh` | the schema is **enforced**, not merely documented — every required field removed one at a time, wrong types, and invariants that would mean the limit had not held | 41 | **41 of 41 pass** |
| `tools/check-completion-contract.sh` + `tools/verify-completion-contract-checker.sh` | §10.6's seven clauses over a finished worktree, **and that UNDECIDABLE never reads as PASS** | 27 | **27 of 27 pass** |

All five scripts are ShellCheck clean at `-S warning`.

**The completion-contract checker decides 4 of 7 clauses and says so in its own output.**
Clauses 1 (acceptance criteria mapped), 4 (static analysis) and 5 without a baseline are
reported `UNDECIDABLE`, the summary line reads `decidable clauses: 5 of 7`, and a run where
nothing at all could be decided exits **2 — not 0**. Six of its 27 fixtures exist only to prove
that, because a checker that quietly counted undecidable clauses as satisfied would report
seven green clauses over a scope of four. That is the shape that voided a twenty-run experiment
here, and it is cheaper to write the fixture than to find it later.

### Author decision 11 item 7 — the only item with a deadline, discharged here

`.agent/run-state.json` gains a **`handoff`** block — `fromAgent`, `toAgent`, `delivered`,
`remaining` — written **unconditionally** on every run of the treated arm and carrying a
`reserved` note naming B8a. `tools/check-run-state.sh` requires the block and all four fields
to be **present**, and deliberately does **not** require them to be non-null: at this version
nothing writes them, and a checker demanding values would be a checker demanding that B8a
already exist. Two of its fixtures are negative controls pinning exactly that — an all-null
handoff is valid, and so is a populated one.

**It is L3 and it is labelled L3.** Nothing executes on it at this stop. By the workspace rule
applied in order: the bad value can still be written down — any process can put anything in a
JSON field — so it is not L1; and the field itself runs nothing. Calling it a control would be
the substitution `CLAUDE.md` names by name, *"adding `required:` to a template … none of these
run"*. What `check-run-state.sh` enforces is that **the field exists and says it is reserved**,
which is a real L2 claim about the schema and not a claim about the handoff.

## Preflight — §4 step 5, BE-003 pair, 2026-09-15

**Neither run enters `n`.** Both sit under `EXP-B8-RUNSTATE-BE003-PREFLIGHT`, they are `n = 1`
per arm, and nothing below is a result about the treatment's effect.

| | treated | control |
|---|---|---|
| run id | `1df030f7-b6e4-4220-8129-0f5c2268e1b8` | `0ba1534b-e343-4f56-a725-835b2d1784f0` |
| overlay | `agent-v1.1` | `verify-v1.0` |
| evaluator | **exit 0**, acceptance 7/7 | **exit 0** |
| `customization.instructionsHash` | `sha256:a94237242e8c1308fb1d434a06a03463` | **`null`** |
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` | **identical** |
| `runtime.version` | `2.1.272 (Claude Code)` | `2.1.272 (Claude Code)` |
| `behavior.modelCalls` | 22 | 18 |
| `efficiency.estimatedCost` | `$0.134602` | `$0.091396` |

Both worktrees, both run records, the init read-back and the run-state file are preserved under
`evidence/b08/worktrees/<run id>/` **the day they were made**, because `$TMPDIR` on this machine
empties a kept worktree in about three days and leaves the directory behind — which is why the
decision-11 census returned no reading at all.

### The five delivery conditions, each checked rather than inferred

| | condition | result |
|---|---|---|
| a | the run-state file exists and names **that** run's worktree | **holds** — `worktree` reads `…/observatory-run-1df030f7-…`, `schemaVersion: b8-v1.1` |
| b | its `hookExecutions` prove both hooks ran inside a real worktree | **holds** — `repair-limit/allow: 7`, `repair-record/success: 7` |
| c | **nothing** was written inside the worktree | **holds** — no `run-state*` or `*.jsonl` anywhere under it |
| d | the `init` read-back shows **`Bash`** in the delivered tool set (author decision 8) | **holds** — `delivered n=4 ["Read","Edit","Write","Bash"]`, `verdict=match` |
| e | the control writes **no such file at all** | **holds** — absent by `stat`, and the v1.0 overlay carries neither hook |

`./tools/check-run-state.sh` on the treated file exits **0**.

**Condition (b) is the one the preflight was actually for.** The hook *mechanism* was already
settled for free before the build (`evidence/b08/hook-event-probe-…/`); what a probe in a
throwaway directory could not show is that `run-agent.sh:338` copies the overlay into an
observatory worktree, that `--setting-sources project` loads *this* `settings.json` rather than
the operator's, and that `$CLAUDE_PROJECT_DIR` resolves inside the worktree so the hook finds
its own paths. Fourteen hook executions across two events say all three hold.

**And condition (d) is not a formality here.** `tools:` filtering rewrites the delivered set —
E-005 had `Read, Grep, Glob, Bash` delivered as `["Read","Bash"]` on 10 of 10 runs — so a
`Bash` matcher in a run whose model was never handed `Bash` would produce an empty state file
and look exactly like a hook that did not execute. It was handed `Bash`, and it made seven
`Bash` calls.

### Two things worth writing down before the batch, neither of which is a result

**1. Seven `Bash` calls, seven allows, seven successes, zero repairs, zero blocks.** Every
`Bash` command in the treated run succeeded on its first attempt. That is what P2 predicts for
BE-003 (`totalRepairAttempts` median 0) and it is `n = 1`, so it is consistent with the
prediction and is not evidence for it. It is also the first direct confirmation **inside a real
run** of the probe's finding: 7 `PreToolUse` allows and 7 `PostToolUse` successes means all
seven succeeded, and had any failed, the `PostToolUse` count would have been lower while the
`PreToolUse` count stayed at seven.

**2. The cost gap in this pair is far larger than P5 predicts, and it is `n = 1` per arm.**
`$0.134602` against `$0.091396` is **+47 %**; P5 predicts +2 % to +8 % and registers that band
as sitting inside the transferred MDE of $0.045 (30 %). **This is not a refutation of P5 and is
not recorded as one.** Two single runs of a task whose cost varies run to run cannot separate a
treatment effect from ordinary variance — E-016's BE-004 control range spans a factor of six —
and the prediction is registered against a 10-per-arm comparison, not against a preflight pair.
It is written here, before the batch, for one reason: **so that if the batch does land outside
the band, this line already exists and cannot be produced afterwards as a prediction.** The
registered band stands unedited (§4 step 12).

## Preflight — §4 step 5, BE-004 pair, 2026-09-15

**Neither run enters `n`.** Both sit under `EXP-B8-RUNSTATE-BE004-PREFLIGHT`, `n = 1` per arm.

| | treated | control |
|---|---|---|
| run id | `aa143b15-b6ad-4fd1-b1c6-4ae3b89fb9d0` | `b356238d-6bfd-46cf-8a19-29bd49117b32` |
| overlay | `agent-v1.1` | `verify-v1.0` |
| evaluator | **exit 0**, acceptance 7/7 | **exit 0**, acceptance 7/7 |
| `behavior.modelCalls` | 28 | 28 |
| `behavior.toolCalls` | 26 | 26 |
| `efficiency.estimatedCost` | `$0.234364` | `$0.198211` |

All five delivery conditions hold, checked the same way as the BE-003 pair: the state file
names `observatory-run-aa143b15-…` at `schemaVersion: b8-v1.1`; `hookExecutions` carry
**8 `repair-limit/allow` and 6 `repair-record/success`**; nothing was written inside the
worktree; the `init` read-back delivers `["Read","Edit","Write","Bash"]` at `verdict=match`;
the control's file is **absent by `stat`**. `check-run-state.sh` exits 0.

### 8 allows, 6 successes — and the two missing ones are the most useful thing in this preflight

**Two `Bash` commands failed in the treated run, and the success oracle is the only thing in
this project that can see them.** No evaluator field, no telemetry counter and no hash records
a failing command; the evaluator reads the end state, and the end state here is
`acceptance 7/7, exit 0`. What identifies the two failures is the *gap* between the events:
eight `PreToolUse` allows against six `PostToolUse` successes, with the two uncleared
fingerprints still sitting in `repairAttemptsByFingerprint`. The design derived that from a
free probe; this is the first time it has been read off a real benchmark run.

**It also answers the question the workbook said the batch could not answer, in the one
direction the batch could never have shown.** §Design registered *"a counter that increments on
failure will read 0 on almost every run in both arms"*, and on that reasoning a run that passes
7/7 would have been assumed to have failed nothing. It failed two commands on the way.

### And it bears directly on P2 — at `n = 1`, which is why this is written before the batch

`totalRepairAttempts` on this run is **0**, while P2 predicts a median of **at least 1** on
BE-004. The two are not in conflict: **the model failed two commands and retried neither.**
Under the corrected definition registered in E-019 the counter counts *repeat attempts*, and a
failure nobody repeats contributes nothing to it — which is the definition working as intended,
not a gap in it.

**What it does mean is that P2's `≥ 1` needs the model to fail *and then try the same thing
again*, and this run shows the first half happening without the second.** That is registered
here, before the batch, with its `n = 1`. It is not a refutation, P2 is not edited (§4 step 12),
and if the batch lands at a median of 0 this paragraph is the reason that outcome will be
readable rather than re-interpreted afterwards.

**One number to carry forward and not to read as a result:** the pair's cost gap is `+18.2 %`
(`$0.234364` against `$0.198211`), against P5's registered `+2 %` to `+8 %`. The BE-003 pair was
`+47 %`. Both are `n = 1` per arm, both sit against a transferred MDE derived from 10-per-arm
populations, and **the registered band stands unedited**. Two preflight pairs both landing above
the band is a reason to read the cost column carefully at step 8 — not a reason to change what
was predicted.

## Batch — §4 step 6, the driver and what proves it, 2026-09-15

**The driver is [`evidence/b08/run-b8-batch.sh`](../../evidence/b08/run-b8-batch.sh), committed at
`119ffa0` before the first run started at `2026-09-15T18:24:37Z`.** `n = 10` per arm per task,
interleaved treated/control, on the two registered keys `EXP-B8-RUNSTATE-BE003` and
`EXP-B8-RUNSTATE-BE004`. Batch tag `20260915T182436Z`.

**It exists as a committed file for a reason this stop found out the hard way.** The §4 step 5
preflight's own invocation was never written down — `evidence/b08/` holds its *results* and no
script — so the four runs that proved the five delivery conditions cannot be reproduced from
anything on disk. A prediction is a committed file here; a command that spends money should be
one too. From this step on it is.

### Three things it does differently from `run-b7-batch.sh`, each with its reason

| | what | why it is not a preference |
|---|---|---|
| 1 | calls `runner/run-agent.sh` **directly**, not `make run-benchmark` | `Makefile:24-25` defaults `OTLP_HTTP_PORT`/`OTLP_GRPC_PORT` to `4318`/`4317`, and on this machine those two are **leaked `limactl` listeners**: `POST localhost:4318/v1/traces` answers `000`. A run that reaches them records `null` `modelCalls` and `null` cost — which reads exactly like a run that made no model calls. The API is on `127.0.0.1:18081`; `:8081` answers `000` and belongs to a **second, empty stack**, which is how a previous session read an empty database as data loss. Direct invocation states all three endpoints in one place where an `-include` of an unreadable `infra/.env` cannot re-default them. |
| 2 | the per-run delivery proof is the **run-state file**, not a policy log | both overlays carry `.ai/hooks/policy-gate.sh`, so a policy event proves nothing about *this* treatment. Only `agent-v1.1` carries the `PreToolUse`/`Bash` + `PostToolUse`/`Bash` pair, and `repair-limit.sh` writes `${TMPDIR}/run-state-observatory-run-<runId>.json` on the **first `Bash` call whatever its outcome**. P1 is a gate on the whole experiment — decision-rule **row 0 VOIDs the batch** if either half fails on 2 or more treated runs — so both halves are asserted per run rather than once at preflight. |
| 3 | copies each run's evidence off `$TMPDIR` **the moment the run ends** | the reaper here empties a kept worktree's files in about three days and **leaves the directory standing**, so `ls -d` passes on a hollowed one. The author decision 11 census returned **no reading at all** because all 54 kept BE-004 worktrees still existed and held zero files. A copy made later is a copy of nothing. Small artefacts go to the committed `evidence/b08/worktrees/<run id>/`; the ~27 MB worktrees go to `evidence.local/b08-worktrees/<run id>/`, gitignored by `*.local`. |

### The guards, and the fixture set that proves they refuse — L2

`./evidence/b08/verify-b8-batch-guards.sh` → **12 passed, 0 failed**
([`verify-b8-batch-guards-20260915T182335Z.txt`](../../evidence/b08/verify-b8-batch-guards-20260915T182335Z.txt)).
`B8_GUARDS_ONLY=1` runs every guard and exits 0 without invoking a run, so each case perturbs
exactly one registered value **in a copy** of an overlay and asserts both the exit code and that
the refusal names the right thing.

| case | perturbation | expected |
|---|---|---|
| A | the registered configuration, untouched | **exit 0**, "every guard passed and NOTHING was run" |
| B | `B8_API` at a dead port | exit 7, names the code it answered |
| C | `B8_OTLP` at `4318`, the leaked listener | exit 7 |
| D | control's agent file drifted by one byte | exit 6, "the arms' agent files DIFFER" |
| E | the **same** drift in both arms | exit 6, "agent file is not the registered one" |
| F | treated `CLAUDE.md` drifted | exit 6, "treated CLAUDE.md is not the registered one" |
| G | control given any `CLAUDE.md` | exit 6 — P1's second half is `instructionsHash` **null** on 10 of 10 controls |
| H / H2 | treated hook deleted / present but not executable | exit 6 each |
| I | control given `repair-limit.sh` | exit 6 — the treatment in both arms measures nothing |
| J / K | a **live** pid lock refuses (exit 8); a **stale** one does not | exit 8 / exit 0 |

**Case A is the load-bearing one.** Without it the eleven refusals would be consistent with a
driver that refuses everything, including the registered configuration — a control that has never
been shown to *accept* is as uninformative as one never shown to reject. And **case E exists
because D alone cannot see it**: two arms can agree with each other and both be wrong.

**§6's re-verification, done rather than asserted.** Case I was reproduced by hand outside the
verifier, with its own `mktemp -d` copy and no fixture harness in the loop: `exit 6`,
`ABORT: the CONTROL overlay carries .ai/hooks/repair-limit.sh — the treatment is in both arms`.
The registered control's hook directory holds `policy-gate.sh` and nothing else.

### A defect in the driver, found while it was running, and not fixed while it was running

**`B8_GUARDS_ONLY=1` leaves a dated `batch-<TAG>/` directory behind.** `mkdir -p "$EVID/init-schema"`
runs *before* the guards-only exit, so the twelve fixture cases and the first manual probe created
**13 empty `evidence/b08/batch-*/` directories**, each of which reads to a stranger as a batch that
produced nothing. The live batch is `batch-20260915T182436Z`, the only one of the fourteen with a
`manifest.tsv`.

It is recorded here **before** the fix and **not** fixed in place, because §4 step 4 says never edit
a tool while a run of it is in flight — the driver was mid-batch when this was found. The `mkdir`
moves below the guards-only exit, and the 13 empty directories are removed, after the batch ends
and before the PR. *Found by Opus 5 (claude-opus-5), autonomous, 2026-09-15.*

## The batch ran across a clamshell sleep, and the BE-004 arm is split by it

**Written 2026-09-16T07:0xZ, while the batch was still running and before any sheet was opened**,
so that nothing below can be produced afterwards as an interpretation. Evidence:
[`evidence/b08/sleep-2026-09-15/pmset-and-run-starts.txt`](../../evidence/b08/sleep-2026-09-15/pmset-and-run-starts.txt).

**The cause is exact and it is not the machine being flaky.** `pmset -g log`:

```
2026-09-15 21:48:55 +0200 Sleep  Entering Sleep state due to 'Clamshell Sleep' ... Using AC
```

That is **19:48:55Z**. `BE-004 04 control` started at **19:48:07Z** — forty-eight seconds earlier.
The lid was closed on top of a running batch, and the machine then cycled Sleep / DarkWake all
night: 605 sleep entries in the log, the batch's own run-start headers showing gaps of
**4h31m** (`BE-004 05 treated` at `00:19:19Z`) and **5h21m** (`BE-004 05 control` at `05:40:20Z`)
against a 3-to-4-minute run. It ended at `2026-09-16 08:59:36 +0200` — `Wake ... due to ... lid
... HID Activity`, the lid being opened — and `BE-004 06 treated` started 71 seconds later.

**`caffeinate -i` was running and did not prevent this, by design.** `-i` prevents *idle* sleep.
It has no effect on clamshell sleep. The launch command was
`nohup caffeinate -i evidence/b08/run-b8-batch.sh`, and it did exactly what it says.

### Which runs are clean, stated as a boundary rather than a judgement

| runs | started | status |
|---|---|---|
| **BE-003, all 20** | 18:24:37Z – 19:21:00Z | **clean** — the whole arm ran and finished before the lid closed |
| **BE-004 01–04 treated, 01–03 control** (7 runs) | 19:21:40Z – 19:44:24Z | **clean** — pre-sleep |
| `BE-004 04 control` | 19:48:07Z | **F13**, `"terminal_reason":"api_error"`, 0 edits, evaluator 12 (`F03`) |
| `BE-004 05 treated` | 00:19:19Z | completed, evaluator 0 — but **ran inside the sleep/wake cycle** |
| `BE-004 05 control` | 05:40:20Z | **F13**, `api_error`, 0 edits, evaluator 12 |
| `BE-004 06` onward | 07:00:47Z – | post-wake |

### What the registered rules already decide, and what they do not

**Decided before the batch, and followed:** `F13` infrastructure aborts are excluded by name in
both experiment files, so the two `api_error` controls leave the scored population — **they are
not re-run**. E-016 is the precedent: it reported at `n = 7` rather than topping up, and decision 9
registered the rule in advance (*"the scored population may be below `n = 10`"*). A replacement run
chosen after seeing **which arm** lost one is a choice the data would then contain.

**Also decided before the batch:** §4 step 6 and this stop's own state-file instruction say
*"do not run across a machine sleep; if a run's duration looks contaminated, exclude duration, not
the run"*. So `BE-004 05 treated` stays in the population with its duration excluded. Duration was
already unusable here for an unrelated reason — see the null-column note below.

**What the rules do NOT decide, and it is named here rather than resolved quietly:** the
interleaving exists so that drift lands on both arms alike, and a nine-hour split does not. The
BE-004 arm is now *two populations wearing one experiment key* — seven runs from a quiet hour and
the rest from a night of DarkWake cycles — and `BE-004 05 treated` is the most expensive run in the
arm at `$0.257` against a pre-sleep treated median near `$0.20`, which is what a run that retried
across a dropped connection looks like. **Whether the BE-004 comparison survives that is a step-8
question**, answered against the population that occurred, with the pre-sleep seven reported
separately and — at `n = 4` and `n = 3` per arm — stated as *true of those runs*, never as a
property (§5).

**BE-003 is untouched by all of this** and is the arm the exit gate can lean on without a caveat.

*Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-16.*

### A second instrument defect, found at the 20-run mark: two null columns

`durationMs` and `changedFiles` are `null` on **every row of the manifest** — wrong `jq` paths in
the driver, the same class of mistake the state file warns about for `.behavior.*` versus
`.overhead.*`. **Neither takes a verdict:** duration is registered as *"no verdict is taken from
duration"* and `changedFiles` appears in no decision-rule row. Both are recoverable from the run
records already saved under `evidence/b08/worktrees/<run id>/run-record.json`, so no run is harmed
and nothing needs re-running. The paths are corrected and both columns re-derived from those saved
records after the batch ends — not while the driver is in flight (§4 step 4).

## Predict before you run

The predictions are registered **per task**, in their own files, with their own MDEs and their
own decision rules — author decision 9, and no verdict is computed across the two:

- [`experiments/E-018-run-state-repair-limits-BE003.md`](../../experiments/E-018-run-state-repair-limits-BE003.md) — `EXP-B8-RUNSTATE-BE003`
- [`experiments/E-019-run-state-repair-limits-BE004.md`](../../experiments/E-019-run-state-repair-limits-BE004.md) — `EXP-B8-RUNSTATE-BE004`

**The one prediction registered as most likely to be wrong** is P2's second half, and it is
worth naming here because it is the only row in either file that reports a quantity nobody has
measured: `totalRepairAttempts` — **failing commands**, not failing runs. The evaluator has only
ever seen the end state, so this project genuinely does not know whether the pinned model
compiles clean on the first attempt on a five-file cross-module change. The prediction is
**median 0 on BE-003 and at least 1 on BE-004**, and either way it is the first number of its
kind in the track.

**The expected verdict is `KEEP AS L2, WITH NO MEASURED EFFECT`** — decision-rule row 3, the row
B7 closed on. That is written down before the batch so that landing there is a result and not a
consolation.

## Lab B8.1 — measure against v1.0

The scaffold asks the right question — *the gate asks for **no regression**, which is a different
test from an improvement; say in advance what regression you would accept* — so here is the
answer, before the batch.

**What "no regression" is measured against.** `verify-v1.0` as it closed at B7, **re-run
concurrently**, not the stored E-015/E-016 numbers. Those runs recorded `runtime.version`
`2.1.267`; stop 16 ran on `2.1.268`; this batch runs on **`2.1.272`**. Comparing against stored
runs would put a three-version CLI move inside the comparison, and the CLI is a controlled
variable. The stored numbers are used for **one** thing — transferring the MDE — and are labelled
transferred everywhere they appear.

**The regression I will accept, registered now:**

| dimension | accepted | rejected |
|---|---|---|
| evaluator pass rate | a difference of **0 to 4 runs** at `n = 10` — it does not clear Fisher, so it is **NOT DETECTABLE**, and it is not called "no regression proved" either | **5 or more runs below** the control → decision-rule row 1, **REJECT** |
| rubric, any of four categories | a median delta of **0** — which, on a 0–2 integer scale, is the smallest thing the instrument can report and is consistent with any true effect under one point | **≥ 1 point in the worse direction** → row 2, **REJECT on quality** |
| `estimatedCost` | anything **inside** the transferred MDE — $0.045 (30 %) on BE-003, $0.030 (13 %) on BE-004. The predicted +2 % to +8 % sits inside both, so P5 is registered as **undecidable by this experiment** | **outside**, worse direction → row 5, **REJECT on cost**, recorded *beside* the quality row and never instead of it |
| `modelCalls` | inside 6 calls (BE-003) / 4.09 calls (BE-004) | outside → row 4, **INCONCLUSIVE**, named with the amount |
| `durationMs` | **no verdict is taken from duration at all.** BE-004's control range spans a factor of six (190 000 ms median, 180 000–1 084 000), and a machine sleep is not excludable after the fact | — |

**And what no result here can establish.** The repair limit will not fire during the batch,
because the model does not fail these tasks. So Lab B8.1 answers *"does carrying v1.1 cost
anything"* and **cannot** answer *"does v1.1's enforcement work"*. The second question is
answered by `tools/verify-repair-limit.sh`, which executes and must refuse, and by the deliberate
failure below. Reporting Lab B8.1's null as evidence that the limits work would be the house
failure mode — a control reporting success over a scope smaller than it claims — and it is
written here so that it cannot be done by accident later.

## Deliberate failure

### The prediction, written and committed BEFORE the variant exists and before any run of it

**What is being tested is not the agent. It is P1.** P1 is the gate on this whole stop — decision
rule row 0 voids the experiment if it fails on two treated runs — and it held on 20 of 20 treated
runs. **A gate that has never been shown to fail is indistinguishable from a gate that cannot
fail** (§6, and the house failure mode this project has met four times). So the deliberate failure
breaks the treatment in the one way that would be invisible to every other check, and asks whether
P1 notices.

**The break: `agent-v1.1-unwired-DELIBERATE-FAILURE`.** Byte-identical to `agent-v1.1` in every
file *except* `.claude/settings.json`, from which the two `Bash` hook registrations are removed.
The hook **scripts are still there**, executable, unchanged — `.ai/hooks/repair-limit.sh` and
`.ai/hooks/repair-record.sh` both present. `CLAUDE.md` is unchanged, so `instructionsHash` will be
the registered treated sha. `backend-feature-phases.md` is unchanged, so `agentHash` matches too.

**This is the L3-wearing-L2 costume, deliberately.** Every artefact a reader would check says the
treatment is installed: the files exist, the hashes match, the overlay directory looks right. The
one thing that does not happen is execution — which is exactly the substitution the workspace
`CLAUDE.md` warns about (*"adding `required:` to a template, documenting a unit, defining an enum
in a comment — none of these run"*) and exactly what B7's `hooksHash` cannot catch, because it is
declared and never computed.

**Predicted, before the run:**

| # | prediction | mechanism |
|---|---|---|
| D1 | **the run-state file is ABSENT** at `${TMPDIR}/run-state-observatory-run-<runId>.json` | no `PreToolUse` registration means `repair-limit.sh` never executes, and the file exists if and only if it executed |
| D2 | **`customization.instructionsHash` is the registered treated sha** `sha256:a94237242e8c1308fb1d434a06a03463` | `CLAUDE.md` is untouched — so the hash says "treated" on a run where the treatment did not execute |
| D3 | **`customization.agentHash` matches both arms** `sha256:b3450564b6f32d6193e8580db766210e` | the agent file is untouched |
| D4 | **the evaluator still passes, exit 0** | the hooks touch nothing the evaluator scores; a run without them is a plain baseline run |
| D5 | **the `init` read-back still shows `Bash`** in the delivered tool set | `tools:` is unchanged; the break is in the hook wiring, not in the tool grant |

**The reading, registered in advance.** If D1 holds while D2 and D3 hold, then **P1 is a real
control**: it detects a treatment that every hash in the run record calls delivered. If D1 fails —
a run-state file appears without the hook being registered — then **P1 is measuring something other
than hook execution**, the 20 of 20 in this stop means less than it appears, and the stop's delivery
proof needs rebuilding before the exit gate can be answered.

**`n = 1`, one run, on BE-003, under its own key `EXP-B8-RUNSTATE-BE003-DELIBERATE-FAILURE`.** It
enters no comparison and no `n`. One run is sufficient because D1 is a structural claim — the file
exists or it does not — not a rate.

*Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-16, before the variant directory was
created and before any run of it. The author did not review before the run.*

### Disclosed BEFORE the run: this run overlaps the opencode second reader

**The second reader is in flight as this run starts**, and this project's own `EXCLUSIONS.md` names
a concurrent `opencode` process among its contaminants. The overlap is declared here, before the
run, rather than discovered later in the timestamps — the same disclosure the B7 preflight made
when its review call overlapped a batch by under a minute.

**Why it is run anyway rather than waited out:** every one of D1–D5 is **binary or structural** —
a file exists or does not, a hash equals a registered value or does not, an exit code is 0 or is
not, a tool name is in a delivered set or is not. **None of them is a duration, a cost, a token
count or a rate**, which are the quantities a competing process can move. `durationMs`,
`estimatedCost` and `modelCalls` from this run therefore **enter nothing** — no comparison, no MDE,
no table — and are not reported as measurements.

**If any of D1–D5 comes back ambiguous rather than binary, the run is discarded and repeated on a
quiet machine.** That rule is written here before the outcome is known.


<!-- TODO: interrupt a run mid-repair and confirm the counters survive.
     Then force the same failure four times and confirm it BLOCKS rather
     than looping. -->

### The result — all five held, and P1 is therefore a real control

Run `5116b598-3cdd-49b3-b497-2e4bf7de46c2`, `EXP-B8-RUNSTATE-BE003-DELIBERATE-FAILURE`, `n = 1`,
2026-09-16. Evidence: [`evidence/b08/deliberate-failure-20260916/`](../../evidence/b08/deliberate-failure-20260916/).

| # | predicted | observed | |
|---|---|---|---|
| D1 | run-state file **ABSENT** | **absent** — `stat`: *No such file or directory* | **HELD** |
| D2 | `instructionsHash` = the registered **treated** sha | `sha256:a94237242e8c1308fb1d434a06a03463` | **HELD** |
| D3 | `agentHash` matches both arms | `sha256:b3450564b6f32d6193e8580db766210e` | **HELD** |
| D4 | evaluator still passes | **exit 0** | **HELD** |
| D5 | `init` read-back still shows `Bash` | `delivered n=4 ["Read","Edit","Write","Bash"]`, `verdict=match` | **HELD** |

**The load-bearing detail is that the run was not idle.** It made **6 `Bash` calls** and **3 edit
calls**. Had it made none, an absent state file would be `INCONCLUSIVE-0-edits` — the driver's own
category — and would have proved nothing. It ran six commands that *would* have fired
`repair-limit.sh` on every one, and no file appeared, because nothing registered the hook.

### What this establishes, in the terms registered before the run

**P1 is a real control.** The registered reading was: *"If D1 holds while D2 and D3 hold, then P1
detects a treatment that every hash in the run record calls delivered."* It does. This run's record
is indistinguishable from a treated run by **every hash the runner computes** — `instructionsHash`
is the treated sha, `agentHash` matches, `runtime.version` and `runtime.model` match, the delivered
tool set matches, and the evaluator passes. **On the hashes alone it is a treated run.** The only
artefact that knows otherwise is the one P1 reads.

**So the 20 of 20 in this stop means what it appears to mean**, and that was not safe to assume
beforehand: a proof that has never been shown to fail is indistinguishable from a proof that cannot.

**And it measures the size of the hole that `hooksHash` leaves.** `customization.hooksHash` is
declared in `run.schema.json:60`, in the web types, in the DTO and in the entity, and is computed
nowhere. This run is what that hole looks like from inside: an overlay that is *not* the treatment,
wearing every hash the treatment wears. A `hooksHash` over `.claude/settings.json` would have caught
it — and until one exists, **an artefact that only appears when code executes is the stronger
proof**, which is the opposite of what a schema field suggests.

*The opencode overlap disclosed above did occur; the second reader was running throughout. No
prediction here is a duration, cost or rate, and `durationMs`, `estimatedCost` and `modelCalls`
from this run are recorded nowhere and enter nothing.*

## Keep, modify, remove — §4 step 10, decided per component from the measurement

§4 step 10 is blunt: *"A rule with no measured effect is removed, and its removal is recorded as the
finding."* B3 is the precedent — a 57-word instruction file moved nothing and was removed and **not
replaced**. B8 built three things, they did not all measure the same, and they do not all get the
same answer.

| component | layer | what 20 treated runs measured | decision |
|---|---|---|---|
| the **run-state file** written outside the worktree | **L2** | delivered on **20 of 20**, absent on **17 of 17** scored controls, `check-run-state.sh` exit 0 on every one. No behaviour effect on any registered outcome | **KEEP** |
| **`repair-record.sh`** as a success oracle | **L2** | the `PreToolUse`/`PostToolUse` gap is the **only** instrument in this project that can see a failing command. It saw one on BE-003 (48 vs 47) and two in the BE-004 preflight (8 vs 6) | **KEEP — and it is the stop's real deliverable** |
| **`repair-limit.sh`'s blocking threshold** | **L2 by fixture, never exercised in a run** | **0 blocks across 20 treated runs.** `totalRepairAttempts` reached 1 exactly once and the limit is above 1 | **KEEP, with the gap stated — see below** |
| the **completion contract** | **L3** | decides seven clauses at *scoring* time; no `Stop`-class hook runs it. P6 predicted it would change nothing in-run and it did not | **KEEP as L3, labelled** — and it is **not** counted as a control |

### The blocking threshold is the interesting one, and the rule does not cleanly apply

**Step 10's rule would remove it**: it has no measured effect, 0 of 20. **It is kept anyway, and the
reason is stated rather than assumed.** A limit that blocks a *repeated failing command* is a safety
property — it fires on pathological runs, and twenty runs on two tasks a capable model passes are
not pathological. Removing a guard because a happy path never tripped it is the error that reads as
prudence.

**What is honestly recorded instead of an effect:**

- its blocking path has **never executed in a benchmark run**, on either task, at any stop;
- its only evidence is `tools/verify-repair-limit.sh`, **30 of 30 cases**, re-run at this stop —
  which proves the code blocks when fed the state that should trigger it, and proves nothing about
  whether that state occurs;
- so it is **L2 by fixture and unexercised in situ**, and that phrase is the claim. It is not "a
  measured control".

**What would exercise it**, registered here so a later stop can do it rather than rediscover the
question: a task on which the pinned model actually retries a failing command. This batch says it
does not — one failed command on BE-003 and two in the BE-004 preflight, **retried zero times
between them**. That is a fact about the model, not about the hook, and it is why P2's second half
was refuted.

### What this stop actually bought

**Not a behaviour change — the registered outcomes moved by 0 on both tasks.** What it bought is an
*observation channel*: before B8 nothing in this project could distinguish a run in which every
command succeeded from a run in which two failed and the agent carried on. The evaluator reads the
end state; the telemetry counts calls; no hash sees an exit code. The `PreToolUse`/`PostToolUse`
gap does, and it did so on a run the evaluator scored 7/7 exit 0.

**That is a smaller claim than "v1.1 improves the agent" and a more durable one**, and it is the
claim the evidence supports.

## Exit gate

**From the build track:** counters persist across interruption · limits technically enforced ·
a blocked run produces a clear machine-readable result · **no regression against the v1.0
benchmark.**

**Three of the four clauses are met. The third is not, and the stop closes saying so.**

### 1. Counters persist across interruption — **MET**, and by accident rather than by design

| evidence | |
|---|---|
| the artefact | `evidence/b08/worktrees/b90c76d7-…/run-state.json` — BE-004 seq 05 treated |
| the interruption | that run began at `00:19:19Z`, **inside the clamshell-sleep window**, on a machine cycling Sleep/DarkWake |
| the span | hook executions from `01:44:34Z` to `04:47:41Z` — **3 h 3 m**, **12 executions** |
| the gaps | **35 min, 32 min, 16 min, 80 min, 10 min, 8 min** between consecutive executions on the same file |
| the counters | `schemaVersion: b8-v1.1` intact, `hookExecutions` **not reset**, 12 entries accumulated across every gap |

**A file that had been re-initialised after a sleep would show a short array and a late first
timestamp. It shows twelve entries spanning three hours.** The counters survived an 80-minute
system sleep mid-run and kept appending.

**This is `n = 1` and it is an accident, not a designed test**, and both facts are stated rather
than smoothed over. It is nonetheless a stronger demonstration than the synthetic interruption this
stop would otherwise have written: a real sleep, on a real benchmark run, that nobody arranged.

### 2. Limits technically enforced — **MET as specified, with the exercise gap named**

The clause in `build/README.md#b8` is *"enforced by hook or wrapper, **never by prompt**"*, and that
is structural: `repair-limit.sh` runs as a `PreToolUse` hook and blocks with `exit 2`; nothing about
the limit is asked of the model. **Proved by `tools/verify-repair-limit.sh`, 30 of 30 cases**,
re-run at this stop.

**And the deliberate failure proves the enforcement path is real rather than nominal**
(`5116b598`): remove the hook's *registration* while leaving the script in place, and the artefact
vanishes — so the wiring, not the file, is what executes.

**What is not claimed:** the blocking branch has **never fired in a benchmark run**, 0 of 20. Its
evidence is fixtures. The honest description is **L2 by fixture, unexercised in situ**, and §4
step 10 records why it is kept anyway.

### 3. A blocked run produces a clear machine-readable result — **NOT MET**

**`runner/lib/classify-permission-block.sh` has exactly two references in `agent-observatory`:
itself and `runner/verify-permission-block-classifier.sh`, its own verifier. Nothing in the run path
calls it.** A classifier that only its own test invokes is **L3 in the run path**, whatever its
fixture count, and this stop does not inherit a control from stop 16 that stop 16 did not wire in.

**Nor was the clause satisfied from the other direction:** `repair-limit.sh` emitted **zero `block`
decisions across 20 treated runs**, so no blocked run exists whose result could be inspected.

**The gate is therefore not closed on this clause, and §5 is explicit about what to do:** *"If the
only proof that a gate held is that you say so, write L3 and do not close the gate."* Written: **L3,
not closed.**

### 4. No regression against the v1.0 benchmark — **MET, with the limit stated**

| task | treated | control (v1.0) | reading |
|---|---|---|---|
| BE-003 | 10 / 10 evaluator exit 0 | 10 / 10 | **equal** |
| BE-004 | 9 / 10 | 7 / 7 non-F13 | **one run**, inside P3's registered tolerance; row 1 needs five |
| both | all rubric medians delta **0** except BE-004 `change-focus` | | that cell is **unmeasurable**, not an improvement — see E-019 |
| cost | +2.4 % / +4.4 % | | inside the **re-derived** MDE, which is tighter than the transferred one |

**"No regression" here means no regression this instrument could detect**, and the re-derived MDEs
are the statement of what that instrument can see: one full rubric point, `$0.0163` on BE-003,
`$0.0089` on BE-004. A regression smaller than those is not excluded by this batch.

### The gate, in one line

**B8 closes with three of four clauses met and clause 3 explicitly not met.** v1.1 is kept, is not
promoted, and the unmet clause is carried forward as work rather than waved through — wiring
`classify-permission-block.sh` into the run path is a change to `agent-observatory` that belongs to
whichever stop next needs a BLOCKED verdict, not to a sentence here.

**Plus, for this to count as a learned phase:**

```yaml
learning:
  what_was_added: >
    A run-state file written OUTSIDE the worktree by a PreToolUse/Bash hook, a PostToolUse/Bash
    hook that clears a fingerprint on success, a repair limit that blocks at 3 per fingerprint
    and 7 per run, and a completion contract decided by script at scoring time.
  why_it_exists: >
    v1.0 asked the model to verify and to stop; B8 was to make two of those things execute.
    The file is outside the worktree because B7 scored two correct runs exit 21 when a
    guardrail's own log inside the worktree counted as an unrelated production file.
  observed_effect: >
    On the registered outcomes, none. Evaluator pass rates equal on BE-003 and within one run on
    BE-004; all four rubric medians delta 0 on BE-003 and on three of four for BE-004; cost inside
    the re-derived MDE on both tasks. What it DID produce is an observation channel: the gap
    between PreToolUse allows and PostToolUse successes is the only thing in this project that can
    see a command fail, and it saw one on BE-003 and two in the BE-004 preflight.
  unexpected_effect: >
    Three. (1) P2's second half was refuted — this model fails a command and retries it ZERO
    times, so a counter of repeat attempts stays at 0 while commands are still failing. (2) BE-004
    produced its first evaluator failure on this model, and the oracle says every one of that
    run's ten Bash commands succeeded: it never ran the suite it broke. (3) The change-focus
    anchors on BOTH rubrics were shown under-determined, three independent ways, which supplies
    the mechanism decision 10.3 recorded without one.
  keep_or_remove: >
    KEEP the run-state file and the success oracle — the oracle is the stop's real deliverable.
    KEEP the blocking threshold despite 0 of 20, with its description corrected to "L2 by
    fixture, unexercised in situ" rather than "a measured control". KEEP the completion contract
    labelled L3 and not counted as a control.
  next_question: >
    What is the rate at which this model repeats a failing command, on a task where it fails
    more often? Three observed failures, zero repeats, is the whole of what is known — and the
    repair limit cannot be exercised until that number is above zero.
```

## §4a review — round 1, and what a critic found in my own controls, 2026-09-16

Two invocations, panel `codex` (`gpt-5.6-sol`, agent sha `5ae27fa4d5e2`) + `ollama-cloud/deepseek-v4-pro`,
acceptance `ollama-cloud/minimax-m3` (`4aa690d15304`), opencode 1.18.27. Both exited 0 with findings
below the header, no stall, no dropped family. **Both acceptance gates returned REJECT.** 25
line-level findings. The dotfile-path artefacts were reviewed as byte-identical copies in a
scratchpad, because `rtk` hides `.claude/` and `.ai/` paths from the harness and it would have
reviewed nothing and exited 0 (§4a rule 5); each copy's sha is in the findings header.

Findings files: `findings/opencode/review-protected-paths-v1.1-20260916T174543Z.md` (contracts, 337
lines) and `findings/opencode/review-repair-limit-20260916T175132Z.md` (tools, 249 lines).

### The seven findings in my own checkers, all real, all fixed at `5d23904`

**Two of my controls were grading their own homework, and that is the house failure mode.** Each
fix has a fixture that *is* the failure scenario the critic named, and **each of those fixtures
passed the old checker** — proved by running the old file out of git, not asserted:

| finding | rec. | the fix | old → new |
|---|---|---|---|
| `check-run-state.sh`: `inside("allow block success error")` is a **substring** test, so `"allo"`, `"low b"`, `""` and `"allowed"` all passed the `.decision` enum | 2/2 | exact membership via `index($d)` | `allo`: **exit 0 → exit 1** |
| `check-run-state.sh`: the counter ceilings were read from `.limits` **in the file being checked**, falling back to 3/7 only if absent — so a file declaring `maxTotalRepairAttempts: 1000` while sitting at 900 passed the check meant to catch it | 1/2 | the registered 3 and 7 are written in the checker, and the file's own `.limits` block is now **checked against** them | tamper: **exit 0 → exit 1** |
| `check-run-state.sh`: `type == "number"` admits `2.5` for three fields that are counts | 1/2 | integrality checked separately from type | `2.5`: **exit 0 → exit 1** |
| `check-completion-contract.sh`: a `--baseline` that does not resolve gave an **empty diff with stderr discarded**, so clauses 5 and 6 PASSED having compared nothing | 1/2 | the baseline is resolved once, up front; an unresolvable one is **exit 30** | new fixture |
| `check-completion-contract.sh`: the deny list is extracted by `sed`, and a reindented or unquoted policy file yields **zero patterns** — so clause 6, *the one clause this script calls itself authoritative on*, PASSED having read no rules | 1/2 | patterns are extracted and **counted** first; zero is **exit 2**, and the count is printed on the PASS line | new fixture |
| `check-completion-contract.sh`: clauses 2 and 3 print as two independent PASSes from one instrument | 2/2 | both lines say `shared source`, and the summary says *"clauses 2 and 3 are TWO LINES FROM ONE INSTRUMENT"* | new fixture |
| `check-completion-contract.sh`: exit 0 with most clauses undecidable reads as "contract satisfied" | 1/2 | a majority-undecidable run prints what exit 0 does **not** mean | new fixture |

Fixture sets: **41 → 54** and **27 → 36**, all green, re-run immediately before this section.

**And the measurement survives the stricter test, which is the part that matters.** The
strengthened `check-run-state.sh` re-run over all **22 kept run-state files** admits **22 of 22**
(`evidence/b08/recheck-20260916/strengthened-checker-over-22-kept-files.tsv`). The defects were
real and admitted nothing false *in this batch*, so the recorded `state_valid` column stands —
said from the re-run, not from hope. The old column is not edited; it is what the old checker
returned.

### Two findings disputed, with the evidence, not with "stylistic"

**1. *"the run-state file is keyed by project basename, not by run id, so two sequential runs share
it and run 2 starts already blocked"* (1/2).** True of the code, and **the failure scenario cannot
occur in the registered harness**: the observatory creates a fresh worktree per run named
`observatory-run-<uuid>`, so `$(basename "$CLAUDE_PROJECT_DIR")` **is** per-run. Checked rather
than argued — **22 of 22** kept state files carry a **distinct** `.worktree` naming their own run,
and `$TMPDIR` holds **23 distinct** `run-state-observatory-run-*.json` files. **The scope limit is
recorded, not waved away:** outside this harness — the same project directory reused across runs —
the finding is correct and the hook would carry a counter between runs.

**2. *"`repair-record.sh`'s success predicate is exit 0, not task success"* (1/2, the critic marked
it non-blocking).** Correct, and **already written in the file's own header** before the review
ran: `./mvnw test -Dtest=DoesNotExist` exits 0 and clears the fingerprint. It is the honest limit
on the success oracle and is recorded as one, not fixed — a semantic success predicate is the
phrase-matching trap this stop is named after.

### The one finding that meets my own §5 finding, and together they are the better result

The critic flagged **no locking on the read-modify-write of the run-state file** (1/2): concurrent
`Bash` calls race, and a lost update drops a record. Independently, writing the §5 table found that
run `b90c76d7` recorded **5 `repair-limit` allows against 7 `repair-record` successes** — a gap
that is structurally impossible if both hooks see and record every event.

**The critic's finding is a mechanism for my anomaly.** Neither half proves it: a lost allow
record and a missed `PreToolUse` firing look identical in the artefact, and nothing here
distinguishes them. What can be said is that the anomaly now has a named candidate cause that is
**testable without an agent** — drive the two hooks concurrently against one state file and count
— and that the test belongs to whichever version fixes the locking, not to this stop, whose overlay
is measured.

### The twelve findings on the measured overlay are NOT fixed, and §6 is the reason

`build/customizations/agent-v1.1/` ran 40 benchmark runs. §6: *"never edit a registered variable
mid-experiment"*, and §3's overlay decision: *"a version that has been measured is never edited; a
change is a new version."* So every finding below is **recorded, carried to v1.2, and changes no
claim this stop makes** — except where the last column says it does.

| # | artefact | rec. | finding | does it move a stop-17 claim? |
|---|---|---|---|---|
| 1 | `.claude/settings.json` | **2/2** | `policy-gate.sh` is wired only to the `Edit\|Write\|NotebookEdit` matcher, so **`Bash` writes bypass the policy entirely** (`sed -i`, `echo >`, `tee -a`) | **No stop-17 claim, and it is the most serious of the 25.** Stop 16 already measured this model completing a task with **29–91 `Bash` calls** after `Edit` was denied, so the bypass is not hypothetical here. It is a finding about **B7's** gate, inherited into v1.1, and it belongs to v1.2's design |
| 2 | `protected-paths.yaml` | **2/2** | the deny list is **enumerative** and misses whole categories the boundary sentence claims — `Dockerfile.prod`, `Jenkinsfile`, `pnpm-lock.yaml` pass | No. B8's registered outcomes do not read the policy |
| 3 | `protected-paths.yaml` | 1/2 | *"fnmatch semantics"* is named with **no implementation specified**; shell `globstar` and Python `fnmatch` disagree, and a root `pom.xml` is undefined | No |
| 4 | `backend-feature-phases.md` | 1/2 | the file still tells the agent its boundaries are **prose**, while v1.1's gate now executes them | No — but it is stale prose inside a measured treatment, which is worth knowing when reading a null |
| 5 | `CLAUDE.md` | 1/2 | completion-contract clause 6 **restates the already-enforced** protected-paths gate, so it is a **constant** across every run it can see | No, and it is the v2-rubric lesson again: *restating a gate carries no information* |
| 6 | `CLAUDE.md` + `backend-feature-phases.md` | 1/2 | **two different repair thresholds** for one situation — *"fails twice, stop"* against the hook's *3 before the 4th is refused* — and the prose never defines a fingerprint | No. The counter stayed at 0 because the model **never retried**, not because it followed either number — but a contradiction between what the agent reads and what the hook enforces is exactly the kind of thing that makes a null hard to attribute |
| 7 | `CLAUDE.md` | 1/2 | *"Required tests passed. All of them"* is ambiguous between the ticket's tests and the repo's | No |
| 8 | `backend-feature-phases.md` | 1/2 | the phase markers are **self-reported strings and nothing checks them** | **Already recorded** — the workbook labels the phase contract **L3** for this exact reason. Confirmation, not a new finding |
| 9 | `backend-feature-phases.md` | 1/2 | *"touch a file only if the ticket cannot be completed without it"* has no objective standard | No |
| 10 | `backend-feature-phases.md` | 1/2 | the escalation threshold is undefined (changes-correctness vs reasonably-interpreted) | No |
| 11 | `CLAUDE.md` + `backend-feature-phases.md` | 1/2 | the `DONE` marker is required **even on escalation**, while the completion contract says an escalated run is not done | No — a contradiction inside the measured prose, carried |
| 12 | `backend-feature-phases.md` | 1/2 | *"approved commands"* and a `Bash` CLI-level allowlist are **named but nowhere defined or verifiable** | No, and this is the shape this project keeps meeting: **prose that names a control which does not exist** — L3 wearing L2's clothes. Recorded as such |

**One overlay finding is not deferred but answered here, because it bears on gate clause 2.** The
critic's strongest tools finding (2/2) is that `repair-limit.sh`'s **fingerprint is the sha256 of
the whitespace-normalised command text**, so `-Dtest=A` and `-Dtest=B` are two fingerprints and a
cosmetic argument change resets the consecutive counter. **Verified in the file** (`repair-limit.sh`
lines 58–68), and it is a **deliberate, documented** choice: a semantic classifier is the trap this
stop is named after, and phrase-matching an error string failed four times in the observatory.

The finding's true content is therefore not "a bug" but **a limit on what clause 2 enforces**: the
implemented fingerprint is **narrower than the registered definition** in `build/README.md#b8`,
which says *failure class + command + normalized primary error + affected module*. So the limit
bounds **byte-identical retries**, not repair attempts in the spec's sense. That gap is now stated
in the §5 table's clause-2 row rather than left for a reader to discover.

`Reviewed by codex + deepseek-v4-pro; dispositions decided by Opus 5 (claude-opus-5), autonomously,
2026-09-16. Round 1 of at most three.`

### §4a round 2 — the acceptance gate blocked on my own fix, and it was right

Same panel, same versions. **Exit 0, findings below the header, REJECT again**, at
`findings/opencode/review-check-run-state-20260916T182713Z.md` (201 lines). Seven findings.

**Three of the four round-1 defects are gone and the critic says so** — the enum substring test is
not mentioned by either family; deepseek confirms the ceilings *"removes the file-grades-its-own-
homework vector"*; and the unresolvable-baseline and zero-pattern cases *"assert the right exit
codes"*.

**The fourth survived in a form I introduced, and the gate blocked on exactly that.** My
zero-pattern fix set the exit code to 2 and **left `PASS 6. no forbidden files changed — 0 deny
pattern(s) read` on stdout**. A reader parsing per-clause output saw PASS while the process said 2.
**My fix wore the defect it fixed.** The line a reader reads is what a reader reads, so the line is
what changed: clause 6 now prints **UNDECIDABLE** on zero rules, and a fixture asserts that **no
`PASS 6` line exists at all** in that output.

**And one finding is a correctness bug, not a reporting one.** Clauses 2 and 3 were driven from
`--evaluator-exit` with *any* non-zero mapped to `FAIL build passed`. **Evaluator exit 21 is the
scope guard** and 20 the dependency guard (`BE-004/verify-evaluator.sh:5-16`) — a submission that
**built, whose tests passed**, and which then touched an unrelated production file. The checker was
asserting a fact the instrument never reported. Now: **12 and 13** attribute (functional, contract);
**20 and 21** report the guard and leave clauses 2 and 3 **UNDECIDABLE**; an unmapped code is
undecidable rather than guessed.

**The fixture set was defending that bug**, which is the worse half of it. Three cases *required*
`clause 2 == FAIL` on exit 21. A fixture set that encodes a misclassification cannot catch it, and
this project has now shipped that twice. Those three cases were rewritten to exit 12 and 13, and
five new cases assert the guard behaviour.

| finding | rec. | disposition |
|---|---|---|
| clause 6 printed `PASS` on stdout while exiting 2 | 1/2 + **acceptance block** | **fixed** — prints `UNDECIDABLE`; a fixture asserts no `PASS 6` line exists |
| one evaluator exit drove both clauses; exit 21 misreported as a build failure | 1/2 | **fixed** — 12/13 attribute, 20/21 report the guard as undecidable, unmapped codes undecidable |
| the fixture suite *required* clause 2 to FAIL on a successful build | 1/2 | **fixed** — the three cases moved to 12/13, five new guard cases added |
| `REG_PER`/`REG_TOTAL` duplicated the hook's constants and can drift | 1/2, called L1 | **fixed** — both are now **read out of `repair-limit.sh`**, the same argument this project already makes about the deny list. An unreadable or constantless hook is **exit 30, never a fallback**, and three fixtures prove it — including one where the hook's limits *move* and the checker follows the hook |
| empty `.worktree` / `.startedAt` / `.updatedAt` / `.phase` passed type-only validation | 1/2 | **fixed** — required strings must be non-empty; four fixtures plus a negative control |
| the suite had no fixture for an empty required scalar | 1/2 | **fixed** by the same four fixtures |
| clauses 2 and 3 can never disagree, being one instrument | 1/2 | **answered in the output**, not removed: both lines say `shared source` and the summary says *"TWO LINES FROM ONE INSTRUMENT"*. Two clauses of §10.6 genuinely have one instrument here, and the fix for that is a second instrument, which would be a new registered variable |

**Fixture sets after round 2: 30 of 30, 62 of 62, 44 of 44, and the batch guards 12 of 12** — every
one re-run immediately before this was written. **And the twice-strengthened checker still admits
22 of 22 kept run-state files**
(`evidence/b08/recheck-20260916/round2-strengthened-checker-over-22-kept-files.tsv`), so nothing in
the batch was retroactively invalidated by either round.

**A process failure of mine, recorded because the catch was luck.** I read
`review-check-run-state-20260916T182713Z.md` at 1 139 bytes, ran `pgrep` filtered for
`lab-critic|lab-acceptance`, got zero, called it a stall under §4a, and **re-ran the review**. The
file was **mid-write and the run was alive**; my process check came back empty because the tool
output on this machine arrives with command lines stripped, so it matched nothing. That is the
documented shape — *"the procedure written to catch a control that reports success over a smaller
scope than it claims was itself one"* — this time with `rtk` in the role `LC_ALL` played in 2026-09-03.
Cost: one duplicate review invocation, whose own file (`…183208Z.md`) **did** stall at 1 139 bytes
and is left on disk as what a real stall looks like beside a real one. No evidence was destroyed
and no benchmark run was touched.

`Round 2 of at most three. Reviewed by codex + deepseek-v4-pro, acceptance minimax-m3; fixes and
dispositions by Opus 5 (claude-opus-5), autonomously, 2026-09-16.`

## §5 validation table

**Every command in the "re-derive" column was run again immediately before this table was
written** (§5), on 2026-09-16, and the three that decide a verdict — the manifest's per-arm
hash and counter columns, the 36 rubric shas, and the reference count behind clause 3 — were
re-derived by the orchestrator from the files themselves rather than taken from a subagent's
report.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| *counters persist across interruption* | `evidence/b08/worktrees/b90c76d7-12df-4dcb-beb6-630dd8cef809/run-state.json` — BE-004 seq 05 **treated**, evaluator exit 0. `schemaVersion: b8-v1.1`, `hookExecutions` **12 entries**, first `2026-09-16T01:44:34Z`, last `2026-09-16T04:47:41Z` (3 h 03 m). The interruption itself: `evidence/b08/sleep-2026-09-15/pmset-and-run-starts.txt` — clamshell sleep `2026-09-15T19:48:55Z`, lid-open wake `2026-09-16T06:59:36Z` | **L2 for the persistence** — the counters are on disk and accumulated across every gap, and nothing about that is asserted. **L3 for it being a test**: `n = 1`, and the interruption was an accident, not something this stop arranged | `python3 -c "import json;d=json.load(open(P));print(d['schemaVersion'],len(d['hookExecutions']),d['hookExecutions'][0]['ts'],d['hookExecutions'][-1]['ts'])"` → `b8-v1.1 12 2026-09-16T01:44:34Z 2026-09-16T04:47:41Z`. A file re-initialised after the sleep would carry a short array and a late first timestamp |
| *limits technically enforced* (`build/README.md#b8`: *"enforced by hook or wrapper, never by prompt"*) | `build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh`, sha **`fa38193a5093c09bf0261947b0b4d2750b9c973b90fb17123eec82519077cea5`**, registered as a `PreToolUse`/`Bash` hook in `.claude/settings.json` sha **`925a382322daada434a8d3716f8696882a1759b048ccc7f0d580a902ea27fb2b`**. Fixture set `tools/verify-repair-limit.sh` — **30 of 30**, re-run 2026-09-16 at this step. Wiring proved by removal: `evidence/b08/deliberate-failure-20260916/`, run `5116b598-3cdd-49b3-b497-2e4bf7de46c2` | **L2 by fixture — and explicitly *unexercised in situ*.** The blocking branch fired **0 times in 20 treated runs**; its evidence is fixtures plus the removal probe, never a benchmark run. **And what it bounds is narrower than the clause's own definition:** `build/README.md#b8` defines the fingerprint as *failure class + command + normalized primary error + affected module*; the implementation (`repair-limit.sh:58-68`) is the sha256 of the whitespace-normalised **command text alone**, so `-Dtest=A` and `-Dtest=B` are two fingerprints and the limit bounds **byte-identical retries**. That is a deliberate, documented choice — a semantic classifier is the trap this stop is named after — and it is stated here because §4a round 1 found it at 2/2 and a reader should not have to discover it | `./tools/verify-repair-limit.sh` → `30 of 30 cases pass`; `awk -F'\t' '!/^#/&&!/^task\t/{print $3,$16}' evidence/b08/batch-20260915T182436Z/manifest.tsv \| sort \| uniq -c` → `20 control 0`, `20 treated 0` |
| *a blocked run produces a clear machine-readable result* | **NOT MET.** `grep -rln classify-permission-block` in `agent-observatory` at `1376a2eef5539914a463f9226ccc11cc8a421df4` returns exactly two paths: `runner/lib/classify-permission-block.sh` and `runner/verify-permission-block-classifier.sh`, its own verifier. Nothing in the run path calls it. From the other side: `blocks` = 0 on 20 of 20 treated rows, so no blocked run exists to inspect | **L3 — and therefore the gate is not closed.** §5: *"if the only proof that a gate held is that you say so, write L3 and do not close the gate"* | `git -C ../agent-observatory rev-parse HEAD` then the `grep -rln` above → two paths, one of which is the file itself. There is no third caller to find |
| *no regression against the v1.0 benchmark* | Population: `evidence/b08/batch-20260915T182436Z/manifest.tsv`, **40 rows**; `evidence/b08/gate-20260916/admitted.tsv`, **36**; 4 gate refusals named in `gate-results.tsv` (BE-004 `2ebaa773`, `80b21210`, `00b6ccbb` — `f13=yes`, evaluator 12; BE-004 treated `ebf9e05e`, evaluator 11). Scores: `evidence/b08/scoring-20260916/category-values.tsv`, 36 rows, **four non-null categories on 36 of 36**, rubric shas **20 × `396e1799eb2b`** (BE-003) and **16 × `6252778b8472`** (BE-004). Readings in `experiments/E-018-…-BE003.md:352-369` and `E-019-…-BE004.md:350-363`; MDE in `evidence/b08/scoring-20260916/mde-rederived.md` | **L2 for every number** — sheets, manifest and reports are all re-readable. **L3 for the phrase "no regression"** as a property: what is shown is *no regression this instrument can see*, and the instrument's floor is written down — one full rubric point, **$0.0163** on BE-003 (`n = 10`), **$0.0089** on BE-004 (`n = 7` control / `n = 9` treated) | `./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml --run-id <any BE-003 id>` reproduces a sheet at the same sha; medians from `category-values.tsv` by `awk`; BE-003 evaluator 10/10 vs 10/10 and BE-004 9/10 vs 7/7 from manifest columns 3 and 6 |
| *the prediction was on record before the first run* | Prediction commit **`5d7bfe0`**, `2026-09-15T14:31:03Z`. First run `startedAt`: BE-003 `2026-09-15T18:24:37Z` (E-018:318), BE-004 `2026-09-15T19:21:40Z` (E-019:316) | **L2** — the ordering is in git, not in prose | `git log --format=%cI -1 5d7bfe0` precedes both timestamps by ≥ 3 h 53 m |
| *P1 — the treatment reached the treated arm and not the control* | `manifest.tsv`: `instr_hash` = `sha256:a94237242e8c1308fb1d434a06a03463` on **20 treated**, `null` on **20 control**; `agent_hash` = `sha256:b3450564b6f32d6193e8580db766210e` on **40 of 40** (so nothing about the B5 phase agent moved between arms); `state_file` **PRESENT × 20 treated**, **ABSENT × 17 control** and `INCONCLUSIVE-0-edits × 3` (the three F13 control runs made no edits, so their column is honest rather than a claim); `state_valid` = 0 (`check-run-state.sh` accepts) on **20 of 20** treated; `init_tools` = `n=4 ["Read","Edit","Write","Bash"]/match` on **40 of 40** | **L2** — every value is read back from the run's own init record or from the hook's own output, never from the flag that was passed | `awk -F'\t'` over columns 12, 11, 13, 14 and 24 of the manifest reproduces each count. The two registered hashes are re-derivable from the overlay: `shasum -a 256 build/customizations/agent-v1.1/CLAUDE.md` → `a94237242e8c1308f…` and `.claude/agents/backend-feature-phases.md` → `b3450564b6f32d619…`, the runner storing the first 32 hex characters |
| *the registered variables did not move* | `runtime_ver` = `2.1.272 (Claude Code)` and `model` = `claude-haiku-4-5-20251001` on **40 of 40** manifest rows; benchmark baseline `eea144ef940fda4cb6090561fdd901aed0013c8e`; runner commit `1376a2eef553`; rubric shas as above, one per task with **no mixing** | **L2** | `awk -F'\t' '{print $9,$10}' manifest.tsv \| sort -u` → one line; `git -C ../agent-observatory-benchmarks rev-parse origin/main` → `eea144ef…`; `shasum -a 256` on both rubric files |
| *at least one scored cell re-read by hand, beside the sheet's value* | `evidence/b08/hand-rereads-20260916/BE-003-change-focus-6e5cac9b.md` — run `6e5cac9b-…`, `change-focus`, **hand = 1, sheet = 1**, cited at `ApiError.kt:36`. `evidence/b08/hand-rereads-20260916/BE-004-change-focus-b33a8233.md` — run `b33a8233-…`, `change-focus`, **hand = 2, sheet = 1**, cited at `OrderController.kt:21` and `ShipmentController.kt:26`. Both committed at **`8c56ba8`, 2026-09-16T09:51:59Z** | **L2 — and the ordering is the point.** The hand values predate every sheet of this batch by 2 h 18 m, so neither was written with a number to match | `git log --format=%cI -1 8c56ba8` → `2026-09-16T09:51:59Z`; earliest `scored_utc` across the 36 sheets → `20260916T120919Z`. **The BE-004 cell disagrees with its sheet and is left disagreeing** — the disagreement is the evidence for the change-focus defect, not something to reconcile by editing either value |
| *second reader, not a vote* | `evidence/b08/scoring-20260916/second-reader-results.tsv`, 36 rows; concordance in `concordance.md`: architecture-consistency **29/30**, maintainability **29/30**, test-quality **26/30**, change-focus **17/30** | **L2** — two harnesses, both on disk, per run id | `diff` the two results files by run id; the change-focus column is the one that splits, which is the third independent arrival at the same defect |
| *deliberate failure: the wiring, not the file, is what executes* | `evidence/b08/deliberate-failure-20260916/`, run `5116b598-3cdd-49b3-b497-2e4bf7de46c2`. Variant `build/customizations/agent-v1.1-unwired-DELIBERATE-FAILURE/` — the three hook scripts present and byte-identical, the `settings.json` registration removed. `condition-d1-absent.txt`: *"condition D1: run-state file ABSENT"*. The run still produced `"evaluation":{"exitCode":0,"passed":true}` | **L2** — the failure was induced on a real run and observed, not argued | `shasum -a 256` the three hook scripts in both overlays (identical); `diff` the two `settings.json` (the hook block is the only change); `stat` the run-state path for `5116b598` → no such file |
| *author decision 11 item 7 — the `handoff` field is written and marked reserved* | `handoff` is a top-level key of every treated run's `run-state.json`; re-read here from `b90c76d7-…/run-state.json` alongside `phase`, `goal`, `affectedFiles`, `limits`, `repairAttemptsByFingerprint`, `totalRepairAttempts`, `blocks`. Marked reserved for B8a in the workbook at `phases/b08-run-state-repair-limits/README.md:497-513` | **L3, and deliberately** — nothing executes on it at this stop, which is what "reserved" means. Calling a written field a control would be the substitution the workspace `CLAUDE.md` names | `python3 -c "import json;print(sorted(json.load(open(P)).keys()))"` → `handoff` is present; `grep -rl '"handoff"' evidence/b08/worktrees/*/run-state.json \| wc -l` → 22 |
| *the schema checker admits nothing false — re-asked after §4a strengthened it* | `evidence/b08/recheck-20260916/strengthened-checker-over-22-kept-files.tsv` — the post-§4a `tools/check-run-state.sh` re-run over all **22 kept run-state files**: **22 of 22 exit 0**. The old checker's own exit codes over the three new fixtures are recorded beside the new ones (`allo`, the 1000-ceiling tamper, `2.5`): **old 0 → new 1** on all three | **L2, and this row is the reason the `state_valid` column above is still worth quoting.** A checker that had never been shown to refuse anything would make `state_valid 0 on 20 of 20` unfalsifiable | `for f in evidence/b08/worktrees/*/run-state.json; do ./tools/check-run-state.sh "$f"; done` → 22 × exit 0; `git show <pre-fix sha>:tools/check-run-state.sh` over the same three mutations → exit 0 each time |
| *and the population reconciles against the observatory, not only against my own manifest* | `GET /api/runs?limit=1000` through the colima tunnel `127.0.0.1:18081`, 617 runs total, filtered on `experimentKey`: **`EXP-B8-RUNSTATE-BE003` = 20**, **`EXP-B8-RUNSTATE-BE004` = 20**, `…-BE003-PREFLIGHT` = 2, `…-BE004-PREFLIGHT` = 2, `…-BE003-DELIBERATE-FAILURE` = 1 | **L2** — the count comes from the instrument the runs were written to, which is a different thing from the file the driver wrote | 20 + 20 = the manifest's 40 rows exactly, **0 unaccounted in either direction**; the 5 non-batch runs all sit under their own keys, so no preflight or deliberate-failure run can have leaked into an arm |
| *the population is exactly the 40 named runs, and no run was re-run* | 40 manifest rows = 36 admitted + 4 gate-refused; 3 of the 4 are `f13=yes` (`api_error`, evaluator 12) and were **deliberately not topped up**, as E-016 did at `n = 7`; the fourth (`ebf9e05e`, evaluator 11) is BE-004's **first evaluator failure on this model** and is a result, not an exclusion | **L2** — every id reconciles, in both directions | `wc -l` on `manifest.tsv` minus header and comments → 40; `wc -l admitted.tsv` → 36; `awk -F'\t' '$7=="yes"' manifest.tsv` → 3 rows, all BE-004 control |

**Every number above carries its `n`.** BE-003 is `n = 10` per arm. BE-004 is `n = 9` treated and
`n = 7` control after the gate, and the one BE-004 evaluator failure is written as *one run*, never
as a rate — §5 forbids stating an `n < 5` result as a property, and `n = 1` is the strongest case
of that. Clause 1's persistence demonstration is `n = 1` and is labelled as such in its own row.

### One thing this table found that the exit gate above does not say, 2026-09-16

The success oracle's evidence is the **gap** between `PreToolUse` allows and `PostToolUse`
successes, and §4 step 10 keeps it as *"the stop's real deliverable"* on the strength of the
BE-003 pooled gap, **48 allows vs 47 successes**. Re-deriving the same columns for BE-004 at this
step gives a pooled gap of **0** — and that 0 is a **cancellation, not an agreement**: seq 03
`+1`, seq 09 `+1`, seq 05 `−2`.

A negative gap cannot happen if both hooks see every `Bash` event, because every success must have
had an allow. On seq 05 — run `b90c76d7-…`, the same run clause 1 rests on — the state file records
**5 `repair-limit` allows and 7 `repair-record` successes**. So on 1 of 20 treated runs the two
hooks demonstrably did **not** see the same event stream, and it is the run that spanned the
80-minute sleep.

What this changes, and what it does not:

- **It does not change any registered outcome.** No prediction reads the gap; P2's registered
  quantity is `totalRepairAttempts`, which is 0 on that run and read from the same file.
- **It does change what may be claimed for the oracle.** A gap is interpretable only when the
  allow side is complete, and this batch contains one run where it is not. The honest form of the
  step-10 keep is *"the gap is the only instrument here that can see a failing command, and it is
  trustworthy per run only where allows ≥ successes"* — true of 19 of 20 runs.
- **It sharpens clause 1 rather than weakening it.** The counters survived the sleep; the *event
  capture* did not survive it intact. Those are two different properties of the same run, and only
  the first is what the clause asks about.

**Nothing above is edited into a prediction, a sheet or a result.** Found by Opus 5
(`claude-opus-5`), autonomously, at §4 step 13, 2026-09-16, by re-deriving manifest columns 17 and
18 for BE-004 — a task the batch's own report never asked for, which is why it was not found
earlier.

## The published boards were checked claim by claim, not by the green check — 2026-09-16

`check-board-freshness.sh` compares a digest and **cannot read a sentence**. On 2026-09-11 that let
a board publish *"17 of 17 treated runs denied a real violation"* when the policy gate had denied
nothing, and the check passed over it. So the boards were verified the way that incident says to:
every factual claim in the new stop-17 material was extracted from both sources and checked
against the measurements.

**Both boards republished with real content, first attempt each, no refusals.** Markers relabelled
to prose `e67c87306a93`, built-from `196731f`; `check-board-freshness.sh` exits 0, *2 board(s)
current*. Relabelling alone would **also** have gone green and would have left both boards lying,
which is the failure the check exists to prevent rather than to perform.

**Every stop-17 claim on both boards is correct against the evidence.** The ones that could have
been wrong, and what each was checked against:

| claim, as published | checked against |
|---|---|
| three of four gate clauses; clause 3 NOT met, L3, gate not closed | the exit gate above, and `grep -rln classify-permission-block` in `agent-observatory` at `1376a2eef553` → two paths, one of them the file itself |
| `0` block decisions across 20 treated runs | `manifest.tsv` column 16 → `20 treated 0`, `20 control 0` |
| BE-003 `10/10 vs 10/10`, four medians Δ0, `+2.4 %`, `n = 10` | `E-018:325`, `:354-357`, `:367` |
| BE-004 `9/10 vs 7/7`, three of four Δ0, `+4.4 %`, `n = 9` / `n = 7` | `E-019:328`, `:352-355`, `:362` |
| `48 allows against 47 successes` (BE-003 pooled) | re-derived from manifest columns 17 and 18 |
| BE-004 pooled gap `0` by cancellation: seq 03 `+1`, seq 09 `+1`, seq 05 `−2`; and `5 allows against 7 successes` on `b90c76d7` | the same re-derivation, and `b90c76d7`'s own `run-state.json`: `Counter({('repair-record','success'): 7, ('repair-limit','allow'): 5})` |
| `instr_hash` 20/`null` 20, `agent_hash` 40 of 40, `init_tools` match 40 of 40, `state_file` PRESENT×20 / ABSENT×17 + 3 `INCONCLUSIVE-0-edits` | manifest columns 11, 12, 13, 24 |
| re-derived MDE `$0.0163` / `$0.0089` | `evidence/b08/scoring-20260916/mde-rederived.md:16`, `:23` |
| BE-005 absent: `eea144ef940f` holds BE-001…BE-004, no PR open | `git ls-tree origin/main tasks/` and the repo's open-PR list, both read this session |
| **Runs on record 617**, and *"stop 17 added 45 — 40 batch, 2 + 2 preflight, 1 deliberate-failure"* | **the arithmetic and the instrument agree exactly.** `40 + 4 + 1 = 45`; `572 + 45 = 617`; and `GET /api/runs?limit=1000` returns **617 total with 45 under the four `EXP-B8-RUNSTATE*` keys and 572 not** |

**One thing the check found, and it is not a stop-17 claim.** Two sentences already on the boards
say that promoting B6's skill *"is a B8 decision at the v1.1 boundary"* — `b2-board.html:688` and
`road-to-agent.html:563-564`. **B8 has now closed without making that decision.** Both sentences
sit in the stop-13 sections, which these boards keep by design alongside every superseded *"Spine
N of 28"* header, so they are **historical rather than false** — but a reader skimming will read
them as pending. Recorded in `author_notes` rather than rewritten, because editing a historical
section to match today is how a board stops being a record.

## Commit

<!-- TODO -->
