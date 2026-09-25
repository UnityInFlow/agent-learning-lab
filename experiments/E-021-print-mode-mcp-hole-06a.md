# Experiment E-021 — the print-mode MCP hole

**Experiment key:** `EXP-06A-MCP-PRINT-MODE`
**Spine stop:** 18 (Phase 6A — Code intelligence) · **Lab 6.5** · **Branch:** `stop18/06a-code-intelligence`
**Workbook:** [`phases/06a-code-intelligence/README.md`](../phases/06a-code-intelligence/README.md)
**Version:** none. This stop builds no version of the agent; it measures the harness.

> **Everything down to and including Decision rule was written and committed BEFORE the first
> run.** The commit timestamp and the first run's `startedAt` are both written into
> *Prediction-commit ordering* below, after the runs, from git and from the run log — not from
> prose.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-25T18:39Z; the author did not
review before the run.`

## Question

`run-agent.sh:776` passes `--strict-mcp-config` on every claude run and passes no
`--mcp-config`, and its own comment says the reason is that otherwise *"the agent inherits
whatever MCP servers the operator has configured"*. The Claude Code documentation says a
**project-scoped** `.mcp.json` is approved interactively — and then says:

> "In `claude -p` runs, Agent SDK sessions, and cloud sessions, Claude Code can't show that
> prompt: it loads project-scoped servers without asking."

**Every run this project has ever made is `claude -p`** (`run-agent.sh:816-817`).

So: **does a project-scoped `.mcp.json` actually reach the model under `claude -p`, and does
`--strict-mcp-config` actually stop it?** The first half decides whether the documented
approval prompt is a safeguard this harness has (it is not). The second half decides whether
the flag the harness relies on instead is an **L2 control that executes** or an **L3 claim
about help text**.

This is not a vendor-claim re-read. It is the same shape as `--disable-slash-commands`, whose
scope excluded this harness and on which position 8 built a halt from a wrong premise. That
one was found by probe, after the halt. This one is probed before anything depends on it.

## Hypothesis

`--strict-mcp-config` is a real filter applied by the CLI when it assembles the session's MCP
server set, so a project-scoped `.mcp.json` in the run's working directory is loaded in its
absence and dropped in its presence. The interactive approval prompt is not in the path at
all in print mode, so its absence changes nothing about what loads — it only removes the
operator's chance to see it.

**Mechanism, stated so it can be wrong:** the flag acts on *configuration sources*, not on
*tool names*. E-005 measured the opposite kind of filter on `tools:` — a name filter the
runtime rewrote — and stop 17a then measured `tools:` withholding a capability outright. A
source filter should be all-or-nothing per source, which is why the predictions below are
5-of-5 / 0-of-5 rather than a rate.

## Predictions

The registered outcome per run is **the delivered MCP tool set, read from the run's own
`system`/`init` stream-json record** — the only place the delivered schema exists (E-005;
author decision 8's read-back). Specifically: does the string `mcp__stop18probe__` appear in
`init.tools`, and does `stop18probe` appear in `init.mcp_servers` and with what `status`.

1. **Arm P (positive control) delivers the tool.** `mcp__stop18probe__probe_marker` appears in
   `init.tools` on **1 of 1** run, and `stop18probe` appears in `init.mcp_servers` with
   `status: connected`. *Mechanism:* `--mcp-config` is the source `--strict-mcp-config`
   explicitly permits. **If this fails the lab is VOID (row 0) and no claim is made about A or
   B** — a null in both arms would otherwise be indistinguishable from a broken server, which
   is this project's house failure mode wearing a different hat.
2. **Arm A (no `--strict-mcp-config`) delivers the tool on 5 of 5.** *Mechanism:* the
   documented sentence above; nothing else in the runner's flag set names `.mcp.json`.
3. **Arm B (the harness as it runs) delivers it on 0 of 5**, and `init.mcp_servers` either is
   empty or does not contain `stop18probe`. *Mechanism:* the flag's own help text on 2.1.282,
   *"Only use MCP servers from --mcp-config, ignoring all other MCP configurations"*, with no
   `--mcp-config` passed.
4. **No approval prompt appears in either arm's stream** — no `permission` / `can_use_tool`
   event and no assistant text asking to approve an MCP server — on 10 of 10 runs of A and B.
   *Mechanism:* print mode cannot display it. **This is the prediction that makes the
   documented safeguard L3-and-absent rather than merely L3**, and it is falsifiable: one
   approval event anywhere refutes it.
5. **Arm A′ (contingency, run only if prediction 2 is refuted with a null on all 5).**
   Removing `--setting-sources project` as well makes the tool appear on 5 of 5. *Mechanism:*
   `.mcp.json` would then be reached through the project settings source rather than through
   its own loader. **If A′ is also null on 5 of 5, the documented sentence does not describe
   CLI 2.1.282**, and that — not a confirmation — is the stop's finding.

**Which claim each makes (template's two-column rule).** 1, 2, 3 and 5 are **one-arm
binomials** — "this arm reaches X on k of n" — and need no control to be refuted. 4 is a
one-arm binomial pooled over two arms. The **A-vs-B contrast** is the two-arm claim and is the
only place an MDE applies.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing between arms A and B: the presence of `--strict-mcp-config` on the
`claude` command line.** Arm P adds `--mcp-config` and is a positive control, not a
comparison. Arm A′ removes `--setting-sources project` and is a diagnostic that runs only on
the branch prediction 5 names.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | A project-scope `.mcp.json` in the run's working directory, declaring one stdio server `stop18probe` that exposes one tool `probe_marker`. The server is a dependency-free Python 3 stdio JSON-RPC process implementing `initialize`, `notifications/initialized`, `tools/list` and `tools/call`. |
| Content hash | `sha256` of `.mcp.json` and of `probe_server.py`, computed by the probe driver before the first run and written into `evidence/p06a/mcp-hole-probe-<ts>/HASHES.txt`; the same bytes are committed inert as `evidence/p06a/mcp.json.fixture` and `evidence/p06a/probe_server.py.fixture`. |
| Preflight assertion | **Arm P.** The tool must appear in `init.tools` on the positive-control run. This proves the server is reachable *and* that the read-back can see an MCP tool at all. Nothing else in this experiment is interpretable until it holds. |
| Control assertion | **Arm B.** `mcp__stop18probe__` absent from `init.tools` and `stop18probe` absent from `init.mcp_servers`, per run, read from that run's own `init` record — never inferred from the flag being on the command line. |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.
> **Here the inverse is also true: a flag on a command line is not a control.** That is the
> whole experiment.

**Why the read-back and not the run record.** `customization.mcpHash` is null by construction
on every run ever recorded (workbook extract §4: the emitter at `run-agent.sh:645` produces
four hashes and `mcpHash` is not one of them). There is therefore **no observatory field that
can carry this measurement**, which is why this lab does not use the runner at all and reads
the CLI's own `init` record directly.

## Controlled variables

- [x] starting commit / benchmark revision SHA — **n/a, no benchmark task runs.** The prompt
      is a fixed 9-word string, identical in every arm, recorded in `PROMPT.txt`.
- [x] task + revision — the fixed prompt above.
- [x] harness + version — `claude` **2.1.282**, recorded by `claude --version` into the
      evidence directory before the first run and again after the last.
- [x] model — **`claude-haiku-4-5-20251001`**, passed with `--model` on every arm. This is the
      pinned agent under test (§2) and it does not move, even though no task is performed.
- [x] permissions / permission mode — `--permission-mode acceptEdits` and the same two
      `--allowedTools` entries on every arm, copied from `run-agent.sh:775-777`.
- [x] environment: hooks, plugins, skills, MCP servers, settings sources —
      `--disable-slash-commands` and `--setting-sources project` on P, A and B; **A′ is the
      one arm that drops the second, and that is its entire definition.** The working
      directory is a throwaway outside all three repositories, created fresh per run, so no
      `CLAUDE.md`, no `.claude/`, no skill and no git history is inherited.
- [x] runner commit — **n/a: `run-agent.sh` is not invoked.** Its flag set is copied verbatim
      from `run-agent.sh:774-777, 786-792, 816-817` (runner commit `5ba0719a5983`) at the commit recorded in `HASHES.txt`,
      and the copy is asserted line-by-line by the probe driver's guard 4, which refuses to
      run if the runner's flag block has changed.

## Runs

Repetitions per arm: **P = 1 · A = 5 · B = 5 · A′ = 5 (contingency only)** · Total budget:
**$0.50**, hard-stopped by the driver at that ceiling.

Eleven runs at minimum, sixteen at most. Each run is a nine-word prompt answered by a haiku
model; the `init` record is emitted before the model does any work, so the cost is dominated
by session start-up. The estimate is ~$0.005–0.02 per run. **`n = 5` and not 3** because §5
forbids stating an `n < 5` result as a property, and predictions 2, 3 and 5 are written as
properties of the flag, not as facts about particular runs.

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

**This is not a decision about the agent under test.** `n = 0` on the agent: no task is
performed, no diff is produced, nothing is scored by a rubric, and no result here enters any
B step's comparison. It decides whether an existing control executes.

## Minimum detectable effect

**Derived from a measured arm before any threshold above was written.** The measured arm this
transfers from is **E-005's arm F** (`phases/04a-agents-permissions/`, `experiments/E-005`),
the only prior measurement in this project of *what the CLI delivers into `init.tools`*: the
delivered tool list was `["Read","Bash"]` on **10 of 10** runs against a `tools:` file naming
four. The spread of that outcome was **zero** — a delivered tool set is a deterministic
function of the launch on a fixed CLI version, and stop 17a measured the same shape again
(`["Read","Grep","Glob"]`, verdict MATCH, **5 of 5**).

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: `mcp__stop18probe__` present in `init.tools`, A vs B | E-005 arm F: 10/10 at zero spread; stop 17a: 5/5 at zero spread | With zero within-arm spread, **5 vs 0 of 5 is Fisher `p = 0.0079`**; the smallest detectable split at `n = 5` per arm is **4/5 vs 0/5, `p = 0.048`**. A 3/5-vs-0/5 split is `p = 0.167` and is **not** detectable. | yes |
| secondary: `stop18probe` in `init.mcp_servers` | same | same | yes |
| secondary: any approval/permission event in the stream, pooled A+B | none — never observed in this project | one-arm: a single event refutes prediction 4 at `n = 10`; there is no threshold to miss | yes |

**Derived against the interval, not the point estimate.** The plausible range for arm A's rate
is not 0–100 %: it is **either 0 or 5 of 5**, because the delivered set is assembled from
configuration before any sampling happens. The only outcome that would put this experiment
inside its own MDE is an arm landing at 1–3 of 5 — which is why **decision-rule row 4 exists
and is written to catch exactly that**, and why a mid-range count is recorded as
nondeterminism rather than as an effect. That is the §0a row-6 lesson applied in advance: on
seven invocations `verify-codex-isolation.sh` returned four leaks and three passes, and the
session that saw a disagreement read it as an unreliable reader rather than a nondeterministic
instrument. **Re-deriving a value once distinguishes a misread from a fact only when the value
is stable**, so every arm here runs 5 times even where 1 would "obviously" do.

## Deterministic evaluation

There is no evaluator and no rubric — nothing is scored, so `codex-score.sh` and
`opencode-score.sh` do not run and Decision C is not engaged. Correctness is decided by
`jq` over each run's own `init` record:

```
jq -r 'select(.type=="system" and .subtype=="init") | {tools, mcp_servers}'
```

run by `evidence/p06a/run-mcp-hole-probe.sh` and written per run to
`init-<arm>-<i>.json`, with the two derived booleans in `RESULT.tsv`. The classification is
mechanical: a substring test for `mcp__stop18probe__` and a key test for `stop18probe`.
**A run whose stream contains no `init` record at all produces no row**; see Exclusions.

## Exclusions

Registered now, before any data:

- **No `init` record in the stream** (harness failure, non-zero exit before session start):
  the run is excluded, its index recorded in `RESULT.tsv` as `no-init`, and **one replacement
  run is launched** so the arm still reaches its registered `n`. More than two such runs in
  one arm ends the lab as VOID rather than being papered over.
- **A rate limit (the F13 shape: `429`/`529` in the stream, or a `result` record reporting a
  usage limit):** excluded, recorded, replaced once. `--keep` does not apply — there is no
  worktree — so the whole stream log is kept instead.
- **Budget ceiling reached** ($0.50): the batch stops and the population that occurred is
  reported, as E-016 did at `n = 7` and E-020 did at `n = 8`.
- **Nothing is excluded after seeing the data.** No result of this lab is excluded for being
  surprising; a surprising result is row 2 or row 3.

## Decision rule

Registered before data. The rows are exhaustive and disjoint; every combination of
(P, A-count, B-count) reaches exactly one.

| Row | Condition | Verdict |
|---|---|---|
| **0 — VOID** | Arm P does not deliver `mcp__stop18probe__`, **or** >2 excluded runs in any arm | The instrument is unproven. **No claim is made about A or B.** Fix the probe, re-run, and record the void as the result of the attempt. |
| **1 — HOLE REAL, CONTROL EXECUTES** | P ok · A ≥ 4 of 5 · B = 0 of 5 | Both halves: the documented approval prompt is absent in print mode **and** `--strict-mcp-config` is an **L2 control that executes**. The workbook's provisional label is settled to L2 with the run ids as evidence. |
| **2 — HOLE REAL, CONTROL LEAKS** | P ok · A ≥ 4 of 5 · B ≥ 1 of 5 | `--strict-mcp-config` is **L3 on this dimension**. Every plain-baseline run in this project's history inherits an unproven isolation claim. Goes to `author_notes` the same session, and the exact leak count is reported — a B between 1 and 4 is *also* nondeterministic and is named as such inside this row. |
| **3 — NO HOLE IN THIS CONFIGURATION** | P ok · A = 0 of 5 | The documented sentence does not describe this launch. **Run A′.** A′ ≥ 4 of 5 → the flag that closes it is `--setting-sources project`, and `--strict-mcp-config` is not the load-bearing one; A′ = 0 of 5 → the sentence does not describe CLI 2.1.282 at all and the extract's §3 gets a dated amendment carrying this measurement. Either way the extract is amended, never rewritten. |
| **4 — NONDETERMINISTIC** | P ok · A between 1 and 3 of 5 | The delivered set is not a deterministic function of the launch. **No property is stated**; the counts that occurred are reported. This is the strongest result of the four for the project, because every delivery proof in Track B assumes exactly the determinism this row denies. |

**Cost is a reported row, never a condition on a verdict row.** Total spend and per-run spend
are reported beside the verdict; no row pairs "it did not work" with "it was expensive".

**Keep / remove (§4 step 10).** `--strict-mcp-config` is an existing control, not a new rule,
so the keep/remove decision is: **row 1 → keep, and the keep is now measured rather than
assumed**; **row 2 → keep the flag and record that it is insufficient, and name what would
replace it**; **row 3 → keep, and record that its contribution on this dimension is
unmeasured**; **row 4 → keep, and the finding is about the instrument, not the flag.** No row
removes it: removing a control on the strength of one lab is how this project would lose its
baseline isolation, and §6 forbids editing a registered variable of every past run.

## Deliberate failure — §4 step 9, registered BEFORE it runs

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-25T18:52Z, after arms P, A and B
were run and read, and before arm D existed. The author did not review before the run.`

**What is being broken is the containment claim, not the flag.** Arms A and B settle that
`--strict-mcp-config` filters a `.mcp.json` **in the run's own working directory**. The way
that finding could still be wrong in practice is if the hole reaches this harness through a
path arm A never tested — and there is exactly one such path with a name: **a `.mcp.json`
above the run's cwd.** Every benchmark run this project makes happens in a git worktree
nested inside a directory tree the operator controls, so "project scope" meaning *cwd only*
versus *anywhere at or above cwd* is the difference between a hole that needs a file planted
in the worktree and a hole that needs one planted anywhere above it.

**Arm D:** the arm-A flag set exactly, cwd **empty**, and the `.mcp.json` one directory
**above** it. `n = 5`. Budget ~$0.08, inside the $0.50 ceiling (spent so far: $0.1548).

**Predictions, both falsifiable, neither edited after the run:**

- **DF1 — `mcp__stop18probe__` is ABSENT on 5 of 5.** *Mechanism:* "project scope" in Claude
  Code means the file in the directory the session starts in, and nothing walks upward. If
  this holds, the hole measured in arm A requires a file **inside** the run's own worktree,
  which is a materially narrower exposure than an operator's home directory.
- **DF2 — `stop18probe` is absent from `init.mcp_servers` on 5 of 5**, for the same reason.

**The clause to watch, and it is bigger than the experiment that checks it:** *if DF1 is
refuted — if the tool appears — then any benchmark worktree nested under a directory that
carries a `.mcp.json` inherits it silently under `claude -p`, `--strict-mcp-config` is the
only thing standing between this project's every baseline run and an operator's file it never
looks at, and the extract's §3 understates the hole rather than overstating it.* That is a
`author_notes` item the same session and a direct input to **B9 (stop 20)**.

**Why this and not "remove `--strict-mcp-config` and watch it break":** that is arm A, already
run. A deliberate failure that re-runs an arm measures nothing. This one asks a question whose
answer is not implied by any run already on disk, and whose refutation would enlarge the
stop's own finding rather than confirm it.

**Arm D is a deliberate failure, not a comparison arm.** It enters no decision-rule row of the
A-vs-B contrast, moves no registered variable, and is reported on its own.

### Deliberate failure, extension — arms D2 and D3, registered BEFORE either exists

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-25T18:53Z, after arm D was run
and hand-verified, and before arms D2 and D3 existed. The author did not review before the
run. Additive: nothing above is edited, and arm D's registered prediction stays refuted.`

**Arm D refuted DF1 and DF2 at 5 of 5: the loader walks upward.** That turns the stop's
finding from *"a file planted in the run's own worktree"* into *"a file planted somewhere
above it"*, and **how far above** decides whether this project's actual runs are exposed.
Every benchmark run happens in a **git worktree** nested under directories the operator
controls, so there are exactly two questions worth one run each:

- **DF3 — depth. Arm D2:** `.mcp.json` at the top of a throwaway tree, cwd **three plain
  directories below it**, arm-A flags, no git anywhere. **Prediction: the probe tool is
  PRESENT on 5 of 5.** *Mechanism:* arm D showed one level; a loader that walks at all has no
  reason to stop at one, and the documented phrase is "project scope", not "parent scope".
- **DF4 — the git boundary. Arm D3:** `.mcp.json` at the top of a throwaway tree, cwd a
  directory **two levels below that is itself a `git init`-ed repository**, arm-A flags.
  **Prediction: the probe tool is PRESENT on 5 of 5 — i.e. the git root does NOT stop the
  walk.** *Mechanism:* the MCP loader and git's repository discovery are unrelated subsystems
  and nothing in the docs ties one to the other.

**DF4 is the one that matters, and it is written to be wrong in the direction that would be
good news.** If the tool is **absent** on 5 of 5 in arm D3, the git root **is** the boundary,
and this project's benchmark worktrees are protected by a property of git rather than by
`--strict-mcp-config` — a materially smaller exposure and a different sentence in the extract.
If it is **present**, then an operator's `.mcp.json` anywhere above the worktree reaches every
`claude -p` run that does not pass `--strict-mcp-config`, and the flag at `run-agent.sh:776`
is the single thing standing between this project's baseline and the operator's machine.

`n = 5` per arm, ~$0.10 for both, inside the $0.50 ceiling (spent after arm D: $0.1838).
Neither arm enters the A-vs-B decision rule; both are reported on their own.

---
*Everything below is filled in AFTER the runs.*
---

## Prediction-commit ordering

| | |
|---|---|
| Prediction commit sha | `5f3f69139951a7ea303d6012bf9280b549fc28af` |
| Prediction commit timestamp | **2026-09-25T18:42:24Z** (`git log -1 --format=%cI`, converted from +02:00) |
| First run's `startedAt` | **2026-09-25T18:45:33Z** (arm P, `preflight-20260925T184532Z/RESULT.tsv`) |
| Ordering holds? | **Yes — the prediction commit precedes the first run by 3 min 9 s.** Both values read from git and from the driver's own TSV, not from prose. |

Arm D's prediction was committed at `054b0b8` (2026-09-25T18:50Z) before arm D's driver
existed; arms D2 and D3's predictions at `2c27630` (2026-09-25T18:53Z) before theirs did.
Neither is edited after its run.

## Observed telemetry

None. This lab reads the CLI's own `system`/`init` stream-json record and the terminal
`result` record, per run, on disk. **No observatory run record exists for any of these 26
runs** — `run-agent.sh` was never invoked — and that is deliberate: `customization.mcpHash`
is null by construction on every run the observatory has ever stored, so there is no field
that could have carried the measurement. Cost comes from `result.total_cost_usd`, the CLI's
own accounting, and is not a telemetry-sourced number.

## Results

**Evidence root:** `evidence/p06a/` · arm P in `preflight-20260925T184532Z/` · arms A and B in `batch-20260925T184656Z/` ·
arm D in `deliberate-failure-20260925T185104Z/` · arms D2 and D3 in `walk-D2-20260925T185343Z/` and `walk-D3-20260925T185343Z/`.

### Raw — the registered outcome, per run

| Arm | flags, relative to `run-agent.sh`'s claude set | `.mcp.json` at | `mcp__stop18probe__probe_marker` in `init.tools` |
|---|---|---|---|
| **P** | + `--mcp-config` | cwd (ignored) | **yes — 1 of 1** |
| **A** | **MINUS `--strict-mcp-config`** | cwd | **yes — 5 of 5** |
| **B** | unchanged | cwd | **no — 0 of 5** |
| **D** | as A | **one level above an empty cwd** | **yes — 5 of 5** |
| **D2** | as A | **three levels above** | **yes — 5 of 5** |
| **D3** | as A | **two levels above, cwd is a git repo** | **yes — 5 of 5** |

`server_present` and `server_status` track `tool_present` exactly on all 26 runs: wherever the
tool is delivered, `stop18probe` is in `init.mcp_servers` with `status: connected` and
`source: project`; wherever it is not, `init.mcp_servers` is `[]`.

**A vs B, the one registered contrast: 5 of 5 against 0 of 5, two-sided Fisher `p = 0.0079`**
— the exact value the MDE table registered before the run for a complete separation at `n = 5`
per arm. Zero within-arm spread in both arms, as the transferred E-005 spread predicted.

### Summary — median and range, never an average alone

| Metric | Arm A (no `--strict-mcp-config`) | Arm B (the harness as it runs) |
|---|---|---|
| probe tool delivered | 5 of 5 | 0 of 5 |
| **total tools delivered** | **median 53, range 37–53** | **median 28, range 28–28** |
| MCP tools delivered | median 22, range 9–22 | 0 on 5 of 5 |
| `result.total_cost_usd` | median $0.015204, p25 $0.015081, p75 $0.015252 | median $0.013142, p25 $0.013140, p75 $0.013147 |
| `permission_denials` | 0 on 5 of 5 | 0 on 5 of 5 |

### Three things the run found that were not the registered outcome

**(a) Arm A inherited five of the operator's own MCP servers, and that was never predicted
here — only asserted in a comment.** `run-agent.sh:759-762` says `--strict-mcp-config` exists
because otherwise *"the agent inherits whatever MCP servers the operator has configured at
user scope, so the 'plain baseline' varies by machine and its tool schemas inflate the context
of every request — which lands on cost, the primary metric."* **Both halves are now measured
rather than reasoned.** Arm A's `init.mcp_servers` carries `claude.ai Claude Docs`, `claude.ai
Slack`, `claude.ai Google Drive`, `claude.ai Gmail` and `claude.ai Google Calendar` with
`source: claudeai` on 5 of 5 — including tools that send Slack messages and read Drive — and
the delivered tool set is **53 against B's 28**. The cost half: **+15.7 % on the median
($0.015204 vs $0.013142) for a nine-word prompt that does no work.** A schema-inflation cost
measured on an empty task is a lower bound on the same cost across a benchmark run.

**(b) `--setting-sources project` does not close this channel.** Every arm-A run carried it.
It keeps the operator's *settings* and *plugin skills* out — measured at stop 8 — and it does
**not** keep the operator's MCP servers out. Two flags, two different channels; only the
second one is MCP.

**(c) Arm A's delivered tool set is NOT deterministic, and arm B's is.** A-2 received 37 tools
where A-1, A-3, A-4 and A-5 received 53, because `claude.ai Slack` was `status: pending` at
`init` on that run and `connected` on the others. Arm B was 28 on 5 of 5 with zero spread.
**This is a co-variate, not a result** — the registered outcome was 5 of 5 either way, so
decision-rule row 4 does not fire and no property is claimed from it. It is worth the sentence
because every delivery proof in Track B reads a set assumed to be a deterministic function of
the launch, and in arm A it is a function of the launch **and of a network race**. E-004's
`maintainability` is the precedent for reporting a co-variate as a co-variate.

### The deliberate failure, and its extension

| Prediction | Registered | Observed | Verdict |
|---|---|---|---|
| **DF1** probe tool ABSENT with the file one level up, 5 of 5 | `054b0b8`, 18:50Z | **present 5 of 5** | **REFUTED** |
| **DF2** server absent from `init.mcp_servers`, 5 of 5 | `054b0b8`, 18:50Z | **present, `connected`, `source: project`, 5 of 5** | **REFUTED** |
| **DF3** probe tool PRESENT three levels up, 5 of 5 | `2c27630`, 18:53Z | present 5 of 5 | **HELD** |
| **DF4** a git root at the cwd does NOT stop the walk, 5 of 5 | `2c27630`, 18:53Z | present 5 of 5; the file sits two levels **above** the repository root | **HELD** |

**The loader walks upward, and neither depth nor a git boundary stops it.** DF4 was written to
be wrong in the direction that would have been good news, and it was not wrong. Hand re-read
off the tree rather than off the driver: `find` reports exactly one `.mcp.json` in each
throwaway tree and it is above the cwd; `git rev-parse --show-toplevel` in arm D3's cwd returns
the cwd itself, two levels below the file that loaded.

### Spend

**$0.2393 of the registered $0.50 ceiling, over 26 runs.** The ceiling was not reached; the
batch stopped at its registered `n`, not on budget.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | Arm P delivers the tool, 1 of 1 | **held** | 1 of 1, `connected`, $0.0132 |
| 2 | Arm A delivers it 5 of 5 | **held** | 5 of 5, `source: project` |
| 3 | Arm B delivers it 0 of 5 | **held** | 0 of 5, `init.mcp_servers == []` |
| 4 | No approval event in either arm, 10 of 10 | **held, on better evidence than the one registered** | `result.permission_denials == []` on 11 of 11, `terminal_reason: completed`. The grep this experiment registered is **not** what carries it — see Failure analysis. |
| 5 | A′ delivers it 5 of 5 *(contingency)* | **not run** | Its trigger was "prediction 2 refuted with a null on all 5". Prediction 2 held, so A′ was never opened: registered and unfired, not skipped. |
| DF1 | absent one level up, 5 of 5 | **REFUTED** | present 5 of 5 |
| DF2 | server absent one level up, 5 of 5 | **REFUTED** | present 5 of 5 |
| DF3 | present three levels up, 5 of 5 | held | present 5 of 5 |
| DF4 | git root does not stop the walk, 5 of 5 | held | present 5 of 5 |

**Four of the five main predictions held and both deliberate-failure predictions were
refuted.** The refutations are the stop's finding; the confirmations are the control that makes
them readable.

## Failure analysis

**Was this the agent, or the harness? The harness, on every line.** No prediction here is about
`claude-haiku-4-5-20251001`'s behaviour; the pinned model was used so nothing about the launch
differed from a benchmark run, and the `init` record it reads is emitted before the model
produces a token. The agent under test is `n = 0` at this stop.

**Two instrument defects found, both before they could decide anything.**

1. **The F13 detector was a false positive on every run.** The first version grepped
   `rate.?limit` and matched the routine `{"type":"rate_limit_event","rate_limit_info":
   {"status":"allowed",...}}` record every run of this CLI emits — a record that says the run
   was **not** limited. E-021 registers F13 under Exclusions, so a detector firing on every run
   would have emptied the population into the exclusion list. Corrected to a structural `jq`
   test before the batch, with no run in flight; the preflight's `RESULT.tsv` is **not**
   rewritten and `preflight-*/NOTE-f13-false-positive.md` carries the correction and the hand
   re-derivation. `verify-mcp-hole-probe-guards.sh` re-run under the patched driver: 13 of 13.
2. **Prediction 4's registered detector has never been shown to fire, so it is not what proves
   prediction 4.** The driver greps for `can_use_tool`, `permission_request`,
   `permission_denial` and two prose strings. None appears in this stream format on any of the
   26 runs, so `approval_event: no` states that four strings were absent — *"a control that has
   never been shown to reject anything is indistinguishable from one that rejects nothing"*,
   §4 step 4, applied to my own instrument. **What actually carries prediction 4 is structural,
   and was found by reading the stream rather than by trusting the column:** every `result`
   record has `permission_denials: []` and `terminal_reason: completed`, and in arm A the
   servers reached `status: connected` with their tools delivered inside a five-second
   non-interactive run. A run that had waited for approval could not have delivered them. **The
   registered prediction held; the registered detector is not the reason, and saying so is the
   point.**

## Sanity checks

- [x] **Did any dramatic number appear?** Yes — arm A delivering 22 MCP tools including Slack
      send-message and Google Drive. Explained: the operator's claude.ai connectors at user
      scope. **The explanation was tested**: arm B, same machine, same minute, same `.mcp.json`
      bytes (sha256 `078f9a41…`, identical across arms by `shasum`), delivers 0. The only
      difference on the command line is `--strict-mcp-config`.
- [x] **Did any flattering number appear?** Yes — a clean 5-of-5 / 0-of-5. **Disbelieved
      twice:** by arm P, which proves a null in arm B is not a broken server; and by hand
      re-reading the raw `init` records of A-2 and B-3 straight from their streams, which
      reproduced the driver's values exactly. A third, unplanned disbelief arrived on its own —
      the deliberate failure refuted the containment claim I would otherwise have written around
      that clean number.
- [x] **If a fix motivated this run, did the original symptom disappear?** No fix motivated it.
      The F13 fix made during it was re-derived by hand on the run it had mislabelled, and that
      run's label changes from `f13-candidate` to `ok`.

## Decision

**KEEP `--strict-mcp-config`, and the keep is now measured rather than assumed** —
decision-rule **row 1**, from P ok · A 5 of 5 · B 0 of 5.

- **The workbook's provisional layer label is settled: `--strict-mcp-config` is L2.** Something
  executes and rejects the configuration, and the rejection is visible in the run's own
  delivered tool set on 5 of 5 against a control that receives it on 5 of 5.
- **The interactive approval prompt is L3 and absent**, confirmed rather than assumed: 26 runs,
  zero permission denials, servers connected and tools delivered without one.
- **`mcpHash` stays L3** and is untouched by this lab. **B9 (stop 20) still owes a writer** —
  and after arm D it owes more than a hash, because what needs proving is not only *which* MCP
  config a run received but *from how far above it*.
- **No control is removed.** §4 step 10's default is that a rule with no measured effect is
  removed; this one has a measured effect of 25 delivered tools and +15.7 % cost, so the default
  does not apply.
- **What this does NOT decide:** whether MCP-returned content is treated as untrusted (Lab 6.3,
  deferred), anything about the codex or Copilot runtimes, and anything about the agent under
  test.

## Follow-up

1. **`author_notes`, this session:** an operator `.mcp.json` **anywhere above** a benchmark
   worktree — not inside it, and not stopped by the worktree's own git root — reaches every
   `claude -p` run that omits `--strict-mcp-config`. One flag at `run-agent.sh:776` is the whole
   boundary. **Nothing to fix: the flag is passed on every run.** The exposure is what a future
   step must not quietly remove.
2. **Stop 20 (B9)** inherits the `mcpHash` gap and now also a provenance question: a hash of the
   config a run received will not say whether it came from the worktree or from three
   directories above it. `obs#88`'s `agentsHash` is the shape for the first half only.
3. **Registered as open, not run here:** how far up the walk goes (`$HOME`? `/`?), and whether
   `--add-dir` or a symlinked worktree changes it. Cheap, and out of scope at a stop the spine
   funds one lab for.
4. **Labs 6.1–6.4 stay deferred** and `lab#8` stays open naming them.
