# B8a — §4 step 5, the preflight pair: what was observed, and the four things it changed

Two runs, probe key `EXP-B8A-PREFLIGHT`, never the batch key. Task `BE-005`, model
`claude-haiku-4-5-20251001`, claude `2.1.282`, `--isolate-user-settings --keep`.
Raw observations: [`OBSERVED.md`](OBSERVED.md). Run records: `run-record-{control,treated}.json`.
Kept worktrees copied the same day to `evidence.local/b08a-worktrees/<run id>/`, 26 MB each.

| | control `8d8505d7` | treated `a390a301` |
|---|---|---|
| `agentHash` | `null` | `sha256:1f27323694e579ec11dbca026bfbb326` — the registered sha |
| `instructionsHash` / `skillsHash` | `null` / `null` | `null` / `null` |
| `runtime.model` | `claude-haiku-4-5-20251001` | `claude-haiku-4-5-20251001` |
| evaluator `exitCode` | **12** | **0** |
| `estimatedCost` | **$0.414733** | **$0.807472** |
| `durationMs` | 235 000 | 643 000 |
| `modelCalls` / `toolCalls` | 47 / 44 | 102 / 124 |
| `changedFiles` | 11 | 11 |
| delegations (distinct `tool_use`) | **0** | **6** |

**Nothing in that table is a result.** `n = 1` per arm, and §5 forbids stating anything from
`n < 5` as a property. In particular the evaluator's 12-versus-0 is **one run against one run**
and is recorded here only because it is what happened.

## The four delivery conditions (decision 11 item 9) — all four observed, one from a different source

- **(a) every overlay file is in the setup commit's tree.** `git ls-files --error-unmatch` inside
  the kept worktree: `orchestrator.md`, `planner.md`, `implementer.md`, `verifier.md` all
  **TRACKED**. Not `test -f` — a file present but untracked never reached the setup commit, and
  three of these four are files no hash sees.
- **(b) `agentHash` equals the registered sha.** It does, exactly.
- **(c) the `init` read-back shows `Task` in the orchestrator's delivered set.** It does:
  delivered `["Read","Task","Grep","Glob"]` against declared `["Read","Grep","Glob","Task"]` —
  **same set, different order**, `verdict=order-differs`. `Task` is present, so (c) holds. The
  order difference is the state stop 11 §4 step 4 already met and recorded.
- **(d) each of the three specialists is named in a delegation.** **Observed — 3 of 3 — from the
  agent stream, and the source is a substitution that is named rather than taken silently.**

### Why (d)'s source moved, measured rather than assumed

`events.jsonl` **grew by 806 953 bytes** across the pair (17 574 371 → 18 381 324), **70 of its
lines carry this run's id**, and it **does** record the delegations: `tool_name` = `Agent`
appears on this run. What it does **not** carry, anywhere, is a `subagent_type` attribute. The
attribute keys telemetry emits for this run are `observatory.run.id`, `experiment.variant`,
`benchmark.id`, `session.id`, `event.*`, `prompt.id`, `tool_use_id`, `tool_name`, `duration_ms`,
`model`, `request_id`, `query_source`, `tool_source`, `tool_input_size_bytes`, `success`,
`source`, `decision`, `tool_result_size_bytes` — and no field holding which subagent was called.

So **the three names are not in telemetry and no query over it can find them.** Decision 11 item
9(d) asks for a telemetry source; the telemetry schema does not have the field. The agent stream
is not a weaker substitute here — it is the only place the fact exists, and it is the source
telemetry is derived from. Recorded as a **proof-source substitution** in `TRACK-B-STATE.md`
`author_notes`; the author may reverse it.

**This is not the early-end condition firing.** Decision 11 item 11 ends the step on *"a preflight
that cannot show all four delivery conditions"*. All four are shown. One is shown from a source
one layer closer to the model than the registered one, and that is said out loud.

## Four findings, and two of them would have destroyed the batch

### 1. The wire tool name is `Agent`, not `Task` — and the first query would have voided every treated run

The frontmatter says `tools: … Task`. `init.tools` reads back `Task`. The model then emits
`"name":"Agent"`. **`"name":"Task"` appears ZERO times in a transcript containing six real
delegations.**

Worse, the driver's original condition (d) grepped `events.jsonl` for the run id, **found 70
matching lines**, and therefore never reached its stream fallback — then failed to find the
specialist names, which are not there. Every treated run would have returned `fail-0-of-3`,
every treated run would have been **row 0a**, and the batch would have **ended at pair 2 with
exit 10** reporting a delivery failure that had not happened. A wrong query reads empty and looks
exactly like a missing measurement; the B8 driver's header records the same failure for
`.behavior.*`. **Fixed and re-derived on this run's real data, in both directions: treated 6
delegations and 3 of 3 specialists, control 0 and 0 of 3.** A query that cannot tell the arms
apart is not a measurement.

### 2. A line count is not a call count — 19 against a true 6

The first delegation column counted *matching lines* and returned **19** for a run that made
**six** delegations, because a streaming transcript repeats each call across several events. The
column now counts **distinct `tool_use` ids** and returns 6, which matches a hand count of the
six invocations.

### 3. SIX delegations, not three or five — and four of them to the planner

| # | `tool_use` id | subagent | description |
|---|---|---|---|
| 1 | `toolu_01M16QepTHRwBpyf3t4eEK1a` | planner | Plan backend ticket BE-005 |
| 2 | `toolu_01M8uUE9H7oyPPPytmuMvkrT` | planner | Planner progress check |
| 3 | `toolu_01TnyZNVSqfiPPXLY5t1o4m3` | planner | Continue first planner with ticket |
| 4 | `toolu_016WgoHaN2qgLhWnJk2Efseb` | planner | Plan BE-005 ticket |
| 5 | `toolu_012Lwohzj3UK8vYpkrm7moNk` | implementer | Implement BE-005 ticket |
| 6 | `toolu_01JzDhAt2EiPSFsGeKARQLZB` | verifier | Verify BE-005 implementation |

Q8 fixes the expected count at **3** (no bounce) or **5** (one bounce) and says **"4 or 6+ is a
finding"**. This is 6, and it is **not a bounce** — the verifier ran once and never reported back
to the implementer. It is the orchestrator **re-delegating to the planner three extra times**.

**It is recorded, not voided.** Decision 11 item 9 lists four delivery conditions and the
delegation *count* is not one of them, so a six-delegation run is a result about the
orchestrator's discipline rather than a failed delivery. The manifest now carries a `deleg_q8`
column classifying every run `q8-ok-3`, `q8-ok-5` or `finding-<n>`.

**And it is the direct measurement of a label this workbook already made.** The design's layer
table row 6 called *"one bounce"* **L3** — *"nothing counts delegations"* — and named it the label
most likely to be mistaken for a control. One preflight run overran it by three. An L3 rule is a
sentence, and this is what a sentence is worth.

### 4. There is no `init` record for a subagent — so two L2 labels cannot be earned

The treated transcript holds **three** `system`/`init` records and **all three are identical**:
`["Read","Task","Grep","Glob"]`, the **orchestrator's** list, emitted once per session turn.
`init.agents` lists the available agent *names* (`implementer`, `orchestrator`, `planner`,
`verifier`, …) and carries **no tool sets**. `check-init-schema.sh` reads the first init record
and the dispatched agent's file, so it asserts the orchestrator's list and nothing else.

**Consequence, applied rather than noted:** the planner's `Read, Grep, Glob` and the verifier's
`Read, Grep, Glob, Bash` **cannot be read back by any instrument this project has.** Author
decision 8 requires the delivered schema before a `tools:` allowlist is registered as a control,
and for these two agents there is no delivered schema to read. The design's own rule — *"if a list
arrives rewritten, the label drops to L3 for that agent and the workbook says so"* — covers a list
that arrives wrong; **a list that is never observed is not better off than one that arrives
wrong.** Layer table rows 1 and 2 are therefore **amended from L2 to L3** in the workbook.

**The `tools:` lines are not edited.** They are the author's Q3; the label is mine, and the label
moves.

*Observed and written by Opus 5 (claude-opus-5), autonomously, 2026-09-25. Both queries that
decide condition (d) were re-derived by hand in the main context against this run's own
transcript, and against the control's, before the fix was believed.*
