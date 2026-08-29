# B2 readiness — what is true before the first run, 2026-08-28

The runbook says how to run B2. This says whether B2 can be run *yet*, and what is wrong
with the harness that would only show up afterwards. Written to be attacked: every claim
below carries the command that produced it, so a reviewer can disagree with the evidence
rather than with the conclusion.

**B2 builds nothing. It produces the number everything downstream is compared against.**
A defect here does not crash; it returns a confident wrong baseline, and every later
treatment is measured as a difference from it.

---

## Part 1 — What is already true

Verified 2026-08-28, third session, on this machine.

| Precondition | State | How it was checked |
|---|---|---|
| Docker | running | `docker info` |
| Stack | **18/18 checks pass** — API, web, Grafana, Prometheus, Tempo datasource, OTLP port, both scrape targets, four API contracts, both cardinality rules | `make smoke` |
| Ports | API 8081, UI 5174, Tempo 3200, Grafana 3001 | `make urls` — **prints configuration, proves nothing**; the row above is the probe |
| `claude` | 2.1.251 | `claude --version` |
| `codex` | codex-cli 0.147.0 | `codex --version` |
| `copilot` | GitHub Copilot CLI 1.0.74 | `copilot --version` |
| `BE-003` resolves | `tasks/BE-003-confirm-shipment` | `run-agent.sh:77` globs `${BENCHMARK_ID}-*` |
| `sample-service` present | yes, with `mvnw` and `pom.xml` | `ls agent-observatory-benchmarks/sample-service` |
| Path B gate works | ACCEPT on `exitCode 0`, REFUSE on `F13` | `check-run-gate.sh` against two live run records |
| `KEEP=1` reaches `--keep` | yes, `${KEEP:+--keep}` in the recipe | `make -n run-benchmark`, and the commit that added it is pushed |

**Corrected after review.** This table first cited `make urls` as evidence that the stack
was up. `make urls` prints the configured URLs; it does not connect to anything. Two of
three review families caught it, and the failure they named is concrete: if Tempo is down,
a run completes and its traces are silently lost, discovered only after the run is spent.
The evidence is now `make smoke`, which probes all six services and the API contract, and
which passes 18/18 on this machine as of 2026-08-28. **Re-run `make smoke`, not `make urls`,
before any batch.**

**Path B's gate is proven against real data, not fixtures.** `check-run-gate.sh` was run
against run `4b7cafce` (`passed=true`, `exitCode 0`) and run `e783f367` (`passed=false`,
`exitCode 12`, `failureClass F13`). It accepted the first and refused the second with the
right reason. That is the half of Decision D that can be proven without spending a run.

---

## Part 2 — The observatory holds 172 runs, and none of them can be SCORED

`GET /api/runs` returns **172 runs across 16 experiment keys**, including **17 BE-003
`variant: baseline` runs** under `EXP-BE003-CLAUDEMD` on `claude-code/haiku`, dated
2026-08-12. Ten passed with `exitCode 0`; seven are `F13`.

It is tempting to read that as "B2 is already half done". It is not, and the reason is
structural rather than a matter of taste:

1. **Their worktrees are gone.** `ls ${TMPDIR}observatory-run-*` returns **zero
   directories**. Those runs predate `--keep` by sixteen days, so `run-agent.sh` deleted
   each worktree at step 12. `codex-score.sh --run-id` resolves the worktree *from* the id
   and refuses when it is absent — deliberately, because a run scored from a deleted
   worktree is not something it can reconstruct. **No existing run in this observatory is
   scoreable under Decision D.** Not one.
2. **They predate the rubric.** `backend-quality.yaml` v2 (`396e1799eb2b`) was written
   2026-08-27. There is no sheet that could have been produced against it on 2026-08-12.
3. **`EXP-BE003-CLAUDEMD` is not a plain baseline by name.** The variant field says
   `baseline` and the customization hashes are null, so it probably *was* one — but "probably
   was" is exactly the kind of claim this project has been burned by. An experiment key that
   says CLAUDEMD and a variant that says baseline disagree, and nothing on disk resolves it.

**Consequence, stated plainly: B2 starts from zero *scoreable* runs, not from seventeen.**
Five fresh runs per arm, with `--keep`, against rubric `396e1799eb2b`.

**Narrowed after review.** This section first said the 172 runs "cannot be used", which is
too strong and was flagged as such. They cannot be **scored** — Decision D needs a worktree
and every worktree is gone. They remain perfectly good evidence for anything that reads the
run record itself: pass rate, failure classes, duration, tool counts, token cost. The ten
exit-0 and seven F13 BE-003 records are usable history; they are not usable rubric input.
Do not discard them, and do not count them toward B2's n.

---

## Part 3 — The codex arm is not isolated, not pinned, and would record a model it never used

This is the finding that matters. The claude arm has been hardened over several
experiments; the codex arm has never been run and has none of that hardening. Both arms are
launched from the same `case` statement in `runner/run-agent.sh`, and they are not
comparable.

### 3.1 What the claude arm does (`run-agent.sh:306-352`)

```
--permission-mode acceptEdits          explicit, equal latitude
--strict-mcp-config                    no operator MCP servers
--disable-slash-commands               no operator plugins/skills
--allowedTools Bash(./mvnw:*) …        the task tells the agent to run the build
--setting-sources project              (with --isolate-user-settings) no user hooks
--model $AGENT_MODEL                   pinned
```

Every one of those flags exists because an earlier experiment was contaminated without it.
The comment above them says it directly: *"Latitude must be explicit and equal to Copilot's,
or the harness measures its own configuration. It did."*

### 3.2 What the codex arm does (`run-agent.sh:354-361`)

```
codex exec "$(cat task.md)"
```

That is the whole arm. Consequences, each independently sufficient to void it:

**(a) `--model` is accepted and silently dropped.** `AGENT_MODEL` is parsed at line 57 and
passed to `copilot` (line 293) and to `claude` (line 345). It is **never passed to codex**.
The runbook's instruction "Pin `MODEL` explicitly" therefore does nothing on this arm, and
the vendor routes.

**(b) The run record claims the model anyway.** Line 543 writes
`--arg model "${AGENT_MODEL:-auto}"` into `runtime.model` — the value the *caller asked
for*, never the value the runtime was told. So a codex run invoked with `MODEL=gpt-5.6-sol`
records `model: gpt-5.6-sol` while codex used whatever `~/.codex/config.toml` selects. That
is not a missing control; it is a **provenance field that will be wrong**, and it is wrong
in the direction that looks correct.

**(c) `--isolate-user-settings` does nothing on this arm.** It is parsed, it is recorded in
the invocation, and the codex branch never reads it. A run that *asked* for isolation and
did not get it is worse than one that never asked, because the record says it was isolated.

**(d) What actually joins a "plain" codex baseline on this machine**, counted 2026-08-28:

| user-scope surface | count | what it does |
|---|---|---|
| `~/.codex/config.toml` | 249 lines | project trust entries, feature flags |
| `[mcp_servers.*]` | **3** — chrome-devtools, openaiDeveloperDocs, **memtrace** | memtrace is a code-search tool; it changes how an agent explores a codebase, which is most of what BE-003 measures |
| `~/.codex/skills/` | **71** | |
| `~/.codex/agents/` | **66** | |
| `~/.codex/hooks/` | 2 | |
| `~/.codex/plugins/` | 1 | |
| `~/.codex/rules/` | 1 | execpolicy |
| **`~/.codex/AGENTS.md`** | 32 lines via `@import` | **global instructions** |

That last row is the one to stop on. `~/.codex/AGENTS.md` imports `~/.codex/RTK.md`, a
32-line instruction file telling the agent to route shell commands through a proxy. **B3 is
"minimal global instructions" — the treatment. The codex arm of B2 would ship that treatment
inside the control.** A B3-vs-B2 comparison on this arm would be measuring one instruction
file against a different one, and reporting it as instructions-versus-none.

This is harness bug #13 again, on a different CLI. That one cost 5 contaminated runs of 23
and landed on two registered outcomes.

**(e) No sandbox or approval policy is set.** `codex exec` picks its defaults. The claude
arm learned this the expensive way: with latitude left ambiguous, *"seven of ten sonnet runs
never implemented anything and were recorded as incorrect code"*, with `permissionDenials`
at 0 throughout — nothing refused, so no telemetry showed it. The codex arm currently has
the same ambiguity and no telemetry at all (ADR-001), so the same failure would be **less**
visible, not more.

### 3.3 The codex CLI has every flag needed. None of them are used.

From `codex exec --help`, version 0.147.0:

| need | flag | claude-arm analogue |
|---|---|---|
| pin the model | `-m, --model` | `--model` |
| drop user config + MCP servers | `--ignore-user-config` | `--setting-sources project` + `--strict-mcp-config` |
| drop execpolicy rules | `--ignore-rules` | — |
| explicit latitude | `-s workspace-write` | `--permission-mode acceptEdits` |
| no human in the loop | `--approve-for-me` | `acceptEdits` |
| deterministic output | `--color never` | `--no-color` (copilot) |
| structured events | `--json` | telemetry |
| capture the final message | `-o, --output-last-message` | `$AGENT_LOG` |
| no session files on disk | `--ephemeral` | — |

### 3.3b The flag does not do it. That is measured, not read.

`--ignore-user-config` is documented as "Do not load `$CODEX_HOME/config.toml`" and says
nothing about `$CODEX_HOME/AGENTS.md`. **Tested 2026-08-28** with a marker instruction —
a global `AGENTS.md` demanding the token `ZEBRAFISH-7741` at the start of every reply — and
an identical trivial prompt in an empty working directory:

| `CODEX_HOME` | flags | marker in the reply? |
|---|---|---|
| test home holding `auth.json` + marker `AGENTS.md` | none | **yes** |
| the same home | `--ignore-user-config --ignore-rules` | **yes — the flag does not drop it** |
| clean home, `auth.json` alone | none | **no** |

**The flag is not the control. The environment is.** The arm now builds a `CODEX_HOME`
containing `auth.json` and nothing else, per run, beside the worktree.

**The observable and its acceptance condition, since the artifact was reviewed for not
having stated one:** the marker token appears in the model's reply, or it does not. The test
is deliberately **two-sided** — it first proves the marker is reachable *without* isolation,
because a one-sided test passes when codex is broken, when auth fails, or when the marker
was never reachable at all. It is `runner/verify-codex-isolation.sh` in the observatory;
exit 0 isolation holds, 1 inconclusive, 2 leaks. It passed on codex-cli 0.147.0.

**And it is L2, not L1 — correcting this artifact's own earlier claim.** Apply the guardrail
rule in order: *can the bad value still be written down after the fix?* Yes. Nothing stops
anyone from putting an `AGENTS.md` into that directory after the runner builds it. What
makes it a control is that something *executes* — the runner rebuilds the directory each run
and the verifier can re-check the claim — which is the definition of L2. Calling it L1 was
the exact mistake `CLAUDE.md` says has already cost this project a voided twenty-run
experiment, and a reviewer caught it here.

### 3.4 Proposed change, and what it costs

Bring the codex branch to parity:

**BUILT 2026-08-28**, `agent-observatory` commit `b288625`. The flag set is exhaustive and
each omission is deliberate — the first draft of this section listed nine flags as "needed"
and then proposed seven, which a reviewer correctly called a silent gap:

| flag | used | why |
|---|---|---|
| `--sandbox danger-full-access` | **yes** | the analogue of copilot's `--allow-all-paths` and of claude running unsandboxed. Not convenience: the task instructs `./mvnw test`, and Maven writes to `~/.m2` and fetches over the network. Under `workspace-write` this arm alone would fail the build, and the evaluator would record it as incorrect code |
| `--color never` | **yes** | copilot's `--no-color` |
| `--model` | **yes** | pinned, as on both other arms |
| `CODEX_HOME=<clean>` | **yes**, under `--isolate-user-settings` | the isolation, per 3.3b |
| `--approve-for-me` | **no** | it adds an automatic reviewer the other two arms do not have. Approval is already `never` in `exec` mode, so it buys nothing and changes behaviour |
| `--json` | **no** | it replaces the human-readable stream the other arms `tee` into `$AGENT_LOG`. Worth revisiting as a telemetry path (Part 7), not as part of a parity change |
| `-o, --output-last-message` | **no** | `$AGENT_LOG` is produced by `tee`, identically to the other two arms. The analogue already exists |
| `--ephemeral` | **no** | codex writes sessions to `$CODEX_HOME/sessions`, and under isolation that is the disposable per-run directory beside the worktree — **not** the worktree, so the `--keep` diff is unaffected. Verified by inspecting the clean home after a run |
| `--ignore-user-config` / `--ignore-rules` | **no** | 3.3b shows they do not achieve the isolation; keeping them would suggest they do |

**What it costs, stated so it is not discovered later:** this changes the instrument. Every
codex run before the change and after it are not comparable — and since there are **zero**
codex runs on record, that cost is currently zero. It will not be zero next week. **Change
it before the first codex run or accept it forever.**

**The hook question, opened here and since ANSWERED — it was the terminal.**

This section originally recorded an open question: `--dangerously-bypass-hook-trust` was
reported as enabled on every codex invocation, and hook events fired even with a clean
`CODEX_HOME` in an empty directory. The source was found on 2026-08-29 and it is neither
codex nor the operator's config.

`which codex` resolved to a **cmux shim at the front of `$PATH`**, which execs
`cmux-codex-wrapper`, which injects `--dangerously-bypass-hook-trust` and `-c hooks.X=…`
into every invocation. An identical `claude` shim sits beside it, appending
`--settings "$HOOKS_JSON"` — 12 hooks — to every `claude` call. `run-agent.sh` passes no
`--settings` at all; these arrive downstream of everything it controls, and nothing in the
run record can see them, because `customization.hooksHash` hashes the repository's files.

Fixed in `agent-observatory` `b46f4e6`: the runner strips `*/cmux-cli-shims*` from `PATH`
before anything resolves a binary, sets both wrappers' own off switches as a second line, and
prints the resolved binary. Measured both ways on the claude arm:

| | `flagSettings` registered | hook executions |
|---|---|---|
| shim present (`092a384a`) | 12 | **26** |
| shim stripped (`0754c154`) | **0** | **0** |

**Two things this corrects.** First, the operator's `~/.codex/hooks.json` being unparseable
was noted here as "clean by accident" — it is irrelevant, since those hooks were never the
ones firing. Second, and more usefully: **the 22 user-scope hooks registered in an isolated
claude run never executed.** `--setting-sources project` works. Registration is not
execution, and this document had been reading the registration count as if it were.

---

## Part 4 — The Copilot arm was tested and it CANNOT run. The deferral stands.

**This section proposed the opposite and was wrong. The proposal, the test and the
refutation are all kept, because a hypothesis that is quietly deleted teaches nothing.**

**What was proposed.** The handoff defers Copilot to after 2026-09-01 on premium-quota
grounds. Two facts argued the deferral was unnecessary: `EXP-BASELINE-COPILOT` already holds
**11 runs on `copilot-cli` / `gpt-5.4-mini`**, and the exhausted counter is *premium
interactions* while `gpt-5.4-mini` was believed to be a 0-premium model. If that held, B2
could be three-armed now.

**The test, redesigned after review.** The first proposal was to read `quota_remaining`
before and after a run and check it did not move. A reviewer refuted the design, not the
conclusion, and was right: another process could consume quota, or the counter could reset,
so an unchanged counter establishes nothing about causation. The account state gives a
cleaner instrument:

```
premium_interactions: entitlement 300, remaining -1, percent_remaining 0,
                      unlimited false, overage_permitted FALSE
chat:        unlimited true
completions: unlimited true
quota_reset_date: 2026-09-01
```

**Overage is not permitted.** So a call that would consume a premium interaction must be
*refused*, and a call that succeeds is proof it consumed none. That is a one-sided test with
no counter arithmetic in it: run it, and the outcome itself carries the answer.

**The result, 2026-08-28:**

```
$ copilot --model gpt-5.4-mini --allow-all-tools --no-color --prompt "Reply with exactly: READY"
You have no quota (Request ID: 5407:1B42:97DAC6:A9651B:6A91CB68)
Requests   0 Premium (5s)
```

**Refused.** The Copilot CLI is gated by the premium counter regardless of the model
selected. The 11 recorded runs happened before exhaustion and do not contradict this.

**Conclusion: the handoff's deferral was correct and this section's hypothesis was wrong.**
B2 runs two arms — claude and codex — until **2026-09-01**. The cost the handoff names is
real and unchanged: Copilot is the runtime the business case names for backend agent v1, so
a two-arm B2 leaves the runtime that matters most from B2 onward unobserved. **Add the arm
after the reset and before drawing conclusions, not after.**

**One thing this does not settle:** whether the refusal is model-independent. Only
`gpt-5.4-mini` was tested, because testing an actual premium model while `remaining` is -1
would either be refused identically or cost an overage that is not permitted. Testing it
after the reset would consume the thing being measured. Recorded as unresolved.

## Part 5 — The preconditions the runbook names that are NOT met

| runbook precondition | state |
|---|---|
| `0A` complete | **NOT DONE.** Position 1 of 28, zero TODOs, 19 open checkboxes, ~5 hours of reading. Its own justification is that 0A is where you learn what the harness does when an agent is blocked — which is the failure B2 will hit |
| `B1` closed | **NOT CLOSED.** 4 predictions and 17 blind cells outstanding, both author-only |
| stack reachable | met |

**Neither of the two unmet ones is a defect. Both are decisions.** Stated as decisions so
they can be taken deliberately:

- **Running B2 before B1 closes** means the baseline exists before the instrument that
  scores it is validated. The runs themselves are still valid — they are agent behaviour,
  recorded — but no sheet can be produced until the rubric is closed, and if B1's gap
  analysis rejects the rubric, the sheets have to be re-produced. The runs do not have to be.
- **Running B2 before 0A** means the operator has not done the reading that names the
  failure modes B2 will produce. That costs interpretation, not data.

**A third option exists and is probably the right one: rehearse the pipeline on ONE RUN PER
ARM, and hold the five-run batches until both rehearsals are inspected.** A rehearsal proves
the pipeline end to end — launch, evaluate, record, `--keep`, score — for the cost of one
run per arm. It is the only way to find out whether Decision D's attachment set is what the
runbook claims it is, because that cannot be inspected without a real worktree.

**The arm is named deliberately, and the order matters.** Two review families flagged that
"one run" without an arm is ambiguous, and one named the concrete cost: a reader who
rehearses on codex *before* parity spends the "zero cost" window on a contaminated run that
is not comparable to anything after it. Parity landed first (commit `b288625`), so both
rehearsals are now safe — **but if the codex arm is ever changed again, the same ordering
applies: instrument first, rehearsal second.**

---

## Part 6 — What must be true before the five-run batch, in order

1. ~~Codex arm brought to parity, and the `AGENTS.md` question answered by test~~ —
   **DONE**, `b288625`. Isolation is `CODEX_HOME`, not a flag, and `verify-codex-isolation.sh`
   re-checks it two-sided
2. ~~`runtime.model` proven to reflect what the runtime was told~~ — **DONE**, `b288625`.
   A guard refuses any run whose `--model` cannot be forwarded, so the record can no longer
   claim a model that never ran
3. ~~Copilot's 0-premium claim measured~~ — **DONE, and it failed.** See Part 4. Two arms,
   not three, until 2026-09-01
4. ~~The batch cannot silently under-sample~~ — **DONE**, `b288625`. `baseline-runs` counts
   recorded runs before and after and refuses to report `n` it did not get
5. **`make smoke` green immediately before the batch** — 18/18, not `make urls`
6. **One rehearsal run per arm**, `--keep`, inspected with `LAB_SCORE_DRY_RUN` before any
   real batch, checking that the attachment set is the changed files and their pre-agent
   versions — **not** all 25 files of `sample-service`. **Still outstanding: this is the
   only item left that requires spending a run.**
7. `EXPERIMENT=` keys chosen so that a later reader cannot mistake an arm for a treatment —
   `EXP-BE003-CLAUDEMD` is the cautionary example already in the database. Proposed:
   `EXP-B2-BASELINE-CLAUDE` and `EXP-B2-BASELINE-CODEX`
8. Then, and only then, `N=5` per arm

## Part 7 — Known, and deliberately not fixed here

- ~~**`make baseline-runs` swallows failures.**~~ **FIXED**, `b288625`. It counted nothing,
  so five banners and exit 0 could mean `n=2`. It now counts *recorded runs* before and
  after the batch and exits 1 on a shortfall, naming it. Recorded runs rather than exit
  codes, because `run-agent.sh` exits with the evaluator's code and an agent that
  legitimately fails the benchmark is a valid observation — counting exits would discard
  exactly the runs B2 exists to see.
- **`opencode-score.sh` has no `--run-id` path**, so no cross-harness check is possible on
  B2. Decision C makes codex the scorer; this is a consequence of it, recorded rather than
  discovered.
- **`architecture-consistency` may null** if the agent never touches `ApiError.kt`. Under
  Decision D an unchanged file is not attached. BE-003 requires the error envelope, so it
  should change; if it does not, that null is honest.
- **Codex telemetry is not normalized** (ADR-001). Note that `codex exec --json` emits JSONL
  events — the data exists and is simply not mapped to the trace/metric shape. That is a
  smaller gap than "no telemetry", and it is worth recording which it is.

---

## Part 8 — What the panel found, and what was done with each finding

This document was written first and then attacked by three independent families before
anything was built from it. That order is the point: every fix below is a defect that would
otherwise have been discovered by a spent run.

**The panel that actually ran** — a panel that quietly became smaller is its own failure:

| family | harness | outcome |
|---|---|---|
| codex (`gpt-5.6-sol`) | codex | 8 findings |
| `deepseek-v4-pro` | opencode | 4 findings, 3 `no finding` |
| `gpt-oss:120b` | opencode | **OFF CONTRACT** — prose instead of the section format. Kept in the record; it still produced one usable cross-cutting finding |
| `minimax-m3` | opencode, acceptance gate | **ACCEPT**, 2 non-blocking, 3 disputed |

Findings in `findings/codex/critic-b2-readiness-20260828T174501Z.md` and
`findings/opencode/review-READINESS-20260828T174521Z.md`.

| # | Finding | Families | Disposition |
|---|---|---|---|
| 1 | `make urls` prints configuration; it does not prove reachability. If Tempo is down the traces are lost silently and the run is spent | codex, deepseek | **Accepted.** Evidence replaced with `make smoke`, 18/18 |
| 2 | "None of the 172 runs can be used" is too absolute — they cannot be *scored*, but the records are fine evidence | codex | **Accepted.** Section retitled and narrowed |
| 3 | Calling `CODEX_HOME` an L1 control fails the project's own L1 test | codex | **Accepted.** Reclassified L2, with the rule applied in order and shown |
| 4 | The `CODEX_HOME` requirement is missing from the isolation spec entirely | gpt-oss:120b | **Accepted**, and independently corroborated by measurement |
| 5 | §3.4 proposed 7 flags where §3.3 called 9 "needed", silently | deepseek, minimax-m3 | **Accepted.** Every flag now has a used/not-used row and a reason |
| 6 | The quota test cannot establish causation — the counter can move for other reasons | codex, deepseek | **Accepted.** Test redesigned around `overage_permitted: false`, run, **and it refuted the hypothesis** |
| 7 | "Run the rehearsal on one run" never names the arm; a codex rehearsal before parity spends the zero-cost window | codex, deepseek, minimax-m3 | **Accepted.** One run *per arm*, with the ordering rule stated |
| 8 | The isolation test had no stated observable or acceptance condition | codex | **Accepted.** Marker token, two-sided, in `verify-codex-isolation.sh` |
| 9 | `baseline-runs` can report `n=5` for `n=2` | codex | **Accepted.** Fixed in `b288625` |
| 10 | Without `--ephemeral`, session files contaminate the `--keep` worktree | deepseek | **Disputed, and the gate disputed it too.** Codex writes sessions to `$CODEX_HOME/sessions`; under isolation that is the disposable per-run directory beside the worktree. Verified by inspecting a clean home after a run — the worktree diff is unaffected |
| 11 | Part 1's "stack up and healthy" is consistent with its own table structure | minimax-m3 disputing deepseek | **Overruled — the finding was right.** The gate's reading is defensible, but "healthy" over an unprobed Tempo is exactly how a run gets spent. Fixed anyway |
| 12 | Part 4 asserts the 0-premium claim as both fact and unverified | deepseek | **Accepted, and then made moot by measuring it** |

**Two things the panel did not catch**, found by running the thing rather than reading it,
and recorded so the panel's coverage is not overstated:

- `--dangerously-bypass-hook-trust` is enabled on every codex invocation on this machine,
  and three hook events fire in **every** run including a fully isolated one.
- `~/.codex/hooks.json` fails to parse, so the operator's hooks do not currently load. The
  arm is clean by accident. Repair that file and it stops being clean.

**What the panel is not.** It reviewed a *document*. It did not read `run-agent.sh`, and it
did not run anything. Findings 1, 3, 5, 7 and 9 are about this artifact's claims; the
defects in the harness itself were found by reading the code and testing the CLI. A clean
panel verdict on a readiness document is not evidence that the harness is ready.
