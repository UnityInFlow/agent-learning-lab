# Experiment E-019 — run state, repair limits and a completion contract — v1.1 against v1.0 on BE-004

**Key:** `EXP-B8-RUNSTATE-BE004` · **Spine stop 17 (B8)** · **Task: BE-004-cancel-order** · **Version: v1.1 closes here**

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-15T16:3xZ; the author did not review before the run.`

> Everything down to and including **Predictions** is written and committed **before the first
> run**. The commit timestamp and the first run's `startedAt` are written back into §Sanity
> checks after the batch, as `E-001`'s nine voided runs require.

## Question

Does the **v1.1 overlay** — persistent run state, a hard repair limit enforced by a `PreToolUse`
hook, and a completion contract that a script decides — **cost anything measurable** against
**v1.0 as it closed at B7**, on BE-004-cancel-order?

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
   decisions (one-arm binomial, `k = 0`). On BE-004, `totalRepairAttempts` has median **at least 1**. *Mechanism:* the counter counts **failing
   commands**, not failing runs, and **nobody in this project has ever counted failing commands** —
   the evaluator sees only the end state. BE-004 is five files across modules with two evaluator-owned suites, and a first-compile or first-test failure there is ordinary and entirely invisible to an evaluator that only reads the end state. **This is the prediction registered as most likely to be wrong**, and it is the only row in this file that reports a quantity no one has ever measured.
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
   The transferred detection limit is ****$0.030 (13 %)****, so **any result inside this predicted band is
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
| Preflight assertion | one treated run under `EXP-B8-RUNSTATE-BE004-PREFLIGHT`: the run-state file exists and names that run's worktree; its `hookExecutions` line for `repair-record` is present; `customization.instructionsHash` is non-null and equals the overlay `CLAUDE.md`'s sha; and the `init` read-back per **author decision 8** shows `Bash` in the delivered tool set — because a `Bash` matcher that never sees a `Bash` call proves nothing |
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
- [x] task + revision — BE-004-cancel-order, unedited
- [x] harness + version — `claude` **`2.1.272 (Claude Code)`**, read back from `runtime.version` on every run, not from the flag
- [x] model — **`claude-haiku-4-5-20251001`**, exact id
- [x] permissions / permission mode — identical in both arms; **no `permissions.deny` anywhere**, which stop 16 showed is not a boundary (arm D changed 2, 3, 3, 4 and 13 files through one)
- [x] environment — `ISOLATE_USER_SETTINGS=1`, confirmed by **observing** `customization.*Hash` and hook executions on the record, not by trusting the flag
- [x] runner commit — `agent-observatory` `main` at **`1376a2eef553`**
- [x] scorer — codex, registered rubric **`6252778b8472`**; opencode/`deepseek-v4-pro` as second reader only

## Runs

Repetitions per arm: **10** · Total budget: **≈ $5**

Plus one preflight **pair** under `EXP-B8-RUNSTATE-BE004-PREFLIGHT`, which enters no `n` and no comparison.

Interleaved, not blocked: treated and control alternate, so a mid-batch machine or CLI change
lands in both arms rather than in one.

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Transferred, and labelled as transferred.** There is no stored population for v1.1, and the
control arm of this experiment *is* the reference population — but it does not exist until the
batch runs. So the limits below are carried from the **v1.0 arm of `E-016`**, which is the same
overlay this experiment uses as its control, and are **re-derived from this batch's own control
before any verdict is written**. Decision 11 item 10 prescribes exactly this for a task with no
stored population; E-016 did it at `n = 7`.

Formula, the same one E-015 and E-016 used: `MDE ≈ 2.8 · sd · sqrt(2/n)`.

| Outcome | measured spread it comes from | MDE at `n = 10` | registered before the run? |
|---|---|---|---|
| primary: weighted rubric total, codex, rubric `6252778b8472` | `E-016`'s **v1.0 (treated) arm** — this experiment's control overlay — at architecture-consistency 2, maintainability 0, test-quality 1, change-focus 0, **identical to its plain control on all four** (`E-016:480-483`, every delta 0); categories are integers 0–2 | **one full category point** — the scale's own floor; nothing smaller is representable | yes |
| primary: evaluator pass rate | `E-016`: control 7 of 7 and treated 7 of 7 exit 0 (`E-016:392`) | a difference below **5 runs** does not clear Fisher at `n = 10` | yes |
| secondary: `estimatedCost` | the spread `E-016` registered **its own** MDE from (`E-016:139-146`): mean $0.2393, sd $0.02431, `n = 10`; its v1.0 arm's median was $0.210563 [$0.195457–$0.242610] (`E-016:388`) | ****$0.030 (13 %)**** | yes |
| secondary: `modelCalls` | `E-016:139-146`: mean 29.0, sd 3.266, `n = 10` | **4.09 calls (14 %)** | yes |
| secondary: `durationMs` | `E-016` control median 190 000 ms, range 180 000–1 084 000 ms | **no verdict is taken from duration** — the range spans a factor of 6 and a machine sleep is not excludable after the fact | yes |
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

`BE-004-cancel-order`'s own evaluator at benchmark `eea144ef940f`, evaluator version `1.0.0`, exit-code
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

<!-- pass OTLP_GRPC_PORT and check events.jsonl grows before trusting a telemetry-sourced
     number -- the stop-11 rule -->

Batch `20260915T182436Z`. Prediction commit `5d7bfe0` at **`2026-09-15T14:31:03Z`**; first BE-004
run `startedAt` **`2026-09-15T19:21:40Z`**, 4 h 50 m later.

**This arm was split by a clamshell sleep and that is stated before any number.** The lid closed at
`2026-09-15T19:48:55Z`, 48 seconds after `BE-004 04 control` started; the machine cycled
Sleep/DarkWake until the lid opened at `2026-09-16T06:59:36Z`. Seven runs (`01`–`04` treated,
`01`–`03` control) are pre-sleep; the rest are not. Evidence:
[`evidence/b08/sleep-2026-09-15/pmset-and-run-starts.txt`](../evidence/b08/sleep-2026-09-15/pmset-and-run-starts.txt).

| | treated (`agent-v1.1`) | control (`verify-v1.0`) |
|---|---|---|
| runs made | 10 | 10 |
| **F13 `api_error` aborts** | **0** | **3** — seq `04`, `05`, `10`, each with 0 edits |
| evaluator exit 0 | **9 / 10** — seq `08` returned **11** | **7 / 7** of the non-F13 runs |
| gate-admitted for scoring | **9** | **7** |
| run-state file | **PRESENT 10 / 10** | **ABSENT** on all 7 scored; `INCONCLUSIVE-0-edits` on the three F13 runs |
| `customization.instructionsHash` | `sha256:a94237242e8c1308fb1d434a06a03463`, one distinct value | **`null`**, one distinct value |
| `agentHash` / `runtime.version` / `runtime.model` | one distinct value each | **identical to treated** |
| `init` read-back | `n=4 ["Read","Edit","Write","Bash"]` / `match` | identical |
| `totalRepairAttempts` (admitted) | `[0 ×8, 1]`, median **0** | `[0 ×7]` |
| `repair-limit` `block` decisions | **0** | — |
| hook executions (admitted) | **54 / 54**, gap **0** | 0 / 0 |
| `estimatedCost` median | `$0.209355` [`0.195181`–`0.257077`] | `$0.200527` [`0.191364`–`0.208626`] |
| `modelCalls` median | 28 [27–38] | 28 [25–32] |
| `changedFiles` / `addedLines` median | 7 / 190 | 7 / 204 |
| `durationMs` median | 187 000 ms | 167 000 ms — **reported, no verdict**; this arm crossed a sleep |

**The three F13 runs are excluded by registration, not by choice after the fact**, and they are
**not topped up**. E-016 reported at `n = 7` on the same reasoning, and picking a replacement after
seeing which arm lost one is a choice the data would then contain.

## Results

**Rubric, codex `gpt-5.6-sol`, sha `6252778b8472` read back from all 16 sheet headers.**

| category | treated `n=9` | control `n=7` | median delta |
|---|---|---|---|
| architecture-consistency | `[2 ×9]` → **2** | `[2 ×7]` → **2** | **0** |
| maintainability | `[0 ×8, 1]` → **0** | `[0 ×7]` → **0** | **0** |
| test-quality | `[1 ×7, 2 ×2]` → **1** | `[1 ×4, 2 ×3]` → **1** | **0** |
| **change-focus** | `[0, 1 ×4, 2 ×4]` → **1** | `[0 ×4, 1, 2 ×2]` → **0** | **+1** |

**MDE re-derived from this batch's own control, `n = 7`**
([`evidence/b08/scoring-20260916/mde-rederived.md`](../evidence/b08/scoring-20260916/mde-rederived.md)):

| outcome | transferred | **re-derived** | observed delta | reading |
|---|---|---|---|---|
| `estimatedCost` | $0.045 (30 %) | **$0.0089 (4.5 %)** | **+$0.0088** (+4.4 %) | **inside by $0.0001** |
| `modelCalls` | 6 (29 %) | **3.39 (12.2 %)** | 0 | inside |

**The cost row clears by one ten-thousandth of a dollar, and the three lost runs are why.** At
`n = 10` the same control spread gives an MDE near `$0.0074` and the observed `+$0.0088` would sit
**outside** it. The F13 exclusions did not only shrink the sample; they moved this row from
detectable to not detectable. The registered rule reads the population that occurred, and P5's own
band (+2 % to +8 %) contains the observed +4.4 % — but this is the first thing a clean re-run would
settle.

### The `change-focus` delta is not a result, and the evidence is in the diffs

Full analysis:
[`evidence/b08/scoring-20260916/change-focus-scorer-defect.md`](../evidence/b08/scoring-20260916/change-focus-scorer-defect.md).

- The full-arm exact permutation test gives **`p = 0.2378`** (11 440 labellings). The arms are not
  separated.
- Stratified by the sleep, **the direction reverses**: pre-sleep the *control* scores higher
  (medians 2 vs 1); post-sleep the treated does (2 vs 0). A treatment effect does not change sign
  when a laptop lid shuts.
- The sleep cannot be acting on the scorer — **all 36 sheets were produced in one 25-minute window
  on 2026-09-16**, long after every run finished.
- So the runs were compared directly. **Six control runs, three scored `2` and four scored `0`,
  have identical hunk contexts in both controllers, no deletions in `src/main`, no hunk inside any
  unnamed method, and one added method each.** A `2`-scoring run and a `0`-scoring run open with
  byte-identical additions.
- Against the anchors, **neither value is supportable**: anchor 0 needs *two or more* unnamed
  methods to differ and **zero do**; anchor 2 needs nothing beyond a closed list and **every run
  adds a constructor parameter that is not on it**. The supported value is anchor 1 for all six.
  **The scorer returned 1 on none of them.**
- And it is specific to this rubric: on BE-003, `change-focus` is **`1` on twenty of twenty runs**.

## Which predictions held

| | prediction | outcome |
|---|---|---|
| **P1** | run-state file on 10/10 treated, 0/10 control | **HELD.** PRESENT on 10 of 10 treated; ABSENT on all 7 scored controls. Row 0 does not fire |
| **P2** first half | zero `block` decisions | **HELD**, `k = 0` across all treated runs |
| **P2** second half | `totalRepairAttempts` median **≥ 1** on BE-004 | **REFUTED.** Median **0**; one run of nine reached 1. **The prediction is not edited** (§4 step 12) |
| **P3** | pass rates equal or differing by at most one run | **HELD** — treated 9 of 10, control 7 of 7 non-F13: a difference of **one run**. Row 1 needs five |
| **P4** | all four category medians equal, delta 0 | **REFUTED AS MEASURED** on `change-focus` (+1); held on the other three. The refutation rests entirely on the cell shown above to be undetermined by its own anchors, and that attribution is recorded rather than used to rescue the prediction. P4 is not edited |
| **P5** | cost +2 % to +8 %, inside the MDE | **HELD in direction and size** — +4.4 %, inside the predicted band; inside the re-derived MDE **by $0.0001** |
| **P6** | the completion contract changes nothing in-run | **HELD by construction** — no `Stop`-class hook exists |

**P2's second half was registered in advance as the row most likely to be wrong, and it was wrong.**
That is the most useful outcome in this file. The mechanism is on record from the preflight, written
before the batch: the BE-004 preflight run failed two `Bash` commands and **retried neither**, so a
counter of *repeat attempts at the same fingerprint* stays at 0 while commands are still failing.
The batch confirms it at `n = 9`: 54 `PreToolUse` against 54 `PostToolUse` on the admitted treated
runs — every command succeeded — with one run reaching `totalRepairAttempts = 1`.

## Failure analysis

**Four runs left the scored population, and they are not one thing.**

| run | seq / arm | exit | why | excluded? |
|---|---|---|---|---|
| `2ebaa773` | 04 control | 12 (`F03`) | **F13 `api_error`**, 0 edits | **yes**, by registration |
| `80b21210` | 05 control | 12 (`F03`) | **F13 `api_error`**, 0 edits | **yes**, by registration |
| `00b6ccbb` | 10 control | 12 (`F03`) | **F13 `api_error`**, 0 edits | **yes**, by registration |
| `ebf9e05e` | 08 **treated** | **11 (`F05`)** | **a real failure** — see below | **not** an exclusion; it is the measurement |

**`ebf9e05e` is the first evaluator failure BE-004 has ever produced on this model.** The workspace
`CLAUDE.md` records 9 of 9 before stop 12, 10 of 10 in every arm at B5 and B6, 7 of 7 in both arms
at B7. Exit **11** is `F05`, and in this evaluator that is **AC2 — the repository's own baseline
tests, with the agent's tests stashed out** (`evaluator.sh:171-181`), a design that exists precisely
to stop test-first work being scored as breakage. So this is a genuine regression of pre-existing
behaviour, not a harness artefact.

**And the oracle says something about it that nothing else can: `hooks 10/10` on that run.** Every
one of its ten `Bash` commands exited 0. It never ran the suite it broke. No evaluator field, no
telemetry counter and no hash records that; the gap between `PreToolUse` and `PostToolUse` is the
only place it appears.

**It is one run.** It is reported as a count, it enters the pass-rate row as the failure it is, and
no rate, mechanism or property is claimed from it (§5, `n < 5`).

**The three F13 controls all fall inside the sleep window**, which is recorded as a co-occurrence
rather than a cause: an `api_error` is a dropped connection, a sleeping machine drops connections,
and three of three landing there is consistent with that — but three events cannot establish it.

## Sanity checks

- [x] prediction commit timestamp vs first run `startedAt` — `5d7bfe0` at `2026-09-15T14:31:03Z`;
      first BE-004 run `2026-09-15T19:21:40Z`
- [x] `customization.instructionsHash` differs between arms and matches the two overlays' shas —
      registered sha on 10/10 treated, `null` on 10/10 control
- [x] `runtime.model` and `runtime.version` identical across all runs, read from the record —
      one distinct value each across all 20
- [x] benchmark revision identical across all runs — `eea144ef940f`
- [x] one scored cell re-read by hand off a kept worktree, its value written beside the sheet's —
      `change-focus` on `b33a8233`: hand **2**, sheet **2**, committed at `d845bc6` **before any
      sheet existed**. The agreement is reported and **not leaned on**: the hand reader recorded, in
      advance, that the anchor does not determine the value, and the scorer's own scatter across six
      equivalent runs is the demonstration
- [x] **the kept worktrees are copied somewhere durable the day they are made** — done by the driver
      itself the same day: 44 under `evidence.local/b08-worktrees/`, small artefacts committed under
      `evidence/b08/worktrees/` — `$TMPDIR` on this
      machine empties a worktree's files in about three days and leaves the directory, so `ls -d`
      passes on a hollowed one. The decision-11 census returned **no reading** because all 54 BE-004
      worktrees had been emptied before it opened. This box is here because that already happened.

## Decision

**`KEEP AS L2, WITH NO MEASURED EFFECT` on the three measurable categories — decision-rule row 3 —
and `change-focus` recorded as UNMEASURABLE. Row 6 is declined, with reasons, and the declining is
itself reported.**

**Row 6's condition is met as written**: *"Any rubric category median moves by ≥ 1 point in the
better direction with P3 holding → IMPROVED"*. `change-focus` moved +1 and P3 held. **I am not
recording `IMPROVED`**, and the grounds are not judgement but evidence:

- the cell it reads is demonstrably not determined by its own anchors — six structurally identical
  runs scored `2,2,0,0,0,0`, and the one value the anchors support was returned on none of them;
- the arms are not separated by an exact permutation test (`p = 0.2378`);
- the direction reverses at a laptop lid closing.

**Row 6 anticipated exactly this and is the reason it is declinable:** it was registered with the
clause *"a positive here is first a reason to check the delivery proof"*, because B8's treatment has
no mechanism by which it should improve a rubric score. The delivery proof is sound — P1 held 10/10
— so the check moved to the measurement, and the measurement is where it failed.

**The gap this exposes is in the decision rule, not in the result.** Rows 0–7 have a row for *the
treatment was not delivered* (row 0) and none for *the instrument did not measure*. A rule with no
such row forces a choice between reporting an effect nobody believes and silently ignoring a row
that fired. **This is recorded as a defect in E-019's own decision rule, discovered by running it**,
and it is the kind of thing only a registered rule can expose — an unregistered one would have been
quietly adjusted.

**What a validator should check first:** open
`evidence/b08/scoring-20260916/change-focus-scorer-defect.md`, take any two of the six control runs
named there — one scored 2 and one scored 0 — and diff them against each other. If they differ in a
way anchor 0 or anchor 2 names, this decision is wrong and `IMPROVED` should stand.

**v1.1 closes on BE-004 with no regression** (P3 held; the one genuine failure is within the
one-run tolerance registered before the run) **and no credible improvement.**

## Follow-up

- **BE-004's `change-focus` anchors are the instrument to fix**, not the category: BE-003's are
  stable at `n = 20` on the same scorer. The fix moves rubric sha `6252778b8472`, which four
  experiments cite, so it is an author decision at a version boundary and **not** a change this
  stop may make (§6).
- **A clean BE-004 re-run under a new experiment key would settle two rows at once** — the cost row
  that clears its MDE by `$0.0001` only because `n = 7`, and whether `change-focus` scatters again
  on a rubric nobody has touched. About $4 and 80 minutes. It is **not** done here: the population
  that occurred is what the registered rule reads, and re-running an arm because its result was
  inconvenient is the thing this project does not do. It is offered to the author as a decision.
- **`totalRepairAttempts` has now been measured on both tasks** — 0 on all 20 BE-003 runs, median 0
  with a single 1 on BE-004. The quantity is real and the counter works; what P2 got wrong was the
  rate at which this model repeats a failed command, which is apparently near zero.

- The in-run completion contract (a `Stop`-class hook) is **not built at this stop** and is named
  here so it is not mistaken for something this experiment measured.
- `customization.hooksHash` is declared and never computed. An additive instrument PR that hashes
  the overlay's `.claude/settings.json` and `.ai/hooks/*` the way `skills_hash` hashes `SKILL.md`s
  would make P1's assertion a hash rather than an artifact. It is the builder's merge under §4
  step 14 and it does **not** gate this step, because a schema field is not a control until a run
  record shows it written.
