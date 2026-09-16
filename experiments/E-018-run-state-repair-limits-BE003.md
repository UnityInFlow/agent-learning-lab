# Experiment E-018 — run state, repair limits and a completion contract — v1.1 against v1.0 on BE-003

**Key:** `EXP-B8-RUNSTATE-BE003` · **Spine stop 17 (B8)** · **Task: BE-003-confirm-shipment** · **Version: v1.1 closes here**

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-15T16:3xZ; the author did not review before the run.`

> Everything down to and including **Predictions** is written and committed **before the first
> run**. The commit timestamp and the first run's `startedAt` are written back into §Sanity
> checks after the batch, as `E-001`'s nine voided runs require.

## Question

Does the **v1.1 overlay** — persistent run state, a hard repair limit enforced by a `PreToolUse`
hook, and a completion contract that a script decides — **cost anything measurable** against
**v1.0 as it closed at B7**, on BE-003-confirm-shipment?

**This is a no-regression question, and it is not the same question as "does the machinery
work".** The second one is not answerable from this batch and the experiment does not pretend
otherwise: the limit only fires when the agent fails a command repeatedly, and
`claude-haiku-4-5-20251001` does not fail these tasks. *(Author decision 11's own count: BE-004
is 9 of 9 before stop 12, 10 of 10 in every arm at B5 and B6, 7 of 7 in both arms at B7.)*
Enforcement is proved by `tools/verify-repair-limit.sh` and by the deliberate failure at §4
step 9, both of which execute; this file measures the **price of carrying it**.

## Hypothesis

The v1.1 additions change **what happens when the agent fails**, and on this task it does not
fail. So they will be invisible to the evaluator and to the rubric, and visible only in cost —
and there only through the prose they add to the overlay's `CLAUDE.md`, not through the hooks,
which exit 0 in silence on every allow path and cost nothing at inference time.

The mechanism this predicts from is **measured, not assumed**: B7's Layer 2 policy gate executed
on 17 of 17 treated runs and moved all four BE-004 rubric deltas by **0** at **+5.02 %** cost
(`E-016:388,478-483`); B3's 57-word instruction file moved nothing, and the same three rules
diluted 25× to 1 455 words also moved nothing, at **+4.2 %** (`E-003`). Two different treatments,
both delivered and proved, both null on quality and small on cost.

## Predictions

1. **P1 — delivery, and it is a gate on the whole file.** On **10 of 10** treated runs a
   run-state file exists at `${TMPDIR}/run-state-observatory-run-<runId>.json` naming that run's
   worktree, and on **0 of 10** control runs any such file exists. *Mechanism:* `repair-record.sh`
   runs on the first `Bash` `PostToolUse` and always exits 0, so **the file exists if and only if
   the hook executed**. This is the delivery proof *because no hash can be one* —
   `customization.hooksHash` is declared in `run.schema.json:60`, in the web types, in the DTO and
   in the entity, and is computed nowhere (`run-agent.sh:625-629`). It is B7's answer inherited:
   a hook that writes only on the interesting path is indistinguishable from a hook that never ran.
2. **P2 — the limit does not block, but the counter is not zero, and the second half is the one
   most likely to be wrong.** Across all 10 treated runs, `repair-limit.sh` emits **zero** `block`
   decisions (one-arm binomial, `k = 0`). On BE-003, `totalRepairAttempts` has median **0**. *Mechanism:* the counter counts **failing
   commands**, not failing runs, and **nobody in this project has ever counted failing commands** —
   the evaluator sees only the end state. BE-003 is a single-file change the model has passed on essentially every run since B2, so there is little for a command to fail at.
3. **P3 — no evaluator regression.** Treated and control evaluator pass rates are equal, or differ
   by at most one run. *Mechanism:* the hooks touch nothing the evaluator scores, and the
   bookkeeping artifact is written **outside the worktree**, which is the specific failure B7
   measured — runs `2077432c` and `88b861f3` solved their tasks and were scored **exit 21,
   unrelated production files changed**, where the unrelated file was the guardrail's own log
   (`E-016:227-237`). *Two-arm claim.* A difference below **5 runs** does not clear Fisher at this
   `n` and is reported **NOT DETECTABLE**, never as "no regression proved".
4. **P4 — no rubric regression.** All four category medians equal the control's, delta **0** on
   each. *Mechanism:* as the Hypothesis. *Two-arm claim, and the scale is the limit:* categories
   are integers 0–2, so **one full point is the smallest movement this instrument can show**.
   A delta of 0 is therefore consistent with any true effect under one point and is reported as
   **not detectable**, not as "identical".
5. **P5 — cost rises, between +2 % and +8 %, and this band is INSIDE the MDE, which is registered
   now so it cannot be claimed later.** *Mechanism:* the overlay's `CLAUDE.md` grows by the
   completion-contract text and the run-state instructions; hooks that exit 0 add no tokens.
   The transferred detection limit is ****$0.045 (30 %)****, so **any result inside this predicted band is
   NOT DETECTABLE at `n = 10`** — P5 is written as a prediction about the *direction and size of a
   real effect*, and it is registered as **undecidable by this experiment on purpose**. `E-002`
   filled an MDE with its own thresholds and two of its three refutations turned out to sit inside
   its own detection limit; this row is what not doing that looks like.
6. **P6 — the completion contract changes nothing about the run, because at this stop it does not
   execute inside one.** `tools/check-completion-contract.sh` decides §10.6's seven clauses over a
   finished worktree **at scoring time**; no `Stop`-class hook is built. So the treated and control
   arms are identical with respect to it, and any difference attributed to it would be an error.
   *Mechanism:* stated in §How the treatment is delivered, and the reason it is not an in-run hook
   is given there rather than left as an omission.

> **DATED CORRECTION TO P1's AND P2's MECHANISM, 2026-09-15 — written before the overlay was
> built and before any run of this experiment. The predicted values above are NOT edited**
> (§4 step 12): P1 stays 10 of 10 / 0 of 10, and P2 stays zero `block` decisions with the
> median registered above. What is corrected is the *mechanism sentence* under each, because a
> free probe showed the mechanism as written cannot produce the quantity it names.
>
> **The measurement.** Three `claude -p` sessions in a throwaway directory with the runner's
> own flag set, CLI `2.1.272`, model `claude-haiku-4-5-20251001`, thirteen `Bash` calls, one
> hook on both events. Payloads and derivation:
> [`evidence/b08/hook-event-probe-20260915T153209Z/`](../evidence/b08/hook-event-probe-20260915T153209Z/README.md).
> **`PostToolUse` on `Bash` fires if and only if the command exited 0** — 6 of 6 successes,
> 0 of 6 failures, two-sided Fisher **p = 0.0022** — and `tool_response` carries no exit code
> (`{stdout, stderr, interrupted, isImage, noOutputExpected}`). `PreToolUse` fired on 13 of 13,
> and its `exit 2` blocked a `Bash` call outright.
>
> **What that does to P1.** The mechanism sentence says the file exists iff `repair-record.sh`
> ran on the first `Bash` `PostToolUse`. Under the measurement that is true only if the run's
> first `Bash` call *succeeded*; a run whose first command failed would have no file, and P1
> would have recorded a delivery failure that was really an oracle artefact. **The file is now
> written by `repair-limit.sh` on `PreToolUse`, which fires on every `Bash` call whatever its
> outcome.** P1's *prediction* is unchanged and its *proof is strictly stronger*: the file
> exists iff the hook executed, and the hook executes on every call rather than on every
> successful one.
>
> **What that does to P2, and this is the substantive half.** The mechanism says *"the counter
> counts **failing commands**"*. **A hook in this runtime cannot count failing commands** — no
> event carries one. Built as written, `totalRepairAttempts` would have read **0 on every run
> of both arms**, and that zero would have been reported as *the model does not fail this task*
> when it meant *the counter never sees a failure*. It would not have looked like a defect; on
> BE-003 **it would have looked exactly like P2 holding.**
>
> **The corrected quantity, registered here before any run.** `totalRepairAttempts` counts
> **repeat attempts at the same command fingerprint** — a second or later `PreToolUse` on a
> fingerprint whose counter a success has not cleared — with `PostToolUse` acting as the
> success oracle that clears it. This is a rule over facts the record already holds, needing
> no exit code and no vocabulary, which is the same shape as the rule Track A landed on for
> BLOCKED (*"an agent that changed no file and called no tool did not attempt the task"*).
> **It is a different quantity from the one P2's mechanism named, and the predicted number is
> deliberately carried across unchanged rather than re-tuned to fit it** — re-tuning a number
> to a definition discovered after it was written is the thing this project does not do.
> P2 remains the row registered as most likely to be wrong, and it is now also the row whose
> *units* were corrected before it was measured; both facts are reported with the result.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing: the customization overlay.**

| arm | `--customization` | what it is |
|---|---|---|
| treated | `build/customizations/agent-v1.1/` | v1.0's overlay **plus** `repair-record.sh` (`PostToolUse`/`Bash`), `repair-limit.sh` (`PreToolUse`/`Bash`), the run-state schema and the completion-contract text |
| control | `build/customizations/verify-v1.0/` | **v1.0 exactly as it closed at B7**, unmodified and unedited — a measured version is never edited (§3 pre-made decision) |

**The control is v1.0, not plain, and that is the gate's own wording** — `build/README.md#b8`
asks for *"no regression against the v1.0 benchmark"*. This experiment therefore makes **no claim
against a plain baseline**; B7 owns that comparison and it is not recomputed here.

**The control is run concurrently, and at this stop that matters more than usual.** E-015 and
E-016 recorded `runtime.version` `2.1.267 (Claude Code)`; stop 16 ran on `2.1.268`; this batch will
run on **`2.1.272`**. Comparing v1.1 against E-015/E-016's *stored* v1.0 runs would put a
three-version CLI move inside the comparison. Running v1.0 again, interleaved, removes it —
the stored numbers are used **only** to transfer the MDE, and are labelled as transferred wherever
they appear.

**B8 adds three things at once**, because `build/README.md#b8` defines the step that way.
Registered here rather than discovered in the write-up: **a null cannot be attributed to any one
of run state, repair limits, or the completion contract.** Separating them needs three arms, which
this step does not have.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.1/`, copied into the worktree by `run-agent.sh:338` and force-added at `:371` |
| Content hash | **registered at §4 step 4**, when the overlay exists: `sha256` of each of `.claude/settings.json`, `.ai/hooks/repair-record.sh`, `.ai/hooks/repair-limit.sh`, `CLAUDE.md`, recorded here before the preflight run |
| Preflight assertion | one treated run under `EXP-B8-RUNSTATE-BE003-PREFLIGHT`: the run-state file exists and names that run's worktree; its `hookExecutions` line for `repair-record` is present; `customization.instructionsHash` is non-null and equals the overlay `CLAUDE.md`'s sha; and the `init` read-back per **author decision 8** shows `Bash` in the delivered tool set — because a `Bash` matcher that never sees a `Bash` call proves nothing |
| Control assertion | the same paths are **absent** on a control run, checked by `stat`, and `customization.instructionsHash` equals `verify-v1.0/CLAUDE.md`'s sha and **not** the treated one |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.
> **And no hash covers hooks here**, which is why the assertion above is an artifact the hook
> leaves rather than a hash the runner computes. Author decision 11 item 9 registers the same
> shape for B8a; it arrives one stop early.

**Why the completion contract is not an in-run hook, stated before the run rather than after:**
a `Stop`-class hook that decides §10.6's seven clauses has to run the build and the test suites
inside the run, which on BE-004 is minutes per invocation and a new registered variable in the
cost column — and **nothing in this project has ever observed whether this runner reaches a
`Stop` hook at all**. Building it blind and measuring it in the same batch would confound the
step's only cost signal. It is `tools/check-completion-contract.sh` at scoring time, **L2 as a
checker and explicitly not an in-run control**, and the in-run version is named as follow-up.

> **CONTENT HASHES, REGISTERED AT §4 STEP 4 — 2026-09-15, before the preflight run and before
> any batch run.** `sha256`, first 32 hex characters, of the overlay as it exists on this
> branch. `tools/check-overlay-parity.sh` re-derives these; a mismatch at scoring time voids
> the run rather than being explained.
>
> | file | in `agent-v1.1` (treated) | in `verify-v1.0` (control) |
> |---|---|---|
> | `CLAUDE.md` | `a94237242e8c1308fb1d434a06a03463` | **absent** |
> | `.claude/settings.json` | `925a382322daada434a8d3716f869688` | `1dc38808bee86df9b128435a90ef27cf` |
> | `.ai/hooks/repair-limit.sh` | `fa38193a5093c09bf0261947b0b4d275` | absent |
> | `.ai/hooks/repair-record.sh` | `7339e63045fa4e2a2ecd835d57e317d9` | absent |
> | `.claude/agents/backend-feature-phases.md` | `b3450564b6f32d6193e8580db766210e` | `b3450564b6f32d6193e8580db766210e` — **identical, byte for byte** |
> | `.ai/hooks/policy-gate.sh` | `f432abbcbf1f3b90ec4dd801a23c333a` | `f432abbcbf1f3b90ec4dd801a23c333a` — **identical** |
> | `.ai/policies/protected-paths.yaml` | `76c4c34c0f4ca5ebeb12dbb3c25bd717` | `76c4c34c0f4ca5ebeb12dbb3c25bd717` — **identical** |
>
> **The three inherited files are byte-identical to v1.0's, asserted rather than assumed.**
> That is what makes "v1.0's overlay **plus**" a true description of the independent variable:
> the agent prose, the policy gate and the deny list are not merely *similar*, they are the
> same bytes, so nothing in them can be a between-arm difference. `verify-v1.0` itself was not
> touched — *a measured version is never edited* (§3 pre-made decision) — and
> `git status --porcelain build/customizations/verify-v1.0` is empty on this branch.
>
> **DATED CORRECTION TO THE CONTROL ASSERTION IN THE ROW ABOVE, 2026-09-15.** That row reads
> *"`customization.instructionsHash` equals `verify-v1.0/CLAUDE.md`'s sha and **not** the
> treated one"*. **`verify-v1.0` carries no `CLAUDE.md`** — it never did; its prose lives in
> `.claude/agents/backend-feature-phases.md`. `run-agent.sh:572-576` returns the literal
> `null` for a file that is not there, so the control's `instructionsHash` will be **`null`**,
> not a sha. **The assertion is therefore: treated runs carry
> `instructionsHash = sha256:a94237242e8c1308fb1d434a06a03463` and control runs carry
> `null`.** That is a stronger separation than the one registered, not a weaker one, and it is
> corrected here rather than discovered while reading a sheet. *(The registered wording is left
> above as written; this note is the operative form.)*
>
> **And what that costs, stated plainly:** `CLAUDE.md` is a file the treated arm has and the
> control does not, so the v1.1 bundle includes *an instruction file* among its three things.
> E-003 measured a 57-word global instruction file and found it moved nothing (`REJECT`,
> 2/10 vs 3/10, p = 1.0), which is the best available reason to expect this carries no effect
> of its own — but it is **a fourth thing in a bundle already registered as three**, and the
> limitation section's sentence *"a null cannot be attributed to any one of them"* now covers
> four, not three. Registered here, before the run.

## Controlled variables

- [x] starting commit / benchmark revision SHA — `eea144ef940f` (`agent-observatory-benchmarks` `main`)
- [x] task + revision — BE-003-confirm-shipment, unedited
- [x] harness + version — `claude` **`2.1.272 (Claude Code)`**, read back from `runtime.version` on every run, not from the flag
- [x] model — **`claude-haiku-4-5-20251001`**, exact id
- [x] permissions / permission mode — identical in both arms; **no `permissions.deny` anywhere**, which stop 16 showed is not a boundary (arm D changed 2, 3, 3, 4 and 13 files through one)
- [x] environment — `ISOLATE_USER_SETTINGS=1`, confirmed by **observing** `customization.*Hash` and hook executions on the record, not by trusting the flag
- [x] runner commit — `agent-observatory` `main` at **`1376a2eef553`**
- [x] scorer — codex, registered rubric **`396e1799eb2b`**; opencode/`deepseek-v4-pro` as second reader only

## Runs

Repetitions per arm: **10** · Total budget: **≈ $3**

Plus one preflight **pair** under `EXP-B8-RUNSTATE-BE003-PREFLIGHT`, which enters no `n` and no comparison.

Interleaved, not blocked: treated and control alternate, so a mid-batch machine or CLI change
lands in both arms rather than in one.

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Transferred, and labelled as transferred.** There is no stored population for v1.1, and the
control arm of this experiment *is* the reference population — but it does not exist until the
batch runs. So the limits below are carried from the **v1.0 arm of `E-015`**, which is the same
overlay this experiment uses as its control, and are **re-derived from this batch's own control
before any verdict is written**. Decision 11 item 10 prescribes exactly this for a task with no
stored population; E-016 did it at `n = 7`.

Formula, the same one E-015 and E-016 used: `MDE ≈ 2.8 · sd · sqrt(2/n)`.

| Outcome | measured spread it comes from | MDE at `n = 10` | registered before the run? |
|---|---|---|---|
| primary: weighted rubric total, codex, rubric `396e1799eb2b` | `E-015`'s **v1.0 (treated) arm** — which is this experiment's control overlay — at architecture-consistency 2, maintainability 2, test-quality 1, change-focus 1 (`E-015:387-390`); categories are integers 0–2 | **one full category point** — the scale's own floor; nothing smaller is representable | yes |
| primary: evaluator pass rate | `E-015`: control 10 of 10 and treated 10 of 10 exit 0 (`E-015:303`) | a difference below **5 runs** does not clear Fisher at `n = 10` | yes |
| secondary: `estimatedCost` | the spread `E-015` registered **its own** MDE from (`E-015:139-146`): mean $0.1491, sd $0.03567, `n = 10` — **not** its v1.0 arm's median, which was $0.127329 [$0.091474–$0.155815] (`E-015:299`) | ****$0.045 (30 %)**** | yes |
| secondary: `modelCalls` | `E-015:139-146`: mean 21.9, sd 5.152, `n = 10` | **6 calls (29 %)** | yes |
| secondary: `durationMs` | `E-015` control median 105 000 ms, range 75 000–123 000 ms | **no verdict is taken from duration** — the range spans a factor of 1.6 and a machine sleep is not excludable after the fact | yes |
| reported, not tested: `totalRepairAttempts` | **no measured spread exists** | **none — it has never been measured.** Reported as a distribution with its `n`, never as a comparison | yes |

**Derive against the interval, not the point estimate.** `E-003` lost an effect from p = 0.023 to
p = 0.070 on one run of control drift. Here the control is the same overlay that produced the
transferred spread, so the drift risk is the CLI move from `2.1.267` to `2.1.272` — which is why
the control is re-run rather than reused, and why the transferred numbers set the *limit* and the
batch's own control sets the *verdict*.

| the prediction says | what tests it | what a null means |
|---|---|---|
| P1 *"10 of 10 treated, 0 of 10 control"* | one-arm, per arm | **row 0, void before scoring** if it fails either half |
| P2 *"zero blocks"* | one-arm binomial on `k = 0` | a single block refutes it |
| P3, P4, P5 *"the arms differ"* | two-arm against the control that **occurred** | inside the MDE → **not detectable**, never "no regression proved" |

## Deterministic evaluation

`BE-003-confirm-shipment`'s own evaluator at benchmark `eea144ef940f`, evaluator version `1.0.0`, exit-code
contract unchanged. `./tools/check-run-gate.sh` admits a run to scoring; a run it refuses is not
scored, in either arm. **The evaluator decides, not the agent — and not this stop's completion
contract**, which is a second, separate reading and enters no gate.

## Exclusions

Registered **now**:

- `F13` / `F15` infrastructure aborts, either arm.
- Any run whose `runtime.version` is not `2.1.272 (Claude Code)` or whose `runtime.model` is not
  `claude-haiku-4-5-20251001`, read from the record.
- Any treated run failing **either half of P1** — that is **row 0, void before scoring**, exactly
  as E-007 registered and as decision 11 item 9 repeats.
- Duration on any run that spans a machine sleep: **duration is excluded, the run is not.**
- **Not excluded:** a run whose `totalRepairAttempts` is high. That is the measurement.

## Decision rule

Registered before data. The rows are exhaustive; cost is its own row and never a second
condition on a failure row.

| # | condition | verdict |
|---|---|---|
| 0 | P1 fails either half on 2 or more treated runs | **VOID** — the treatment is not proved delivered, and nothing else in the file is read |
| 1 | P1 holds and the treated arm's evaluator pass rate is **5 or more runs below** the control's | **REJECT** — v1.1 regresses the gate it was built to protect |
| 2 | P1 holds, pass rates within the MDE, and **any** rubric category median moves by ≥ 1 point in the **worse** direction | **REJECT on quality** |
| 3 | P1 holds, P3 and P4 inside their MDEs, and every secondary inside its MDE | **KEEP AS L2, WITH NO MEASURED EFFECT** — v1.1 closes, is not promoted, and the null is the result |
| 4 | P1 holds, P3 and P4 inside their MDEs, and any secondary **outside** its MDE in the worse direction | **INCONCLUSIVE** — named, with which secondary and by how much |
| 5 | Row 3 or 4 holds **and** `estimatedCost` is outside its MDE in the worse direction | **plus: REJECT on cost**, recorded beside the row above, never instead of it |
| 6 | Any rubric category median moves by ≥ 1 point in the **better** direction with P3 holding | **IMPROVED** — and it is reported with the warning that B8's treatment has no mechanism by which it should, so a positive here is first a reason to check the delivery proof |
| 7 | `repair-limit.sh` blocks on **1 or more** runs | **P2 refuted** — recorded, and it does not by itself move rows 0–6; the block's fingerprint and the run id are reported |

**Useless-and-cheap is still a rejection** — row 5 is separate from rows 3 and 4 for that reason.
**And `KEEP AS L2, WITH NO MEASURED EFFECT` is the expected verdict**, on the same evidence the
Hypothesis cites. It is not a disappointment; B7 closed on that row and the track is better for it.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

Batch `20260915T182436Z`, driver [`evidence/b08/run-b8-batch.sh`](../evidence/b08/run-b8-batch.sh),
manifest `evidence/b08/batch-20260915T182436Z/manifest.tsv`. **All twenty BE-003 runs executed
between `18:24:37Z` and `19:21:00Z` on 2026-09-15 — before the clamshell sleep that split the
BE-004 arm. This arm is uncontaminated by it.**

**Timestamp check, from git and the run records rather than from prose:** prediction commit
`5d7bfe0` at **`2026-09-15T14:31:03Z`**; first run `startedAt` **`2026-09-15T18:24:37Z`**. The
prediction precedes the runs by 3 h 53 m.

| | treated (`agent-v1.1`) | control (`verify-v1.0`) |
|---|---|---|
| runs | 10 | 10 |
| F13 / F15 aborts | 0 | 0 |
| evaluator exit 0 | **10 / 10** | **10 / 10** |
| run-state file | **PRESENT 10 / 10** | **ABSENT 10 / 10** |
| `check-run-state.sh` | exit **0** on all 10 | n/a — no file to validate |
| `customization.instructionsHash` | `sha256:a94237242e8c1308fb1d434a06a03463`, **one distinct value** | **`null`, one distinct value** |
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` | **identical** |
| `runtime.version` / `runtime.model` | `2.1.272 (Claude Code)` / `claude-haiku-4-5-20251001` | identical |
| `init` read-back (decision 8) | `n=4 ["Read","Edit","Write","Bash"]` / `verdict=match` | identical |
| `totalRepairAttempts` | `[0 ×10]`, median **0** | `[0 ×10]` |
| `repair-limit` `block` decisions | **0** | — |
| hook executions | **48 PreToolUse / 47 PostToolUse** | 0 / 0 |
| `estimatedCost` median | `$0.119766` [`0.102048`–`0.144211`] | `$0.116974` [`0.101403`–`0.140168`] |
| `modelCalls` median | 19 [17–22] | 21 [17–26] |
| `changedFiles` / `addedLines` median | 3 / 78 | 3 / 75 |
| `durationMs` median | 111 000 ms | 110 000 ms [97 000–151 000] — **reported, no verdict** |

**`durationMs` and `changedFiles` were `null` in the manifest** — the driver read them at the top
level of the run record and they live at `.efficiency.durationMs` and `.result.changedFiles`. They
are re-derived from the 44 saved run records by
[`evidence/b08/rederive-null-columns.sh`](../evidence/b08/rederive-null-columns.sh), 44 read and 0
unreadable. The manifest keeps its nulls; nothing was overwritten.

## Results

**Rubric, codex `gpt-5.6-sol`, rubric sha `396e1799eb2b` read back from all 20 sheet headers.**
Sheets: `evidence/b08/scoring-20260916/category-values.tsv`, one per run, no duplicates, exit 0 on
all 20.

| category | treated `n=10` | control `n=10` | median delta |
|---|---|---|---|
| architecture-consistency | `[2 ×10]` → **2** | `[1, 2 ×9]` → **2** | **0** |
| maintainability | `[0 ×7, 2 ×3]` → **0** | `[0 ×7, 2 ×3]` → **0** | **0** |
| test-quality | `[1 ×9, 2]` → **1** | `[1 ×9, 2]` → **1** | **0** |
| change-focus | `[1 ×10]` → **1** | `[1 ×10]` → **1** | **0** |

**Three of the four distributions are not merely equal in median — they are identical multisets.**
The fourth differs by a single run.

**The MDE, re-derived from this batch's own control as registered**
([`evidence/b08/scoring-20260916/mde-rederived.md`](../evidence/b08/scoring-20260916/mde-rederived.md)):

| outcome | transferred MDE | re-derived MDE | observed delta | reading |
|---|---|---|---|---|
| `estimatedCost` | $0.045 (30 %) | **$0.0163 (13.6 %)** | **+$0.0028** (+2.4 %) | inside → not detectable |
| `modelCalls` | 6 (29 %) | **3.04 (14.5 %)** | **−2.0** | inside → not detectable |
| rubric categories | one full point | one full point (the scale's floor) | 0 on all four | inside → not detectable |

**The re-derived limits are tighter than the transferred ones**, so the null is not an artefact of a
generous limit.

## Which predictions held

| | prediction | outcome |
|---|---|---|
| **P1** | 10/10 treated carry the run-state file, 0/10 control | **HELD, both halves.** Decision-rule row 0 does not fire and the experiment is readable |
| **P2** first half | zero `block` decisions across all treated runs | **HELD**, `k = 0` |
| **P2** second half | `totalRepairAttempts` median **0** on BE-003 | **HELD** — 0 on all ten runs, not merely at the median |
| **P3** | pass rates equal or differing by at most one run | **HELD** — 10/10 against 10/10, a difference of zero |
| **P4** | all four category medians equal, delta 0 | **HELD** — and reported as *not detectable*, never as "identical", exactly as P4 registered. Three distributions are in fact identical multisets |
| **P5** | cost rises, +2 % to +8 %, and the band sits inside the MDE | **HELD in direction and size** — observed **+2.4 %**, inside the predicted band and inside the re-derived MDE. P5 registered itself as *undecidable by this experiment on purpose*; it is |
| **P6** | the completion contract changes nothing in-run because it does not execute in one | **HELD by construction** — no `Stop`-class hook exists, both arms identical with respect to it |

**Every registered prediction held on this task.** That is worth one caution rather than
satisfaction: six of the seven predict *no difference*, and an instrument that finds no difference
is consistent both with a treatment that does nothing and with an instrument that cannot see. The
re-derived MDE is what separates those, and it is the tighter of the two available limits.

## Failure analysis

**Nothing failed on this task.** No F13, no F15, no evaluator non-zero, no gate refusal, no run
excluded. All twenty runs are in the scored population.

**One thing is visible here that no previous stop could see: 48 `PreToolUse` allows against 47
`PostToolUse` successes across the treated arm.** `PostToolUse` fires if and only if the command
exited 0 (measured at `evidence/b08/hook-event-probe-…`, 6 of 6 successes and 0 of 6 failures,
Fisher `p = 0.0022`). So **exactly one `Bash` command failed across ten runs that the evaluator
scored 10/10 at exit 0**, and the model retried nothing — `totalRepairAttempts` is 0 on every run.

That single failing command is not a result: it is `n = 1`, it is reported as a count and not as a
rate, and no comparison is computed from it. It is recorded because it is the first direct evidence
this project has that the success oracle sees something the evaluator, the telemetry and every hash
cannot.

## Sanity checks

**The checklist below was registered BEFORE the run and is restored here verbatim, ticked from
evidence.** An earlier revision of this section replaced it with the table that follows; that was a
mistake — a pre-registered checklist is a commitment, and replacing it with a prettier table written
after the fact removes the commitment and keeps only the answer. *Restored by Opus 5, 2026-09-16.*

<!-- pass OTLP_GRPC_PORT and check events.jsonl grows before trusting a telemetry-sourced
     number -- the stop-11 rule -->
- [x] prediction commit timestamp vs first run `startedAt` — both written here verbatim:
      `5d7bfe0` at `2026-09-15T14:31:03Z`, first run `2026-09-15T18:24:37Z`
- [x] `customization.instructionsHash` differs between arms and matches the two overlays' shas —
      `sha256:a94237242e8c1308fb1d434a06a03463` on 10/10 treated, `null` on 10/10 control
- [x] `runtime.model` and `runtime.version` identical across all runs, read from the record —
      single distinct value each across all 20
- [x] benchmark revision identical across all runs — `eea144ef940f`
- [x] one scored cell re-read by hand off a kept worktree, its value written beside the sheet's —
      `change-focus` on `6e5cac9b`: hand **1**, sheet **1**, committed at `8c56ba8` before any sheet
- [x] **the kept worktrees are copied somewhere durable the day they are made** — `$TMPDIR` on this
      machine empties a worktree's files in about three days and leaves the directory, so `ls -d`
      passes on a hollowed one. The decision-11 census returned **no reading** because all 54 BE-004
      worktrees had been emptied before it opened. This box is here because that already happened.
      **Done the same day by the driver itself**: 44 worktrees under `evidence.local/b08-worktrees/`
      (1.1 GB) and the small artefacts under the committed `evidence/b08/worktrees/`.
- [x] telemetry was checked before being trusted — `modelCalls` and `estimatedCost` are populated on
      all 40 runs; the OTLP endpoints were asserted `200` by the driver before the first run

| check | how | outcome |
|---|---|---|
| prediction precedes every run | `git show 5d7bfe0` against the first `startedAt` | **3 h 53 m** ahead |
| one variable moved between arms | `agentHash`, `runtime.version`, `runtime.model`, `init` read-back all single-valued **across both arms** | only `instructionsHash` and the two `Bash` hooks differ |
| the treatment reached the model | `instructionsHash` = registered sha on 10/10 treated | held |
| the treatment stayed out of the control | `instructionsHash` `null` on 10/10 control; `verify-v1.0` carries no `CLAUDE.md` | held |
| the scorer is the registered one | `model:` and `rubric_sha:` read back from all 20 sheets | `gpt-5.6-sol`, `396e1799eb2b`, single-valued |
| a hand re-read precedes the sheets | [`evidence/b08/hand-rereads-20260916/BE-003-change-focus-6e5cac9b.md`](../evidence/b08/hand-rereads-20260916/BE-003-change-focus-6e5cac9b.md), committed at `8c56ba8` before any sheet existed | hand **1**, sheet **1** — agree |
| the batch avoided the machine sleep | driver run-start headers against `pmset -g log` | all 20 finished **27 minutes before** the lid closed |

**The hand/sheet agreement is reported without being leaned on.** Both readers can be downstream of
the same ambiguous anchor text, and the hand re-read recorded in advance that a defensible reading
of that anchor gives 2. Agreement on a value is not agreement that the anchor determines it.

## Decision

**`KEEP AS L2, WITH NO MEASURED EFFECT` — decision-rule row 3, the registered expectation.**

Rows 0, 1, 2, 4, 5, 6 and 7 are each checked and none fires: P1 held so row 0 is out; pass rates are
equal so row 1 is out; no category median moved in either direction so rows 2 and 6 are out; every
secondary is inside its re-derived MDE so rows 4 and 5 are out; zero blocks so row 7 is out.

**v1.1 closes on BE-003 with no regression and no measured improvement, and the null is the
result.** The run-state file and the repair-limit hook are **L2** — they execute, they are proved to
execute on 10 of 10 treated runs by an artefact that exists if and only if the hook ran, and
`check-run-state.sh` refuses a malformed one. The completion contract remains **L3** at this stop:
it decides seven clauses over a finished worktree at scoring time and no `Stop`-class hook runs it,
which P6 registered in advance rather than leaving as an omission.

**This is the same row B7 closed on, and the track is not worse for it.** What B8 bought is not a
measurable behaviour change but a per-run artefact that can see a failing command — which is how
the 48/47 gap above became visible at all.

## Follow-up

- **The 48/47 gap deserves a measurement of its own.** One failing command in ten runs, retried
  zero times, is a rate nobody has estimated. It needs its own registered prediction, not a
  retrospective read of this batch.
- **`totalRepairAttempts` has now been measured and is 0 everywhere on this task.** A counter whose
  observed range is a single value across 20 runs is a candidate for removal under §4 step 10 on
  BE-003 alone — but it is retained, because BE-004 produced a non-zero value and the two tasks are
  separate experiments by decision 9.
- **Pre-registered before the run, and still true:** the in-run completion contract (a `Stop`-class
  hook) is **not built at this stop** and is named here so it is not mistaken for something this
  experiment measured. P6 tested exactly that and held.
- **Pre-registered before the run, and now with a number behind it:**
  `customization.hooksHash` is declared and never computed. An additive instrument PR that hashes
  the overlay's `.claude/settings.json` and `.ai/hooks/*` the way `skills_hash` hashes `SKILL.md`s
  would make P1's assertion a hash rather than an artifact. It is the builder's merge under §4
  step 14 and it does **not** gate this step, because a schema field is not a control until a run
  record shows it written. **This batch is the argument for it:** P1 was proved 20 times over by an
  artefact rather than a hash, and that worked — but it only works for a treatment that writes a
  file, and the next overlay may not.
- The BE-004 arm's `change-focus` instability
  ([`evidence/b08/scoring-20260916/change-focus-scorer-defect.md`](../evidence/b08/scoring-20260916/change-focus-scorer-defect.md))
  does **not** appear on this task: `change-focus` is `1` on twenty of twenty runs here. BE-003's
  stability is the evidence that such an anchor set can be stable on this scorer.

