# Track B validation, eighth pass — 2026-09-04

`Validated by Claude Opus 5 (claude-opus-5), section 9 of PROMPT-opus5-track-b.md,
2026-09-04T18:50Z.` Read-only. Nothing outside this file was created, edited or deleted — no
workbook, experiment, run folder, sheet or state file was touched.

**Why the `-8` suffix.** §9 names the output `findings/track-b-validation-<date>.md`. That name
and `-2` … `-7` are taken by today's seven earlier passes. Writing to the base name would destroy
another pass's output, which §9 forbids more strongly than it requires the name. This is the only
deviation from §9 in this file.

**Independence, stated up front.** §9 asks for a model different from the builder's. It did not
get one: the builder is `claude-opus-5` and so is this validator. **Corrected against the files
rather than from memory:** six of the eight passes — 1, 2, 3, 4, 5 and 7 — ran on
`claude-fable-5-1` and did honour §9; only the sixth and this one share the builder's model. So
the caveat is on two passes, not most of them, and this file is one of the two. It is mitigated
only by re-derivation — every number below was recomputed
from raw data with this validator's own parser, its own Fisher implementation, and its own
readings off the kept worktrees. Nothing was accepted because a workbook or an earlier pass said
it.

**Inputs.** `PROMPT-opus5-track-b.md` §9 and §5; `findings/track-b-2026-09-04.md`;
`agent-learning-lab/TRACK-B-STATE.md`; the §5 tables in `phases/b02-plain-baseline/`,
`phases/01-instructions/`, `phases/b03-global-instructions/`, `phases/02-prompt-files/` and
`phases/03-skills/`; `experiments/E-003`, `E-004`; `evidence/b02/`, `evidence/b03/`,
`evidence/p03/`; 249 run records from the live API on `:8081`;
`agent-observatory/infra/telemetry-out/events.jsonl` (33 MB); the codex sheets;
`agent-observatory/runner/run-agent.sh`; the kept worktrees under `$TMPDIR`.

**Repository state at validation time.** `agent-learning-lab` HEAD `03496caa` on
`stop9/validator-pass-3-corrections`, `origin/main` `288ceee3`, branch **not merged**. The
worktree holds **no modified tracked file**; the only entries in `git status --porcelain` are the
sixth and seventh passes' output files, untracked, plus this one. `agent-observatory` `51794327`.
`agent-observatory-benchmarks`
`04486433`, `git status --porcelain` **empty**.

**Scope.** §9 covers closed stops. `TRACK-B-STATE.md` and `findings/track-b-2026-09-04.md` report
stops **4, 5, 6, 7 and 8** as closed and stop **9 as in progress at the §4 step-8 boundary**.
Stop 9 is therefore out of scope and is not validated here, in either direction.

---

## Verdicts

| Stop | Verdict | One line |
|---|---|---|
| **4 — B2 plain baseline** | **CONFIRMED WITH CORRECTIONS** (1) | Every gate clause maps to evidence that opens; the deliberate-failure telemetry re-derived exactly (0×5 vs 27–48×5); one **new** correction about a registered variable that moved and is not covered by the independence check |
| **5 — Phase 1 instructions** | **CONFIRMED WITH CORRECTIONS** (1) | The one measurable row re-derived to the digit — 39 hash / 40 null, one distinct hash, zero exceptions. One correction: the L2 justification names a refusal that executes over a narrower case than the row claims |
| **6 — B3 global instructions** | **CONFIRMED WITH CORRECTIONS** (2) | Primary outcome recounted three ways and agreeing every time (2/10 vs 3/10); every p-value reproduces. Two corrections, one shared with stop 4, one about the word "deleted" |
| **7 — Phase 2 prompt files** | **CONFIRMED** | `n = 0` and the table says so. Every re-derivation command in it was run here and returned the stated value, including the re-anchored `grep` |
| **8 — Phase 3 skills** | **CONFIRMED WITH CORRECTIONS** (3) | The headline re-derives exactly from raw telemetry and stands. Two corrections carried unapplied from passes 6 and 7 are confirmed here a third time; one is new |

**No stop is NOT CLOSED.** Every closing condition is met by evidence that exists on disk and
opens. The corrections below are about where a proof lives and what a sentence claims, not about
whether a stop closed.

**One process fact that belongs at the top.** `TRACK-B-STATE.md`'s `validation_processed` list
ends at `findings/track-b-validation-2026-09-04-4.md`. **Passes 5, 6 and 7 are unprocessed**, and
the four corrections passes 6 and 7 raised against stop 8 are still not applied to any workbook.
Two of them are re-derived and confirmed below. They should ride with stop 9's PR, which is
already carrying the third pass's corrections.

---

## What was re-derived, and what it returned

Independent recomputation, not reading. Each row is a command or a parser written here.

| Claim | Where it is claimed | This validator's value | Agrees? |
|---|---|---|---|
| Stop 8 activations: matched 5/5, misdescribed 0/5, control 0/5 | E-004, §5 table | own OTLP parser over `events.jsonl`: **1,1,1,1,1 / 0×5 / 0×5**, all `skill.source = projectSettings`, `skill.name = custom_skill`, `malformed_lines: 0` | **yes** |
| Fisher `p = 0.0079` | stop 8 headline | own Fisher: **0.00794** | yes |
| Fisher `p = 0.0022` (flag probe 6/6 vs 0/6) | workspace `CLAUDE.md` | **0.00216** | yes |
| Stop 8 co-variate: matched 5/5, misdescribed 4/5, control 1/5 on `maintainability` | E-004, the report | recount off 15 sheets: **5/5, 4/5, 1/5**; pooled treated vs control **p = 0.01698**; matched vs misdescribed **p = 1.0** | yes |
| Body `sha256:d10a2c3988be520e`, arms differ only in `description` | §5 table | `check-overlay-parity.sh --allow-differ description` → same digest, exit 0 | yes |
| Fixture sets 28 / 16 / 16 / 7 | §5 table | ran all four: `28 passed`, `16 passed`, `16 passed`, `7 passed`, 0 failed | yes |
| Stop 6 construct: treatment 2/10, control 3/10 | E-003, census, §5 table | recount off 20 sheets — treatment `a472f54c b93d0f9f`, control `42c67dd8 d04bb5d6 b1daa5db`; **same five run ids the hand census names**; Fisher **1.00000** | yes, three instruments agreeing |
| Stop 6 bloat 3/5 vs treat 2/10 `p = 0.251`; vs control 3/10 `p = 0.329` | `evidence/b03/bloat-arm-comparison` | **0.25075**, **0.32867** | yes |
| `instructions-v0.1` = 57 words, `90f95226cc3d429f6f3e157e4741bbd1` | stop 6 §5 row 1 | `wc -w` → **57**; `shasum \| cut -c1-32` → **`90f95226cc3d429f6f3e157e4741bbd1`**; present on 10/10 treated + preflight, `null` on 10/10 control, `807c5d…` on 5/5 bloat | yes |
| Stop 5: 39 hash / 40 null, zero exceptions | stop 5 §5 row 3 | over the three named keys: **total 79, hash 39, null 40**, exactly one non-null digest `sha256:13a7b6af…` | yes |
| Stop 4 deliberate failure: `hook_execution_start` 0×5 isolated, 27–48×5 open | stop 4 §5 table | own parser: isolated **0,0,0,0,0** (`hook_registered` 23 each); open **48, 31, 27, 33, 29** (`hook_registered` 24 each) | yes |
| Stop 4: prediction `59ac936` @ 13:06:30Z precedes run `4c891809` @ 13:07:19Z | stop 4 §5 table | `git log %cI` → `2026-09-03T15:06:30+02:00` = **13:06:30Z**; API `startedAt` **13:07:19Z**. 49 s | yes |
| Stop 8: prediction `f8ff084` @ 10:34:48Z precedes first batch run @ 11:03:44Z | stop 8 §5 table | `12:34:48+02:00` = **10:34:48Z**; first `EXP-P3-SKILL-DESC` run with `exitCode 0` **11:03:44Z**. 28 m 56 s | yes |
| Stop 8's four commits are reachable from `main`; stops 4–6's eleven are not | stop 8 §5, stop 4 (c), stop 6 (b) | `git merge-base --is-ancestor`: `f8ff084 7cf5adb 35abde7 40f38e2` **all REACHABLE**; `59ac936 0e0c6f9 2015555 97e2ed5 e963460 eb02928 5d10e31 d6a13f2 225db94 d55150a 29561a2` **all eleven NOT reachable** | yes |
| Stop 7: `grep -c "^## .*DEFERRED"` → 3; four sources not among moved/blocked | stop 7 §5 table | **3**; `check-links.sh` → `ok=64 moved=8 blocked=2 broken=0`, and **none of the four Phase 2 URLs appears in the MOVED or BLOCKED lists** | yes |
| Benchmark `tasks/`+`sample-service/` byte-identical `8aadc75` → `0448643` | stop 4, stop 6 independence checks | `git diff --stat 8aadc75 0448643 -- tasks/ sample-service/` → **empty** | yes, and see correction 4.1 |

**Two scored cells re-derived by hand off the kept worktrees**, per §9 check 3, chosen so as not
to repeat cells the third and sixth passes already re-read.

- **Run `8998ef3b`** (stop 8, matched arm — deliberately one of the two runs correction 8.1 is
  about). `ShipmentController.confirm()` reads
  `val confirmed = when (shipment.status) { CREATED -> …; CONFIRMED -> shipment; CANCELLED -> throw … }`.
  One `when (shipment.status)`, **expression position** (its value is assigned to `confirmed`,
  then returned via `repository.save(confirmed)`), **no `else`**. Anchor 2's three clauses all
  hold. **Validator 2 · sheet 2.**
- **Run `4c891809`** (stop 4, the E-002 isolated run the §5 table names).
  `return when (shipment.status) { CANCELLED -> throw …; CREATED -> repository.save(…); CONFIRMED -> shipment }`.
  One `when`, expression position (returned), no `else`. **Validator 2 · sheet 2 · the workbook's
  hand reading 2.**

---

## Corrections, per stop

### 4.1 — NEW. A registered variable moved between the B2 baseline arm and every later arm, and every independence check in the track verifies a scope one path short of the worktree the runner builds

This is the house failure mode and it has not been caught by any of the seven earlier passes.

The benchmark sha moved `8aadc75` → `0448643` between `EXP-B2-BASELINE-CLAUDE`/`-CODEX` and
everything after them. That move **is** disclosed. Both the stop 4 and stop 6 independence checks
justify it the same way, and the first and sixth passes both re-derived that justification and
accepted it:

> benchmark `0448643`, byte-identical to B2's on `tasks/` and `sample-service/`

I ran it and it is true: `git diff --stat 8aadc75 0448643 -- tasks/ sample-service/` is empty.

**But the worktree the runner builds is not those two paths.** `agent-observatory/runner/run-agent.sh:211`:

```
WORKTREE_KEEP=(sample-service .gitignore)
git -C "$BENCHMARKS_REPO" archive --format=tar "$BASELINE_SHA" -- "${WORKTREE_KEEP[@]}"
```

**`.gitignore` is archived into every run's worktree from the baseline sha, and it is not
byte-identical between the two shas.** `git diff 8aadc75 0448643 -- .gitignore` changes 16 lines:
`.claude/` becomes `.claude/*` plus `!.claude/hooks/` and `!.claude/settings.json`.

That is the one file this project's own workspace `CLAUDE.md` and author decision 2 single out as
measurement-relevant — *"the benchmarks `.gitignore` is read by the evaluator's scope guard and
changing it changes what the benchmark measures"* — and it is the exact reason author decision 2
routed stop 8's unblocking through a runner force-add rather than through this file. The change
also alters what `git ls-files --others --exclude-standard`, the guard's second source, reports.

**What this does and does not do.**

- It **does not** move any headline. E-002, B3 and stop 8 are all self-contained at `0448643`;
  every within-batch comparison in the track is between arms sharing one `.gitignore`.
- It **does** mean the independence check as written is narrower than what it claims. The
  sentence says the benchmark is byte-identical between the two shas on the paths that matter;
  the paths that matter are three, it checks two, and the third is the measurement-relevant one.
- The affected comparison is the cross-sha one: B3's prose *"the control reproduces B2 on six
  measures"*, and stop 4's own baseline arm sitting at `8aadc75` while its deliberate-failure
  arm sits at `0448643`.

**The correction is one clause, not a re-run:** state the third path and either show its
diff is immaterial to the guard on these runs, or say the cross-sha comparison carries it. A
control that verifies two of the three paths it hands the agent, while reporting as though it
verified the environment, is precisely the shape §6 names.

### 5.1 — The L2 justification names a refusal that executes over a narrower case than the row claims

Stop 5's row *"Can I prove the instruction entered the model's context on a given run?"* is
labelled **L2**, justified as:

> the field is written by the runner per run, **and the runner refuses a customization whose
> instruction file the runtime does not read.** That refusal executes, which is what makes this
> row L2 and not L3

The refusal is real — `run-agent.sh:358-368` calls `die` — and I read it. **Its scope is a
filename mismatch only**: it fires when a customization installs `AGENTS.md` for a `claude` run
and no `CLAUDE.md`. Nothing executes that checks the *correctly named* file was read.

E-003 states this correctly and the workbook does not carry it forward:

> The runner now refuses a customization whose instruction file the runtime does not read, which
> makes the **filename** half of that failure L2. **The content half is still this table's job.**

So the row is L2 for *the file was present under the name the runtime reads, and its digest was
recorded* — which is a real, executing, refusal-backed proof and worth having. It is **not** L2
for *the instruction entered the model's context*, which is what the gate clause asks. The
correction is to split the row: the hash claim keeps its L2; the context claim is **L3**. See the
closing finding, which is this observation followed all the way down.

### 6.1 — Same as 4.1

B3's independence check carries the identical two-path sentence and inherits the identical gap.
B3 is the stop where it matters least — its comparison is against a concurrent control at the
same sha, which is exactly why the "vs B2" clause was answered that way — and the fix is the same
clause.

### 6.2 — "deleted three rules" describes an act that did not happen to the artifact

The §5 row and its amendment both read *"a human read four numbers and **deleted** three rules"*,
and the report and workspace `CLAUDE.md` say `instructions-v0.1` was *"removed and not replaced"*.

`build/customizations/instructions-v0.1/CLAUDE.md` **is still on disk**, still 57 words, still
hashing to `90f95226cc3d429f6f3e157e4741bbd1` — I checked, because the same table's row 1 cites
that file as evidence and would fail if it had gone. Keeping it is correct: §6 forbids removing
evidence, and a deleted overlay would make row 1 unverifiable.

So "removed" is a **decision to retire a version**, honoured in practice (no experiment after
stop 6 uses it; stop 8 uses `skill-v0.2*`, stop 9 `agent-v0.1-*`), and not a deletion. The row is
already labelled L3 and the closure does not turn on it, so this is wording, one word wide — but
"deleted" is the kind of word a later reader re-derives and finds false.

### 8.1 — CONFIRMED A THIRD TIME, STILL UNAPPLIED. Two of the five matched activations were not `claude-proactive`

Raised by pass 6, re-derived by pass 7, re-derived independently here with a parser written for
this pass, and then **confirmed by the project's own tool**. It is not in any workbook.

The §5 row *"the treatment reached the model"* and E-004's results table both say:

> 5 of 5 matched runs carry an activation with `invocation_trigger = claude-proactive`

The telemetry says otherwise:

```
d6aec246  projectSettings=1  custom_skill  claude-proactive
45a70775  projectSettings=1  custom_skill  claude-proactive
2cf0c720  projectSettings=1  custom_skill  claude-proactive
33a4090d  projectSettings=1  custom_skill  nested-skill
8998ef3b  projectSettings=1  custom_skill  nested-skill
```

`./tools/skill-activation.sh … 33a4090d-…` prints `invocation_triggers: nested-skill=1`. **The
repository's own instrument contradicts the row that cites it.**

**Sized, so it is neither dismissed nor inflated.** The registered outcome is *an activation
attributable to the installed project scope*, and that is **5 / 0 / 0, `p = 0.00794`,
unchanged** — I recomputed it. What moves is the mechanism sentence. E-004 defines
`claude-proactive` as implicit selection from the description; if only that trigger counts as
description-driven selection, the evidence is 3 of 5 against 0 of 5 — **`p = 0.16667`** — or 3 of
5 against the pooled 0 of 10 untreated, **`p = 0.02198`**. Neither is `0.0079`. The sentence that
survives at `0.0079` on any reading is the weaker and still-valuable one: **a matched description
produces an activation and a mismatched one does not.** The stop's title claim, *the description
decides whether a skill loads*, is currently wider than its evidence on 2 of 5 runs.

### 8.2 — CONFIRMED, STILL UNAPPLIED. The arm-C half of the "treatment reached the model" row has no artifact on disk

`evidence/p03/` holds exactly two files — `skill-delivery-probe-20260904T072000Z.md` and
`skill-flag-probe-20260904T102230Z.md`. I listed the directory; there is no third. The row's
arm-C evidence — *"explicit `/shipment-service-conventions` in the kept worktrees loaded the skill
and quoted its body in 4 of 6 probed, `Unknown command` in 0"* — is labelled **L2**, *"both are
executions"*, and the execution has left no record. The gate clause is still met at L2 by the
matched arm's five activations, which I re-derived. The arm-C half is currently **L3**: a
statement that six commands were run, with the transcripts absent.

### 8.3 — NEW. The row's own re-derivation command returns 16, not 15

> `curl :8081/api/runs \| jq '[.[]\|select(.experimentKey=="EXP-P3-SKILL-DESC")]\|length'` → **15**

I ran it. It returns **16**. The sixteenth is `62deb6c5` — the registered F13 exclusion, `exitCode
12`, `startedAt 10:50:29Z` — which is correctly disclosed *elsewhere in the same section* and is
simply not subtracted by the command the row hands the stranger. Pass 6 read 16 in its
registered-variable check and did not connect it to this cell.

Small, and it is the cell whose whole job is to let someone else get the same number. The stable
form adds the filter the workbook already applies in prose:
`… select(.experimentKey=="EXP-P3-SKILL-DESC" and .evaluation.exitCode==0) … | length` → **15**.

---

## The §9 checks, answered

1. **Does every gate clause map to evidence that exists at the cited path or id?** Yes, with one
   exception: stop 8's arm-C probe (8.2). Every other cited path opened — five B2 codex sheets,
   five B2 opencode sheets, three `evidence/b02/` files, six `evidence/b03/` files, two
   `evidence/p03/` files, 15 stop-8 sheets, 25 B3 sheets, both stop-8 overlays. One cited *command*
   returns a different number than its cell states (8.3).
2. **Does the prediction commit precede the first run's `startedAt`, read from git and the run
   record?** Yes, for every stop that ran anything: stop 4 by 49 s, stop 6 by 10 s (preflight) /
   3 m 21 s (first treated run), stop 8 by 28 m 56 s. All read with `git log --format=%cI` and the
   API, not from prose. **Stops 4–6's eleven commits remain unreachable from `origin/main`** — I
   confirmed all eleven — so a stranger cloning the repository cannot perform this check for those
   stops at all. Stop 8's four are reachable; author decision 4 worked.
3. **One scored cell per step re-derived from the kept worktree at the registered rubric sha.**
   Done for stops 4 and 8 above, on cells no earlier pass used. Rubric verified at
   `396e1799eb2b` by `shasum -a 256 | cut -c1-12`. Stops 5 and 7 have no scored cells (`n = 0`
   runs launched); stop 6's cell was re-read by pass 1 on `367a809d` and its whole 20-run census
   is reproduced above from the sheets instead.
4. **Did the treatment reach the model and not the control?** Read from run records, not flags.
   Stop 5 and stop 6: `instructionsHash` separates perfectly, zero exceptions, one distinct digest
   per arm. Stop 8: `customization.*Hash` is **`null` on all 16 runs, control and treated alike** —
   it cannot separate the arms, E-004 registers that as prediction 4 holding rather than working
   around it, and delivery rests on telemetry, which I re-derived. **Stop 4/E-002's independent
   variable reached one arm and not the other**: 0×5 against 27–48×5, recounted here.
5. **Any claim stated as a property from `n < 5`?** None found in a closed stop's workbook. Every
   count carries its `n` and the `n < 5` figures are labelled *true of these runs* (the flag matrix
   at `n = 3` per cell, the arm-C probe at `n = 6`, the bloat arm at `n = 5` reported as NOT
   DETECTABLE with its p-values). The one place an `n` is dropped is outside the workbooks: the
   workspace `CLAUDE.md` quotes B3's *"cost only +4.2 %"* with no `n` and no `p`; it is `n = 5`
   against `n = 10`, `p = 0.679`.
6. **Any L1/L2 label on something that does not execute?** One (5.1). I ran the four stop-8
   fixture sets and `check-overlay-parity.sh` to test the L2 labels that claim an executing
   refusal, and read `run-agent.sh`'s `die` for stop 5's. The two L2→L3 relabels the third pass
   made to stop 8's table are present and correct in the file. Stop 7's table is still the
   best-labelled in the track.
7. **Was a registered variable moved between B2 and a later step?** Three moves. Two are disclosed:
   harness `2.1.251` → `2.1.259` (B2 baseline → E-002/B3, disclosed in B3) and `2.1.259` →
   `2.1.260` (→ stop 8, disclosed in E-004 after the third pass). Model
   `claude-haiku-4-5-20251001`, evaluator `1.0.0` and rubric `396e1799eb2b` are single-valued
   across all 66 Track B runs. The third is the benchmark sha, disclosed but justified over a
   scope that omits the changed file — correction 4.1.
8. **For every "remove", is the no-effect measured? For every "keep", is the effect measured?**
   Stop 6 removes three rules and all three no-effects are on record with their instruments: R1
   2/10 vs 3/10 (`p = 1.0`, census + sheets + this validator agreeing), R2 inside the
   pre-registered MDE on both registered outcomes, R3 **20/20 both arms** from
   `convention-census-r3-20-runs`, pooled 34/34 with B2's 14/14. R3 was planted predicted-inert
   before the run, so the clause had to remove something or expose itself — that is the study
   design doing the work, and the row says so. Nothing in a closed stop is *kept* on an assumed
   effect.

---

## The single finding most likely to overturn the track's result if pursued

**The track's only substantive measured result is B3's null, and the track has no runtime-side
proof that the file whose absence of effect it measured ever reached the model. The one
measurement that could have distinguished "delivered and inert" from "never delivered" was made,
was deterministic, and came out null.**

B3's headline — *a 57-word instruction file, proved delivered by hash on 10 of 10 treated and
absent by structure on 10 of 10 controls, moved nothing measurable* — is now load-bearing across
three repositories. The workspace `CLAUDE.md` instructs every future session to read E-003 before
recommending an instruction file anywhere here, and the conclusion it carries is that *the
smallest instruction file that changes measured behaviour is no file.*

What "proved delivered" means here, exactly: the runner copied the file into the worktree,
committed it, hashed it, and the digest is on the run record. The refusal that makes any of this
L2 fires on a **filename mismatch** and nothing else (correction 5.1); E-003's own delivery table
says the content half is unproven and its exit gate then says delivery *"is now L2"* flat. **No
event, exit code, or check in this repository observes the runtime receiving those bytes.** The
proof is that the bytes were at the path the vendor documents the runtime as reading.

Two things make that gap worth chasing rather than shrugging at.

**First, the one test of it failed to fire.** E-003's deliberate-failure arm registered DF2: the
bloated file is 1 400 words larger, roughly 1 900 tokens, committed into the repository before the
agent starts, so those tokens **must** appear in the created prefix. E-003 calls DF2 *"the
deterministic half — the prediction that could falsify the EXPLANATION rather than the effect."*
Observed: `cacheCreationTokens` **+610 median, `p = 0.679`** — NOT DETECTABLE. E-003 records this
honestly, offers cache-bucket migration as an explanation, and states plainly that *"THAT
EXPLANATION IS NOT TESTED HERE."* DF2 was, in effect, the track's only delivery assay for an
instruction file, and it did not see the file.

**Second, this instrument can now do better, and has — for every treatment class except this
one.** Stop 8 proves a skill reached the model with `claude_code.skill_activated` telemetry: the
runtime says it loaded the file. Stop 9's subagent probe gets an exit code — `--agent <bogus>`
exits 1 and prints the registry — which the state file correctly calls the first L2 delivery proof
in the project for any customization class. Instructions are the oldest treatment class in the
track and the only one whose delivery is still argued from disk layout. The asymmetry is not
fundamental; it is unexamined.

**Why it could overturn rather than merely qualify.** If the file was delivered, B3's REJECT is a
finding about instruction files and the lesson stands as written. If it was not — or was delivered
into a part of the context that does not behave as the design assumed — then B3 measured the
runner, not the agent, and the workspace `CLAUDE.md`'s standing instruction is the wrong lesson,
propagated to every future stop. That is the same shape as stop 8's halt, which spent three runs
and a §7 escalation on a premise that turned out to be a flag; and stop 6's B3 is the larger of
the two claims.

**It is cheap, it needs no new arm, and it touches no registered variable.** The 25 B3 runs' raw
telemetry is on disk. Three routes, cheapest first: (1) recheck DF2 against `cachedTokens` and
`inputTokens` on the same kept records — E-003 already notes `cachedTokens` moved **+13.2 %**
while `cacheCreationTokens` moved +610, and whether those 1 900 tokens are anywhere in the
accounting is answerable now, from data already collected; (2) a single positive-control run whose
instruction file demands a token the task cannot otherwise produce, which converts delivery from
inference to observation for about \$0.15; (3) check whether any Claude Code telemetry event names
a loaded instruction file, as `skill_activated` does for skills. Route (1) costs nothing and
should be taken before stop 13, because **B4 at stop 10 registers "run approved commands" as an
allowance and B6 at stop 13 compares runs with and without a specialist skill** — both are
instruction-shaped treatments that will inherit this delivery proof unexamined.

---

## Two notes for the builder, not verdicts

- **Passes 5, 6 and 7 are unprocessed.** `validation_processed` ends at pass 4. Corrections 8.1
  and 8.2 above are passes 6 and 7's, re-derived here independently and confirmed; 8.3 and 4.1 are
  new. All four are additive edits to `phases/03-skills/README.md`, `experiments/E-004-*.md` and
  the two independence-check sentences — none rewrites a prediction, result, sheet or run folder,
  and all should ride with stop 9's PR, which already carries the third pass's five.
- **The amendments still exist only on `stop9/validator-pass-3-corrections`.** `origin/main` is
  `288ceee3` and the branch is unmerged, so a reader of `main` today sees the pre-correction stop-8
  table. Pass 4 raised this and correctly declined to escalate it; it is now four passes old and
  resolves the moment that PR merges.
