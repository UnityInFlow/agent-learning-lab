# B2 runbook — the plain-prompt baseline, end to end

Written 2026-08-28, before the first run. Every command here was exercised against a stub
run; the only step never executed for real is the agent launch itself.

**B2 builds nothing.** What it produces is the number everything downstream is compared
against. If it is sloppy, nothing after it means anything.

## 0 — Preconditions

```bash
# stack up, on THIS machine's ports (3000/8080/5173 are taken; infra/.env overrides them)
cd ../agent-observatory && make up && make urls

# runtimes. Copilot is DEFERRED — premium quota exhausted, resets 2026-09-01. Two arms, not three.
claude --version && codex --version
```

| must be true | why |
|---|---|
| `0A` complete | B2's prerequisite. Not a formality — 0A is where you learn what the harness does when an agent is blocked, which is the failure B2 will hit |
| `B1` closed | B2's gate wants completed rubrics, and the rubric is B1's product |
| stack reachable | `run-agent.sh` dies on `${API}/actuator/health` rather than recording a broken run |

## 1 — Run the baseline

**Five runs, three minimum. One run is a story.**

```bash
cd ../agent-observatory
make baseline-runs \
  N=5 \
  RUNTIME=claude \
  MODEL=<exact-model-id> \
  BENCHMARK=BE-003 \
  VARIANT=baseline \
  EXPERIMENT=EXP-B2-BASELINE-CLAUDE \
  ISOLATE_USER_SETTINGS=1 \
  KEEP=1
```

Then the second arm, identical but `RUNTIME=codex` and its own `EXPERIMENT=`.

**`ISOLATE_USER_SETTINGS=1` is not optional.** It passes `--setting-sources project`. Without
it, **22 user-level hooks across 8 events** join the run and you are measuring this machine,
not the baseline. Verified 2026-08-28; the phase README still says ~21.

**`KEEP=1` is not optional either.** `run-agent.sh` deletes the worktree at step 12, and the
scorer reads the changed files out of it. Discovered after five runs, this costs all five.

**Never `--bare`.** It skips hooks *and* `CLAUDE.md` discovery — which is B3's treatment —
and forces `ANTHROPIC_API_KEY`, so on a subscription account it exits `Not logged in`.

**Pin `MODEL` explicitly.** `auto` lets the vendor route, which breaks the one-variable rule
the moment their routing changes underneath the comparison.

## 2 — Score each run against the rubric

```bash
cd ../agent-learning-lab
./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml --run-id <run-id>
```

**`--run-id`, not a directory.** The scorer derives the worktree from the id, so the path and
the record cannot disagree. It then reads `GET /api/runs/<id>` and scores only if the
evaluator recorded `passed` / `exitCode 0` — **Decision D**. No evaluation record means
refuse: an unevaluated run is not a passing one.

Set `LAB_OBSERVATORY_API` if the API is not on `http://localhost:8081`.

**Inspect the evidence set before committing five runs to it:**

```bash
LAB_SCORE_DRY_RUN=/tmp/prompt.md ./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml --run-id <id>
grep -E '^### (BASELINE )?FILE:' /tmp/prompt.md
```

Expect **the files the agent changed, and their pre-agent versions** — not all 25 files in
the service. That is Decision D, and the reason is `test-quality`: `sample-service` already
ships `ShipmentControllerTest.kt`, so attaching the whole worktree would put a test file
among the attachments on every run and Decision A's null precondition could never fire.

## 3 — Record per run

`templates/run-record.yaml`, plus what B2 specifically asks for: which files it inspected ·
did it understand the architecture · did it verify its own work · what needed correction ·
**which metrics were even available**.

That last one is where the Codex arm differs. **ADR-001: Codex's telemetry is not
normalized.** It launches, runs and records a verdict, but its structured agent-aware events
(approvals, tool results, MCP calls) are not comparable to the trace/metric shape. Record
that as a property of the arm; do not read it as the agent behaving differently.

## 4 — Gate

- ≥3 run folders with diffs, verification results and completed rubrics
- a baseline report with **median and range** — never an average alone

## Known limitations, recorded rather than discovered later

- **`opencode-score.sh` has no `--run-id` path.** Decision C makes `codex` the scorer, so B2
  does not need it. A cross-harness check on B2 would, and that is not currently possible.
- **Copilot arm deferred** to after 2026-09-01. It is the runtime the business case names for
  v1, so add it before drawing conclusions — not after.
- **`architecture-consistency` may null if the agent never touched `ApiError.kt`.** Its
  anchors rest on the convention that file declares, and under Decision D an unchanged file
  is not attached. BE-003 requires the error envelope so it should change; if it does not,
  that null is honest and informative rather than a defect.
