# B2 runbook — the plain-prompt baseline, end to end

Written 2026-08-28, before the first run. Every command here was exercised against a stub
run; the only step never executed for real is the agent launch itself.

**Revised the same day, after a readiness review found three defects in the harness that
this runbook would have walked straight into.** Read
[`READINESS.md`](READINESS.md) before step 0 — it carries what was wrong, what was fixed in
`agent-observatory` commit `b288625`, and the one hypothesis that was tested and refuted.

**B2 builds nothing.** What it produces is the number everything downstream is compared
against. If it is sloppy, nothing after it means anything.

## 0 — Preconditions

> **Launch from a plain shell, and read the runner's `shims` line.** A terminal host can put
> a wrapper ahead of the real CLI on `$PATH` — cmux does, and it appends `--settings` with 12
> hooks to every `claude` call and `--dangerously-bypass-hook-trust` to every `codex` call.
> That added **26 hook executions** to the first rehearsal, on PreToolUse and
> PermissionRequest, invisible to the run record. `run-agent.sh` now strips those shims and
> reports it (`agent-observatory` `b46f4e6`) — **read the line rather than assume it.**

```bash
# stack up, on THIS machine's ports (3000/8080/5173 are taken; infra/.env overrides them)
cd ../agent-observatory && make up

# PROVE it is up. `make urls` prints configuration and connects to nothing — if Tempo is
# down, every run completes and loses its traces silently, and you find out after the runs
# are spent. `make smoke` probes all six services and the API contract: 18 checks.
make smoke

# runtimes. Two arms, not three — see below.
claude --version && codex --version

# the codex arm's isolation is an ENVIRONMENT, not a flag, and it is re-checkable.
# Two-sided: it proves the leak is detectable before it reports that there is none.
./runner/verify-codex-isolation.sh
```

**Copilot is deferred, and that was measured rather than assumed.** `premium_interactions`
is at `remaining: -1` with `overage_permitted: false`, resetting **2026-09-01**. Because
overage is forbidden, a call that would cost a premium interaction must be refused — so a
successful call would have proved it cost none. It was tried:
`copilot --model gpt-5.4-mini …` → **`You have no quota`**. The CLI is gated by the premium
counter regardless of model. **Two arms until 2026-09-01, then add the third before drawing
conclusions.**

| must be true | why |
|---|---|
| `0A` complete | B2's prerequisite. Not a formality — 0A is where you learn what the harness does when an agent is blocked, which is the failure B2 will hit. **NOT DONE** |
| `B1` closed | B2's gate wants completed rubrics, and the rubric is B1's product. **NOT CLOSED** — 4 predictions and 17 blind cells outstanding, both author-only |
| stack reachable | `run-agent.sh` dies on `${API}/actuator/health` rather than recording a broken run. **`make smoke` 18/18** |
| codex arm at parity | until `b288625` this arm had no model, no sandbox policy and no isolation, and would have recorded a model it never used. **DONE** |

**Neither unmet precondition is a defect; both are decisions.** Running B2 before B1 closes
means the runs are valid — they are recorded agent behaviour — but no sheet can be produced
until the rubric is closed, and if B1's gap analysis rejects the rubric the *sheets* must be
re-produced while the *runs* need not. Running before 0A costs interpretation, not data.
Decide deliberately; do not drift past them.

## 0.5 — Rehearse ONE run per arm, and inspect it, before any batch

**This is the only step left that costs a run, and it is the one that cannot be skipped.**
Decision D's attachment set cannot be inspected without a real worktree, and inspecting it
after five runs is inspecting it too late.

```bash
cd ../agent-observatory
make run-benchmark \
  RUNTIME=claude MODEL=<exact-model-id> BENCHMARK=BE-003 VARIANT=baseline \
  EXPERIMENT=EXP-B2-REHEARSAL-CLAUDE ISOLATE_USER_SETTINGS=1 KEEP=1

# then the same with RUNTIME=codex and EXPERIMENT=EXP-B2-REHEARSAL-CODEX
```

Three things to check on each, in this order:

```bash
# 1. the record does not lie about its own independent variable
curl -fsS "$API/api/runs/<run-id>" | jq '{runtime, variant, experimentKey}'
#    runtime.model must be the model you asked for AND the one the CLI was told.

# 2. the worktree survived
ls -d ${TMPDIR}observatory-run-<run-id>

# 3. the evidence set is Decision D's, not the whole service
cd ../agent-learning-lab
LAB_SCORE_DRY_RUN=/tmp/prompt.md ./tools/codex-score.sh \
  benchmark/rubrics/backend-quality.yaml --run-id <run-id>
grep -cE '^### (BASELINE )?FILE:' /tmp/prompt.md
```

**Expect a handful of files, not 25.** If the count is 25 the whole service is attached,
`test-quality`'s null precondition can never fire, and Decision A is silently disabled
between B1 and B2. **Do not start the batch on a 25.**

**Rehearsal runs use their own `EXPERIMENT=` keys** so they never land in the batch's `n`.

### The rehearsal was run, 2026-08-29. Both arms passed. Here is what it proved.

| check | claude `092a384a` | codex `514b094e` |
|---|---|---|
| evaluator | `passed: true`, `exitCode 0` | `passed: true`, `exitCode 0` |
| `runtime.model` recorded | `claude-haiku-4-5-20251001` — the **exact id**, not the `haiku` alias | `gpt-5.6-sol`, and this time actually forwarded |
| worktree kept | yes | yes |
| **attachment set** | **3 files + 3 pre-agent baselines** | **2 files + 2 pre-agent baselines** |
| isolation | `--setting-sources project` | `CODEX_HOME=…codex-home (auth.json only)`; **RTK did not appear anywhere in the log** |
| files changed | `ApiError.kt`, `ShipmentController.kt`, `ShipmentControllerTest.kt` | `ShipmentController.kt`, `ShipmentControllerTest.kt` |

**Decision D is proven end to end.** Not 25 files — the changed files and their pre-agent
versions, exactly as specified, on a real run. That could not be checked any other way.

**The codex run did not touch `ApiError.kt`**, which is the case the known-limitations
section below predicted: under Decision D an unchanged file is not attached, so
`architecture-consistency` may legitimately `null` on that arm. **That null is honest and
informative — do not read it as a defect.**

**A finding the rehearsal produced that no amount of reading would have — now fixed.** The
codex arm recorded `behavior.modelCalls: 0`, `toolCalls: 0`, `permissionRequests: 0` while
adding 64 lines of working code, because `run-agent.sh` fills `BEHAVIOR` only for
`copilot|claude` and the API rendered the empty object as zeros. The inconsistency was
*inside one record*: `efficiency` reported `null` for the same missing measurements and
`behavior` reported `0`.

**Fixed before the baseline rather than after it** — `agent-observatory` `5ed158e`,
migration `V4__behavior_not_measured.sql`. The counters are nullable; `null` is "not
measured" and `0` is "measured as zero". 18 historical rows became null, 156 kept their
measurements, and the claude rehearsal still reports `retries: 0` because that was measured.
`analyze-experiment.py` now names it out loud — *"arm 'baseline' has 1 run(s) missing
toolCalls telemetry"* — instead of averaging a zero in.

**The reason it was fixed first and not caveated:** zero batch runs existed, so changing the
instrument cost nothing. Once the baseline is on record it costs the baseline. That is the
same argument that justified rebuilding the codex arm, applied one layer up.

**What is still true:** codex reports honest nulls, not real numbers. `behavior.*` and
`efficiency.*` remain **not comparable across arms** until observatory#10 normalizes codex
telemetry — the difference is that the record now says so itself rather than requiring a
reader to know. Quality and outcome are comparable. The rubric half was never affected;
scoring reads source files.

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

**Name the keys so an arm cannot be mistaken for a treatment.** `EXP-B2-BASELINE-CLAUDE`
and `EXP-B2-BASELINE-CODEX`. The database already contains `EXP-BE003-CLAUDEMD` holding
runs whose `variant` says `baseline` — a name and a field that disagree, with nothing on
disk to resolve them. Do not add a second one.

**`baseline-runs` now asserts its own `n`.** It counts *recorded runs* before and after the
batch and exits 1 naming the shortfall. Before `b288625` a batch of five where three died
printed five banners and exited 0. If it reports a shortfall, **re-run the shortfall or
report the real `n`** — do not report the one you asked for.

**`ISOLATE_USER_SETTINGS=1` is not optional, and it means something different on each arm.**

- **claude** — passes `--setting-sources project`. **Verified by telemetry 2026-08-29, and
  the verification changed what the claim means:** the 22 user-level hooks are still
  *registered* in an isolated run, and **none of them execute** — every hook execution in
  that run came from somewhere else. Registration is not execution; do not read a
  registration count as contamination.
- **codex** — builds a `CODEX_HOME` holding `auth.json` and nothing else. Without it the run
  loads `~/.codex/AGENTS.md`, which imports a 32-line shell-routing instruction file, plus
  **3 MCP servers** (one a code-search tool), **71 skills** and **66 agents**. A global
  instruction file inside a plain baseline is B3's treatment inside B2's control.
  **`--ignore-user-config` does NOT do this** — measured, with a marker token: the
  instructions survived the flag. See `READINESS.md` §3.3b.

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

```bash
cd ../agent-observatory
make baseline-report EXPERIMENT=EXP-B2-BASELINE-CLAUDE
./runner/baseline-report.py EXP-B2-BASELINE-CLAUDE EXP-B2-BASELINE-CODEX   # side by side
```

**Built 2026-08-29 because nothing could produce this.** `analyze-experiment.py` analyses a
*two-arm* experiment and refuses without a treatment, so asking it to describe B2 returns
`arm 'instructions' has 0 measuring runs, expected 10`. `baseline-report.py` prints no mean —
it does not compute one, and a test asserts that against the parsed tree.

It shares the exclusion rule, the telemetry rule and the metric accessors with
`analyze-experiment.py`, so a baseline and a later comparison cannot disagree about which
runs counted: F13/F15 discarded and named, a run missing a measurement excluded from *that*
metric and counted in the output, an F03 kept because the agent being wrong is the
measurement. It refuses below three runs, and it warns when an arm mixes models or runtime
versions.

**Why it matters, on this project's own data:** over the 17 BE-003 runs already recorded,
median duration is **101 s** and the maximum is **1711 s**. The mean is 262 — a number no run
produced. That is the whole argument for "never an average alone", and it is already in your
database.

## Known limitations, recorded rather than discovered later

- **`opencode-score.sh` has no `--run-id` path.** Decision C makes `codex` the scorer, so B2
  does not need it. A cross-harness check on B2 would, and that is not currently possible.
- **Copilot arm deferred** to after 2026-09-01, and the deferral was *tested*, not assumed:
  `copilot --model gpt-5.4-mini` returns `You have no quota`. The premium counter gates the
  CLI regardless of model. It is the runtime the business case names for v1, so add it
  before drawing conclusions — not after.
- **Codex telemetry is not normalized (ADR-001), but the data exists.** `codex exec --json`
  emits JSONL events. That is a mapping gap, not an absence, and it is worth recording as
  the smaller thing it is. `--json` is deliberately *not* used today because it replaces the
  human-readable stream the other two arms `tee` into `$AGENT_LOG`.
- **Three hook events fire on every codex run**, isolated or not, and
  `--dangerously-bypass-hook-trust` is reported as enabled on every invocation on this
  machine. They are not the operator's hooks — `~/.codex/hooks.json` currently fails to
  parse, so those do not load at all. **The arm is clean by accident. Repair that file and
  it stops being clean.** Open question, recorded rather than assumed harmless.
- **`architecture-consistency` may null if the agent never touched `ApiError.kt`.** Its
  anchors rest on the convention that file declares, and under Decision D an unchanged file
  is not attached. BE-003 requires the error envelope so it should change; if it does not,
  that null is honest and informative rather than a defect.
