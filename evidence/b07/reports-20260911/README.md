# Stop 15 (B7) — §4 step 7 and step 8 artefacts, 2026-09-11

Batch `20260910T183731Z`. 34 runs: BE-003 10 treated + 10 control, BE-004 7 treated + 7 control.

## 1. Gate (Decision D) — 34 admitted, 0 refused, from two independent documents

`./tools/check-run-gate.sh` takes a file and deliberately does not fetch, so it was fed two
different documents per run: the kept worktree's own `evaluation.json`, and `GET /api/runs/{id}`
through the tunnel `127.0.0.1:18081`.

| source | exit 0 | exit 1 | exit 2 |
|---|---|---|---|
| worktree `evaluation.json` | **34** | 0 | 0 |
| API run document | **34** | 0 | 0 |

**The two sources agree on 34 of 34.** 0 API fetch failures.

## 2. `verify-sh.sh` beside the evaluator — `verify-sh-vs-evaluator.tsv`

Registered in E-015 and E-016 as *"run over every kept worktree of both arms, after the batch, and
its per-stage verdict recorded beside the evaluator's … the interesting number is how often they
disagree."* `verify-sh` v1.0.0, run per worktree with `--task` and `--json`; the 34 JSON documents
are in `verify-sh-json/`.

| | count |
|---|---|
| runs where `verify-sh` exit == evaluator exit | **34 of 34** |
| runs where they disagree | **0 of 34** |
| `verify-sh` exit codes observed | `0` only |
| evaluator exit codes observed | `0` only |
| `verify-sh` failing stage | none, on any run |
| stages passed per run | `manifest`, `build`, `test`, `deps`, `scope` — all 5 |

### The headline is 0 disagreements and it is weaker than it looks

**The denominator contains no failures.** The evaluator returned exit 0 on 34 of 34 runs, so there
was never a failing run for `verify-sh` to disagree *about*. A 0 % disagreement rate measured on a
population with nothing but passes does not establish that the two instruments agree on failures; it
establishes that this batch produced none.

`verify-sh` deliberately adopts the evaluator's own exit-code mapping precisely so that *"the agent
could have known"* and *"the evaluator found out"* are comparable. **On this batch that comparison is
untested**, and the first place it can be tested is §4 step 9's deliberate failure, where a violation
is committed on purpose. Recorded here so the number is not later quoted as a concordance result.

## 3. `baseline-report` — and a real defect it exposes

`baseline-report-EXP-B7-POLICY-BE003.txt` · `baseline-report-EXP-B7-POLICY-BE004.txt`, from
`agent-observatory/runner/baseline-report.py … --api http://127.0.0.1:18081`.

**BE-004 is clean: the tool reports 14 measuring runs and the batch has exactly 14.**

**BE-003 is not. The tool reports 25 measuring runs where the batch has 20.** The five extra runs
were identified by set difference against the manifest and every one of them is a **registered
exclusion**:

| run id | variant | startedAt | `durationMs` | in `batch-20260910T132311Z/EXCLUSIONS.md`? |
|---|---|---|---|---|
| `f381a596-7181-494d-b615-57ab647a6831` | verify-v1.0 | 2026-09-10T13:33:51Z | **5 192 000** (86.5 min) | yes |
| `5b1df59d-8075-47fe-8d86-a615ae9a6c0c` | phases-v1.0 | 2026-09-10T13:31:10Z | 131 000 | yes |
| `8c17e8ac-b9b2-47ac-ad7b-f577f8ba46ef` | verify-v1.0 | 2026-09-10T13:28:16Z | 143 000 | yes |
| `1cd13b2a-3d01-41b8-aab8-9e7e01d590b5` | phases-v1.0 | 2026-09-10T13:25:37Z | 128 000 | yes |
| `11dd0c8d-a569-4eb6-83b8-3a83bc548ac5` | verify-v1.0 | 2026-09-10T13:23:12Z | 114 000 | yes |

These are the 13:23Z batch that was stopped by hand at load average 202 and excluded by name. The
sixth excluded id, `0c93f9e0-ff9a-4511-9a68-cac151209bc0`, was killed mid-run and never POSTed a
record, so it is absent from the API — which is why five appear here and six are on the list. The
exclusion bookkeeping is internally consistent; the *tool* is what does not honour it.

**The defect, stated precisely.** `baseline-report.py` aggregates every run the API holds under a
given `experimentKey` and **has no exclusion mechanism at all**, so a registered exclusion is
invisible to it. On this stop the consequence is concrete: its BE-003 duration column has a median
of 115 s and a **max of 5 192 s**, and that maximum is the contaminated run the exclusion exists to
remove.

**Two reasons no number in E-015 or E-016 comes from this tool**, so the defect changes no result
here:

1. it is a **single-arm** summariser by its own description (*"Single-arm baseline: median and range,
   never a mean"*), and B7 is a two-arm experiment — it pools treated and control into one column;
2. every figure in both experiment files was computed from the **34 manifest run ids only**, read
   individually from `GET /api/runs/{id}`.

It is kept here as the §4 step 8 artefact with its count named, rather than omitted, because a
report whose `n` disagrees with the manifest is exactly the thing a later reader would otherwise
quote. **The tool is not edited now** — §6 forbids editing a tool while a run of it is in flight and
this stop's scoring is unfinished; the fix is an instrument note carried to §4 step 14.

*Produced by Opus 5 (claude-opus-5), autonomous, 2026-09-11.*
