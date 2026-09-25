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

---
*Everything below is filled in AFTER the runs.*
---

## Prediction-commit ordering

| | |
|---|---|
| Prediction commit sha | *(filled after the runs, from `git log`)* |
| Prediction commit timestamp | *(filled after the runs)* |
| First run's `startedAt` | *(filled after the runs, from the probe driver's log)* |
| Ordering holds? | *(filled after the runs)* |

## Observed telemetry

*(filled after the runs)*

## Results

*(filled after the runs — raw, then summary; median and p25/p75, never an average alone)*

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | Arm P delivers the tool, 1 of 1 | | |
| 2 | Arm A delivers it 5 of 5 | | |
| 3 | Arm B delivers it 0 of 5 | | |
| 4 | No approval event in either arm, 10 of 10 | | |
| 5 | A′ delivers it 5 of 5 *(contingency)* | | |

## Failure analysis

*(filled after the runs. For each failure: was it the agent, or the harness? At this stop the
honest prior is **the harness** — that is what the stop measures.)*

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

*(filled after the runs)*

## Follow-up

*(filled after the runs)*
