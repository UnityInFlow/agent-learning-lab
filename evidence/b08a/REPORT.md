# B8a — §4 step 8, the report. Median and range, never a mean alone.

`Written by Opus 5 (claude-opus-5), autonomous, 2026-09-25.` Every number here is re-derivable by
`./evidence/b08a/tally.py evidence/b08a/batch-20260925T091510Z/manifest.tsv evidence/b08a/shape/classifications.tsv`,
whose output is kept verbatim at `evidence/b08a/tally-20260925.txt`. **This file reports. It does not
answer the exit gate** — that is §4 step 11 and it is not written yet.

## 0. The population, and why it is 8 per arm and not 10

The batch stopped on its own **registered cost ceiling** — decision-rule **row 0b**, `$9.70`, enforced by
`evidence/b08a/run-b8a-batch.sh` at exit 11 — after pair 08, at **$9.7948**, with **n = 8 per arm, 16
runs**. That is registered behaviour and not a shortfall: E-020 says *"the batch stops when the ceiling is
reached and the population that occurred is reported"*, as E-016 did at `n = 7`. **The ceiling prediction
made at §4 step 5 was right**: one preflight pair cost $1.2222 and the workbook said *"expect n ≈ 8 per
arm"*.

**Every number below `n = 8` per arm or `n < 5` is stated as true of these runs and never as a property
(§5).** The control arm's rubric population is `n = 3`.

## 1. Delivery — read before any comparison

| | |
|---|---|
| decision-rule **row 0a** (a treated run missing any of the four delivery conditions) | fires on **0 of 8**. `cond_a`, `cond_b`, `cond_c` all `ok` and `cond_d` `ok-stream-3of3` on every treated run |
| control assertion | `agentHash`, `instructionsHash`, `skillsHash` all `null` on **8 of 8** controls, read from their own records |
| `runtime.model` | `claude-haiku-4-5-20251001` on **16 of 16** |
| gate (`check-run-gate.sh`, each run's own `evaluation.json`, API-independent) | **10 admitted, 6 refused** — treated 7 of 8, control 3 of 8 |
| **decision-rule row 1 (VOID)** | **does not fire** |

## 2. The registered outcome — P1, and it is REFUTED

**`architecture-consistency`, codex, rubric `945817b8c509`, gate-passing runs only (Decision D).**
All 40 values re-derived by me off the ten sheets, not taken from the scoring subagent's report; all 40
matched and all ten `rubric_sha` are `945817b8c509`. **Zero nulls in 30 measured cells.**

| category | treated (n = 7) | control (n = 3) |
|---|---|---|
| **architecture-consistency** | **median 0**, range 0–1 — `[1,0,1,0,1,0,0]` | **median 0**, range 0–1 — `[0,1,0]` |
| maintainability | median 0, range 0–0 | median 0, range 0–0 |
| test-quality | median 1, range 1–1 | median 1, range 1–1 |
| change-focus | **unmeasured — author decision 2026-09-25 item 1**; reported, not computed: `[1,1,1,0,2,1,2]` | same: `[1,1,2]` |

**P1 predicted treated median 2 against control median 0. Measured: 0 against 0. REFUTED.** And E-020
registered, before the batch, that it expected this outcome to be unmeasurable and said why — the control
arm's rubric population is `n = 3`, below the `n < 5` line, so even the *direction* here is "true of these
three runs".

**No regression in any measured category:** maintainability is flat at 0 in both arms and test-quality flat
at 1 in both. **There is no improvement either.** `test-quality` anchor 2 is UNREACHABLE in the fixture
proof and **no claim is made about it in either direction.** Because `change-focus` carries no measurement,
**BE-005's weighted total is 85 measured points on a 100-point scale and is NOT comparable to BE-004's.**

## 3. The two secondaries disagree, and E-020 registered that as the more informative outcome

| | treated | control | Fisher two-sided |
|---|---|---|---|
| **P2 — evaluator pass rate** | **7 of 8** | **3 of 8** | **p = 0.1189** |
| **P3 — shape classification** (`evidence/b08a/shape/SHAPE-RULE.md`, two blind readers, 16 of 16 agreement) | **8 of 8 RIGHT** | **2 of 8 RIGHT** (1 `NO-ATTEMPT`, denominator only) | **p = 0.0070** |

**P3 clears p ≤ 0.05 and P2 does not, and the gap is not an artefact of any exclusion choice:**

| population | P2 | P3 |
|---|---|---|
| all 16 — **the registered population** | p = 0.1189 | **p = 0.0070** |
| minus control 07 (the F13 decision) | p = 0.1189 | **p = 0.0070** |
| minus **both** runner-labelled F13 controls (what `baseline-report.py` does) | p = 0.2448 | **p = 0.0150** |

**They disagree on 4 of 16 runs, in both directions.** The evaluator **passes two wrong-shaped controls**
(`4ec4cb7a`, `33b4c452` — all three read paths trust the stored copy, exit 0) and **fails two right-shaped
submissions** (`4319e882` control and `b755f13f` treated, exit 12). **So P2's mechanism — "the evaluator
returns 12 on the wrong shape and 0 on the right one, so pass rate *is* shape on this ticket" — is measured
and it is wrong.** That sentence was the reason P2 was registered as "the row that can actually carry a
verdict", and it is the single most consequential thing this batch measured.

## 4. P4 — REFUTED, and it was registered as the prediction most likely to be wrong

Delegation count in `{3, 5}` on **6 of 8** treated runs; **2 outside** — pair 03 at 12 and pair 07 at 8.
E-020: *"1 of 10 outside {3,5} is a finding, not noise"*, and *"this is the prediction I expect to be
wrong … 'one bounce' is L3 — nothing counts delegations."* **The L3 label predicted its own failure and the
run confirmed it.**

**And the two sources disagree on exactly those two runs.** Stream vs telemetry: pair 03 `12` vs `15`,
pair 07 `8` vs `6`; the six runs inside `{3, 5}` agree exactly. The stream is P4's registered source
(`cond_d = ok-stream-3of3`) and stays the number of record; the disagreement is reported beside it, never
averaged.

## 5. Reported rows — no thresholds, they decide nothing

| | treated (n = 8) | control | P5/P6 predicted |
|---|---|---|---|
| `estimatedCost` | median **$0.7149**, range 0.5678–1.6229 | median **$0.3912** (0.0934–0.5042, n = 8) · **$0.3990** (0.2788–0.5042, n = 7, minus F13) | P5: **2–4×**. Measured **1.83×** (1.79× on n = 7) — **REFUTED, below the band** |
| duration | median **631 s**, range 488–1307 | median **230 s**, range 198–283 (n = 7, F13's duration excluded per §4 step 6) | — |
| `modelCalls` | median **82.5**, range 61–222 | median **43**, range 23–53 (n = 7) | P6: treated **≥ 90**. Measured median 82.5 — **REFUTED**, though ~1.9× the control |
| files changed | median 13, range 11–15 | median 12, range 1–14 | — |

**Three independent replications of the transferred spread, which is the strongest validity check in this
batch.** The MDE was transferred from Gate B′'s five runs on ticket A′, and B8a's own control reproduces it:
cost median **$0.399 vs $0.388**, duration **230 s vs 230 s**, `modelCalls` **43 vs 43**. A control arm that
lands on three transferred medians is a control arm behaving like the population it was transferred from.

## 6. P7 — the co-variate that interprets the null, and its registered medium does not exist

**P7's registered source is wrong and the run proves it.** P7 says the `handoff.delivered` table is *"on
disk in every kept worktree"*. It is not. The `handoff` block is written by **agent-v1.1's `CLAUDE.md` and
`.ai/hooks/repair-limit.sh`**, and `b8a-pipeline-v1.0` installs **four agent files and nothing else** — no
`CLAUDE.md`, no hook, no `.ai/`. I checked a treated worktree: the only non-`sample-service` content is the
four `.claude/agents/*.md`. **There is no handoff artifact on disk in either arm.**

So P7 was answered from **the planner's returned plan in the agent stream** — the same substitution of
source that `cond_d` already makes, recorded rather than quietly performed:

| | |
|---|---|
| planner delegation present | **8 of 8** treated runs |
| all three read paths **named** in the planner's plan | **7 of 8** (pair 01 omits the list body) |
| a **per-read-path** stored-or-computed decision, fully qualifying | **5 of 8** `YES`, **3 of 8** `PARTIAL`, **0** `NO` |

Registered threshold was ≥ 8 of 10, so **P7 is below it** — but P7 *enters no decision-rule row*, and what
it was built to do, it did: **it rules out "the prose was not followed" as the explanation for the null.**
Every treated run delegated to a planner, and the planner reasoned per read path on five of eight. The null
on P1 is not a compliance failure.

## 7. The registered command's own output, and what its exclusion rule costs

`make baseline-report EXPERIMENT=EXP-B8A-DECOMP-BE005` is §4 step 8's command. Its output is kept verbatim
at `evidence/b08a/baseline-report-20260925.txt`. **Read it with two things in mind:**

1. **It is single-arm.** It pools all 14 runs it keeps across both arms, so its medians are not a comparison
   and its `pass rate 10/14` is not P2.
2. **It discards two runs on its own F13 rule, and one of those labels is wrong.** `run-agent.sh:1352-1357`
   marks a run F13 when the run failed **and** `tail -3` of the agent log matches an infrastructure
   signature. It fired on **two controls**: `ed58787c` — **correctly**, 47 HTTP 529s, 3 751 s, 11 model
   calls, one changed file — and `4abf7f01`, **whose log tail said `API error` and whose run is otherwise
   indistinguishable from every other control**: 12 changed files, 41 model calls against a control median
   of 43, 230 s against a control median of 230 s, and a complete submission that two blind readers
   classified from the diff on all three read paths.

**Decision: `4abf7f01` is NOT excluded.** `Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-25.`
Three grounds:
- E-020's `Exclusions` admits exactly three, a log-tail match is none of them, and *"nothing is excluded
  for its result."*
- The F13 rule's own justification is *"this run is not evidence about the variant — it measures your
  quota"*. This run **is** evidence about the variant, on every axis I can measure.
- The rule's own comment explains that a tail match alone *"would have discarded three passing runs"*,
  which is why it added the "the run FAILED" condition. `4abf7f01` shows the exposure that remains: **a
  failing run that produced a complete submission and happens to end on an `API error` line is condemned by
  the tail alone.** The protection was built for the passing half only.

**The rule is NOT changed by me** — it is what every stop's records are classified by, and moving it
mid-track moves an instrument under the whole track. It is recorded in `author_notes` with this evidence,
and the third population above shows exactly what it costs: P2 p = 0.1189 → 0.2448, P3 p = 0.0070 → 0.0150.
**The verdict does not turn on it either way.**

## 8. The hand re-read, and it agreed

`evidence/b08a/hand-reading/be4a6a94-architecture-consistency.md`, committed at `5f20c34` **before any B8a
sheet existed on disk**. Hand value **1**; codex's sheet for the same run: **1**. The hand reading also
registered, in advance, the disagreement it thought likely — that a scorer might read anchor 2 (ii) loosely
and return 2 — **and that disagreement did not occur.** The one cell re-read by hand matches the instrument
that produced the registered number.

## 9. What is still owed at this boundary

- **The second reader.** Decision C makes opencode the second reader and **not a vote**. 1 of 10 sheets
  exists (`4ec4cb7a`: `0 / 0 / 1 / 1`, **identical to codex's** `0 / 0 / 1 / 1` on that run); the other
  nine are running. No number above depends on them.
- **The decision rule does not resolve, and that is a finding, not an oversight.** Row 0a no, row 1 no,
  row 2 needs *both* rates at p ≤ 0.05 and P2 is 0.1189, row 3 needs a *lower* treated rate, row 4 fires
  only when **neither** rate separates — and P3 separates at 0.0070. **No row fires.** The rule was written
  assuming P2 and P3 would agree; they did not, and the rule has no row for exactly one of them separating.
  Resolving it is **§4 step 11's** work and is deliberately not done here.
