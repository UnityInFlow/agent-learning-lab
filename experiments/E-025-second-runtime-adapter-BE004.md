# Experiment E-025 — the portable core on a second runtime, BE-004

**Key:** `EXP-B10-RUNTIME-PORT-BE004` · **Stop:** 21 (B10) · **Version:** v1.2
**Task:** `BE-004-cancel-order` · **Runtime under test:** `codex`
**Workbook:** [`phases/b10-second-runtime-adapter/README.md`](../phases/b10-second-runtime-adapter/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-27T10:2xZ; the author did not review
before the run.`

> Author decision 9: BE-003 and BE-004 are separate experiments with separate keys, separate
> prediction commits, separate controls and separate decision rules. **No verdict is computed
> across tasks.** BE-003 is `E-024`.

---

## Question

The business case claims **P5 — "portable core and thin adapters."** B10 is the only step that
can falsify it. Two questions, and they are deliberately not the same question:

1. **How much of the measured overlay survives a move to a second runtime** — counted two ways,
   as files and as *delivered controls*.
2. **Once it is moved, does the portable part do anything on the second runtime**, measured
   within that runtime against its own concurrent control.

## Hypothesis

**P5 is true of text and false of controls.** The portable-looking part of `agent-v1.2-knowledge`
is portable *because* it is inert: shell scripts nothing wires, YAML nothing reads, a corpus
nothing is obliged to consult. The two pieces that this track has ever *measured* as Layer 2 —
B7's policy gate (17 of 17 executions) and B4/B5's named-agent boundary — are delivered by
`.claude/settings.json` and by the `--agent` flag, and **neither has an analogue the runner can
deliver on codex** (workbook Extract facts 3–7). A framework whose portable half is its inert
half satisfies P5 by construction and buys nothing by satisfying it.

Mechanism for the run half: the ported overlay is `AGENTS.md` plus `.ai/**`. On claude, stop 20
measured the same `.ai/knowledge` corpus arriving on 20 of 20 runs and being consulted by 3 of
20, verdict `VOID — the treatment was not tested`. Nothing about codex makes the *instruction to
consult* more binding, and codex additionally seeds six of its own skills into the session
(Extract fact 10), which competes for the same attention. So the corpus should be delivered and
ignored again.

## Predictions

Direction, magnitude and mechanism for each. Predictions 1 and 2 are the **primary** and need no
run; 3–6 need the batch.

1. **Files that port unchanged: 8 of 11 (73 %).** Mechanism: everything under `.ai/` is shell,
   YAML and markdown that no runtime parses by name; `CLAUDE.md` needs a rename to `AGENTS.md`;
   `.claude/settings.json` and `.claude/agents/backend-feature-phases.md` have no analogue the
   runner can deliver. *One-arm claim: a count, refutable by the census alone.*

2. **Measured L2 controls that survive the port: 0 of 2 (0 %).** Mechanism: the policy gate and
   repair limit are wired by `.claude/settings.json`, which only claude reads and which this
   runner does nothing with on codex; the named-agent boundary needs `--agent`, which
   `codex exec --help` on `codex-cli 0.154.0` does not have and which `run-agent.sh:320-327`
   refuses to forward. *One-arm claim.*

3. **`knowledgeHash` and `instructionsHash` are set on 5 of 5 treated codex runs and `null` on
   5 of 5 codex controls.** Mechanism: both hashes are computed from the customization directory
   at `run-agent.sh:663-668`, before launch, and are runtime-independent. **This is the
   prediction registered as most likely to be wrong**, because every delivery proof in this track
   that was assumed rather than observed has failed at least once, and the codex arm has never
   carried a customization at all — all eight stored codex runs have every hash `null`.

4. **Corpus contact on the treated codex arm is 0 of 5.** Mechanism: stop 20 measured corpus
   contact on BE-004 at **1 of 10** — lower than BE-003's 3 of 10, and that negative was recorded
   as the result for this task. Scaled to `n = 5` that is below one run. Plus codex's six seeded
   system skills competing for the same attention. *One-arm claim, refuted if it reaches ≥ 2 of 5.*

5. **`estimatedCost`, `modelCalls`, `inputTokens` and `outputTokens` are `null` on 10 of 10 codex
   runs, and `reportedTotalTokens` is non-null on ≥ 8 of 10.** Mechanism: `codex exec` has no
   OTel path (ADR-001, obs#10); `run-agent.sh:1236-1244` scrapes a bare total out of the agent
   log. This is gate clause *"observability capability"* stated as a falsifiable number rather
   than as prose.

6. **`architecture-consistency` on the codex scorer does not separate the treated arm from the
   codex control** — the arms land within one rubric point of each other's median. Mechanism:
   the port carries no control that could change the shape of the code; only a corpus that
   prediction 4 says will not be read.

7. **BE-004's evaluator does not pass on 5 of 5 codex control runs.** Mechanism: BE-004 has never
   failed the evaluator on `claude-haiku-4-5-20251001` — 9 of 9 before stop 12, 10 of 10 at B5 and
   B6, 7 of 7 at B7, 10 of 10 at stop 20 — but that is a property of **that model**, and this arm
   changes the model. *One-arm claim about the codex control alone; a pass rate is a result, not a
   nuisance (decision 9). If the control passes 5 of 5 the prediction is refuted and BE-004's
   ceiling on codex is the same as on claude.*

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Within the batch: the presence of the ported overlay**, on the codex runtime, holding task,
benchmark sha, evaluator, runtime binary, model and sandbox policy fixed.

**Across runtimes: nothing is compared.** The claude arms cited in the workbook carry a
different overlay (11 files against 8) and a different model, and `agent-observatory#47` is
open. Three independent reasons, each sufficient. No cross-runtime verdict appears in this file.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | overlay directory `build/customizations/agent-v1.2-knowledge-codex/`, installed by `run-agent.sh --customization`: `AGENTS.md` (the v1.2 `CLAUDE.md` body verbatim) + `.ai/**` (7 files, byte-identical) |
| Content hash | **registered 2026-09-27 at §4 step 4, before the preflight and before any run.** Directory digest over the sorted (path, content) pairs of all nine files: `sha256:65a8b15a320df2ec0a074c4d5fd8038f5867b8f7f6ac3e777e81a6c50407edd8`. Per file, full sha256: `AGENTS.md` `ebf489800a60a156986f98ea4f127848222a0ca449983c6831230e99b17ec3cb` · `.ai/knowledge/index.yaml` `57cda5082f15a81f65aa427b55bd412246912cd63222cb12b3468ce83ef5bcef` · `.ai/knowledge/router.sh` `5cb83b49f81c6c7c2794aeba7dd622d078bcc7d551dda67cb5743490b0145e4b` · `.ai/knowledge/documents/kotlin-exhaustive-when.md` `5a8881116e1dbd048f821bc7b92ac2167a2935ed9fc8ba2f2a5085f340f634f9` · `.ai/knowledge/summaries/kotlin-exhaustive-when.md` `f38b03186f726b92c4191677b3a32d522e9e9c326574713146ac477f3449f2fb` · `.ai/policies/protected-paths.yaml` `76c4c34c0f4ca5ebeb12dbb3c25bd717533a6219b2ba9ab0a340c41dc90663e6` · `.ai/hooks/policy-gate.sh` `f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca` · `.ai/hooks/repair-limit.sh` `fa38193a5093c09bf0261947b0b4d2750b9c973b90fb17123eec82519077cea5` · `.ai/hooks/repair-record.sh` `7339e63045fa4e2a2ecd835d57e317d948c38acad5f0b1a6ca5c1dcf897c767a`. **The two hashes the record will carry are registered as exact values, not as "non-null":** `instructionsHash` = `sha256:ebf489800a60a156986f98ea4f127848` and `knowledgeHash` = `sha256:0770219ae7f4281a80071d78dadea285` — computed from the runner's own `hash_of()` (`run-agent.sh:572-576`) and `knowledge_hash()` (`:653-668`) and **read back from a real `--check-customization` invocation**, not predicted. Both are **bit-for-bit the values stop 20 registered for the claude arm** (`evidence/b09/run-b9-batch.sh:73,75`), which is the strongest available statement that the portable half ported: not "the same text", the same digest. Modes were checked too, because stop 20's deliberate failure proved a mode bit is in no hash: `755` on all four `.sh`, `644` on the rest, identical on both sides. |
| Preflight assertion | one codex run per arm under key `EXP-B10-PREFLIGHT-BE004`, **not in the population**: treated shows `customization.instructionsHash` and `knowledgeHash` non-null; the `init` read-back per author decision 8 is recorded for the codex arm even though codex has no `tools:` list, because *"the runtime rewrites the list before the model sees it"* was discovered exactly by taking that read-back on an arm nobody expected it from |
| Control assertion | control run shows all five `customization.*Hash` `null`, read back from the record, not inferred from the absent flag |

> Placing a file is not delivering a treatment. Stop 20 proved the sharper version: **delivering a
> file is not delivering a behaviour** — 20 of 20 delivered, 3 of 20 consulted.

## Census result — predictions 1 and 2, answered 2026-09-27 with no run and no money

Registered before it was computed; the decision rule says in terms that *"the census verdict is
separate and is not gated by any run"*. Script `evidence/b10/census-port.sh` (ShellCheck clean),
transcript `evidence/b10/census-port-20260927.txt`, exit 0 — every probe behaved as registered.

**Prediction 1 — files that port unchanged: 8 of 11. HELD, at exactly the predicted number.**
Source overlay 11 files, ported overlay 9. `diff -r` over the `.ai` tree returns **nothing**: all
eight files are byte-identical. `CLAUDE.md` and `AGENTS.md` are the same bytes at a different path
— a **rename**, which prediction 1's own mechanism excludes from "unchanged". The two files that do
not port at all are `.claude/settings.json` and `.claude/agents/backend-feature-phases.md`.

**Prediction 2 — measured L2 controls that survive the port: 0 of 2. HELD — and the two are lost
in two different ways, which the prediction did not distinguish and which is this census's own
finding.** Five probes, each an invocation of the real `run-agent.sh --check-customization`, which
installs the overlay, hashes it and exits before the model is called (`:670-686`), so the whole
census cost nothing:

| probe | what it installs on codex | exit | what executed |
|---|---|---|---|
| 1 | the 9-file port | **0** | `tracked overlay files in the setup commit: 9 of 9`; hashes exactly as registered above |
| 2 | the 11-file claude overlay unchanged | **1** | `run-agent.sh:406` — *"installs 'CLAUDE.md', which runtime 'codex' does not read"* |
| 3 | the port **plus `--agent`** | **1** | `run-agent.sh:325` — *"--agent … is not forwarded to runtime 'codex'"* |
| 4 | the port **plus `.claude/agents/`** | **1** | `run-agent.sh:522` — *"codex reads no agent directory at all"* |
| 5 | the port **plus `.claude/settings.json`** | **0** | `tracked overlay files in the setup commit: 10 of 10`, **and nothing refused** |

**The named-agent boundary is lost loudly. The policy gate is lost silently.** Probes 3 and 4 are
the **L2** proof for one of the two controls: two independent refusals execute, and a port that
tries to carry the boundary does not start. There is **no** equivalent for the other. Probe 5
shows `.claude/settings.json` — which is how B7's policy gate (measured at 17 of 17 treated runs)
and B8's repair limit are wired — copied, committed, **tracked**, and read by nothing, at exit 0.
No `settingsHash` or `hooksHash` appears in the customization block at all: the five fields are
`instructionsHash`, `skillsHash`, `agentHash`, `agentsHash`, `knowledgeHash`. So that control's
absence is provable only by reading the runner and by `hooksHash` being null on every run ever
recorded — **L3**, and it is labelled L3 here and in the workbook.

**Both halves of P5 therefore hold at once, and the pair is the stop's headline rather than either
number alone:** 8 of 11 files port unchanged (73 %), and 0 of 2 measured L2 controls survive — one
refused by something that runs, one lost with nothing to say so.

*Census computed and interpreted by Opus 5 (claude-opus-5), autonomously, 2026-09-27; the author
did not review before it ran. It moved no registered variable and no prediction was edited.*

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` at the sha stop 20
      used, read back per run, **identical on both arms**
- [ ] task + revision — `BE-004-cancel-order`, unchanged since stop 12 (benchmarks#29 → `eea144ef`)
- [ ] harness + version — `codex` **`codex-cli 0.154.0`**, read back from `runtime.version` on
      every run. **This is a moved variable against the stored codex baseline**, which is
      `0.147.0`: the five `EXP-B2-BASELINE-CODEX` runs are therefore a *transferred* reference and
      not a control, and the control that decides anything here is the concurrent one
- [ ] model — **`gpt-5.6-sol`**, exact id, forwarded and enforced by `run-agent.sh:305-312`
- [ ] permissions — `--sandbox danger-full-access`, `--disable plugins`, as `run-agent.sh:912`
- [ ] environment — isolated `CODEX_HOME` + `HOME`. **Not claimed as proven:** the codex
      isolation verifier reported `ISOLATION LEAKS` on 2026-09-27 (workbook Extract fact 11).
      Re-running it is the first act of §4 step 4 and the arm does not open until it is resolved
      one way or the other; if it leaks on both arms alike it is recorded as a shared uncontrolled
      variable, not silently
- [ ] runner commit — the same sha on both arms, recorded per run
- [ ] **uncontrolled and named:** codex seeds six skills into `skills/.system` on both arms
      (`run-agent.sh:934-940`); `--enable-skills` is a no-op on codex (Extract fact 10)

## Isolation, resolved at n = 3 before the arm opened — 2026-09-27

`## Controlled variables` registers the environment row as **not claimed as proven**, because
`runner/verify-codex-isolation.sh` reported `ISOLATION LEAKS` at this session's §0a preflight, and
§4 step 4's registered first act was to resolve it *"one way or the other"* at `n = 3` before any
arm opened. It was resolved. `evidence/b10/probe-codex-isolation.sh` (ShellCheck clean, wall-clock
bounded at 420 s per invocation with a process-**group** kill, because macOS has no `timeout` and
`LAB_REVIEW_TIMEOUT`'s poll loop has already been seen not to kill what it polls):

| invocation | exit | verdict | log |
|---|---|---|---|
| 1 | 0 | `ok: ALL THREE checks hold for codex-cli 0.154.0` | `evidence/b10/iso-probe/run-1-20260927T123945Z.txt` |
| 2 | 0 | same | `evidence/b10/iso-probe/run-2-20260927T124200Z.txt` |
| 3 | 0 | same | `evidence/b10/iso-probe/run-3-20260927T124416Z.txt` |

Each invocation's **positive control fired first** — the marker present without isolation, the
operator's instruction files found with a real `HOME`, four plugins installed without
`--disable plugins` — so all three negative results mean something rather than describing a
model that declined to look.

**The earlier `ISOLATION LEAKS` did not reproduce, and it is recorded as unreproduced rather than
as refuted, for a reason that is about evidence and not about tact: its output was not kept.** It
survives only as a message quoted in `TRACK-B-STATE.md`. The only artefact on disk from that
episode is `evidence/b10-iso-probe-20260927-wedged.txt`, which is **64 bytes — one line** — from
the *second*, wedged invocation. So there is nothing to re-derive the leak from, and no reading of
today's three passes can settle what the one failure saw.

**A mechanism can be named but not measured, and it is written down as a hypothesis.** Check B's
leak branch greps the redirected-`HOME` run's *output* for the literal strings `$HOME/.agents/`
and `$HOME/.codex/skills` (`verify-codex-isolation.sh:135`). A model that reached nothing but
*narrated* the path it tried — "checked /Users/&lt;op&gt;/.agents, nothing there" — would trip that
branch. That would make the detector match a **mention** rather than a **reach**, which is the
house failure mode inverted: a control reporting failure over a scope wider than it claims. It is
**not** asserted here; the output that would prove or disprove it was not kept.

**So the registered statement for both codex arms is this, and it is deliberately weaker than
"isolation holds":** the isolation control is **L2** — three checks that execute, each with a
positive control — and it is **verified at `n = 3` on the exact binary (`codex-cli 0.154.0`) this
batch uses, hours before the batch**. On the same machine and the same day it also produced one
unreproduced leak report and one wedge. **That intermittency is recorded as a shared uncontrolled
variable across both codex arms**, not as a resolved question: both arms run through the same
`--isolate-user-settings` path, so an intermittent leak would fall on treated and control alike
and cannot manufacture a within-runtime difference — which is the only comparison this experiment
computes. It could, however, contaminate both arms against the *cited* claude rows, and no
cross-runtime verdict is computed here for three independent reasons already on record.

*Resolved and interpreted by Opus 5 (claude-opus-5), autonomously, 2026-09-27; the author did not
review before the runs. The probe decides nothing on its own — it records three outcomes and this
paragraph is the judgement.*

## Runs

Repetitions per arm: **5** (floor 3, §4 step 6) · Total budget: **20 codex runs across E-024 and
E-025, 4 h of batch wall-clock**.

**No dollar budget is written, and that is not an omission.** `estimatedCost` is `null` on 8 of 8
codex runs ever recorded, so a dollar ceiling cannot fire on this arm.

**And there is no stored codex run on this task at all.** All eight codex records are BE-003.
Wall-clock is therefore *transferred* from BE-003's stored codex median of 115 s and scaled by the
ratio this project has already measured between the two tasks on claude — BE-004 is five files and
two suites and runs roughly two to three times BE-003 — giving an expected 4–6 min per codex run
and the same 4 h batch ceiling. **That scaling is a transfer, not a measurement**, and the first
BE-004 codex control run replaces it.

## Preflight result — §4 step 5, 2026-09-27, PASSED 4 of 4

Driver `evidence/b10/run-b10-preflight.sh`, manifest
`evidence/b10/preflight-20260927T124708Z/manifest.tsv`, key `EXP-B10-PREFLIGHT-BE004` —
**excluded from the population** by `## Exclusions`, and given its **own** key rather than the
batch's, because `run-b9-preflight.sh:134` handed the preflight the batch's key at stop 20 and
`make baseline-report` then pooled 25 runs into a registered population of 20.

| task | arm | verdict | `instructionsHash` | `knowledgeHash` | eval | `reportedTotalTokens` | `durationMs` | changed |
|---|---|---|---|---|---|---|---|---|
| BE-003 | control | **ok** | `null` | `null` | 0 | 31 067 | 81 000 | 2 |
| BE-003 | treated | **ok** | `sha256:ebf489800a60a156986f98ea4f127848` | `sha256:0770219ae7f4281a80071d78dadea285` | 0 | 24 523 | 112 000 | 4 |
| BE-004 | control | **ok** | `null` | `null` | 0 | 29 454 | 154 000 | 8 |
| BE-004 | treated | **ok** | `sha256:ebf489800a60a156986f98ea4f127848` | `sha256:0770219ae7f4281a80071d78dadea285` | 0 | 30 706 | 122 000 | 8 |

**Prediction 3 — the one registered as most likely to be wrong — holds on the preflight pair, at
the exact registered digests rather than merely non-null.** The reason it was registered that way
is that *"the codex arm has never carried a customization at all — all eight stored codex runs have
every hash `null`"*. It carries one now. The control assertion holds in its own right and was
**read back from the record**: all five `customization.*Hash` `null`, not inferred from the absent
flag. The batch's own `n = 5` per arm is what the prediction is scored against; the preflight is
not in that population.

**The `init.tools` read-back is `absent` on all four runs, and that is a measurement.** Author
decision 8 requires it *"even though codex has no `tools:` list"*, because E-005's rewrite —
`Read, Grep, Glob, Bash` delivered as `["Read","Bash"]` on 10 of 10 — was found by taking this
read-back on an arm nobody expected it from. Here it produces nothing: `codex exec` emits no
`init`/`system` record that `INIT_SCHEMA_DIR` can capture. So the tool-schema question is **not
answerable on this runtime with this instrument**, which is an observability limitation of the
codex adapter and is reported under the gate's *"document each provider's limitations"* clause
rather than passed over.

**`estimatedCost`, `modelCalls` and `toolCalls` are `null` on 4 of 4 and `reportedTotalTokens` is
set on 4 of 4** — prediction 5's shape, visible before the batch. It is scored on the batch, not
here.

### The preflight found the thing nobody predicted, and it is recorded without touching prediction 4

**Both treated runs called the router — 2 of 2 — and each called it exactly once, on a `hit`.**
The two logs are kept at
`evidence/b10/preflight-20260927T124708Z/router-logs/knowledge-log-observatory-run-{{fcd1b669…,5314a421…}}.jsonl`
and copied out of `$TMPDIR` at the end of the run that wrote them, because `router.sh:51` writes
outside the worktree and macOS reaps `$TMPDIR` in about three days. The queries are the task's,
not boilerplate:

- BE-003: `implement shipment status transition from CREATED to CONFIRMED, idempotent when already CONFIRMED, reject CANCELLED`
- BE-004: `implement order and shipment status enum branching cancellation state transitions Kotlin when versus if`

**Prediction 4 says corpus contact on the treated codex arm is ≤ 1 of 5, and this is 2 of 2 on
runs that are not in the population.** The prediction is **not edited** (§4 step 12) and this note
is not a result: preflight runs are excluded, `n = 2`, and §5 forbids stating anything from
`n < 5` as a property — it is true of these two runs. It is written down here, before the batch,
so that whichever way the batch falls the reader can see the signal was visible in advance and was
left alone. **If the batch refutes prediction 4, the interesting number will not be codex's rate
but the comparison with claude's 3 of 20 at stop 20** — same corpus, same instruction text, same
digests, different runtime — and that comparison is blocked as a *quality* claim and permitted as
an *uptake* one, because uptake is read from the router's own log rather than from a rubric.

*Recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-27, between §4 step 5 and step 6; the
author did not review. No prediction, MDE row or decision rule was edited.*

## Minimum detectable effect

**There is no stored codex population on BE-004 of any kind** — not a rubric sheet, not a run.
All eight codex records on the API are BE-003, and none of them has a sheet. So **every MDE row
below is registered as undefined before the batch**, and BE-004's own concurrent codex control is
its first measurement — exactly the pattern decision 9 item 3 registered when BE-004 first had no
stored baseline at stop 12. Saying so is the honest register rather than inventing a spread.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary (census): files and controls that port | none needed — a count over 11 files | exact | **yes** |
| primary (run): `architecture-consistency`, codex scorer, rubric `6252778b8472` (`backend-quality-be004.yaml`) | **none exists on codex** | **undefined before the batch; the concurrent control is its first measurement**, as decision 9 item 3 did for BE-004 | **yes, as undefined** |
| secondary: corpus contact | stop 20, 3 of 20 on claude, **transferred** | at `n = 5`, 0/5 vs 3/5 is Fisher `p = 0.17` — **not decidable**; the prediction is therefore written as a one-arm claim, which needs no control | **yes** |
| secondary: `reportedTotalTokens` | **none on this task** — all 8 stored codex runs are BE-003 | **undefined before the batch;** the concurrent control is its first measurement | **yes, as undefined** |

**A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as refuted.**

## Deterministic evaluation

`agent-observatory-benchmarks` `BE-004-cancel-order/evaluator.sh`, on BE-003's exit-code
contract, unchanged since stop 12, `verify-evaluator.sh` re-run on `main` at 12 of 12. The evaluator decides correctness; the rubric decides nothing about
correctness.

## Exclusions

Registered now:

- the two preflight runs (`EXP-B10-PREFLIGHT-BE004`) are **not in the population**;
- F13 — a run whose `durationMs` is implausible against the batch (machine sleep) has its
  **duration** excluded, not the run (§4 step 6); the stored BE-003 codex run `77c7d1c3` at
  35 342 s is the precedent;
- F15 — a run the runner refuses before launch is not a run;
- a run in which codex is refused on quota mid-batch is excluded and the batch stops (§4c);
- **row 0a, void before scoring:** a treated run whose `instructionsHash` *or* `knowledgeHash` is
  `null`, or a control run with any hash non-null.

## Decision rule

Registered before data. Rows are checked **in order** and the first that matches is the verdict.
`H` = treated runs with corpus contact, out of the treated population that cleared row 0a.

| row | condition | verdict |
|---|---|---|
| **0a** | ≥ 2 treated runs void on the delivery proof | **VOID — not delivered.** Report the count; no other row is evaluated |
| **0b** | the batch reaches 20 runs or 4 h before both arms reach `n = 3` | **stop; report the population that occurred**, then continue at the first row below that can be evaluated |
| **0c** | codex refuses on quota before both arms reach `n = 3` | **DEFERRED** under §4c; not a §7 halt |
| **1** | delivery proof holds and `H = 0` | **VOID — the treatment was not tested.** The corpus arrived and nothing read it |
| **2** | `H ≥ 1` and `architecture-consistency` medians differ by ≥ 1 point in the treated arm's favour, Fisher or Mann–Whitney on the arms that occurred | **IMPROVED** |
| **3** | `H ≥ 1` and the medians differ by ≥ 1 point against the treated arm | **REJECT** |
| **4** | `H ≥ 1` and the medians are within 1 point | **NOT DETECTABLE at this `n`** |
| **5** | *(reported separately in every case, never a condition on another row)* `reportedTotalTokens` median moves by more than the stored range | **reported as a cost row, not a verdict** |

**The census verdict is separate and is not gated by any run:** predictions 1 and 2 are answered
from the file census and the runner's three refusals, and they answer P5 whatever the batch does.

**Useless-and-cheap is still a rejection** — cost is row 5 and is never a second condition on a
failure row.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

**`estimatedCost`, `modelCalls`, `toolCalls`, `permissionDenials` and `retries` are `null` on
20 of 20 runs of this batch** — both arms alike, which is a measurement and is prediction 5's
subject. `reportedTotalTokens` is non-null on 20 of 20, scraped out of the agent log at
`run-agent.sh:1236-1244`. `durationMs` survives too, from the runner's clock rather than the
agent's.

So the gate clause **"observability capability"** is a count: **one** of the six behaviour and
efficiency numbers this track reads on claude crosses to codex.

**Prediction-commit ordering, checked after the runs as §4 step 3 requires**, from git and the
run records rather than from this file's prose:

| | value |
|---|---|
| prediction commit `05aaf3e` | `2026-09-27T12:12:30+02:00` = **10:12:30Z** |
| first run of the batch `a06c2daf` `startedAt` | **2026-09-27T12:58:09Z** |
| first BE-004 run `efd94f24` `startedAt` | **2026-09-27T13:02:54Z** |
| last run `63e7739f` `finishedAt` | 2026-09-27T13:45:43Z |
| margin | the prediction precedes the first run of this task by **2 h 50 m 24 s** |

## Results

Population: **`n = 5` per arm.** `check-run-gate.sh` exit 0 with `gate passed (exitCode 0)` on
10 of 10 BE-004 runs (20 of 20 across both tasks,
`evidence/b10/batch-20260927T125809Z/run-gate.tsv`), so nothing is excluded by Decision D.
Every sheet carries exactly four `score:` lines — **zero stalls, zero retries, first attempt on
all 10**.

Registered scorer codex (Decision C), rubric **`6252778b8472`**, asserted on disk by the driver
before it ran. **Second reader DEFERRED per run** — `ollama-cloud` has been on its weekly limit
for five consecutive sessions. Decision H is **not** fired; it promotes the unavailable model.
Author decision 10.3's `change-focus` carve-out **does not bite here**, because these sheets are
codex, the registered scorer, not the fallback — so `change-focus` below is admissible.

### The registered primary outcome

| arm | `architecture-consistency`, every run | median |
|---|---|---|
| control | 2, 2, 2, 2, 2 | **2** |
| treated | 1, 1, 2, 2, 2 | **2** |

Difference `0`. Mann–Whitney U = 7.5, **exact** two-sided `p = 0.4444` (= 4/9) — exact, not the
normal approximation, which is wrong at `n = 5`.

**Decision rule, walked in order** (`evidence/b10/decide-b10.py`, transcript `decision.txt`):
row 0a does not fire (0 void); row 0b does not fire (both arms reached `n = 5` ≥ 3 inside the
20-run and 4-hour ceiling — the batch finished 20 runs in 48 minutes); row 0c does not fire;
row 1 does not fire (`H = 5`); row 2 does not fire; row 3 does not fire; **row 4 FIRES.**

> ### Verdict: NOT DETECTABLE at this `n`.

### The registered outcome was at its ceiling in the control here too

The **control scored 2 on 5 of 5**, the maximum of the 0–2 scale, so improvement was
arithmetically impossible on this cell before the first treated run started. The MDE registered
this outcome as *"undefined before the batch; the concurrent control is its first measurement"* —
and that first measurement is **zero variance at the maximum**.

**This is the one place BE-004 was supposed to help, and it did not.** Author decision 9 added
this task precisely because E-006 found 50 of 100 rubric points at zero variance on BE-003 with
`claude-haiku-4-5-20251001`. The fix was written against that model. On `gpt-5.6-sol` the harder
task's control is at ceiling on this dimension just as BE-003's is, so **the headroom decision 9
bought does not transfer across runtimes.** That is a finding about decision 9's scope, not a
failure of it.

Two treated runs scored **1**, and the movement that exists is therefore *downward* — which is
the only direction a ceiling leaves open. It is inside the MDE and is recorded as NOT DETECTABLE,
never as a rejection (registered: *"a result that lands inside an MDE is recorded as NOT
DETECTABLE at this `n`, never as refuted"*).

### What did move — reported as co-variates, and neither is this experiment's result

| category | control | median | treated | median | direction |
|---|---|---|---|---|---|
| `maintainability` | 0, 0, 0, 0, **null** | **0** (`n = 4`) | 2, 2, 2, 2, 2 | **2** | **for** the treated arm |
| `test-quality` | 1, 1, 1, 1, 1 | 1 | 1, 1, 1, 1, 2 | 1 | flat |
| `change-focus` | 1, 1, 1, 1, 1 | **1** | 0, 0, 0, 0, 0 | **0** | **against** the treated arm |

Two of the three moved, in **opposite directions**, each with zero within-arm variance:

- **`maintainability` 0 → 2 on 5 of 5.** The same move, same magnitude, same direction as
  BE-003's. Two tasks agreeing is the strongest signal in this batch.
- **`change-focus` 1 → 0 on 5 of 5.** Every treated run scored the floor and every control run
  scored 1. The treated arm also touches more: `changedFiles` median 7 both arms but range
  7–9 treated against 6–7 control, `addedLines` median 171 against 166, `deletedLines` median 18
  against 16. So the overlay is **plausibly making the diff wider**, which is what `change-focus`
  penalises.

**Neither is a result of this experiment and this file does not report them as one.** Only
`architecture-consistency` was registered; §4 step 12 and §5 forbid promoting a co-variate after
seeing it, and E-004 refused exactly this move. Two further reasons to hold `change-focus`
especially loosely: author decision 10.2 records that on 34 runs codex and the second reader agree
34/34 on the other three categories and only **18 of 34** on `change-focus`, always in the same
direction — so it is the noisiest dimension in the instrument — and the second reader that would
test it is unavailable.

The weighted total moves with the two of them and nets out small: control median 55.0
(`n = 4`), treated median 72.5. Reported under the same restriction.

### Row 5 — the cost row, reported, never a verdict

`reportedTotalTokens`: control median **29 624** (range 24 989–46 238, width 21 249), treated
median **33 349** (range 30 367–40 158). The median shift of **+3 725 (+13 %) is INSIDE the
control's range**, so on this task row 5 does **not** clear its own threshold — unlike BE-003,
where the shift was +34 % and outside it. The control's range is three times wider here, which is
the whole reason, and it is a property of the harder task rather than of the treatment.
`durationMs` median 138 000 → 145 000 ms.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | files port unchanged 8 of 11 | **HELD** | 8 of 11 (73 %), census, exactly the predicted number |
| 2 | measured L2 controls survive 0 of 2 | **HELD** | 0 of 2, both losses traced to a named runner line |
| 3 | both hashes set 5/5 treated, null 5/5 control | **HELD** | `instructionsHash sha256:ebf489800a60a156986f98ea4f127848` AND `knowledgeHash sha256:0770219ae7f4281a80071d78dadea285` — the **full** values against the registered ones, not a non-null test — on 5 of 5 treated; all five `null` on 5 of 5 control. Re-derived from `GET /api/runs/{id}` for all 20, not read off the driver's own manifest. **Registered as the prediction most likely to be wrong; it held cleanly.** |
| 4 | corpus contact **0 of 5**, refuted at ≥ 2 of 5 | **REFUTED** | **5 of 5** — the whole population, past a threshold set at 2 |
| 5 | cost/calls/tokens null 10/10, reportedTotalTokens ≥ 8/10 | **HELD** | `estimatedCost`, `modelCalls`, `toolCalls` `null` on 10 of 10; `reportedTotalTokens` non-null on 10 of 10 |
| 6 | `architecture-consistency` does not separate | **HELD** | medians 2 vs 2, difference 0, exact `p = 0.4444` |
| 7 | BE-004 evaluator does **not** pass 5/5 on the codex control | **REFUTED** | **5 of 5 passed**, exit 0. And 5 of 5 on the treated arm too |

**Five of seven held; both refutations are worth more than the five.**

**Prediction 7's refutation is the load-bearing one.** It was written on the reasoning that
BE-004's perfect evaluator record — 9 of 9, 10 of 10, 7 of 7, 10 of 10 — is *"a property of
**that** model, and this arm changes the model."* It is not: `gpt-5.6-sol` also passes 10 of 10.
So **BE-004's ceiling is a property of the task, not of `claude-haiku-4-5-20251001`** — and a task
that two model families from two vendors never fail has no correctness headroom for any later
step to measure. Decision 9's *"pass rate is a result, not a nuisance"* applies: this is the
result, and it is a constraint on every remaining B step that uses BE-004.

**Prediction 6 held for a mechanism its own batch refutes.** It predicted no separation *"because
the port carries no control that could change the shape of the code; only a corpus that prediction
4 says will not be read."* The corpus **was** read, 5 of 5. The number is right, the stated reason
is wrong, and the actual reason — the control at ceiling — appears in neither prediction.

## Failure analysis

**1. Prediction 4 refuted at 5 of 5 against a predicted 0 of 5.** The transferred reference was
stop 20's **1 of 10** on this task with claude, scaled below one run. It was the wrong reference
class: measured on `claude-haiku-4-5-20251001` under a `.claude/` overlay, applied to
`gpt-5.6-sol` under an `AGENTS.md` overlay. **Stop 20's corpus-contact rate is not evidence about
codex in either direction.** The prediction stands as written (§4 step 12).

**2. Prediction 7 refuted, and BE-004 is now measured as ceilinged across two model families.**
Above. This goes to `author_notes` because it bears on stops the author owns: it is the second
independent reason (after `architecture-consistency` at ceiling) that BE-004 cannot discriminate
on this runtime, and it is evidence for the premise behind author decision 11's BE-005 — that a
task needs headroom built in from the first sentence rather than added by size.

**3. The primary outcome could not move, on both tasks, and the missing control was cheap.**
There was **no control-arm rubric census before the batch**. One codex control run scored on the
registered rubric — **18 seconds** at this batch's median per-sheet time (13 s fastest, 37 s
slowest, 400 s for all 20) — would have shown `architecture-consistency = 2` and turned the choice
of primary outcome into a decision. That is
the cheapest missing control in the track. `author_notes`.

**4. One null cell, bounded, on this task's control arm.** `efd94f24` scores
`maintainability: null`, `reason: "ambiguous: 0 vs 1; status if is delegated outside the method
named cancel"`. A missing cell is not a null cell and this is a **null cell** — the scorer used
the rubric's ambiguity escape hatch and **named both candidates, 0 and 1, both below the treated
arm's 2**. The `maintainability` direction therefore does not depend on it. It is excluded from
that arm's median rather than imputed, which is why that cell reads `n = 4` and why the arm's
weighted total does too.

**5. What this experiment still cannot say.** No cross-runtime quality verdict, for the three
independent reasons in the workbook's `## Goal`. The comparison here is **within codex only**,
treated against its own concurrent control.

## Sanity checks

- [x] **Did any dramatic number appear? Has it been explained *and* the explanation tested?**
  Two. **(a)** Corpus contact 5 of 5 against a predicted 0 — explained by the router being
  invoked, and **tested rather than asserted**: a per-run router log was copied out of `$TMPDIR`
  for each of the 5 treated runs (`router-logs/knowledge-log-observatory-run-*.jsonl`, 1 line
  each, `corpus_contact=router`) while the control column reads `none` with 0 lines on 5 of 5.
  **(b)** `change-focus` at the floor on 5 of 5 treated — explained by a wider diff, and that
  explanation is tested against `changedFiles`, `addedLines` and `deletedLines`, all three of
  which are higher on the treated arm. It remains a co-variate on the instrument's noisiest
  dimension and is not claimed.
- [x] **Did any flattering number appear? Has it been disbelieved twice?**
  Yes — `maintainability` 2 on 5 of 5 treated against a control median of 0. Disbelieved twice:
  **(a)** it is not a registered outcome and enters no row of the decision rule; **(b)** the
  control's floor is softer than `0, 0, 0, 0` looks, because the fifth cell is the scorer calling
  the same dimension ambiguous between 0 and 1. Third: the second reader that would test it is
  unavailable, so this is one harness unchecked. **And the flattering number has a companion
  moving the other way** — `change-focus` 1 → 0 on 5 of 5 — which is the reason the weighted
  total nets out to something far less impressive than `maintainability` alone suggests.
- [x] **If a fix motivated this run, did the original symptom actually disappear?**
  Not applicable — no fix motivated it. The isolation question that opened §4 step 4 did resolve:
  `verify-codex-isolation.sh` returned `ok: ALL THREE checks hold for codex-cli 0.154.0` at exit 0
  at this session's §0a, after leaking once and wedging once the session before. Recorded as
  resolved-at-`n`-observed, not as a fix.

## Decision

**Keep the port; make no claim for it on this outcome; and record BE-004 as ceilinged on codex.**

- The **port is kept**: delivered on 10 of 10 treated runs across both tasks by exact hash, 8 of
  11 files crossed unchanged. P5's *"portable core"* half is **supported** at the file level and
  by delivery proof.
- P5's *"thin adapters"* half is **refuted by the census**: 0 of 2 measured L2 controls survive.
  What crosses is prose and a corpus; what does not cross is every control that executes.
- **No `keep`/`remove` decision on the knowledge corpus from this stop.** §4 step 10's *"a rule
  with no measured effect is removed"* does **not** apply — this is not a measured no-effect, it
  is an outcome with **no headroom**, and conflating the two would remove a mechanism the
  co-variates suggest is doing the most visible work in the batch. That distinction is the thing
  from this stop most worth carrying forward.
- **BE-004 is recorded as having no correctness headroom on either model family** — 10 of 10 on
  `gpt-5.6-sol` here, beside the record already on file for `claude-haiku-4-5-20251001`, quoted
  rather than re-totalled because the per-arm counts do not add to a single figure without
  assuming how the arms were pooled: *"9 of 9 before stop 12, 10 of 10 in every arm at B5 and B6,
  7 of 7 in both arms at B7"* (run prompt §3, author decision 11), plus 10 of 10 per arm at stop
  20. **No batch on either model has ever produced a BE-004 evaluator failure.** That sentence is
  what the evidence supports; a total is not. Also no rubric headroom on `architecture-consistency`
  on codex. Both go to `author_notes`.
- **Primary runtime: claude. Fallback: codex** — the gate's *"pick primary and fallback"* clause
  answered from this batch, and answered the same way on both tasks: codex loses 5 of 6
  observability numbers and both executing controls, and gains nothing measurable on the
  registered outcome.

## Follow-up

1. **Register a control-arm rubric census before any future batch**, before the primary outcome
   is chosen. `author_notes`.
2. **`maintainability` on codex is the outcome a later stop should register** — it is the only
   dimension that moved the same way on both tasks — with its prediction written before any of
   these sheets are re-read.
3. **`change-focus` needs the second reader before anyone builds on it**, per decision 10.2's
   18-of-34 concordance. Deferred, not waived.
4. **BE-004's ceiling is now measured on two model families** and is an input to whatever the
   author decides about BE-005 and later steps. Not the builder's to act on (§7: a new task is
   the author's).
5. The second reader is owed on all 20 run ids; when `ollama-cloud` returns, `opencode-score.sh`
   on the same ids, labelled as the second reading produced after the registered sheet.

*Filled in from evidence by Opus 5 (claude-opus-5), autonomously, 2026-09-27. No prediction, MDE
row or decision rule in this file was edited after its run; predictions 4 and 7 stand as written
and refuted.*
