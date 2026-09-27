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
| Mechanism | overlay directory `build/customizations/agent-v1.2-knowledge-codex/`, installed by `run-agent.sh --customization`: `AGENTS.md` (the v1.2 `CLAUDE.md` body verbatim) + `.ai/**` (**8** files, byte-identical — **nine in total**; this row said `7` and is corrected additively 2026-09-27 at §4a round 1, finding 12, to agree with the digest row beside it and with the §4-step-4 correction in the workbook) |
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

#### Correction, additive, 2026-09-27 at §4 step 9 — the customization block has **seven** fields, and `hooksHash` is one of them

*By Opus 5 (claude-opus-5), autonomously. The census paragraph above is kept verbatim and is not
rewritten; §4 step 12 protects the text and this is the amendment that carries the fix. No
prediction, verdict or decision-rule row moves — see the last paragraph.*

The census wrote: *"No `settingsHash` or `hooksHash` appears in the customization block at all: the
five fields are `instructionsHash`, `skillsHash`, `agentHash`, `agentsHash`, `knowledgeHash`."*
**Half of that is wrong.** Re-derived from the API record itself rather than from a probe's stdout:

```
curl -s $API/api/runs/<id> | jq -c '.customization|keys'
["agentHash","agentsHash","hooksHash","instructionsHash","knowledgeHash","mcpHash","skillsHash"]
```

**Seven fields, not five.** Identical on a treated batch run (`4df04e27`), a control batch run
(`a06c2daf`) and the §0a claude isolation run (`69cba7f0`). So:

- **`settingsHash` genuinely does not exist.** The only key anywhere in the record matching
  `/settings/i` is `runtime.userSettingsIsolated`. That half of the census sentence stands.
- **`hooksHash` DOES exist, and is `null` on 20 of 20 runs of this batch** — checked one record at
  a time, `sort | uniq -c` → `20 null`. It is null on every run this project has ever recorded.

**Why the slip happened, because it is the more useful half of this correction.** The census read
the field list off `--check-customization`'s *printed output* — the runner's own five-hash
read-back — and generalised it to *"the record has five fields"*. Those are two different
surfaces. The correct version was **already on this project's record** before the census ran: the
stop-16 author note, quoted in the run prompt's §3 under author decision 11 item 9, says
*"`hooksHash` and `mcpHash` exist in the API schema, are described in a runner comment as working,
and are null on every run ever recorded."* A census contradicted a fact the project already held,
and the contradiction survived a scoring pass and a boundary write. **That is the house failure
mode in its documentary form:** a claim re-derived from a narrower surface than the one it names.

**Nothing registered moves, and the direction of the change is worth naming.** Prediction 2 — *0 of
2 measured L2 controls survive the port* — is unaffected: a field being present and `null` is not a
control executing. The layer label is unaffected for the same reason; §5's layer column asks what
**ran**, and no null hash ran. What changes is that the claim gets **sharper rather than weaker**:
the schema reserves a field for exactly the thing the port silently drops, and that field is never
populated on either runtime. The overlay that ships a dead guardrail is indistinguishable, in every
field the record carries, from the overlay that does not ship it — and now that statement can be
made about a field that exists, which is a stronger thing to be able to say than that no field does.

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
codex runs ever recorded, so a dollar ceiling cannot fire on this arm. Wall-clock is derived from
the stored codex durations on this exact task: 35 s, 97 s, 115 s, 121 s, 455 s — median **115 s**
— excluding `77c7d1c3`, whose 35 342 s is a machine-sleep artefact and is excluded as *duration*,
not as a run.

## Preflight result — §4 step 5, 2026-09-27, PASSED 4 of 4

Driver `evidence/b10/run-b10-preflight.sh`, manifest
`evidence/b10/preflight-20260927T124708Z/manifest.tsv`, key `EXP-B10-PREFLIGHT-BE003` —
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

**`estimatedCost`, `modelCalls`, `toolCalls`, `permissionDenials` and `retries` are `null` on
20 of 20 runs of this batch.** Not missing — `null`, on both arms alike, which is a measurement
and is prediction 5's subject. The one efficiency field that survives is
`reportedTotalTokens`, non-null on 20 of 20, scraped out of the agent log at
`run-agent.sh:1236-1244` rather than reported by an OTel path.

So the gate clause **"observability capability"** is answered by a count and not by prose: of
the six behaviour and efficiency numbers this track reads on claude, **one** crosses to codex.
`durationMs` also survives, from the runner's own clock rather than from the agent.

**Added additively 2026-09-27 after §4a round 1, finding 2 — the two registered fields this section
never named.** The reviewer found that prediction 5 registers **four** null fields —
`estimatedCost`, `modelCalls`, **`inputTokens`** and **`outputTokens`** — and that this section
reported `toolCalls`, `permissionDenials` and `retries` instead, so **P5 was marked HELD without its
own registered condition ever being checked on two of its four fields.** That was true. Checked now,
across all 20 runs of this batch, one record at a time:

```
jq -r '[(.efficiency.inputTokens // "ABSENT-OR-NULL"),(.efficiency.outputTokens // "ABSENT-OR-NULL")]|@tsv'
  → 20  ABSENT-OR-NULL  ABSENT-OR-NULL
```

Both fields **exist** in the schema (`efficiency.inputTokens`, `efficiency.outputTokens`, beside
`cachedTokens` and `cacheCreationTokens`) and both are **`null` on 20 of 20**. **So P5's verdict
stands — and it now stands on evidence that did not exist when it was written.** The substituted
fields reported above are kept: they are a wider observation of the same clause and were never wrong,
only insufficient.

**Prediction-commit ordering, checked after the runs as §4 step 3 requires**, from git and the
run records rather than from this file's prose:

| | value |
|---|---|
| prediction commit `05aaf3e` | `2026-09-27T12:12:30+02:00` = **10:12:30Z** |
| first run `a06c2daf` `startedAt` | **2026-09-27T12:58:09Z** |
| last run `63e7739f` `finishedAt` | 2026-09-27T13:45:43Z |
| margin | the prediction precedes the first run by **2 h 45 m 39 s** |

## Results

Population: **`n = 5` per arm**, 20 runs across both tasks, `check-run-gate.sh` exit 0 with
`gate passed (exitCode 0)` on **20 of 20** (`evidence/b10/batch-20260927T125809Z/run-gate.tsv`),
so no run is excluded by Decision D and nothing was scored that had not cleared the evaluator.
Every sheet carries exactly four `score:` lines — **zero stalls, zero retries, 20 of 20 on the
first attempt** — which is the first codex scoring batch in this track to do that.

Registered scorer codex (Decision C), rubric `396e1799eb2b`, asserted on disk by the driver
before it ran. **The second reader is DEFERRED, per run:** `ollama-cloud` has been on its weekly
limit for five consecutive sessions (§0a row 2 stalled at 903 bytes with 0 finding sections
again this session), so `opencode-score.sh` cannot produce the concordance sheets §4 step 7 asks
for. Decision H is **not** fired — it promotes the very model that is unavailable.

### The registered primary outcome

| arm | `architecture-consistency`, every run | median |
|---|---|---|
| control | 2, 2, 2, 2, 2 | **2** |
| treated | 2, 2, 2, 2, 2 | **2** |

Difference `0`. Mann–Whitney U = 12.5, **exact** two-sided `p = 1.0000` — computed exactly rather
than by the normal approximation, which is wrong at `n = 5`.

**Decision rule, walked in order** (`evidence/b10/decide-b10.py`, transcript
`decision.txt`): row 0a does not fire (0 void of 10 treated, 0 control with a non-null hash);
row 0b does not fire (both arms reached `n = 5` ≥ 3, inside 20 runs and 48 minutes of a 4-hour
ceiling); row 0c does not fire (codex never refused); row 1 does not fire (`H = 5`, not 0);
row 2 does not fire; row 3 does not fire; **row 4 FIRES.**

> ### Verdict: NOT DETECTABLE at this `n`.

### The registered outcome was at its ceiling in the control, and that is the finding

`architecture-consistency` is scored 0–2 and the **control scored 2 on 5 of 5 runs**. The
treated arm therefore had **no headroom**: on this cell an improvement was arithmetically
impossible before the first treated run started, and the only movement the outcome could have
shown was downward.

The MDE table registered this outcome as *"undefined before the batch; the concurrent control is
its first measurement."* **That first measurement has now been taken and it is: zero variance,
at the maximum.** Registering an MDE as undefined was the honest move and it was also not
enough — an outcome can be undefined *and* already known to be unable to move, and the census
that would have caught it is one codex control run, which this stop could have afforded.

This is **E-006's defect reappearing on a new runtime.** E-006 found 50 of 100 rubric points at
zero variance on BE-003 with `claude-haiku-4-5-20251001`, and author decision 9 added BE-004 to
fix it. The fix worked for the model it was written against. It did not transfer: on
`gpt-5.6-sol`, `architecture-consistency` is at ceiling on **both** tasks' controls
(`BE-004` likewise 2, 2, 2, 2, 2), so adding the harder task bought nothing on this dimension.

### What did move — reported as a co-variate, and it is not this experiment's result

| category | control | median | treated | median |
|---|---|---|---|---|
| `maintainability` | 0, 0, 0, 2, 2 | **0** | 2, 2, 2, 2, 2 | **2** |
| `test-quality` | 1, 1, 2, 2, 2 | 2 | 2, 2, 2, 2, 2 | 2 |
| `change-focus` | 1, 1, 1, 1, 2 | 1 | 1, 1, 1, 1, 2 | 1 |

`maintainability` moves by **two points of a three-point scale**, in the treated arm's favour, at
25 % weight — and it does the same thing on BE-004 (control median 0, treated 2 on 5 of 5). Two
tasks, same direction, same magnitude, treated arm at the ceiling on 10 of 10 runs.

**It is not a result and this file does not report it as one.** `maintainability` was never a
registered outcome of E-024; §4 step 12 and §5 forbid promoting a co-variate to a verdict after
seeing it, and E-004's own write-up refused exactly this move for exactly this category. What it
is: **the strongest candidate for a registered primary outcome at any later codex stop**, and the
reason the sentence above about the ceiling is a design finding rather than an excuse. A stop
that registers `maintainability` on codex and finds nothing will have measured something; this
stop cannot claim it either way.

The weighted total moves with it — control median 67.5, treated median 92.5 — and is reported
under the same restriction, since it is a function of the same four cells.

### Row 5 — the cost row, reported, never a verdict

`reportedTotalTokens`: control median **25 840** (range 21 958–28 866, width 6 908), treated
median **34 736** (range 25 214–40 683). The median shift of **+8 896 (+34 %) is outside the
control's whole range**, so row 5 fires as a reported cost row. `durationMs` moves with it,
median 85 000 → 108 000 ms.

The mechanism is not in doubt and is not orchestration: the treated arm carries an instruction
file and a knowledge corpus the control does not, and the router was invoked on 5 of 5 treated
runs. **A cost row is never a second condition on a failure row** (registered), so this does not
convert row 4 into a rejection — but a +34 % token cost for a cell that could not move is the
honest shape of this result.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | files port unchanged 8 of 11 | **HELD** | 8 of 11 (73 %), census, exactly the predicted number |
| 2 | measured L2 controls survive 0 of 2 | **HELD** | 0 of 2, and both losses traced to a named runner line |
| 3 | both hashes set 5/5 treated, null 5/5 control | **HELD** | `instructionsHash sha256:ebf489800a60a156986f98ea4f127848` AND `knowledgeHash sha256:0770219ae7f4281a80071d78dadea285` — the **full** values against the registered ones, not a non-null test — on 5 of 5 treated; all five hashes `null` on 5 of 5 control. Re-derived from `GET /api/runs/{id}` for all 20, not read off the driver's manifest. **This was registered as the prediction most likely to be wrong, and it is the one that held cleanly.** |
| 4 | corpus contact ≤ 1 of 5 | **REFUTED** | **5 of 5.** Off by the whole population, and in the direction nobody predicted |
| 5 | cost/calls/tokens null 10/10, reportedTotalTokens ≥ 8/10 | **HELD** | `estimatedCost`, `modelCalls`, `toolCalls` `null` on 20 of 20 (10 of 10 on this task); `reportedTotalTokens` non-null on 10 of 10, above the ≥ 8 threshold |
| 6 | `architecture-consistency` does not separate | **HELD** | medians 2 vs 2, difference 0, exact `p = 1.0000` |

**Five of six held, and the held ones are worth less than the refuted one.** Prediction 6 held
for a reason its stated mechanism gets wrong: it predicted no separation *"because the port
carries no control that could change the shape of the code; only a corpus that prediction 4 says
will not be read."* The corpus **was** read, on 5 of 5 runs. So prediction 6's number is right and
its mechanism is refuted by prediction 4 in the same batch — and the real reason there was no
separation is the ceiling, which neither prediction mentions.

## Failure analysis

**1. Prediction 4 is refuted at 5 of 5, and the refutation is about the runtime, not the corpus.**
Stop 20 measured corpus contact at 3 of 20 on claude and this experiment scaled that number down
to ≤ 1 of 5. On codex it is **5 of 5**. The transferred rate was the wrong reference class: a
number measured on `claude-haiku-4-5-20251001` with a `.claude/` overlay was carried to
`gpt-5.6-sol` with an `AGENTS.md` overlay, and nothing in the mechanism made it portable. The
prediction stands as written (§4 step 12) and the lesson is that **stop 20's rate is not
evidence about codex**, in either direction.

**2. The primary outcome could not move, and nothing in the registered design could catch that.**
Covered above. The concrete instrument gap: **there was no control-arm rubric census before the
batch.** One codex control run scored on the registered rubric — **18 seconds** of scorer
time at this batch's median, 13 s fastest and 37 s slowest over its 20 sheets (400 s of wall clock
for the whole scoring pass) — would have shown `architecture-consistency = 2` and made the choice
of primary outcome a decision rather than an accident. This is the cheapest missing
control in the track and it goes to `author_notes`.

**3. One null cell, and it is bounded.** `evidence/b10` sheet for BE-004 control `efd94f24`
scores `maintainability: null` with `reason: "ambiguous: 0 vs 1; status if is delegated outside
the method named cancel"`. A missing cell is not a null cell and this is a null cell — the
scorer used the rubric's own ambiguity escape hatch and **named both candidates, 0 and 1, both
below the treated arm's 2**. So the direction of the `maintainability` co-variate does not depend
on it, and it is excluded from that arm's median rather than imputed (`n = 4` on that one cell).

**4. What this experiment still cannot say.** No cross-runtime quality verdict, for the three
independent reasons in the workbook's `## Goal` — `agent-observatory#47` open, the model moving
with the adapter (two variables), and HANDOFF's seventh-session block. Nothing here loosens that.
The comparison above is **within codex only**, treated against its own concurrent control.

## Sanity checks

- [x] **Did any dramatic number appear? Has it been explained *and* the explanation tested?**
  Yes — corpus contact 5 of 5 against a predicted ≤ 1. Explanation: the router was invoked, and
  it is **tested rather than asserted** — the driver copied a per-run router log out of `$TMPDIR`
  for each of the 5 treated runs (`router-logs/knowledge-log-observatory-run-*.jsonl`, 1 line
  each, `corpus_contact=router`), and the control's column reads `none` with `0` lines on 5 of 5.
- [x] **Did any flattering number appear? Has it been disbelieved twice?**
  Yes — `maintainability` 2 on 5 of 5 treated against a control median of 0, and the weighted
  total 92.5 vs 67.5. Disbelieved twice: **(a)** it is not a registered outcome, so it is reported
  as a co-variate and enters no row of the decision rule; **(b)** it is on the same dimension the
  BE-004 sheets call ambiguous between 0 and 1 in one control run, so the control's own floor is
  softer than `0, 0, 0, 2, 2` makes it look. A third reason to hold it loosely: the second reader
  that would test it is unavailable, so this is one harness unchecked.
- [x] **If a fix motivated this run, did the original symptom actually disappear?**
  Not applicable — no fix motivated this run. The isolation question that opened §4 step 4 *did*
  resolve: `verify-codex-isolation.sh` returned `ok: ALL THREE checks hold for codex-cli 0.154.0`
  at exit 0 at this session's §0a, after leaking once and wedging once in the previous session.
  Recorded as resolved-at-`n`-observed, not as a fix.

## Decision

**Keep the port; make no claim for it on this outcome.**

- The **port itself is kept**: `build/customizations/agent-v1.2-knowledge-codex/` delivered on
  10 of 10 treated runs across both tasks, by exact hash, and 8 of 11 files crossed unchanged.
  P5's *"portable core"* half is **supported at the file level and by delivery proof**.
- P5's *"thin adapters"* half is **refuted by the census, not by this batch**: 0 of 2 measured L2
  controls survive, so what crosses is the prose and the corpus, and what does not cross is every
  control that executes. A core that ports while its guardrails do not is not a thin adapter.
- **No `keep`/`remove` decision is taken on the knowledge corpus from this stop**, because the
  registered outcome could not see it. §4 step 10's *"a rule with no measured effect is removed"*
  does **not** apply: this is not a measured no-effect, it is an outcome with no headroom, and
  treating the two as the same would remove a mechanism the co-variates suggest is doing the most
  visible work in the batch. That distinction is the one thing from this stop worth carrying.
- **Primary runtime: claude. Fallback: codex** — the gate's *"pick primary and fallback"* clause,
  answered from this batch: codex loses 5 of 6 observability numbers and both executing controls,
  and gains nothing measurable on the registered outcome at +34 % tokens.

## Deliberate failure — DF1, registered 2026-09-27 at §4 step 9, before the run

**The prediction lives in the workbook**, `phases/b10-second-runtime-adapter/README.md`
*"## Deliberate failure → The choice — candidate 2"*, because prediction 2 is registered once there
and cited by both experiments. It is summarised here and **not restated as a second copy**; a
prediction in two files is a prediction that can disagree with itself.

DF1 ships census probe 5's overlay — the nine-file port **plus `.claude/settings.json`**, which the
runner permits at exit 0 — on one real codex run under its own key `EXP-B10-DF-BE003`, outside this
experiment's population, and asks whether the policy gate B7 measured at 17 of 17 executes. Four
predictions: the runner does not refuse (DF-P1); **zero** hook-log lines with a non-empty trigger
population (DF-P2); the same `policy-gate.sh` sha invoked directly **does** fire, 2 and 0 with a log
line each (DF-P3); and neither registered hash moves, with no `settingsHash` or `hooksHash` key
anywhere in the record (DF-P4).

**Why it is here at all:** prediction 2's second half is currently proved by *reading* the runner,
which §5 makes **L3**. DF-P2 and DF-P3 together make it **L2**. DF-P2 alone proves nothing, and is
registered **VOID rather than held** if the run changes 0 files.

*Registered by Opus 5 (claude-opus-5), autonomously, 2026-09-27; the author did not review before
the run.*

**DF1 RAN 2026-09-27 and all four predictions HELD.** Run `18eac7c0-971f-496d-8868-8799d4fec2b5`,
BE-003, codex, evaluator `exitCode 0`, 3 changed files. **0 new or grown `policy-events-*.jsonl`
logs** across `$TMPDIR` and `/tmp` with a **non-empty trigger population**, against B7's 20 treated
logs; the same gate at B7's sha `f432abbc…` fired on demand **twice**, once from the run's own
worktree afterwards; the ten overlay files including `.claude/settings.json` are in the setup commit
`9652494fa571`; both registered hashes unmoved and `hooksHash` `null`. **Prediction 2's second half
is now L2 rather than L3.** Measurement and the six closed alternative explanations:
`evidence/b10/df-20260927T163230Z/RESULT.md`. The full reading, including the unpredicted co-variate
— the router's log was written in the same run the gate's was not, so *what ports is what the model
can call; what does not port is what the runtime must call* (`n = 1`) — is in the workbook.

**CORRECTED 2026-09-27 after §4a round 1: DF-P4 is REFUTED on its second clause and the sentence
above is wrong where it says "all four".** DF-P4 registered *"no `settingsHash` **or `hooksHash`**
key exists anywhere in the record"* and made *"such a key exists"* its own refutation clause.
**`hooksHash` exists and is `null` — a null key is a key.** So the DF is three held and one split:
held on *"neither registered hash moves"*, refuted on *"no such key exists"*. The prediction and the
result table are **not edited** (§4 step 12); the correction is carried in the workbook's
*"Correction, additive … DF-P4 is REFUTED on its second clause"*, which also records how it happened
— DF-P4 was drafted from the census's wrong "five fields" sentence, I corrected that sentence two
commits later in the same session, and never traced the consequence back to the live prediction.
**The substantive conclusion does not move** (no hash saw the tenth file; `hooksHash` is null on
every run ever recorded) — **the prediction's score does**, and a wording refuted while its intent
survives is recorded as refuted.



## Follow-up

1. **Register a control-arm rubric census before any future batch** — one control run scored on
   the registered rubric before the primary outcome is chosen. `author_notes`.
2. **`maintainability` on codex is the outcome a later stop should register**, with its prediction
   written before any of these sheets are re-read.
3. **The second reader is owed on all 20 run ids** and is deferred, not waived; when
   `ollama-cloud` returns, `opencode-score.sh` on the same ids, labelled as the second reading
   produced after the registered sheet.
4. Stop 20's corpus-contact rate must not be cited as evidence about codex again, in either
   direction.

*Filled in from evidence by Opus 5 (claude-opus-5), autonomously, 2026-09-27. No prediction, MDE
row or decision rule in this file was edited after its run; prediction 4 stands as written and
refuted.*
