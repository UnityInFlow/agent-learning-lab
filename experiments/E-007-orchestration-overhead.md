# Experiment E-007 — orchestration overhead on a task too small to split

**Stop:** 11 (Phase 4B, Lab 4B.4) · **Workbook:** [`phases/04b-orchestration/README.md`](../phases/04b-orchestration/README.md)
**Experiment key:** `EXP-4B-ORCH-OVERHEAD` · **Benchmark:** BE-003 · **Agent under test:** `claude-haiku-4-5-20251001`
**Status:** **CLOSED — verdict `NOT DETECTABLE` (decision rule row 4).** 20 runs complete and
gate-admitted · **O1, O5 and O6 held; O2 REFUTED in the opposite direction; O3 and O4 below their
registered thresholds; O7 = 4 of 10, one outside its registered band and far inside its MDE.**

> **Corrected 2026-09-06 by the autonomous run. Attribution:
> `findings/track-b-validation-2026-09-06-3.md` (validator pass 16, claude-fable-5-1),
> correction 3.** Until this edit the Status line above read:
>
> > *"**O7 BLOCKED and the exit gate with it** — the observatory database was destroyed before
> > scoring; see § The database loss"*
>
> Both halves of that sentence were false by the time the file was merged, and both had already
> been retracted **lower down in this same file** — § *The database loss* opens with a
> `RETRACTED IN FULL` block (there was no loss; the halting session read a second, empty docker
> context) and § *O7, measured* carries O7 at 4 of 10 with the verdict computed. **Only the
> summary a reader hits first was left claiming less than the detail beneath it** — pass 13's
> correction 13.2 in a different file, and the third time this run has been corrected on that
> exact shape. Nothing beneath this line is edited; the retraction blocks stay where they are.
> *Corrected by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.*

`Predicted by Claude Fable 5.1 (claude-fable-5-1), autonomously, 2026-09-06T05:2xZ (see the commit
for the exact time); the author did not review before the run.` Written after the §4 step 2 probe
(`evidence/p04b/lab-4b4/probe-20260906T050917Z/`) and before any run on the experiment key.

## Question

On BE-003, what does an orchestrator–worker decomposition cost, and what does it return, against
a concurrent plain baseline — with delegation counted from telemetry rather than assumed from
the transcript?

## Hypothesis

Decomposing a three-file, ~70-line change into an orchestrator that cannot write and a worker
that can costs more tokens, more wall-clock and more tool calls than doing it in one session, and
returns nothing the evaluator or the rubric can see. The mechanism is the one the vendor names:
the split does not reduce what the parent must hold, because the parent holds almost nothing to
begin with; it only adds a second context that re-reads the repository and a summary round trip.

## Predictions

Reference population: E-006 batch 2's **concurrent plain control**, `n = 10`, all exit 0,
2026-09-05T09:50–10:36Z, runtime 2.1.261: `estimatedCost` median **$0.156** (q1 0.139, q3 0.175,
range 0.115–0.192); `durationMs` median **97 s** (85–102, range 68–116); `toolCalls` median
**20** (17–22, range 14–22); `modelCalls` median **22** (20–26); `addedLines` median 69;
`changedFiles` 3 on 9 of 10; `maintainability` anchor 2 on **1 of 10**; evaluator pass **10 of
10**. Re-derived from the API on 2026-09-06T05:05Z, not copied from E-006's prose.

| # | Outcome | Direction · magnitude | Mechanism |
|---|---|---|---|
| **O1** | delegation — `tool_result` events with `tool_name` ∈ {`Task`, `Agent`} per run, from the observatory telemetry | arm O ≥ 1 on **10 of 10**; arm C **0 of 10**; exactly 1 on ≥ 7 of 10 arm-O runs | the orchestrator's delivered pool is `Read, Task, Grep, Glob` (probe, 3 of 3): there is no other route to a diff. Second delegations only on a reported failure. **Registered as least likely to be wrong** |
| **O2** | `estimatedCost` median | **+60 %** on the control median (≈ $0.25); refuted below **+25 %** (the MDE) or above **+150 %** | a second agent with its own system prompt and its own cache prefix re-reads what the first skimmed; cost here is dominated by cached input, and two contexts create two cache prefixes |
| **O3** | `durationMs` median | **≥ +40 %** (≈ 135 s or more) | sequential handoff: the worker starts after the orchestrator has read the ticket, and the summary round trip adds at least one model call at the end |
| **O4** | `toolCalls` median | **≥ +5** (≥ 25), quartiles not overlapping the control's | the worker does roughly the control's work (≈ 20 calls) and the orchestrator adds its own reads |
| **O5** | `modelCalls` median | **≥ +4** (≥ 26) | one orchestrator turn to delegate, one to read the report, one to summarise, plus the worker's own |
| **O6** | evaluator pass rate, arm O | **≥ 8 of 10**, and not lower than arm C by 3 or more | the ticket is passed verbatim by instruction, so the error cases survive the handoff. **Registered as the one most likely to be wrong**: a small orchestrator paraphrases, and BE-003's gate lives in the error cases |
| **O7** | `maintainability` anchor 2 (codex, rubric `396e1799eb2b`) | **1–3 of 10**, no change; only ≥ 9 of 10 would be detectable | nothing in the split touches how the worker writes Kotlin |
| — | `changedFiles`, `addedLines`, `change-focus` | **report only** | `changedFiles` at the floor on 19 of 19 historical controls; `change-focus` = 1 on 70 of 70 scored runs. Not outcomes |

> **Correction, added 2026-09-06 — the report-only row above quotes a count and a word that had
> both already been refuted, and the registered text is kept unedited.** Attribution:
> `findings/track-b-validation-2026-09-06-3.md` (validator pass 16, claude-fable-5-1),
> correction 5.
>
> The row says *"`change-focus` = 1 on 70 of 70 scored runs"* and the workbook's matching line
> calls it *"a dead category"*. **Both are wrong, and both were corrected the day before this
> file was registered.** `E-006 § C2` has the number at **73 of 73** on this model, and it found
> **one `change-focus` = 2** — run `514b094e`, a codex-arm run. So the category is dead **on
> `claude-haiku-4-5-20251001` running BE-003**, which is a fact about a model-and-task pair, not
> a property of the category: a different arm moved it. Pass 13's correction 13.1 amended this
> exact wording in three places on 2026-09-05, and it **re-entered two registered documents on
> 2026-09-06** — here at registration `c21781b`, and at the workbook's outcome list.
>
> **This file already disagrees with itself about it**: § Failure analysis carries *73 runs*
> while the registered row above carries *70 of 70*. The registered row stays exactly as it was
> written — a prediction's premises are not repaired after the fact — and this note is what a
> reader needs beside it. Nothing in O1–O7 depends on the count: `change-focus` is report-only
> by this same row, and it came back **1 on 20 of 20** in both arms.
> *Corrected by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.*

**The gate's number, in the form this task can give it.** If O2 and O3 hold and neither O6 nor O7
improves, then the task size below which decomposition costs more than it returns is **at least
3 files / 69 added lines** (BE-003, `n = 10`) — a lower bound, never a threshold. The threshold
needs a second size and that is BE-004 at stop 12.

## Independent variable

The presence of the `orchestration-4b4-P1` overlay delivered with `--agent orchestrator`. One
directory, two files:

| File | sha256 (prefix) | Layer |
|---|---|---|
| `build/customizations/orchestration-4b4-P1/.claude/agents/orchestrator.md` | `4f2af4ba7f740c33` | `tools:` line **L2** (runtime refuses absent tools by name; observed, stop 9); body **L3** |
| `build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md` | `6096f5ea35383112` | **L3**; no `tools:` key, inherits the session pool (probe, 3 of 3) |

Both `model:` pins are `claude-haiku-4-5-20251001` — L3, observed on 6 of 6 probe streams,
nothing rejects a wrong one.

**Everything else is the plain baseline.** The worker carries a four-line body so that it has a
report shape; it is disclosed that the treatment is *the split including that minimal prose*,
and the deliberate failure at step 9 (variant P2) removes the structural line and keeps the
prose, which is what separates the two.

## How the treatment is delivered — and proved

| | Arm O | Arm C |
|---|---|---|
| Mechanism | `run-agent.sh --customization <overlay dir> --agent orchestrator` — the overlay is copied into the worktree, force-added and committed (author decision 2), the session starts as `orchestrator` | no `--customization`, no `--agent` |
| Delivered schema | `init.tools` per run, checked by `runner/lib/check-init-schema.sh` against `Read, Grep, Glob, Task`; **probe: `["Read","Task","Grep","Glob"]` on 3 of 3** | recorded only; expected the full 29 |
| Activation | O1 — ≥ 1 `Task`/`Agent` event | 0 events |
| Preflight assertion (§4 step 5) | one run on `EXP-4B-ORCH-PREFLIGHT`: `--agent` accepted, schema verdict `matches`, ≥ 1 delegation event, evaluator exit recorded | one run: hashes all `null`, 0 delegation events |
| What cannot be proved from the run record | no `customization.*Hash` field tracks a Claude agent overlay (unchanged since stop 10). Independence rests on the `init` record, the setup commit's tree and the telemetry, as E-006 §5 did |

## Controlled variables

Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`,
Claude Code version, benchmark commit, `evaluator.sh` version 1.0.0, rubric sha `396e1799eb2b`,
`ISOLATE_USER_SETTINGS=1`, `KEEP=1`, `--disable-slash-commands` (no skill is a treatment here),
the runner's flag array, interleaving O/C pairs, no machine sleep, no other benchmark, scorer or
review process running (checked with `LC_ALL=C pgrep` before each pair).

## Runs

**10 O + 10 C, interleaved as pairs, one experiment key.** Preflight pair first on its own key.
Budget ≈ 10 × $0.25 + 10 × $0.16 ≈ **$4.10** plus scoring. Batch driver: a copy of
`evidence/b04/run-e006-armG.sh`'s pair loop (§4 step 4, with its `verify-*.sh` set), not the
bare Makefile target, because the manifest row per run is the progress record.

## Minimum detectable effect

From the reference population above, before any threshold was written:

| Outcome | spread it comes from | MDE at `n = 10` per arm |
|---|---|---|
| O1 delegation | control 0 of 38 (telemetry on file) | Fisher 10/10 vs 0/10: `p = 0.00001`. Anything below 9 of 10 is a delivery failure, not a result |
| O2 cost | control q1–q3 $0.139–0.175 (ratio 1.26) | **≥ +25 %** on the median, as E-003 and E-006 registered |
| O3 duration | control range 68–116 s | **≥ +40 %** on the median and no sleep contamination |
| O4 `toolCalls` | control q1–q3 17–22 | **≥ +5** with non-overlapping quartiles |
| O5 `modelCalls` | control q1–q3 20–26 | **≥ +4** with non-overlapping quartiles |
| O6 pass rate | control 10 of 10 | Fisher 10/10 vs 7/10: `p = 0.21`, **not detectable**; vs 5/10: `p = 0.033`. A drop of 1–2 is reported, not claimed |
| O7 `maintainability` | control 1 of 10 | 9 of 10 → `p = 0.0011`; 6 of 10 → `p = 0.057`, not detectable |

A result inside its MDE is **NOT DETECTABLE at this `n`**, never refuted.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` 1.0.0 decides correctness per run — exit 0 or the
registered non-zero code. Gate-failing runs are reported per arm and not scored.

## Exclusions, registered before the data

1. A run whose evaluator exit code is not 0 is reported per arm (it is O6's numerator) and not
   sent to the rubric.
2. A run whose `runtime.model` is not `claude-haiku-4-5-20251001` is void and reported.
3. An arm-O run whose `init.tools` verdict is not `matches` is **row 0a — void before scoring**
   (author decision 8) and voids the batch's arm O, which is then redesigned, not resumed.
4. Duration only is excluded (never the run) on any run during which another process of this
   lab ran, as the 17:34Z preflight taught.
5. F13 session-limit exits are reported with their count and excluded from every median.

> **Appended 2026-09-06, before the first run on this key — read this before acting on
> exclusion 3.** "Verdict is not `matches`" is resolved to *set* equality, not string equality:
> `order-differs` is admissible and recorded, `mismatch` is row 0a. Full reasoning, both
> readings and the harness move it required: **§ Amendment 2026-09-06** below.

## Decision rule, fixed before the run

| # | Condition | Verdict |
|---|---|---|
| 0a | any arm-O run with schema verdict ≠ `matches`, or O1 < 9 of 10 | **VOID** — the treatment was not delivered; nothing below is read |
| 1 | O2 ≥ +25 % **and** O3 ≥ +40 % **and** O6 not higher than arm C **and** O7 < 9 of 10 | **CONFIRM** — decomposition loses at this size; the gate's lower bound is set |
| 2 | O6 lower than arm C by ≥ 3 | **CONFIRM, stronger reading** — decomposition loses *correctness*; failure analysis classifies each failure handoff-loss / worker-failure by the rule in the workbook |
| 3 | O7 ≥ 9 of 10 in arm O | **REFUTE** — the split returned quality the gate can see; the hypothesis is wrong regardless of cost |
| 4 | O2 < +25 % and O3 < +40 % and nothing improved | **NOT DETECTABLE** — overhead below the instrument's floor; the lower bound is not set |
| 5 | O6 higher than arm C by ≥ 3 | **REFUTE** — the split returned correctness |

Rows 3 and 5 outrank row 1. The hypothesis is confirmed only by row 1 or row 2.

> **Appended 2026-09-06, before the first run on this key.** Row 0a's `≠ matches` is read as
> *set* inequality — see **§ Amendment 2026-09-06** below. Under the strict string reading the
> experiment voids itself on every run of an intact arm, which is why the reading had to be
> settled in writing before the batch rather than discovered in its results.

## Threats to validity, registered before the run

- **The worker's four-line body is prose the control does not have.** It is minimal and it is
  the same on P1 and P2, so step 9's deliberate failure isolates the structural line from it, but
  this batch does not isolate the prose from the split. Disclosed, not worked around.
- **Cost is dominated by cached input tokens** (the sample control: 507 k cached of 534 k). Two
  contexts mean two cache prefixes; O2's mechanism depends on that and it is not independently
  verified before the run. If O2 holds for a different reason the failure analysis says so.
- **Telemetry attribution of the worker's tool calls.** The probe shows the worker's `Write` in
  the parent's *stream*; whether the observatory's `tool_result` events carry the worker's calls
  under the same run id is unverified until the preflight pair. If they do not, `toolCalls` on
  the run record under-counts arm O and O4 is reported with that caveat rather than claimed.
- **Delegation depth.** The worker can itself delegate (docs: three layers). A worker that
  spawns a sub-worker is counted in O1 and reported; it does not void anything.
- **One task, one size.** The gate wants a threshold; this gives a bound. Said in three places.

## Deliberate failure — registered at §4 step 9, not here

Candidate fixed now, prediction written then: variant **P2** — the same overlay with the
orchestrator's `tools:` line removed (`1b259ccc09066cad`), prose intact. The question it asks is
whether an L3 instruction to delegate delegates when nothing structural forces it, which is the
L2-vs-L3 demonstration this stop exists to make.

## Amendment 2026-09-06 — what `matches` means, and the harness move it forced

*Written **before the first run on `EXP-4B-ORCH-OVERHEAD`**, at §4 step 4, by
`Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06`. Nothing above it is rewritten: the
predictions, the MDE table and the decision rule stand at `c21781b` exactly as committed.
No run existed on this key when this was written, and the batch had not started.*

**What was found.** Step 4 begins with the check `next_action` demanded: does
`runner/lib/check-init-schema.sh` compare the declared list as a *set* or as a *list*? It does
both, in that order — exit 0 for an exact match, **exit 6 `order-differs`** for the same set in
a different order, exit 5 `mismatch` for a different set. Run against all three P1 probe
transcripts already on disk, with the shipped overlay as the declaration:

```
evidence/p04b/lab-4b4/probe-20260906T050917Z/P1-{1,2,3}.jsonl
  delivered n=4 ["Read","Task","Grep","Glob"]
  declared  n=4 ["Read","Grep","Glob","Task"]
  verdict=order-differs        EXIT=6      (3 of 3)
```

**Why that was a blocker and not a footnote.** `runner/run-agent.sh` section 12b decided with
`SCHEMA_RC -ne 0` on any arm carrying `--agent`, and exit 9 there means *"the file is not the
treatment, the batch is VOID pending a redesign"*. So **every arm-O run of this batch would
have voided itself**, for a treatment that had arrived with all four tools intact. The caller
was stricter than the check it calls: `check-init-schema.sh`'s own header gives *"VOID,
redesign, do not score"* to exit 5 **alone**, and to exit 6 *"Reported, never silently passed"*.
Nothing executed that would have revealed the disagreement.

**Both readings, written down before the verdict can be computed under either** (the discipline
validator pass 13.3 asked for at stop 10):

| Reading | `matches` means | Consequence for this batch |
|---|---|---|
| **A, strict** | the checker's literal `verdict=match`, exit 0 | every arm-O run is row 0a. The experiment is unrunnable *by construction* and contradicts its own § *How the treatment is delivered*, which registers `["Read","Task","Grep","Glob"]` as the expected observation |
| **B, set equality — ADOPTED** | the delivered **set** equals the declared set; a permutation is recorded, not fatal | arm O stands; the per-run verdict token goes in the manifest and in § Sanity checks; `mismatch`, `no-init-record` and `no-tools-key` remain row 0a |

Reading B is adopted because a `tools:` allowlist is a statement about **capability** — that is
the only thing E-005 ever measured one doing — and a permutation removes no capability. Reading
A is preserved here so a validator can re-derive the choice rather than take it.

**The harness move, disclosed.** Fixing this in the overlay — rewriting its `tools:` line into
the delivered order so the two strings match — was **rejected**: it would make the runtime's
rewriting invisible by construction, which is the defect author decision 8 exists to expose,
not a fix for it. The fix went into the runner instead:

| Artifact | What it is | Layer |
|---|---|---|
| `agent-observatory/runner/lib/schema-verdict-policy.sh` | the six-code decision table, extracted so it can be executed rather than remembered | **L2** — it runs, and it returns 9 |
| `agent-observatory/runner/verify-schema-verdict-policy.sh` | **16 cases**, all passing: the four codes that must still void, the two that proceed, four control-arm cases, three usage cases, and two **end-to-end** cases feeding the real checker's exit code to the real policy | **L2** |
| `runner/run-agent.sh` § 12b | calls the policy; also gains `SCHEMA_CHECKED`, so a run that never reached the checker can no longer be reported as having passed it | **L2** |

**Exactly one exit code moved: 6.** 5, 4, 3, 2 and any unregistered future code still exit 9,
and `verify-schema-verdict-policy.sh` proves that by executing them. This is a change to the
**runner's batch-stop signal only** — the evaluator's exit-code mapping, the benchmark commit,
the fixtures, the rubric sha and the model id are untouched — which is why it is not a §7 halt
under *"any proposed change to what the benchmark or evaluator measures"*. It is recorded as a
**disclosed harness move**, the fourth in this track after `2.1.251 → 2.1.259`, the runner
force-add (author decision 2), and `2.1.259 → 2.1.260`.

**What a reader should distrust about it.** Loosening a control so that one's own arm passes is
this project's house failure mode, and this is that shape. The defences are on the record and
each is checkable: the checker's registered contract already separated 5 from 6 *before* this
arm existed; the capability set is unchanged under a permutation; the alternative fix would
have hidden the runtime's behaviour; and the four fatal codes are proved still fatal by
something that executes. If a validator judges the move wrong, the batch is re-runnable under
reading A only by first making the runtime deliver the declared order, which nothing in this
project knows how to do.

### Second finding of the same step: the runtime moved, and § Controlled variables was already wrong when it was committed

`§ Controlled variables` says the Claude Code version is *"held equal to E-006 batch 2"*, which
is **2.1.261**. At step 4, `claude --version` reports **2.1.263**, and the binary's own symlink
dates the change:

```
/Users/…/.local/bin/claude -> …/versions/2.1.263      repointed  2026-09-06 06:38 local = 04:38Z
probe-20260906T050917Z                                 ran        2026-09-06 05:09Z
c21781b  (the prediction commit carrying that sentence) 2026-09-06 05:14:31Z
```

So the upgrade preceded both the probe and the prediction commit. **The sentence was false when
it was written**, and it is corrected here rather than in place, because `c21781b` is the
prediction commit and §4 step 12 forbids editing it. Three consequences, all registered before
the batch:

1. **The delivered-order observation is a 2.1.263 fact, not a 2.1.261 one.** The three P1 probe
   streams ran 31 minutes after the upgrade. The `["Read","Task","Grep","Glob"]` result and the
   `order-differs` verdict above therefore describe the binary this batch will actually use —
   which is the version of that claim worth having, and it was luck rather than design.
2. **The within-batch comparison is untouched.** Arms O and C are interleaved pair by pair on
   one binary in one window, which is why this design carries its own concurrent control at
   `n = 10` instead of comparing against a stored baseline.
3. **The reference population in § Predictions and § MDE is on a *different runtime*.** Those
   medians — cost $0.156, duration 97 s, `toolCalls` 20, `modelCalls` 22 — come from E-006
   batch 2 at 2.1.261. The registered magnitudes stand exactly as committed and are **not**
   revised. What changes is which number answers them: **every verdict is computed against this
   batch's own 2.1.261-free concurrent control**, and where that control's median differs
   materially from the reference population, § Results says so and reports both. A prediction
   that turns out to have been aimed at a moved baseline is recorded as such, not repaired.

`runtime.version` is on every observatory run record and in this batch's manifest, so a
stranger can separate 2.1.263 runs from every earlier experiment without trusting this note.
**Disclosed harness move, the fifth in this track**, and unlike the first four it is one nobody
chose: the runtime upgraded itself between two sessions. Whether a version bump should void an
open batch remains the author's call (`TRACK-B-STATE.md` `blocked_on_author`); it does not
arise here, because this key had zero runs when the bump happened.

## §4 step 5 — the preflight pair, observed 2026-09-06T08:00–08:05Z

One pair on its own key, **`EXP-4B-ORCH-PREFLIGHT`**. It enters no median, range, quartile or
Fisher test in this experiment and no verdict is computed from it.
Manifest: `evidence/p04b/lab-4b4/batch-20260906T080032Z/manifest.tsv`.

| | Arm O `075857fe` | Arm C `783bc227` |
|---|---|---|
| variant | `orchestration-4b4-P1` | `baseline-e007-window` |
| `--agent orchestrator` | accepted | n/a |
| `init.tools` **delivered** | **4**: `["Read","Task","Grep","Glob"]` | **29**, the full pool |
| schema verdict | `order-differs` — **recorded, not void** | `recorded-only` |
| delegation (`tool_result`, `Agent`/`Task`) | **1** | **0** |
| `customization.*Hash` | all `null` | all `null` |
| `runtime.version` / `.model` | 2.1.263 / `claude-haiku-4-5-20251001` | same |
| evaluator | exit 0, 7 of 7 | exit 0, 7 of 7 |
| `durationMs` · `estimatedCost` | 126 000 · $0.1515 | 111 000 · $0.1658 |
| `toolCalls` · `modelCalls` | 24 · 28 | 20 · 24 |
| `addedLines` · `changedFiles` | 88 · 3 | 61 · 3 |

**Every preflight assertion this experiment registered is met**, and the two that were open
questions are now answered:

**1. Threat 3 is answered, and the answer is the good one.** The registered doubt was whether
the observatory attributes a *worker's* tool calls to the *parent's* run id — if it did not,
O4 would have to be reported with a caveat instead of claimed. Telemetry for `075857fe`
carries **24 `tool_result` events under the parent run id, exactly matching
`behavior.toolCalls`**, and they break down as `Read` 12, `Edit` 6, `Bash` 5, `Agent` 1.
**The orchestrator's delivered pool contains neither `Edit` nor `Bash`**, so those eleven
calls could not have been made by the parent: they are the worker's, counted under the parent.
**O4 is claimable.** This is observation, not inference from a flag — the same standard author
decision 8 imposed on the tool list.

**2. The arms are not separable by `customization.*Hash`, exactly as registered.** Both are
all-`null`, including `agentHash`, on a run that demonstrably carried an agent overlay. The
discriminator is the pair `init.tools` **4 vs 29** and delegations **1 vs 0**, plus the setup
commit's tree — which is what § *How the treatment is delivered* said it would have to be.

**3. A control fact worth having: the plain baseline *can* delegate and does not.** Arm C's
delivered pool of 29 tools **includes `Task`**. Its 0 delegations are therefore a difference in
**behaviour**, not in capability — O1's control arm is not measuring a missing tool.

**4. The isolation row of §0a, observed on a live run rather than inferred.**
`ISOLATE_USER_SETTINGS=1` on both arms: `hook_registered` **23** (the number every run on file
shows, isolated or not) and `hook_execution_start` **absent — 0** on both.

**What the n = 1 numbers do to the predictions: nothing, and that is deliberate.** They are
recorded because hiding them would be worse, and they are not a result — one pair on a
preflight key, and § MDE says nothing below its floor is readable at all. For the record, and
for a validator to hold me to later: against its own same-window control, arm O was **8.6 %
CHEAPER** ($0.1515 vs $0.1658) where **O2 predicts +60 %**; **+13.5 %** on duration where
**O3 predicts ≥ +40 %**; **+4** on `toolCalls` where **O4 predicts ≥ +5**; and **+4** on
`modelCalls`, which is what **O5** predicts. If the batch reads like this pair, O2 is refuted
outright and its stated mechanism — two contexts, two cache prefixes — is wrong. **The
predictions are not touched.** They are committed at `c21781b` and §4 step 12 is the whole
reason this project is worth doing.

**Two defects in the batch driver, found by the preflight and fixed before the batch.** Both
are mine and neither touches a registered variable. (a) `mkdir "$EVID"` ran **ahead of every
guard**, so a refused invocation still created a `batch-<STAMP>/` directory — `verify-run-e007.sh`'s
own fixtures left five empty ones, each of which reads like an aborted batch. Moved after the
guards; verifier case 12 now asserts a refusal creates none, and the five empty directories
were removed after each was confirmed empty. (b) `grep -c || echo 0` printed **two** zeros,
putting a newline inside a TSV field — the stray `0` row in the preflight manifest above. That
manifest is evidence and stays exactly as it is; the driver no longer does it. Verifier back to
**12 of 12**, ShellCheck clean.

## Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG

*Written after validator pass 14 (`findings/track-b-validation-2026-09-06.md`) named, as the
single finding most likely to overturn this stop, that Reading B's premise —"a permutation
removes no capability"— was **asserted, not measured**. It was right. Probe registered at
`a4c219a` **before** it ran; results below.
`Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.`*

`evidence/p04b/lab-4b4/order-probe.sh`, four declared orders of the same four names, 2 reps
each, off the observatory under author decision 6. Results
(`evidence/p04b/lab-4b4/order-probe-20260906T125134Z/summary.tsv`):

| order | declared | delivered | verdict | reps |
|---|---|---|---|---|
| **A** | `Read, Grep, Glob, Task` *(the registered treatment)* | `["Read","Task","Grep","Glob"]` | `order-differs` | 2 of 2 |
| **B** | `Task, Glob, Grep, Read` | `["Task","Read","Glob","Grep"]` | `order-differs` | 2 of 2 |
| **C** | `Glob, Task, Read, Grep` | `["Task","Read","Glob","Grep"]` | `order-differs` | 2 of 2 |
| **D** | `Read, Task, Grep, Glob` | `["Read","Task","Grep","Glob"]` | **`match`** | 2 of 2 |

**The prediction registered at `a4c219a` said all four orders would deliver one canonical array.
Two distinct arrays came back. It is refuted and it stays on the record as refuted.** The
delivered order is **a function of the declared order**, not a constant of the runtime: A and D
land on one array, B and C on another, and the split is not random — it reproduced 2 of 2 in
every cell.

**Two sentences of the first amendment are now wrong, and here they are, corrected in place of
being quietly dropped:**

1. *"the declared position cannot carry information to the model, because the model is handed
   the delivered array and never the declaration"* — **the premise is refuted as stated.** The
   declaration demonstrably reaches the resolution step; a different declared order produces a
   different delivered order.
2. *"the batch is re-runnable under reading A only by first making the runtime deliver the
   declared order, which nothing in this project knows how to do"* — **false, and order D is how.**
   Declaring the tools in the order the runtime delivers them returns `verdict=match`, 2 of 2.
   That was registered as the cell most likely to be wrong and it is the one that held.

**What this does NOT do is void the batch, and the reason is specific rather than convenient.**
Row 0a is set-inequality, and the **set** was delivered intact on 10 of 10 arm-O runs: all four
declared tools, every run. This probe moves *nothing* about which tools arm O had. It refutes my
**rationale**, not the admission rule. And within the batch the declared order is a **constant** —
all ten arm-O runs used order A — so it cannot vary against anything and cannot explain any
O-vs-C difference. Arm C declares no list at all.

**What remains genuinely open, stated as the open question it is rather than closed by
assertion a second time.** Whether the *delivered* order changes model behaviour — whether
position acts as a priority, a default-selection order, or anything at all — is **still
unmeasured**. This probe narrowed the question (the declaration is not discarded) without
answering it. It is not answerable from this batch, because order is constant across arm O. The
honest statement of the treatment is therefore: *arm O is the overlay declared as
`Read, Grep, Glob, Task` and delivered as `["Read","Task","Grep","Glob"]`* — both orders named,
neither claimed to be inert.

**What every later stop that declares a `tools:` list should do, and it costs nothing.**
Declare the tools in the delivered order and the verdict is `match` rather than `order-differs`,
which removes this entire question from B6 (stop 13), B7 (stop 15) and B10 (stop 21). Finding
the delivered order takes one probe run. **This is not applied retroactively to arm O**: the
overlay is the registered treatment at `4f2af4ba7f740c33`, twenty runs were measured against
those bytes, and editing it now would be editing a treatment after its data.

**Pass 14's mechanical half was cleared by the validator itself**, which ran
`verify-schema-verdict-policy.sh` rather than trusting that it existed: 16 of 16, confirming
codes `5`, `4`, `3`, `2` and an unregistered code still void, and only `0` and `6` proceed.

## §4 step 6 — the batch, recorded 2026-09-06T08:09:06–08:53:40Z

**20 of 20 runs, every one evaluator exit 0 and 7 of 7 acceptance criteria.** One key,
`EXP-4B-ORCH-OVERHEAD`; ten O/C pairs interleaved; no gate-failing run and therefore no
excluded run under registered exclusion 1. Manifest, logs and window:
`evidence/p04b/lab-4b4/batch-20260906T080905Z/`. All 20 `--keep` worktrees verified present on
disk at `$TMPDIR/observatory-run-<runId>`; 20 per-run `init.tools` records at
`evidence/p04b/lab-4b4/init-schema/`.

**The prediction precedes every run, checked from git and the run record rather than asserted**
(§4 step 3 requires both timestamps be written here after the runs):

| | |
|---|---|
| prediction commit `c21781b` | **2026-09-06T05:14:31Z** |
| first run `207ff23d` `startedAt` | **2026-09-06T08:09:06Z** |
| margin | **2 h 54 m 35 s** |

The driver re-checks this itself before the first run and refuses otherwise; the check is in
`run-e007.sh` and is exercised by `verify-run-e007.sh` case 9.

| seq | arm | runId | started–finished | dur | cost | tool | model | schema verdict | deleg |
|---|---|---|---|---|---|---|---|---|---|
| 01 | O | `207ff23d` | 08:09:06–08:11:16 | 130 s | $0.1528 | 23 | 27 | `order-differs` | 1 |
| 01 | C | `a2a7cdb1` | 08:11:45–08:13:24 | 99 s | $0.1558 | 18 | 22 | `recorded-only` | 0 |
| 02 | O | `4d7c537d` | 08:14:02–08:16:08 | 126 s | $0.1321 | 23 | 28 | `order-differs` | 1 |
| 02 | C | `11cab10d` | 08:16:46–08:18:31 | 105 s | $0.1445 | 18 | 19 | `recorded-only` | 0 |
| 03 | O | `89ea9063` | 08:19:05–08:20:18 | 73 s | $0.0933 | 16 | 20 | `order-differs` | 1 |
| 03 | C | `4374f319` | 08:20:56–08:23:02 | 126 s | $0.1479 | 18 | 22 | `recorded-only` | 0 |
| 04 | O | `1f806f3d` | 08:23:38–08:25:50 | 132 s | $0.1318 | 22 | 27 | `order-differs` | 1 |
| 04 | C | `9fe27bf1` | 08:26:21–08:27:32 | 71 s | $0.1307 | 15 | 19 | `recorded-only` | 0 |
| 05 | O | `da442dd9` | 08:28:05–08:30:25 | 140 s | $0.1284 | 20 | 25 | `order-differs` | 1 |
| 05 | C | `b0b723f8` | 08:30:58–08:32:24 | 86 s | $0.1494 | 18 | 22 | `recorded-only` | 0 |
| 06 | O | `92f59ff6` | 08:32:53–08:34:37 | 104 s | $0.1247 | 22 | 26 | `order-differs` | 1 |
| 06 | C | `b1609bb9` | 08:35:07–08:36:01 | 54 s | $0.1047 | 15 | 12 | `recorded-only` | 0 |
| 07 | O | `beae5092` | 08:36:36–08:38:18 | 102 s | $0.1159 | 19 | 26 | `order-differs` | **2** |
| 07 | C | `383c915b` | 08:38:56–08:40:33 | 97 s | $0.1484 | 19 | 22 | `recorded-only` | 0 |
| 08 | O | `fb894d7d` | 08:41:04–08:42:33 | 89 s | $0.0950 | 14 | 20 | `order-differs` | 1 |
| 08 | C | `59c1467d` | 08:43:02–08:44:13 | 71 s | $0.1196 | 16 | 18 | `recorded-only` | 0 |
| 09 | O | `2744a92c` | 08:44:51–08:46:43 | 112 s | $0.1160 | 19 | 24 | `order-differs` | 1 |
| 09 | C | `a0202230` | 08:47:11–08:48:38 | 87 s | $0.1411 | 18 | 22 | `recorded-only` | 0 |
| 10 | O | `c0b6721e` | 08:49:06–08:51:10 | 124 s | $0.1415 | 25 | 30 | `order-differs` | 1 |
| 10 | C | `c7e4d207` | 08:51:39–08:53:08 | 89 s | $0.1489 | 18 | 22 | `recorded-only` | 0 |

**Independence, from the run records and not from the flags that were passed.** Every one of
these is a *single* value across all 20 runs: `experimentKey` `EXP-4B-ORCH-OVERHEAD`;
`runtime.version` `2.1.263 (Claude Code)`; `runtime.model` `claude-haiku-4-5-20251001`;
`repository.commitSha` `04486433f3d5e4b1a6e263f58ae47655bc647af5`; `evaluation.evaluatorVersion`
`1.0.0`. Registered exclusion 2 (a wrong model) fires on nothing.

**Row 0a does not fire.** All ten arm-O runs delivered the declared **set** —
`["Read","Task","Grep","Glob"]`, permuted, verdict `order-differs` 10 of 10 — and all ten
controls recorded the full pool. No `mismatch`, no `no-init-record`, no `no-tools-key`.

**The batch did not span a sleep** (`caffeinate -i`, one continuous 44 m 34 s window) and **no
other process of this lab ran during it** — no review, no scorer, no second batch. Registered
exclusion 4 fires on nothing, so `durationMs` is usable on all 20 runs. This is the discipline
stop 10 did *not* keep, when a preflight run on top of a live batch cost four runs' durations.

**The delegation column here is the driver's cheap log-derived count, not the registered
number.** O1's registered observable is the observatory telemetry, and it is read at §4 step 7.
What the column already shows is that the shape is there: **≥ 1 on 10 of 10 arm-O runs, 0 on 10
of 10 controls, and exactly 1 on 9 of 10** — `beae5092` delegated twice, which the orchestrator's
own workflow permits on a reported failure and which § Threats registered as reportable and not
voiding.

**No median, quartile, ratio or verdict is computed here.** That is §4 step 8, after §4 step 7
has put a `check-run-gate.sh` result and a codex sheet against each run id, and after the hand
re-read that §5 requires is written down *before* any sheet is opened.

## The database loss — read this before any number below it

> ## RETRACTED IN FULL, 2026-09-06T17:5xZ. THERE WAS NO DATABASE LOSS.
>
> **Attribution: `findings/track-b-validation-2026-09-06-2.md` (validator pass 15,
> claude-sonnet-5), item 1 and its closing finding. Every claim below this block is FALSE and
> is kept verbatim, unedited, because it is the record of how it was made.**
>
> **What is actually true, re-derived by me before adopting the validator's word** (§6: when a
> check goes green, re-verify one of its cases by hand):
>
> | Check | Command | Result |
> |---|---|---|
> | the real stack | `docker --context colima ps` | `agent-observatory-observatory-api-1` **Up 7 days (healthy)**, `0.0.0.0:8081->8080/tcp`; `agent-observatory-observatory-web-1` Up 8 days |
> | the tunnel this session opened | `lsof -nP -iTCP:18081 -sTCP:LISTEN` | `ssh` pid **9688** still LISTEN on `127.0.0.1:18081` |
> | the database | `curl -s 'http://127.0.0.1:18081/api/runs?limit=500'` | **HTTP 200, 325 run records**, this batch's twenty among them |
>
> **The mechanism of the error, which is this project's house failure mode wearing Docker.**
> This machine has three docker contexts (`colima`, `default`, `desktop-linux *`). The project's
> stack has always run in **`colima`** — a fact this same session had already written into
> `TRACK-B-STATE.md:22`. `make smoke` and `make up` ran against the **`desktop-linux`** default,
> where no `agent-observatory` container existed, so compose built a **second, disjoint, empty
> stack** on ports 8091/5435 with a volume created `2026-09-06T13:08:24Z`. Every one of the three
> facts cited below is individually true and none of them is about the database this project
> uses. **A control reported over a scope smaller than it claimed:** `docker volume inspect`
> without `--context` answers for one context and reads as an answer about the machine.
>
> **And the halt contradicted the same session's own committed work.** All twenty codex sheets
> carry `provenance.observatory: http://127.0.0.1:18081/api/runs/<id>` and were written
> `12:59:10Z`–`13:08:53Z` **through this very tunnel**; `4c12d8b` committed them at `13:13:34Z`;
> the halt commit `8d43a10` landed at `13:21:25Z` — eight minutes after committing the sheets it
> declares impossible to produce. The sentence *"O7 cannot be measured"* was written about a cell
> that had been on disk for twenty minutes.
>
> **What this changes below:** nothing about any measured number — the validator re-derived O1,
> O2, O3, O4, O5 and O6 from disk and telemetry and all six reproduce exactly (item 4 of its
> file). What it changes is the **provenance disclaimer** on § Results — *"nothing here is
> re-derivable from the API"* is false; all of it is, through `127.0.0.1:18081` — and it
> **removes the halt**: O7 is measured at **4 of 10** (§ below), decision-rule row 3 does not
> fire, and the exit gate is answerable.
>
> **What it does NOT change, and what stays owed:** the runner still archives no copy of the run
> record it POSTs (`run-agent.sh:1177`), and nothing in `agent-observatory/` backs this database
> up — greppped for `backup`/`pg_dump`, nothing. The loss described below did not happen; it
> remains possible. That is now a `blocked_on_author` item on its own, not a closed one.

**Between 2026-09-06T08:55Z (the last successful API read of this batch) and 12:49Z (this
session's start) the Docker environment on this machine was wiped.** Not by anything in this
session: the §0a preflight's stack row failed *before* I ran a single docker command
(`make smoke` → *"18 of 18 checks failed"*), the observatory's images had to be re-pulled from
scratch, and `docker volume inspect agent-observatory_postgres-data` gives
`created=2026-09-06T13:08:24Z` — the volume serving the API now is one **my own `make up`
created minutes ago**. It is empty.

**`GET /api/runs?limit=500` returns 0 runs. Every observatory run record this project has ever
produced — roughly 250 runs across stops 4 to 11 — is gone from the database.** The runner
builds its record in memory and POSTs it (`run-agent.sh:1177`); it never archives it to disk,
so there is no copy to restore from, and reconstructing one from my committed table would be
manufacturing a record that claims a completeness it does not have. I have not done that and it
should not be done.

**What survived, verified rather than assumed:**

| Artifact | State | Verified by |
|---|---|---|
| 20 of 20 kept worktrees | **present** | `test -d` on each `$TMPDIR/observatory-run-<runId>` |
| `evaluation.json` per run | **present in every worktree** | `check-run-gate.sh` run on each: **20 admitted, 0 refused** |
| telemetry `events.jsonl` | **present, 8.1 MB** | delegation events found for 20 of 20 runs |
| every committed artifact | **untouched** | manifests, `init-schema/`, the §4 step 6 table, sheets and evidence of stops 4–10 are in git |

**The consequence, stated exactly.** `codex-score.sh --run-id` admits a run through Decision D's
Path B — *the evaluator's verdict as recorded in the API*. With an empty database it refuses,
correctly. **O7 cannot be measured**, and O7 is what separates decision-rule row 3 (REFUTE) from
row 4 (NOT DETECTABLE). **So the exit gate cannot be answered, and this stop halts under §7.**

Everything that does not depend on the blocker was finished first, and is below.

## Results — §4 step 8, as far as the surviving evidence allows

**Provenance is given per metric, because it now differs per metric.** Nothing here is stated as
re-derivable from the API, because the API can no longer derive any of it.

| Outcome | Registered threshold | Observed | Verdict | Provenance of the observation |
|---|---|---|---|---|
| **O1** delegation | O ≥ 1 on 10/10; C 0/10; exactly 1 on ≥ 7/10 | **10/10 · 0/10 · 9/10** | **HELD, all three clauses** | **Telemetry — the registered source, which survived.** Independently recomputed this session |
| **O2** cost median | **+60 %**, detectable ≥ +25 % | **−13.4 %** ($0.1265 vs $0.1462) | **REFUTED — and in the opposite direction** | committed §4 step 6 table, read from the API before the loss |
| **O3** duration median | ≥ +40 % | **+34.1 %** (118 s vs 88 s) | **not met** — below the registered threshold | same |
| **O4** `toolCalls` median | ≥ **+5** *and* non-overlapping quartiles | **+3** (21 vs 18); quartiles 19–23 vs 16–18, non-overlapping | **not met** — the conjunction fails on magnitude | **telemetry AND the committed table, identical on 20 of 20 runs** |
| **O5** `modelCalls` median | ≥ **+4** *and* non-overlapping quartiles | **+4** (26 vs 22); quartiles 24–27 vs 19–22, non-overlapping | **HELD, both clauses** | committed table |
| **O6** evaluator pass rate | ≥ 8/10 and not lower than C by ≥ 3 | **10/10 vs 10/10** | **HELD** — and it was registered as *most likely to be wrong* | **on-disk `evaluation.json`, 20 of 20 gate-admitted** |
| **O7** `maintainability` anchor 2 | 1–3 of 10 | ~~BLOCKED~~ → **4 of 10** | ~~not measurable~~ → **SUPERSEDED** | **THIS ROW IS DEAD.** It was written under the false database-loss halt and is kept only as the record of it. **§ *O7, measured* below GOVERNS: 4 of 10, control 5 of 10**, from twenty codex sheets that already existed when this row was written. §4a finding at 2/2 — two sections gave O7 two values and no supersession rule; this is the rule |

**O4's corroboration is worth stating on its own.** The surviving telemetry's per-run tool counts
are **identical, run for run, to the API-derived numbers committed at `53d2aa0` before the
database was lost** — arm O `[14,16,19,19,20,22,22,23,23,25]`, arm C
`[15,15,16,18,18,18,18,18,18,19]`. Two independent sources, one of which no longer exists,
agreeing exactly. That is the strongest available answer to *"how do we know the committed table
was not mis-transcribed."* It does not extend to cost or duration, which telemetry does not carry.

**Where the decision rule stands, and why it cannot be finished.**

- Row 0a — **does not fire.** Set delivered on 10 of 10; O1 at 10/10, far above its 9/10 floor.
- Row 1 (CONFIRM) — **does not fire.** It requires O2 ≥ +25 % *and* O3 ≥ +40 %. O2 is negative
  and O3 is 34.1 %.
- Row 2 — **does not fire.** O6 is 10/10 in both arms.
- Row 5 — **does not fire.** O6 is not higher in arm O either.
- Row 3 (REFUTE) vs row 4 (NOT DETECTABLE) — **undecidable without O7.** Row 4's conditions are
  otherwise met (O2 < +25 %, O3 < +40 %, nothing improved), but row 3 outranks row 1 and turns on
  O7 ≥ 9 of 10. **This single unmeasured cell is the whole of what the halt costs.**

**The one thing this batch settled regardless of O7, and it is the hypothesis' own mechanism.**
E-007 predicted decomposition would cost **+60 %** in money because *"two contexts create two
cache prefixes."* **Arm O was 13.4 % cheaper than its own concurrent control**, on ten pairs
interleaved in one 44-minute window on one binary. Whatever O7 turns out to be, **the cost
mechanism registered in the hypothesis is wrong**, and it was called wrong twice before the batch
was read — once at the preflight pair (n=1) and once in the state file, both in writing, both
before any median was computed. What decomposition cost here was **time** (+34 %) and **turns**
(+4 model calls), not money.

### O7, measured — and the decision rule finished, 2026-09-06T18:0xZ

**Attribution: `findings/track-b-validation-2026-09-06-2.md` (pass 15) item 3, which found the
twenty registered sheets already committed and pointed at the cell the halt above calls
unmeasurable. Added additively; nothing above is rewritten.**

**The reading is written down before the number is applied**, as pass 13's directive 13.3
established for stop 10: *row 3 fires only on `O7 ≥ 9 of 10` in arm O, counted as the number of
arm-O runs whose `maintainability` cell scores the anchor-2 value; a cell that is `null` is
counted as neither, and the denominator stays 10.* There are no nulls, so the two readings
coincide and no second computation is needed.

Re-derived by me this session by re-running the committed asserting collector,
`evidence/p04b/lab-4b4/batch-20260906T080905Z/step7/collect-sheets.py`, over `findings/codex` and
the batch manifest — not by reading the sheets:

| Outcome | Registered threshold | Observed | Verdict | Provenance |
|---|---|---|---|---|
| **O7** `maintainability` anchor 2 | 1–3 of 10; only ≥ 9 of 10 detectable | **4 of 10** in arm O (raw `0 2 0 0 2 0 2 0 2 0`); arm C **5 of 10** (`0 2 2 2 2 0 0 2 0 0`) | **HELD in substance, missed by one on the letter** — the registered band was 1–3 and the value is 4; it is far inside the MDE, so this is NOT DETECTABLE movement, not a refutation | 20 codex sheets, all `rubric_sha: 396e1799eb2b`, zero nulls, `provenance.observatory: http://127.0.0.1:18081/api/runs/<id>` |

**O7 is 4 of 10, not ≥ 9, so row 3 does not fire.** Nothing improved that the gate can see: arm O
is *lower* than arm C on maintainability (4 vs 5), which is inside the noise of a category whose
control moved 1 of 10 → 5 of 10 between two batches five weeks apart.

**The decision rule, applied in order and completed:**

| Row | Condition | Fires? |
|---|---|---|
| 0a | verdict ≠ `matches` (set reading) or O1 < 9/10 | **no** — set delivered 10/10, O1 10/10 |
| 1 | O2 ≥ +25 % **and** O3 ≥ +40 % **and** O6 not higher **and** O7 < 9/10 | **no** — O2 is **−13.4 %**, O3 is +34.1 % |
| 2 | O6 lower than arm C by ≥ 3 | **no** — 10/10 vs 10/10 |
| 3 | O7 ≥ 9 of 10 | **no** — **4 of 10** |
| 4 | O2 < +25 % **and** O3 < +40 % **and** nothing improved | **YES** |
| 5 | O6 higher than arm C by ≥ 3 | **no** |

## Verdict: **NOT DETECTABLE** (row 4). The lower bound the gate asked for is NOT set.

**Stated with its `n`:** on BE-003 with `claude-haiku-4-5-20251001`, `n = 10` per arm, one
interleaved 44-minute window, splitting this task into orchestrator + implementer produced **no
cost penalty** (−13.4 %, opposite to the registered +60 %), **a duration penalty below the
registered threshold** (+34.1 % against ≥ +40 %), **no correctness change** (10/10 vs 10/10) and
**no quality change the rubric can see** (4 of 10 vs 5 of 10). The registered claim — that
decomposition costs more than it returns below some task size — **is not supported by this batch,
and is not refuted either.** It is below this instrument's floor at this `n`.

### Revision after the §4a review round — `test-quality` MOVED, and I had written that nothing did

*Applied 2026-09-06T19:0xZ from `findings/opencode/review-E-007-orchestration-overhead-20260906T184803Z.md`
(codex panel, `-P codex -A -n 2`, exit 0, 92 finding sections). The finding recurred at **2/2** in
three separate forms and it is correct. **The claim it refutes is mine and it is corrected here
rather than quietly softened above.***

**What I wrote:** *"no quality change the rubric can see"*, and `observed_effect: … nor anything
the rubric can see`. **What the sheets say:**

| dimension | arm O | arm C | |
|---|---|---|---|
| `architecture-consistency` | `2` ×10 | `2` ×10 | no variance |
| `change-focus` | `1` ×10 | `1` ×10 | no variance |
| `maintainability` (**O7**) | anchor 2 on **4 of 10** | **5 of 10** | inside its MDE |
| **`test-quality`** | `2 1 1 2 2 1 2 1 2 1` — **anchor 2 on 5 of 10** | `1` ×10 — **0 of 10** | **Fisher two-sided `p = 0.0325`** |

**So the rubric did see something, in the treated arm's favour, and this experiment cannot credit
it — because `test-quality` is in neither of the two lists the registration wrote.** It is not one
of O1–O7, and it is not in the *"report only"* line, which names `changedFiles`, `addedLines` and
`change-focus` and stops there. **That omission is the defect**, and it was mine, made before the
run.

#### The decision rule under both readings, as pass 13's directive 13.3 requires

Row 4 reads *"O2 < +25 % **and** O3 < +40 % **and nothing improved**"*. The first two clauses hold
on any reading. The third is ambiguous and the ambiguity was not resolved before the batch:

| Reading | *"nothing improved"* means | Row 4 | Verdict |
|---|---|---|---|
| **A** | none of the **registered** outcomes improved — i.e. O6 and O7, the two the rule names elsewhere by number | **fires** | **NOT DETECTABLE** |
| **B** | nothing measured improved, registered or not | **does not fire** — `test-quality` improved at `p = 0.033` | **NO ROW FIRES.** Rows 1, 2, 3 and 5 are all already excluded, so the registered rule returns *no verdict at all* |

**Reading A is adopted as primary**, because every other clause in that rule names a registered
outcome by its number and reading B would let any unregistered co-variate decide a pre-registered
experiment. **Reading B is recorded, not buried**, and under it this experiment has **no verdict**.
Both are stated because the rule did not say, and choosing after seeing the numbers is exactly
what the directive exists to prevent.

#### The finding this actually produces, which is better than the verdict

**Both things this batch detected are outside its own decision rule.** `modelCalls` **+4** with
non-overlapping quartiles — the split's real cost — has no row that reads it. `test-quality`
**5 of 10 vs 0 of 10, `p = 0.033`** — a possible *return* from the split — was never registered as
an outcome at all. The rule sees O2, O3, O6 and O7; the experiment moved on `modelCalls` and
`test-quality`.

**E-007 registered the wrong outcomes.** That is the honest headline of this stop, it is a
statement about my design and not about the agent, and it is worth more than `NOT DETECTABLE`.

**It is NOT repaired here.** `test-quality` is not promoted to an outcome after the fact, the
decision rule is not rewritten, and `NOT DETECTABLE` stands as the verdict under the adopted
reading. §6 forbids moving a registered variable mid-experiment, and a rule edited to fit its own
results measures nothing. **The repair is a registration, in the next experiment**, and it is the
first follow-up.

**A caution on `test-quality` specifically, so it is not over-read.** B1 recorded that this
dimension *"holds 25 of the 100 and is decidable on two of the five variants — the other three
submitted no test file"*, and E-001 left three of twenty cells structurally null on it. Here there
are **no nulls in 20**, so every cell was decidable — but `p = 0.033` at `n = 10` per arm on an
unregistered dimension is a lead, not a result, and it is stated as *true of these twenty runs*.

### A defect in the registered decision rule, recorded and NOT repaired

**O5 held both its clauses and no row of the decision rule reads O5.** `modelCalls` moved +4 with
non-overlapping quartiles (24–27 vs 19–22) — the only registered outcome besides O1 to clear its
own MDE — and the rule that decides this experiment cannot see it. O1 is likewise absent from
every row except as a delivery check in 0a. So the rule reduces a six-outcome experiment to O2,
O3, O6 and O7, and **an overhead that showed up in turns rather than in money or seconds lands as
NOT DETECTABLE.**

This is not corrected. §6 forbids moving a registered variable mid-experiment and the decision
rule is registered; editing it after seeing the numbers is precisely the move this project
exists to refuse. **It is registered as the first follow-up**, and the honest reading of this
batch is the one written above *plus* this sentence: **the split did cost something measurable —
four extra model calls per run, quartiles not overlapping, n = 10 — and the pre-registered rule
had no place to put it.**

### Two claims about O2, which this file was making at once — corrected 2026-09-06 after the §4a review

The §4a critic found, at **2/2 recurrence and in three separate forms**, that `−13.4 %` was called
**REFUTED** in one section and **NOT DETECTABLE** in another. Both words were mine and they are not
interchangeable. **The finding is correct.** Separated:

1. **The prediction `+60 %` is REFUTED.** It named a direction and a magnitude; the observed value
   is on the other side of zero. No reading of `−13.4 %` is consistent with *"about $0.25 where the
   control costs $0.156"*, and its stated mechanism — *"two contexts create two cache prefixes"* —
   is wrong about what the orchestrator does.
2. **No cost EFFECT is claimed, in either direction.** The registered MDE is `≥ +25 %` on the
   median and `|−13.4 %|` is inside it. **Arm O is not established as cheaper.** It is established
   as *not more expensive by the amount predicted*.

**The decision rule uses claim 2, not claim 1** — row 1 asks whether `O2 ≥ +25 %`, and it is not,
so row 1 does not fire. Claim 1 is about the hypothesis' mechanism and is what makes this batch
worth reading. **Wherever this file says "cheaper", read "not more expensive, and 13.4 % below the
control's median at `n = 10`, which is inside the instrument's floor."**


## Amendment 2026-09-07 — the counter that measured O1 can read zero for a run that delegated

*Filed by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-07, from evidence produced by
[`E-008`](E-008-fourth-cell-prose-without-split.md) §4 step 6. **No number, prediction or verdict
in this file is edited.** E-007 remains `NOT DETECTABLE`, decision rule row 4.*

**What E-008 observed.** In a plain-baseline run of E-008's control arm (`9043f824`, BE-003,
`claude-haiku-4-5-20251001`, runtime 2.1.263 — the same model, task and runtime as this
experiment), the model called the **built-in** `Explore` agent: a `tool_use` block with
`"name":"Agent"` in the runner's stream, followed by the runtime's own
`{"subtype":"task_started","subagent_type":"Explore","is_backgrounded":true,"spawn_depth":1}`.
The observatory telemetry for that run id carries **24 events and zero** with
`tool_name ∈ {Task, Agent}`.

**Why it matters here.** O1 is *"delegation — `tool_result` events with `tool_name ∈ {Task,
Agent}` per run, from the observatory telemetry"*, and its result is **arm O 10 of 10 vs arm C
0 of 10**. The arm-O half is a positive detection and is unaffected: the counter saw those
delegations, they happened, and O1's `p = 0.00001` rests on them. **The arm-C half is a
zero from a counter now shown to miss a delegation of this shape** — built-in agent,
backgrounded, result not emitted as a `tool_result` naming `Agent`. It is not blind in general;
it is blind to that shape.

**So the honest form of O1's control number is:** *no delegation to the installed `implementer`
agent was recorded on any of the 10 control runs, and the counter used cannot rule out a call to
a built-in agent on those runs.* Arm C's controls were never re-read from their streams. **That
re-read is cheap and it is not done here** — this file's stop is closed and §6 forbids rewriting
a closed result; it is listed in `HANDOFF.md` as a check somebody should run, and E-009's driver
reads delegation from **both** sources so the successor does not inherit the gap.

**What would change if a control delegation were found in those streams:** O1's magnitude, not
its direction — the split still delegates on 10 of 10 and the plain arm does not delegate *to
the treatment's worker*, which is what the independent variable is about. **The verdict does not
move**; `NOT DETECTABLE` was decided by O2–O7, none of which reads O1's control cell.

## Observed telemetry

*(after the run)*

## §4 step 7 — the hand re-read, written before any sheet for this batch existed

§4 step 7 forbids reading a sheet before an expected score exists on paper, and §5 requires at
least one scored cell per step to be re-read by hand off the kept worktree. Both are discharged
here. **No `codex-score.sh` sheet for any of the twenty E-007 run ids existed when these two
values were fixed** — the first scoring attempt of this session failed before writing anything
(see the API note below), so `findings/codex/` held no E-007 sheet at all. The reading was taken
from the kept worktree and the rubric at its registered sha, by a subagent briefed to open the
source and the rubric and forbidden to open a sheet.

| | |
|---|---|
| run | `207ff23d-d00b-4b5a-8a5e-8fbb2dcc0061` (arm O, seq 01) |
| worktree | `$TMPDIR/observatory-run-207ff23d-d00b-4b5a-8a5e-8fbb2dcc0061` |
| rubric | `benchmark/rubrics/backend-quality.yaml` at **`396e1799eb2b`**, unmodified since `0be66e7` (2026-09-01) |
| file read | `sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt:55–75` |
| values fixed at | **2026-09-06T12:53Z** |

**`architecture-consistency` = 2, by hand.** Two refusal paths, both throwing a subclass that is
already in the attached baseline: `ShipmentController.kt:58` throws
`ResourceNotFoundException(ErrorCode.SHIPMENT_NOT_FOUND, …)`, `ShipmentController.kt:64` throws
`ConflictException(ErrorCode.SHIPMENT_CANNOT_CONFIRM_CANCELLED, …)`; both are present in the
baseline's `ApiExceptions.kt` (`git show 249e638:…ApiExceptions.kt`, lines 19–20 and 23–24), so
neither is a type this submission introduced. No `ApiError(` or `ApiErrorBody(` literal occurs
anywhere in the shipment package, and no `ResponseEntity<Any>` return type occurs; `confirm`
returns `ResponseEntity<Shipment>`. That is every clause of anchor 2.

**`maintainability` = 0, by hand.** The status decision at `ShipmentController.kt:63–74` is a
`when (shipment.status)` in **statement** position: its value is discarded — not returned, not
assigned, not passed as an argument, not the tail expression of a lambda — and each branch does
its own `throw` or `return`. It carries no `else`. Anchor 0's third clause is *"a `when` in
STATEMENT position — its value discarded, used by nothing"*, and it is met.

### A defect in the instrument, found by the hand re-read and NOT repaired

Anchor 1 of `maintainability` lists, among the residual cases, *"also a `when` that is neither
exhaustive nor carries an `else`"*. This run's `when` is exactly that — and it is **also** anchor
0's statement-position case. The two anchors overlap on a real submission, so a scorer reading
anchor 1's list literally scores 1 where a scorer applying the residual rule scores 0.

The rule that resolves it is already written into the rubric and into §4 step 2's layer
discipline: anchor 1 is defined as **THE RESIDUAL — "neither the 0 condition nor every clause of
2"**. The 0 condition is met, so the residual cannot be reached, and the cell is 0. The overlap
is a defect in the anchor's prose, not in the outcome.

**It is not being fixed now, and that is deliberate.** The rubric is a registered variable of this
experiment and of every experiment back to B2; editing it mid-batch is a §7 halt, and editing it
between arms would be worse. It is recorded here, carried to `## Follow-up`, and belongs to a
rubric version that no measured comparison depends on.

*Hand re-read performed at the orchestrator's direction and recorded by Opus 5 (claude-opus-5),
autonomous, 2026-09-06. The interpretation, the anchor ruling and the decision not to repair the
rubric are the orchestrator's, not the subagent's.*

## §4 step 7 — the twenty registered sheets, and the one cell that was checked by hand

Scored 2026-09-06T12:59–13:09Z, `codex-score.sh` against `benchmark/rubrics/backend-quality.yaml`
at **`396e1799eb2b`**, the registered sha. Every one of the twenty sheets carries that sha in its
own provenance block and names `harness: codex`, `model: gpt-5.6-sol`, `schema_pinned: 4
categories` — checked by assertion in the collector, not by eye.

| | |
|---|---|
| collector | `evidence/p04b/lab-4b4/batch-20260906T080905Z/step7/collect-sheets.py` |
| output | `…/step7/scores.txt` |
| sheets | `findings/codex/score-observatory-run-<runId>-20260906T1[23]*.yaml`, twenty of them |

| run | arm | architecture-consistency | maintainability | test-quality | change-focus |
|---|---|---|---|---|---|
| `207ff23d` | O | 2 | **0** | 2 | 1 |
| `4d7c537d` | O | 2 | 2 | 1 | 1 |
| `89ea9063` | O | 2 | 0 | 1 | 1 |
| `1f806f3d` | O | 2 | 0 | 2 | 1 |
| `da442dd9` | O | 2 | 2 | 2 | 1 |
| `92f59ff6` | O | 2 | 0 | 1 | 1 |
| `beae5092` | O | 2 | 2 | 2 | 1 |
| `fb894d7d` | O | 2 | 0 | 1 | 1 |
| `2744a92c` | O | 2 | 2 | 2 | 1 |
| `c0b6721e` | O | 2 | 0 | 1 | 1 |
| `a2a7cdb1` | C | 2 | 0 | 1 | 1 |
| `11cab10d` | C | 2 | 2 | 1 | 1 |
| `4374f319` | C | 2 | 2 | 1 | 1 |
| `9fe27bf1` | C | 2 | 2 | 1 | 1 |
| `b0b723f8` | C | 2 | 2 | 1 | 1 |
| `b1609bb9` | C | 2 | 0 | 1 | 1 |
| `383c915b` | C | 2 | 0 | 1 | 1 |
| `59c1467d` | C | 2 | 2 | 1 | 1 |
| `a0202230` | C | 2 | 0 | 1 | 1 |
| `c7e4d207` | C | 2 | 0 | 1 | 1 |

### The hand re-read agrees with the harness on both cells it checked

The values fixed by hand at 12:53Z, before any sheet existed, were `architecture-consistency = 2`
and `maintainability = 0` for `207ff23d`. **The codex sheet for `207ff23d` says 2 and 0.** Both
cells agree, and they agree for the same stated reason: the sheet's `maintainability` evidence
reads *"The status when is in statement position"*, which is the clause the hand reading applied.
There is no disagreement to take to the diff at this step.

That is one run of twenty and it is not a validation of the harness in general. It is the check
§4 step 7 and §5 require, and it passed.

### Two of the four dimensions did not move at all

`architecture-consistency` is **2 on 20 of 20**. `change-focus` is **1 on 20 of 20**. Together
they are 50 of the rubric's 100 weighted points, and on this task with this model they carry no
information — which is exactly the standing item in `blocked_on_author` ("which rubric categories
CAN move on BE-003 with haiku?"), now observed for a third experiment rather than argued.

### The two dimensions that did move, reported as counts because the median lies here

| dimension | arm O, `n=10` | arm C, `n=10` |
|---|---|---|
| `maintainability` | four 2s, six 0s — **median 0** | five 2s, five 0s — median reads 1.0 |
| `test-quality` | five 2s, five 1s — median reads 1.5 | ten 1s — **median 1** |

**`maintainability` is bimodal and never once scored 1**, so arm C's "median 1.0" is an
interpolation between two 0s and two 2s and is a value no run received. `test-quality`'s "1.5" is
the same artifact. Both are reported as counts above for that reason; the medians are in
`scores.txt` and are not the honest summary of a two-valued distribution at even `n`.

**The one difference worth carrying forward: `test-quality` reached 2 on five of ten arm-O runs
and on zero of ten arm-C runs.** Every arm-C run scored exactly 1. Whether that clears the
decision rule registered before the batch is §4 step 10's question and is **not** answered here —
this section reports what the instrument produced.

### The report-only items, reported — added 2026-09-06 after the stop closed

**Attribution: `findings/track-b-validation-2026-09-06-3.md` (validator pass 16,
claude-fable-5-1), correction 6.** § Predictions registers `changedFiles`, `addedLines` and
`change-focus` as **report only**. `change-focus` was reported (1 on 20 of 20, above);
**`changedFiles` and `addedLines` were registered and then never reported for the main batch.**
Registering something as report-only is a commitment to report it, so here it is.

**Re-derived by me from the API records rather than adopted from the validator's table** (§4b: a
subagent's — or a validator's — number is data, not a verdict), `n = 10` per arm,
`EXP-4B-ORCH-OVERHEAD`:

| metric | arm O median (q1–q3, range) | arm C median (q1–q3, range) | Δ median |
|---|---|---|---|
| `addedLines` | **90** (81–102, 68–106) | **64** (62–67, 56–72) | **+26** |
| `changedFiles` | **3 on 10 of 10** | **3 on 10 of 10** | **0 — at the task's floor** |

`changedFiles` is the floor BE-003 cannot go below and behaves exactly as the registered row
predicted from 19 historical controls; it separates nothing and was right to be report-only.

**`addedLines` is the one that is worth having, and it did not have to be.** The two
distributions do not overlap at the quartiles (81–102 against 62–67) and barely overlap at the
range. **Arm O wrote about 26 more lines per run, and the extra lines are test code** — which is
where the only dimension that moved, `test-quality`, moved: the validator checked the diffs of
one run per arm and found `1f806f3d` (arm O) adding 78 test lines against `a2a7cdb1` (arm C)
adding 43, against totals of 104 and 67 that I re-derived here. **This is not an outcome and no
verdict may be computed from it** — it was registered report-only before the run and stays
report-only afterwards, which is the whole point of registering the label first. It is stated as
*true of these runs*.

**Why it matters anyway:** it is a second, independent measurement pointing at the same place as
the `test-quality` result, and it sharpens pass 16's closing finding rather than answering it —
more test lines is what you would expect *both* from a split that hands a worker a focused brief
*and* from the implementer's four lines of prose telling that worker to write "tests for every
case it names". The registered design cannot separate those two, which is threat 1.
*Added by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.*

### A control of mine that reported success over a smaller scope than it claimed

The first extraction pass reported all four cells MISSING for `c7e4d207` and would have entered a
scored run as unscored. The sheet was complete; **the collector had read it while
`codex-score.sh` was still writing it.** The presence check that gated the read tested that a
FILENAME existed, and was treated as testing that a SHEET existed.

Fixed the way this project's other controls are: `collect-sheets.py` now **asserts** — the
registered rubric sha on every sheet, every one of the four categories parsing, and exactly twenty
sheets — so an unparseable cell is an error that stops the run rather than a silent absence. A
missing cell is not a null cell (§6): `null` is a measurement, and nothing here produced one.

### The second reader is owed and still refused

`opencode-score.sh` was probed once at 13:01Z on `207ff23d` and returned exit 1 with
`Error: you (hermannjirka15) have reached your weekly usage limit` from ollama-cloud — the same
weekly limit first seen 2026-09-05T18:06Z, with no reset time disclosed. Sheet:
`findings/opencode/score-observatory-run-207ff23d-…-20260906T130110Z.yaml`. No stall: the process
exited and left nothing running.

**No substitution was made.** §4c's Decision H governs a *codex* outage and does not fire here;
codex is up and is the registered scorer, so the experiment's numbers are complete. What is
missing is the cross-harness distance, and the debt is now **20 sheets from this stop on top of
the 14 owed from stop 10**. It is recorded, not waived.

*Scored under the orchestrator's direction and recorded by Opus 5 (claude-opus-5), autonomous,
2026-09-06. The reading of the bimodal medians, the decision to report counts, and the refusal to
substitute a scorer are the orchestrator's.*


#### AMENDMENT 2026-09-07 — the debt is discharged, and the second reader has a blind spot

Nothing above is rewritten. The twenty sheets this section records as owed now exist.

The ollama-cloud weekly limit lifted at some point before 2026-09-07T07:27Z, found by that day's
§0a preflight: the default review panel returned twelve findings where the day before it returned a
765-byte header-only stall. All twenty runs of `EXP-4B-ORCH-OVERHEAD` were then scored with
`ollama-cloud/deepseek-v4-pro` against `backend-quality.yaml` at `396e1799eb2b` — the same sha
every registered codex sheet in this experiment asserts. No benchmark run was started; every sheet
reads a run record and a kept worktree that already existed.

**No number in this experiment moves.** codex is the registered scorer under Decision C and stop 11
closed on its sheets; the verdict stays `NOT DETECTABLE`. What the second reading adds is the
cross-harness distance this section said was missing.

Across these twenty runs and stop 10's fourteen — 136 cells — the two harnesses agree exactly on
118. `architecture-consistency`, `maintainability` and `test-quality` agree **34/34 each**.
`change-focus` agrees **16/34**, and every one of the eighteen disagreements runs the same way:
the second reader scores 2 (or `null`) where codex scores 1, never the reverse.

Adjudicated in full, not sampled. Over these 34 runs codex returns `1` **thirty-four times out of
thirty-four**; the second reader returns `2` fifteen times, `1` sixteen times and `null` three
times. **Both anchors were evaluated, not just the one that was convenient** — the acceptance gate
rejected an earlier draft of the write-up for evaluating anchor 2 alone, and it was right, since a
run where anchor 0 holds scores 0 rather than the residual. Anchor 0 (*"two or more methods the
ticket did not name differ"*) fails on 34 of 34: no unnamed method is touched at all
(`anchor0-check.py`, from `git diff -U0` hunk ranges). Anchor 2 fails on 34 of 34: every run also
changes `ApiError.kt`, which is neither `confirm` nor an import. So the score is the residual, `1`,
on all 34, and **codex is correct on all 34 by the rubric's own rule** — there is no unexamined cell
in which the second reader's `2` could be right.

What was *withdrawn* under the same review is the reading that the scorer is demonstrably unstable:
the 34 runs are 34 distinct diffs, so no two identical inputs were scored differently, and some
unexamined feature may yet sort the second reader's answers. The correctness result above does not
depend on that and stands; the mechanism does not, and is left open in
`evidence/second-reader/README.md`.

One cell from this batch was re-derived by hand off the kept worktree. `207ff23d`: codex 1,
*"Class documentation outside confirm differs from baseline"*; `git diff HEAD` shows the class KDoc
replaced. Anchor 2 requires that **only** `confirm` and its by-symbol imports differ, so it fails
and the residual is 1. **codex is right**, and the second reader's reason — *"only confirm added;
create/getById/list and imports identical"* — is true and does not address the class doc. The
mechanism, confirmed again on stop 10's `a06e80c5` where the missed change is a second file: the
second reader reads `change-focus` as a question about the controller's methods and imports; codex
reads it as a question about the whole change.

**Provenance, because this is a confirmation and not a discovery.** `agent-learning-lab/CLAUDE.md`
has recorded since 2026-09-01, at `n = 5`, that *"where they disagreed, opencode's fact was wrong"*,
naming the same two causes — a deleted class KDoc, and a new `ErrorCode` constant in a second
attached file. What this batch adds is scale (3 of 5 → 18 of 34), a uniform direction, and the
anchor-by-anchor adjudication on all 34 that settles the score the earlier record left open as *"a
live rubric question"*. It is not open: anchor 2 requires that only `confirm` and its by-symbol
imports differ, and `ApiError.kt` is neither.

Full write-up, batch logs, the concordance script and the two hand re-derivations:
[`evidence/second-reader/README.md`](../evidence/second-reader/README.md).

*Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-07. Additive: the section above stands as
written on 2026-09-06, including its statement that the sheets were refused, which was true then.*

## §4 step 8 — the report, and why the registered tool could not produce it

Run 2026-09-06T13:0xZ, over the twenty gate-passing runs and no others. Every run in the batch
cleared `check-run-gate.sh`, so "compare only among runs that passed every gate" excludes nothing
here — `n = 10` per arm, not a survivor subset.

| | |
|---|---|
| command | `make baseline-report EXPERIMENT=EXP-4B-ORCH-OVERHEAD API_PORT=18081` |
| output | `evidence/p04b/lab-4b4/batch-20260906T080905Z/step8/baseline-report.txt` |
| per-arm derivation | `evidence/p04b/lab-4b4/batch-20260906T080905Z/step8/per-arm.py` → `per-arm.txt` |

**The registered report tool cannot answer this experiment's question, and that is a finding
about the instrument rather than about orchestration.** `baseline-report.py` is single-arm: it
selects on `experimentKey` and pools everything under it. Both arms of E-007 share one key, so its
median duration of 100 s is the median of arm O and arm C mixed together and is **not** the
comparison. It is kept above because it is the registered command and its pooled figures are a
cross-check on the derivation below — the pooled duration min/median/max (54 / 100 / 140) is
reproduced exactly by `per-arm.py` over the same twenty documents.

`per-arm.py` is committed beside the output and re-derives every cell from the run documents as
the API returns them; its docstring carries the `curl` loop that refetches them. Median and range
only, never a mean.

| metric | arm O median (range), `n=10` | arm C median (range), `n=10` | O − C |
|---|---|---|---|
| duration (s) | **118** (73–140) | **88** (54–126) | **+30 s, +34.1 %** |
| estimated cost ($) | **0.1266** (0.0933–0.1528) | **0.1462** (0.1047–0.1558) | **−0.0196, −13.4 %** |
| input+output tokens | **10 632** (8 841–12 866) | **7 552** (6 710–8 800) | **+3 080, +40.8 %** |
| cached tokens | **410 770** (272 478–546 413) | **635 840** (327 568–682 682) | **−225 070, −35.4 %** |
| tool calls | **21** (14–25) | **18** (15–19) | **+3, +16.7 %** |
| model calls | **26** (20–30) | **22** (12–22) | **+4, +18.2 %** |

**The two directions that matter, stated as what they are.** Arm O is **slower** and
**cheaper**: +34 % on median duration, −13 % on median cost. It bills *more* input+output tokens
(+41 %) while reading *fewer* cached tokens (−35 %), and cached reads are the cheaper unit — so
the cost fall is not a contradiction of the token rise, it is its arithmetic.

**The ranges overlap heavily and the medians should not be read as separation.** Arm O's duration
range (73–140 s) contains most of arm C's (54–126 s); pair 03 alone has arm O at 73 s and arm C at
126 s, the reverse of the median ordering. What is registered here is the median and the spread.
Whether that clears the decision rule registered before the run is §4 step 10's question and is
not answered in this section.

**`toolFailures` is not uniformly zero across the batch** — values of 0, 1 and 2 occur. It was not
a registered outcome and is not treated as one; it is recorded so that a later reading of these
runs does not discover it as news.

*Reported by Opus 5 (claude-opus-5), autonomous, 2026-09-06. The pooled/per-arm distinction and
the decision to commit the derivation script rather than paste numbers are the orchestrator's.*

## §4 step 9 — the deliberate failure, variant P2: predictions registered BEFORE the run

*Written 2026-09-06T18:2xZ, **before `run-e007-p2.sh` existed and before any run on
`EXP-4B-ORCH-DELIB`**. Predicted by Opus 5 (claude-opus-5), autonomously,
2026-09-06T18:2xZ; the author did not review before the run.*

**The break is one line and nothing else.** `diff` between the two orchestrator files is a
single deletion:

```
5d4
< tools: Read, Grep, Glob, Task
```

`implementer.md` is **byte-identical** between the two overlays (`6096f5ea35383112` in both).
The orchestrator goes `4f2af4ba7f740c33` → **`1b259ccc09066cad`**, which is the sha this
experiment registered as the P2 candidate at §4 step 3, before the batch — it is not chosen now.

**Why this is the right break for this stop.** Stop 11's whole subject is the layer model
applied to orchestration. In P1 the orchestrator's delivered pool is `Read, Task, Grep, Glob`:
there is **no Write, no Edit, no Bash**, so implementing the ticket itself is not something it
declines — it is something it cannot do. That is **L2: something executes and refuses.** P2
deletes that line, the agent inherits the full session pool (29 tools, as arm C's ten records
show), and the *only* thing left saying "you do not implement it" is prose in the body. That is
**L3: words a model reads and chooses to follow.** Same words, same worker, same ticket, same
model — one line of difference, and the layer changes.

### The registered predictions

| # | Outcome | Direction · magnitude | Mechanism |
|---|---|---|---|
| **F1** | delegation — `≥ 1` `tool_result` with `tool_name ∈ {Task, Agent}`, telemetry, same query as O1 | **3 to 5 of 5** — reduced from arm O's 10/10 but nowhere near arm C's 0/10 | the body is not a disposition, it is a numbered procedure that names the tool, the `subagent_type` and the order. Stop 10's arm H measured exactly this distinction: an explicit governance instruction moved a hold rate to **8 of 10 vs 0 of 5**, while one sentence of borrowed authority moved it **not at all** (4/5 vs 4/5). This body is the first kind |
| **F2** | **the orchestrator writes code itself** — ≥ 1 `tool_result` for `Write`, `Edit` or `MultiEdit` **in the orchestrator's own stream**, on **≥ 1 of 5** runs | **≥ 1 of 5** | **This is the whole demonstration and it is the one to read first.** In P1 this event is not unlikely, it is *impossible*: the tool is absent from the delivered pool and the runtime refuses by name (observed at stop 9, `toollist-05`). In P2 it is merely discouraged. A single occurrence converts "L2 and L3 are both boundaries" into "one of them is". **Registered as the one most likely to be wrong** — five runs is a small window for a lapse, and haiku is compliant with explicit procedures |
| **F3** | evaluator pass rate on the P2 arm | **≥ 4 of 5**, and not lower than its concurrent control by 2 or more | whoever does the work, it is the same model on the same ticket, and BE-003 passed **20 of 20** in this stop's batch. If P2 fails the gate the cause is the handoff, not the task |
| **F4** | delivered schema, per arm | P2 arm: `delivered n=29`, verdict **`recorded-only`** on 5 of 5 — *identical to arm C*; control arm the same | P2 declares no `tools:` key, so there is nothing for the runtime to narrow. **This is F1's control**: if the pool is not the full 29, the arm is not what it claims and F1 measures something else |

**What no result here can establish, written before the numbers so it cannot be softened after
them.** If F2 comes back **0 of 5**, that is *"at n = 5, on this task, with this body, the L3
instruction was not observed to fail"* — it is **not** "L3 is as good as L2", and it must not be
written up as one. A boundary that cannot be crossed and a boundary that happened not to be
crossed five times are different objects, and the second one's `n` goes in every sentence about
it. The asymmetry is the point: **one** F2 event refutes the equivalence; **no** F2 events refute
nothing.

### An instrument fault of my own making, found mid-batch and NOT worked around silently

*Written 2026-09-06T18:2xZ, while the P2 batch was still running and before any of its numbers
were read as a result.*

**The P2 batch exports no telemetry, and the cause is one missing environment variable of mine.**
`runner/lib/telemetry-env.sh:53` sets, for the `claude` runtime,
`OTEL_EXPORTER_OTLP_PROTOCOL=grpc` and `OTEL_EXPORTER_OTLP_ENDPOINT="$OTLP_GRPC_ENDPOINT"`,
default `http://localhost:4317`. `run-e007-p2.sh`'s `ARM_COMMON` overrides `API_PORT`,
`OTLP_HTTP_PORT` and `TEMPO_PORT` onto SSH tunnels — **and not `OTLP_GRPC_PORT`.** Port 4317 is
one of the dead colima forwards, so every export is posted into a socket that accepts and answers
nothing. `infra/telemetry-out/events.jsonl` has not been written since `08:53Z`, which is when the
*main* batch ended; `grep -c` for each P2 run id returns **0**.

**This is the same defect as the one that opened the day**, one layer down: a forward that accepts
the connection and delivers nothing, and a configuration that looked complete because the three
overrides I *did* write were the three I had thought of.

**What it costs, exactly.** F2, F3 and F4 are unaffected — F2 is a transcript measure by
construction (telemetry cannot separate the orchestrator's calls from its worker's, which is the
whole of what F2 asks), F3 is the evaluator's exit code, F4 is the `init` record. **Only F1's
registered source is gone**, and F1 was registered as *"same query as O1"*, i.e. the observatory
telemetry.

**What I am NOT doing, and why.** Not re-running the batch: the runs are valid — correct overlay,
correct model, correct benchmark sha, evaluator verdicts recorded, transcripts complete — and
re-running them would spend about $1.60 to recover a *second view of an event the transcript
already records upstream of the collector*. Not opening the missing tunnel mid-batch either: an
environment change between run 02 and run 03 is precisely the mid-batch move this project
condemns, and OTLP export is network work inside the measured process.

**What I am doing instead, and the condition on it.** F1 is read from the transcript
(`parent_tool_use_id` null → the orchestrator's own stream) for all five P2 runs, **and the
substitution is proved rather than asserted**: the same transcript measure is run over the *main*
batch's twenty logs, where telemetry **does** exist, and the two must agree run for run. If they
do not agree on 20 of 20, F1 is reported as unmeasured and the batch is re-run. That check is
below, and it was specified here **before** it was run.

### Design, disclosed before the run

- **`n = 5` P2 + 5 concurrent plain controls**, interleaved as pairs, on key
  **`EXP-4B-ORCH-DELIB`** — a key of its own, never `EXP-4B-ORCH-OVERHEAD`. Reusing one key for
  two batches is a recorded process violation of this run (E-006 holds 40 runs under one key);
  it is not repeated.
- **The concurrent control is kept even though arm C already exists at n = 10.** It costs about
  $0.65 and it buys a same-window reference for cost, duration and tool counts, so any statement
  about what P2 *costs* is self-contained instead of reaching back ten hours. It also keeps the
  P2 driver structurally identical to `run-e007.sh`, whose twelve-case verifier is the only
  thing standing in front of money.
- **Driver: a new file, `evidence/p04b/lab-4b4/run-e007-p2.sh`.** `run-e007.sh` is **not edited**
  — its runs are the evidence this stop closes on, and this project has a standing rule against
  editing a tool whose runs are the evidence. The P2 driver's overlay guard is the *inverse* of
  P1's: it refuses if `orchestrator.md` declares **any** `tools:` line, which is the specific
  mistake worth catching here — running P1 under the deliberate failure's name, or the reverse.
- **The comparison for F1 is arm O (10 of 10) from this stop's own batch**, same model, same
  runtime `2.1.263`, same benchmark sha `0448643`, same day. Fisher on 0/5 vs 10/10 is
  `p = 0.0003`; on 5/5 vs 10/10 it is `p = 1.0`.

### Environment disclosure, because the last session got this wrong

These runs POST to the observatory through **`http://127.0.0.1:18081`** and export telemetry
through **`http://127.0.0.1:14318`** — SSH tunnels into the colima VM, opened because *every*
colima host port-forward on this machine is dead (`nc -z` reports the port OPEN and `curl`
returns `000`, which is a port check answering over a smaller scope than it claims). **The stack
itself is untouched and healthy: `make smoke` through the tunnels returns `All 18 checks
passed`.** The API is the same API, the database is the same 325-record database, and no
registered variable moves. This is written down because the alternative reading of a dead
forward — *"the database is gone"* — cost this run a four-hour false halt earlier today.

### §4 step 9 — the result. F2 is REFUTED, and one line turned out to change nothing measurable

**Batch `EXP-4B-ORCH-DELIB`, 5 P2 + 5 concurrent plain controls, interleaved as pairs,
`2026-09-06T18:10:48Z–18:44:20Z` (33 m 32 s, no machine sleep, nothing else of this lab running).
Model `claude-haiku-4-5-20251001` on 10 of 10, evaluator exit 0 on 10 of 10, benchmarks `0448643`,
Claude Code `2.1.263`. Prediction `eab540e` at `18:08:51Z` precedes the first run by 1 m 57 s, and
the driver refused to start otherwise.** Manifest and per-run reader:
`evidence/p04b/lab-4b4/p2-batch-20260906T181047Z/`.

| # | Registered | Observed | |
|---|---|---|---|
| **F1** | delegation on **3–5 of 5** | **5 of 5**, exactly one each | **HELD**, at the top of the band |
| **F2** | orchestrator writes code itself on **≥ 1 of 5** | **0 of 5** | **REFUTED** — and it was registered as the one most likely to be wrong |
| **F3** | evaluator ≥ 4 of 5, not worse than control by 2 | **5 of 5**, control **5 of 5** | **HELD** |
| **F4** | `delivered n=29`, `recorded-only`, 5 of 5 | **5 of 5**, both arms | **HELD** |

**The comparison the deliberate failure exists to make:**

| | delegated | orchestrator wrote code itself |
|---|---|---|
| **arm O** — `tools:` line present, **L2** | 10 of 10 | **0 of 10 — impossible**, `Write`/`Edit`/`Bash` absent from the delivered pool |
| **P2** — line deleted, prose only, **L3** | **5 of 5** | **0 of 5 — possible, and it did not happen** |
| plain control — no overlay | 0 of 10 (main), 0 of 5 (here) | **5 of 5 here**, `Edit` 3–5 per run |

**P2 against arm O on delegation: Fisher `p = 1.0`.** Deleting the one element of this treatment
that *executes* moved the measured behaviour **not at all**. **P2 against its concurrent control:
`p = 0.0079`** — so the prose is doing the work, and doing all of it.

**F2's definition was narrower than its concept, and widening it changes nothing here.** The §4a
critic noted that `Write`/`Edit`/`MultiEdit` is not the whole of *writing code*: stop 9's
deliberate failure got its file written entirely through **`Bash`** — `find`, then a
`cat > ./calc.py` heredoc — with **zero `Write` calls**. Re-derived with `Bash` counted as a write
path, the orchestrator's own stream on all five P2 runs contains **only `Agent` and `ToolSearch`**:
`{'Agent': 1}` ×3 and `{'ToolSearch': 1, 'Agent': 1}` ×2. **F2 is 0 of 5 on either definition**, so
the narrow wording hid nothing here. It is recorded because it *would* have hidden everything on
stop 9's task, and the next experiment reusing this measure should register the wide definition.

**The measure can fire, and that is not an assumption.** The control arm is a positive control for
F2 by construction: same 29-tool pool, no orchestration instruction, and it wrote code in its own
stream on **5 of 5** runs (`Edit` ×3 to ×5). A zero on the treated arm is therefore a real zero and
not an instrument that cannot register the event — which is exactly the gap stop 9's read-only
*description* arm left open, and the reason that arm is still labelled L3.

### What this does and does not license, quoted from the registration rather than composed now

The prediction block said, before the runs: *"If F2 comes back **0 of 5**, that is 'at n = 5, on
this task, with this body, the L3 instruction was not observed to fail' — it is **not** 'L3 is as
good as L2', and it must not be written up as one. …**one** F2 event refutes the equivalence;
**no** F2 events refute nothing."*

**Two different things are being said, and the §4a critic was right that this file ran them
together (2/2).** **F2 as a prediction is REFUTED**: it said `≥ 1 of 5` and the answer is `0`.
**The inference "L3 is equivalent to L2" is NOT licensed** by that zero — that is what the
registration guarded, and it is a claim about the boundary, not about F2. A refuted prediction and
an unlicensed inference are perfectly compatible.

**That is the reading, unchanged by having seen the number.** What was measured is that a
*procedurally explicit* body — a numbered step naming the tool, the `subagent_type` and the order —
produced compliance on 5 of 5 where a plain agent with the same tools implements the ticket itself
on 5 of 5. What was **not** measured is the worst case, because nothing here tested it: no
delegation failed, no worker returned a failure to be re-delegated, and the task is one the model
completes comfortably. **`tools:` does not make delegation more likely; it makes not-delegating
impossible.** Its effect lives in the tail, and five runs of a compliant model on a task it passes
20 of 20 times do not sample the tail.

**The honest one-sentence version, with its `n`:** *of these five runs, the L3 instruction alone
delegated as reliably as the L2 boundary did, and the L2 boundary's value was not tested.*

### The co-variate, and what the telemetry loss actually cost

`durationMs` comes from the runner's own clock and survived; **`estimatedCost`, `inputTokens`,
`cachedTokens`, `toolCalls`, `modelCalls` and `traceId` are `null` on all 10 P2-batch records** and
populated on all 20 main-batch records. That is the gRPC misconfiguration above, scoped exactly.

**Duration, `n = 5` per arm, within-window:** P2 median **110 s** (99–153) against its concurrent
control **108 s** (81–130) — **+1.9 %**, nothing.

**And the concurrent control earned its $0.65 here rather than in theory.** The *same* plain
baseline ran at a median of **88 s** in the morning window and **108 s** in the evening one — the
machine moved **+23 %** between them. A P2-versus-morning-control comparison would have reported a
duration penalty that is an artefact of the clock. **This is the whole argument for a concurrent
control, observed on one day.** Note also that P1's arm O ran **+34.1 %** over its own concurrent
control while P2 ran **+1.9 %** over its own; that difference is **not a result** — different
windows, `n = 10` versus `n = 5`, duration is not a registered outcome for P2, and the two were
never designed to be compared. It is recorded as a question, not an answer.

## Results

*(after the run)*

## Which predictions held

**Main batch, `EXP-4B-ORCH-OVERHEAD`, `n = 10` per arm.** Four of seven held, one was refuted in
the opposite direction to the one registered, and two landed below their own thresholds.

> **Corrected 2026-09-06 — it is three of seven, not four. The table below is right and this
> sentence rounded up.** Attribution: `findings/track-b-validation-2026-09-06-3.md` (validator
> pass 16, claude-fable-5-1), correction 8. Counting the table's own verdict column: **held —
> O1, O5, O6 (three)**; **refuted — O2**; **below threshold, not met — O3, O4**; **outside its
> registered band — O7**, which the table's last row states plainly as *"missed its band by
> one"*. The sentence counted O7 as held. It is not: 4 of 10 sits outside the registered
> `1–3 of 10`, and the honest description is the one the table already gives — *missed its band
> by one, far inside its MDE, and lower than the control*, which is a movement too small to
> detect rather than a prediction that came true. **The direction of the error is the one that
> matters**: a summary counting a near-miss as a hit is the same shape as a status header
> claiming a result the file beneath it does not have, and both were found in this file by the
> same pass. The verdict is unchanged — decision rule **row 4, `NOT DETECTABLE`** — because no
> row of that rule reads O7's near-miss either way.
> *Corrected by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.*

| # | Registered | Observed | |
|---|---|---|---|
| **O1** | ≥1 delegation 10/10, control 0/10, exactly one on ≥7/10 | **10/10 · 0/10 · 9/10** | **HELD**, all three clauses. Registered as *least likely to be wrong*, and it was |
| **O2** | **+60 %** cost, detectable ≥ +25 % | **−13.4 %** | **The PREDICTION is refuted; no cost EFFECT is claimed.** See § *Two claims about O2* — these are different statements and this file was making both without separating them, a §4a finding at 2/2 |
| **O3** | ≥ +40 % duration | **+34.1 %** | **not met**, below its registered threshold. Not "no effect": an effect inside the MDE |
| **O4** | ≥ **+5** tool calls *and* non-overlapping quartiles | **+3**, quartiles non-overlapping | **not met** — the conjunction fails on magnitude while its second clause holds |
| **O5** | ≥ **+4** model calls *and* non-overlapping quartiles | **+4**, quartiles 24–27 vs 19–22 | **HELD, both clauses** — and the decision rule has no row that can read it |
| **O6** | ≥8/10 and not lower than control by ≥3 | **10/10 vs 10/10** | **HELD** — and it was registered as *the one most likely to be wrong*. The handoff dropped nothing BE-003's gate tests |
| **O7** | 1–3 of 10; only ≥9/10 detectable | **4 of 10** (control 5 of 10) | **missed its band by one, far inside its MDE.** Not a refutation: NOT DETECTABLE movement, and *lower* than the control |

**The two that matter are the two registered as extreme, and they went opposite ways.** The
prediction called *least* likely to be wrong (O1) held exactly. The one called *most* likely to be
wrong (O6) also held — a small orchestrator did **not** paraphrase BE-003's error cases away. What
broke instead was the prediction nobody flagged: **cost**, by 74 percentage points and by sign.

**A prediction that was wrong is kept wrong.** O2's `+60 %` is not edited, and the mechanism
sentence beneath it is not repaired. It was called wrong twice in writing *before* any median was
computed — once at the preflight pair (`n = 1`) and once in the state file — and both of those
calls are in the record too.

## Failure analysis

**There were no gate failures to analyse in the main batch: 20 of 20 runs exit 0.** Registered
exclusions 1, 2, 4 and 5 never fired; exclusion 3 (row 0a) did not fire because the delivered set
was the declared set on 10 of 10, permuted. **No run was excluded, and none was re-run.** That is
the honest content of this section and it is short on purpose — a failure analysis with nothing to
analyse should say so rather than manufacture a narrative.

**What failed instead was a prediction and an instrument, and both are worth the space.**

**1. The cost mechanism was wrong, and it was wrong in a direction that teaches something.**
`+60 %` rested on *"a second agent with its own system prompt and its own cache prefix re-reads
what the first skimmed."* The second half is right and the conclusion does not follow. Read the
orchestrator's own stream and the reason is visible in one line: on run `eac5b2b1` — **a §4 step 9
P2 run, NOT one of the twenty in the table above; cited because its orchestrator is unrestricted, so
the behaviour is chosen rather than forced (§4a finding, 2/2)** — it made
**exactly one tool call, `Agent`**, and nothing else. The orchestrator never loads the files at
all — the worker does — so the split does not duplicate a large context, it **moves** it, and
leaves the parent holding almost nothing. That is *context isolation working as advertised*, which
is the exit gate's third item, arriving as a refutation of my own cost prediction rather than as
the confirmation the extract had set up.

**2. The instrument could barely move on this task, and that is a harness fact, not an agent
fact.** Of the rubric's 100 points, `architecture-consistency` scored **2 on 20 of 20** and
`change-focus` **1 on 20 of 20** — 50 points at zero variance across both arms, continuing the
pattern E-006 §C2 recorded over five experiments and 73 runs. Only `maintainability` moved, and it
moved by one run in the *control's* favour. **So O7 is a weak instrument reading, not a strong
null**, and the sentence that survives is the one with its `n` attached: *of these ten runs per
arm, the rubric saw no difference*.

**3. A defect in the registered decision rule, found by applying it.** O5 held both its clauses
and no row reads O5; O1 appears only as a delivery check. A six-outcome experiment is decided by
four of its outcomes, and the two that measured the split's actual overhead — that it happened at
all, and that it cost four extra model calls — cannot reach the verdict. **Recorded, not
repaired.** Editing a decision rule after seeing its numbers is the move this project exists to
refuse, and the correct place for the fix is the next experiment's registration.

## Sanity checks

*Run at §4 step 13, each one executed again rather than recalled. The main batch,
`EXP-4B-ORCH-OVERHEAD`, `n = 10` per arm.*

| Check | Command | Result |
|---|---|---|
| the prediction preceded the first run | `git log --format=%cI -1 c21781b` vs the earliest `startedAt` on the key | `2026-09-06T05:14:31Z` vs `08:09:06Z` — **2 h 54 m 35 s**. The batch driver also refuses to start before its `PRED_COMMIT`, so this is enforced going forward and merely checked backwards |
| per-run schema verdicts | join the manifest's ids to `evidence/p04b/lab-4b4/init-schema/init-schema-<id>.txt` | **10 arm O `order-differs`, `delivered n=4`; 10 control `recorded-only`, `delivered n=29`.** Row 0a does not fire (set equality — see § Amendment) |
| `runtime.model` on 20 of 20 | `curl -s 'http://127.0.0.1:18081/api/runs?limit=500' \| jq '…'` | `claude-haiku-4-5-20251001` on 20 of 20, Claude Code `2.1.263` on 20 of 20 |
| benchmark sha and evaluator equal across arms | asserted by `run-e007.sh` before the first run; `verify-run-e007.sh` drives the guard until it fires | benchmarks `0448643`, evaluator `1.0.0`; verifier **12 of 12** |
| **a registered variable DID move, and this file said otherwise** | § Controlled variables registers Claude Code **`2.1.261`** (E-006 batch 2); every run of this batch is **`2.1.263`**, the binary having been repointed at `04:38Z`, before the prediction commit — disclosed in § *Amendment 2026-09-06* | **L2** — asserted per batch by `run-e007.sh`, which refuses any other version | **CORRECTED 2026-09-06 after the §4a review, found at 2/2.** *"No registered variable moved"* is FALSE as stated. The comparison is protected by this batch's **own concurrent control**, not by version equality with E-006 |
| rubric sha equal across all sheets | `collect-sheets.py`, which **asserts** rather than reports | `396e1799eb2b` on **20 of 20**, **zero null cells** |
| a hand re-read written before any sheet was opened | `git log --format=%cI -1 cd715e6` vs the earliest sheet's timestamp | hand `12:58:11Z`, first sheet `12:59:10Z` — **59 s**. Hand and harness agree on both checked cells of `207ff23d` (`architecture-consistency 2`, `maintainability 0`) |
| O1 re-derived independently, in the main context | count `tool_result` events with `tool_name ∈ {Task, Agent}` in `events.jsonl`, joined to the manifest's 20 ids | **10/10 vs 0/10, exactly one on 9 of 10**, one run at 2. Matches the recorded value |

**The limit of the independence proof, restated because it has not moved.**
`customization.*Hash` is `null` on **all 20 run records including arm O** — no field on the run
record witnesses a Claude *agent* overlay. Independence therefore rests on the setup commit's
tree, the `init` read-back and the telemetry, exactly as E-006 §5 did. **A stranger checking
`customization.*Hash` to see whether the treatment was delivered will find nothing and must not
read that as absence.**

**And one re-derivation command in the §5 table was wrong when first written, and running it is
what caught it.** Globbing `evidence/p04b/lab-4b4/init-schema/*.txt` returns 11 and 12, not 10 and
10, because that directory also holds the §4 step 5 preflight pair and, from step 9, the P2 batch.
The corrected command joins the ids to the batch manifest. **A check answering over a larger scope
than its claim is the same defect as one answering over a smaller scope**, and it is the third
instance recorded in this stop alone.

## Decision — §4 step 10, per element

**Nothing here is promoted. Stop 11 is a Track A stop; it builds no version, and `v1.0` from B4 is
untouched.** The overlay stays in `build/customizations/orchestration-4b4-P1/` as measured
evidence and **is never edited** — a measured artefact is not revised, a change is a new
directory.

| Element | Layer | Measured effect | Decision |
|---|---|---|---|
| the orchestrator's **procedure body** (numbered delegate-and-verify) | **L3** | delegation **5 of 5** with nothing structural forcing it, against a plain control at **0 of 5** on the same pool, `p = 0.0079` | **KEEP.** This is a measured effect, not an assumed one, and it is the strongest positive result this stop produced |
| the orchestrator's **`tools:` line** | **L2** (observed refusing, stop 9) | delegation **10/10 with** it and **5/5 without** it — `p = 1.0`. **No measured effect on this task at this `n`** | **KEEP, against the default rule.** See below — this is a judgement call and it is flagged as one |
| the **`model:` pins** (both files) | **L3** | `claude-haiku-4-5-20251001` on 30 of 30 runs across both batches; nothing executes to reject a wrong one | **KEEP** as a mitigation, labelled L3, not counted as a control |
| the **implementer's four-line body** | **L3** | **not separable in this design** — it was present in every treated run of both variants | **KEEP and disclose**: the treatment is *the split including that prose*, as § Independent variable already says |
| the **batch driver + its 12-case verifier**, the **init-schema read-back**, the **transcript reader** | **L2** | each shown to refuse or to assert: 12 of 12 guards driven until they fired; the reader aborts rather than report a zero if `parent_tool_use_id` disappears | **KEEP** |

### The one decision that departs from *"a rule with no measured effect is removed"*

**By the letter of the rule, the `tools:` line should be removed.** It has no measured effect:
5 of 5 delegated without it, `p = 1.0` against the arm that had it. I am not removing it, and the
reason is not that I like it.

**`tools:` is not a rule that makes delegation more likely. It is a boundary that makes
not-delegating impossible.** Its effect is on the worst case, and a batch of five runs, on a task
this model passes 20 of 20 times, in which no delegation failed and no worker returned an error,
**does not sample the worst case.** Removing an L2 boundary on the strength of a null drawn from
the cases where it was never needed is the same error this project already labelled at stop 9,
where a read-only *description* produced zero write attempts and the arm stayed **L3 because
nothing tested it**. A boundary that cannot be crossed and a boundary that happened not to be
crossed are different objects; the measurement here cannot tell them apart, so it does not get to
decide.

**This is a judgement call, it is reversible, and it is the author's to reverse.** What would
settle it is not more of the same runs but a condition that tempts the orchestrator: a worker that
fails, a ticket the worker returns incomplete, or a task where implementing directly is visibly
faster. **Registered as a follow-up**, not folded into this stop.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-06.*

## Results — the stop's verdict in one place

| | |
|---|---|
| **Main batch verdict** | **NOT DETECTABLE** (decision rule row 4), `n = 10` per arm |
| **The gate's number** | **NOT SET.** The task size below which decomposition costs more than it returns is not established by this batch, and no lower bound is claimed |
| **Deliberate failure** | **F2 REFUTED at 0 of 5**; F1, F3, F4 held. Deleting the L2 line changed delegation `p = 1.0` |
| **What was measured that the rule could not use** | `modelCalls` **+4**, quartiles 24–27 vs 19–22, `n = 10` |
| **Refuted predictions** | **O2** (cost, `+60 %` registered, `−13.4 %` observed — wrong by sign), **F2** (`≥1 of 5` registered, `0 of 5` observed). Both were registered before their runs and neither is edited |
| **Stop 11's own status** | closes as a Track A stop — reading, extract and one lab with evidence on disk. **lab#14 stays OPEN**: labs 4B.1, 4B.2 and 4B.3 are deferred |

## Follow-up

- **`maintainability` anchors 0 and 1 overlap** on a statement-position `when` that carries no
  `else` — anchor 0 names it by position, anchor 1 names it in its residual list. The residual
  rule decides it (0), but the prose should not need the rule. Belongs to a later rubric version;
  it is a registered variable and was not touched mid-experiment. Found by this step's hand
  re-read, 2026-09-06.
- The threshold, not the bound: the same design on BE-004 at stop 12 under author decision 9.
- Whether the observatory attributes a subagent's tool calls to the parent run (threat 3) is an
  instrument question for the observatory repo if the preflight pair answers it badly.
