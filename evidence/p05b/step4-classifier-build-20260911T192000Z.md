# Stop 16, §4 step 4 — the permission-block classifier, built and proved

*Written 2026-09-11T19:20Z by Opus 5 (claude-opus-5), autonomous. Nothing here is a
result of E-017; the runs have not happened. This is the record of what step 4 built,
what it refuses, and the one decision step 4 had to make.*

## What was built, and nothing else

| File | Repo | Layer | Lines |
|---|---|---|---|
| `runner/lib/classify-permission-block.sh` | agent-observatory | **L2** — it executes and its exit code is the verdict | 96 |
| `runner/verify-permission-block-classifier.sh` | agent-observatory | **L2** — it executes in CI and fails the build | 101 |

ShellCheck clean on both. `cd "$(dirname "$0")/.." || exit 1` in the verifier, per §4 step 4.

**The contract.** `classify-permission-block.sh <telemetry-or-run-record-json> <changed-file-count>`

| Exit | Meaning |
|---|---|
| 0 | not a permission block |
| 2 | permission block — `behavior.permissionDenials > 0` **and** changed-file count `== 0` |
| 3 | unclassifiable — refused rather than cleared |
| 1 | usage |

**One field path serves both call sites.** `.behavior.permissionDenials` is what
`runner/lib/claude-telemetry.sh:100-109` writes into the live telemetry JSON *and* what the
API stores and returns, verified by reading both. So a replay over stored evidence reads the
same field a run does — which is what makes P5 and P6 answerable without new runs.

## The trap this step had to convert, and the fixture that converts it

`build/README.md` names the over-fire trap. The tempting rule — *permissionDenials > 0 means
blocked* — is **wrong on this store's own data**, and it was checked before the file was
written rather than after:

```
curl -s "$API/api/runs?limit=2000" | jq -r '[.[] | select((.behavior.permissionDenials // 0) > 0)] | .[]
  | "\(.runId[0:8]) \(.experimentKey) d=\(.behavior.permissionDenials) ch=\(.result.changedFiles|length) passed=\(.evaluation.passed)"'
```

**Six runs of 550 have `permissionDenials > 0`. All six passed.** All six are
`EXP-4B-ORCH-OVERHEAD`, denials 1–2, toolCalls 14–25, changedFiles 3, `evaluation.passed:
true`. A disjunctive rule turns six passing runs into infrastructure discards — obs#47's own
sentence running backwards. Each of the six is a named fixture in the verifier.

## The verifier, and the hand check that did not trust it

`./runner/verify-permission-block-classifier.sh` → **29 passed, 0 failed.**

§6 says re-verify a case by hand when a check goes green. The fixtures are synthetic JSON;
the hand check ran the classifier over the **real stored run records**, straight from the API:

| Run | denials | changedFiles | exit | reason |
|---|---|---|---|---|
| `c0b6721e` | 1 | 3 | 0 | not a permission block: 1 denial(s) but 3 changed file(s) — the run produced work |
| `2744a92c` | 1 | 3 | 0 | same |
| `fb894d7d` | 2 | 3 | 0 | not a permission block: 2 denial(s) but 3 changed file(s) |
| `beae5092` | 1 | 3 | 0 | same shape |
| `1f806f3d` | 1 | 3 | 0 | same shape |
| `4d7c537d` | 1 | 3 | 0 | same shape |

**0 of 6 reclassified.** That is P5's second half, computed rather than asserted — and it is
recorded *before* batch 1 exists, so it cannot later be tuned to a known outcome.

The same replay over obs#47's own seven `F05` sonnet runs of `EXP-BE002-MODEL-TIER`
(`4d0246d7 ca952174 344274bf 6b19bafb 1a0b375e b32a4396 5b576f59`): **0 of 7 reclassified**,
exit 0 on all seven, reason `0 denials and 1 changed file(s)`. That is P6's replay half.

**And it corrects a detail of the step-2 design in the direction of the same conclusion.** The
design said the abstention case is uncovered because *the telemetry conjunct is false*.
Measured, **both** conjuncts are false: those seven runs changed one file each, so the
changed-file conjunct fails too. P6's direction is unchanged and its mechanism is stronger
than written. The design section is amended additively; the prediction is not touched (§4
step 12).

## The L2 claim was false when step 2 wrote it, and it is true now

The step-2 layer table says the verifier is **L2** *"because it executes in CI and fails the
build"*. That was **not true of this repository**: `grep -rn 'verify-' .github/workflows/ci.yml`
returned nothing, and **none of the seven existing `runner/verify-*.sh` scripts runs in CI**.
A fixture set nobody executes is words a human chooses to run — L3 by the workspace rule,
applied in order.

Rather than relabel the row down, the claim was made true: one step added to the `runner` job
of `.github/workflows/ci.yml`, running `./runner/verify-permission-block-classifier.sh`. It
needs only bash and jq — no codex, no model call, no network — so it cannot go red for a
reason unrelated to the rule it guards. **The verifier is L2 as of this commit and was L3
before it**, and that sentence is the layer column's whole job.

**The six sibling verifiers are still not in CI**, which is a defect of this repository and
not of this stop. Logged to `author_notes`; not fixed here (§6, one step at a time).
`verify-codex-isolation.sh` in particular needs a live codex and would fail on a runner, so a
blanket "run every verifier" step would be a red build, not a control.

## The decision step 4 had to make

> **The classifier ships standalone and is NOT wired into `run-agent.sh` at this stop, and the
> choice between reusing `F13`/`F15` and admitting a new `F10` to `INFRASTRUCTURE` is deferred
> to batch 1's data.**
>
> Not deferred out of caution — deferred because wiring it now would destroy the measurement.
> **P1 asks what class the existing, unmodified runner assigns to a blocked run.** A classifier
> installed in `run-agent.sh` before batch 1 changes that answer by construction: it is a
> registered variable moved mid-experiment (§6), and P1 becomes unanswerable rather than
> refuted. Which class is *right* is also not knowable yet — `F13`/`F15` mean contamination and
> harness bug, and whether a block belongs with them depends on where batch 1 shows blocked runs
> currently landing.
>
> The cost of being wrong is one wiring commit at step 10. The cost of the alternative is the
> primary prediction.
>
> *Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-11.*

## What step 4 deliberately did not build

- No `BLOCKED` value in the run record. The step-2 table already labels that **L3 on its own** —
  an enum value nothing validates is the schema-note case.
- No `measurementStatus` field.
- No `F10` admission to `INFRASTRUCTURE` (read at `analyze-experiment.py:160`,
  `baseline-report.py:134`, `derive-mde.py:77`).
- No completion-contract signal. The abstention case is Lab 5B.4 and §6 forbids a future
  step's artifacts.
