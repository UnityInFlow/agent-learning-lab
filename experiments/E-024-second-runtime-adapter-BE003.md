# Experiment E-024 — the portable core on a second runtime, BE-003

**Key:** `EXP-B10-RUNTIME-PORT-BE003` · **Stop:** 21 (B10) · **Version:** v1.2
**Task:** `BE-003-confirm-shipment` · **Runtime under test:** `codex`
**Workbook:** [`phases/b10-second-runtime-adapter/README.md`](../phases/b10-second-runtime-adapter/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-27T10:2xZ; the author did not review
before the run.`

> Author decision 9: BE-003 and BE-004 are separate experiments with separate keys, separate
> prediction commits, separate controls and separate decision rules. **No verdict is computed
> across tasks.** BE-004 is `E-025`.

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

4. **Corpus contact on the treated codex arm is ≤ 1 of 5.** Mechanism: stop 20's 3-of-20 on
   claude, scaled; plus codex's six seeded system skills competing for the same attention.
   *One-arm claim, refuted if it reaches ≥ 3 of 5.*

5. **`estimatedCost`, `modelCalls`, `inputTokens` and `outputTokens` are `null` on 10 of 10 codex
   runs, and `reportedTotalTokens` is non-null on ≥ 8 of 10.** Mechanism: `codex exec` has no
   OTel path (ADR-001, obs#10); `run-agent.sh:1236-1244` scrapes a bare total out of the agent
   log. This is gate clause *"observability capability"* stated as a falsifiable number rather
   than as prose.

6. **`architecture-consistency` on the codex scorer does not separate the treated arm from the
   codex control** — the arms land within one rubric point of each other's median. Mechanism:
   the port carries no control that could change the shape of the code; only a corpus that
   prediction 4 says will not be read.

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
| Preflight assertion | one codex run per arm under key `EXP-B10-PREFLIGHT-BE003`, **not in the population**: treated shows `customization.instructionsHash` and `knowledgeHash` non-null; the `init` read-back per author decision 8 is recorded for the codex arm even though codex has no `tools:` list, because *"the runtime rewrites the list before the model sees it"* was discovered exactly by taking that read-back on an arm nobody expected it from |
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
- [ ] task + revision — `BE-003-confirm-shipment`, unchanged since B2
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

## Runs

Repetitions per arm: **5** (floor 3, §4 step 6) · Total budget: **20 codex runs across E-024 and
E-025, 4 h of batch wall-clock**.

**No dollar budget is written, and that is not an omission.** `estimatedCost` is `null` on 8 of 8
codex runs ever recorded, so a dollar ceiling cannot fire on this arm. Wall-clock is derived from
the stored codex durations on this exact task: 35 s, 97 s, 115 s, 121 s, 455 s — median **115 s**
— excluding `77c7d1c3`, whose 35 342 s is a machine-sleep artefact and is excluded as *duration*,
not as a run.

## Minimum detectable effect

**There is no stored codex rubric population on this task or any other.** Checked 2026-09-27: none
of the five `EXP-B2-BASELINE-CODEX` run ids has a sheet in `findings/codex/` or
`findings/opencode/`. So the MDE for the rubric outcome is **not derivable before the run**, and
saying so is the honest register rather than inventing a spread.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary (census): files and controls that port | none needed — a count over 11 files | exact | **yes** |
| primary (run): `architecture-consistency`, codex scorer, rubric `396e1799eb2b` | **none exists on codex** | **undefined before the batch; the concurrent control is its first measurement**, as decision 9 item 3 did for BE-004 | **yes, as undefined** |
| secondary: corpus contact | stop 20, 3 of 20 on claude, **transferred** | at `n = 5`, 0/5 vs 3/5 is Fisher `p = 0.17` — **not decidable**; the prediction is therefore written as a one-arm claim, which needs no control | **yes** |
| secondary: `reportedTotalTokens` | 5 stored codex runs, BE-003: 28 835 / 32 886 / 42 396 / 49 423 / 50 231, median **42 396**, at CLI `0.147.0` — **transferred, not a control** | a shift smaller than the stored range (21 396) is not claimable at `n = 5` | **yes** |

**A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as refuted.**

## Deterministic evaluation

`agent-observatory-benchmarks` `BE-003-confirm-shipment/evaluator.sh`, BE-003's exit-code
contract, unchanged since B2. The evaluator decides correctness; the rubric decides nothing about
correctness.

## Exclusions

Registered now:

- the two preflight runs (`EXP-B10-PREFLIGHT-BE003`) are **not in the population**;
- F13 — a run whose `durationMs` is implausible against the batch (machine sleep) has its
  **duration** excluded, not the run (§4 step 6). The stored `77c7d1c3` at 35 342 s is the
  precedent and is already excluded from the MDE row above;
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

<!-- TODO -->

## Results

<!-- TODO -->

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | files port unchanged 8 of 11 | | |
| 2 | measured L2 controls survive 0 of 2 | | |
| 3 | both hashes set 5/5 treated, null 5/5 control | | |
| 4 | corpus contact ≤ 1 of 5 | | |
| 5 | cost/calls/tokens null 10/10, reportedTotalTokens ≥ 8/10 | | |
| 6 | `architecture-consistency` does not separate | | |

## Failure analysis

<!-- TODO -->

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

<!-- TODO -->

## Follow-up

<!-- TODO -->
