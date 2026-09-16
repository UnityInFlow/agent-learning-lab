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
