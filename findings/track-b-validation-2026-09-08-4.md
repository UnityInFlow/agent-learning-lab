# Track B validation — 2026-09-08 (pass 22)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 22, 2026-09-08T18:15Z, the session that
wrote pass 21, continued by the author with "verify opus work and provide resolution". Scope:
was pass 21's six-step resolution — which the author handed to Opus verbatim at 14:51Z —
processed honestly, and does the new work hold? Written while a probe batch was IN FLIGHT;
what that batch had produced by 18:12Z is audited, the rest is named as not audited.`

Under review: `agent-learning-lab` `stop12/phase-contract-instrument` at `a768691` (two commits
on pass 21's `03c1cbf`; PR lab#77, open, 9 of 9 checks green after the push); `agent-observatory`
`obs/agent-hash-treatment-file` at `59cad20`, a new branch stacked on `obs/foreign-agent-dir-guard`
`a7fc212` (PR obs#76, open, base `obs/foreign-agent-dir-guard`, 4 of 4 checks green); the
corrected `evidence/b05-preflight/README.md`, `workbench-halt-discharge-stop12.md` and the
brief's §4; and the third probe set `EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV`, launched 18:07:42Z
by Opus session `d851a2c1…`, run 1 complete, run 2 in flight at the time of writing. Author of
the work: Claude Opus 5 (claude-opus-5), 2026-09-08 afternoon and evening.

Read-only against the repositories, the observatory API, the kept logs and the session
transcripts, except for this file. No model call. **No verifier was run** — the brief's §4 says
nothing runs alongside a batch, and `verify-agent-delivery.sh` invokes the runner; Opus's own
runs of it are read from the transcript instead, with the command that produced each. Nothing
under review edited. `TRACK-B-STATE.md` and `HANDOFF.md` unchanged (`08d22ab`, `f1f7c34`).

---

## Verdict

**Pass 21 was processed completely and honestly, and the three defects it left the author are
retired by measurement rather than by annotation.** Both findings files are committed unaltered
(`06b9dae`, 291 insertions, pass 20's placeholder timestamp kept and its mtime recorded in the
commit message, as asked). Defect 3 is corrected in all three documents with the original struck
and the correcting model named. The `agentHash` fix is a real change to the runner, covered by
three new verifier cases, and the negative control for it is red on exactly the two cases it
should be. The first run of the third probe set is the first run in this project's history
whose record carries the hash of its own treatment — and the value is the one pass 21 computed
independently.

**Nothing reopens.** Two things are named below because they are decisions the author still
owns: the merge order of the stacked observatory PRs, and whether the runner should refuse to
run without an explicit OTLP endpoint.

Per-stop verdict: no stop closed. Stop 12 still not opened; nothing of it created. The
`BATCHENV` probe is a decision-8 preflight under its own key, never joinable to an `n`.

---

## The six steps, each checked against the thing

| # | asked (pass 21) | done? | checked how |
|---|---|---|---|
| 1 | commit passes 20 and 21 unaltered | **yes** | `06b9dae`: `-2.md` +123, `-3.md` +168; both files byte-identical to the untracked copies this session left (pass 21's two post-write edits included). Pass 20's `2026-09-08T1x:xxZ` header kept; commit message records mtime `11:00:53Z` |
| 2 | correct defect 3, originals struck, attributed; tunnel ports into the brief's §4; push | **yes** | `a768691` (+53 −10): a `CORRECTED 2026-09-08 by Claude Opus 5` block citing passes 20 and 21, the two-listener table (`4317/4318` → HTTP 000, `14317/14318` → HTTP 200), the two launch commands, and the original struck paragraph by paragraph including the *"confirm the host can reach 4317"* instruction. Discharge document §2a lines 105–118: same, struck and attributed. Brief §4 lines 255–257: tunnel ports beside the API trap. Pushed 14:54Z; lab#77 re-ran 9 of 9 green, `a narrated phase is not a phase` included |
| 3 | author merges obs#75 and lab#77 | **not done — correctly** | both still `OPEN`, `MERGEABLE`, `BLOCKED` on review. §7 and the brief's §5 make this the author's action; Opus did not take it |
| 4 | fix `agentHash` at `run-agent.sh:601-602` | **yes, and more** | `59cad20`: `agentHash` ← `.claude/agents/${AGENT_NAME}.md` when runtime is `claude` and `--agent` was passed, `null` otherwise with the reason stated in the comment; `skillsHash` ← one digest over every `SKILL.md` in the worktree, sorted, path included. The hash block moved **above** the `--check-customization` exit and is printed there, so a hash can be read without a model call — the property whose absence let two wrong paths sit for months. `hash_of` is unchanged and resolves against `$WORKTREE` |
| 5 | decide the re-run | **decided: re-run, all flags** | `EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV`, launch script read from the process table: `--variant phases-v1.0`, `--isolate-user-settings`, `OTLP_GRPC_ENDPOINT=http://localhost:14317`, `OTLP_HTTP_ENDPOINT=http://localhost:14318`, `INIT_SCHEMA_DIR` into `evidence/b05-preflight/init-schema/`, on the fixed runner. All three omissions of the previous two sets are closed in one launch |
| 6 | open stop 12 | **not yet** | correct: step 5's batch is in flight and steps 3 and 4 are unmerged |

The author's 14:51Z message to Opus is pass 21's resolution verbatim, so steps 4 and 5 were
directed, not taken.

---

## The runner change and its verifier, read from the transcript

`verify-agent-delivery.sh` now registers **16** cases; N (a dispatched agent overlay records the
hash of the file it dispatches), O (the control arm records `null`, so the arms are
distinguishable in the record), P (an installed skill records a non-null `skillsHash`). Opus's
runs, in order, with the command that produced each:

| time (Z) | runner | result | failing |
|---|---|---|---|
| 18:05:59 | the real one, `./runner/verify-agent-delivery.sh` | **16 passed, 0 failed** | — |
| 18:06:21 | a copy under the session scratchpad `ctl/` with the hash block stripped by a Python edit | 14 passed, 2 failed | **N** (`agentHash` got `''`), **P** (`skillsHash` null) |
| 18:06:51 | — | commit `59cad20` | — |
| 18:07:17 | the stripped copy again | 14 passed, 2 failed | N, P |
| 18:07:42 | — | batch starts, tree clean | — |

So the negative control is red on exactly the two cases the fix exists for, and green on O —
which is right: a runner without the fix also records `null` on a control, so O cannot
distinguish the fixed runner from the broken one and is not claimed to. The batch started 51
seconds after the commit on a clean tree; the §4 rule about editing a tool with a run in flight
was kept.

Not re-run here (batch in flight). Opus's 16 of 16 is a transcript reading, not this pass's.

---

## The third probe set, as far as it had got

Run 1, `c6d44da9`, started 18:07:43Z, finished 18:11:02Z, read from the API through the tunnel:

| field | value | means |
|---|---|---|
| `experimentKey` | `EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV` | own key, never an `n` |
| `variant` | `phases-v1.0` | defect 1 retired on this run |
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` | **equals the overlay file's hash pass 21 computed independently** (`shasum -a 256 … \| cut -c1-32`); defect 2 retired |
| `behavior.modelCalls` / `toolCalls` | 27 / 25 | telemetry arrived — 21 lines in `events.jsonl` for this run id, file growing at 18:10 local; defect 3 retired |
| `efficiency.estimatedCost` | 0.226901 | matches the kept log's `total_cost_usd` 0.2269007 |
| `evaluation` | passed, 7 of 7 | same as the six before it |
| `init-schema` (7th file, untracked) | delivered `["Read","Edit","Write","Bash"]`, declared same, `match` | 7 of 7 across three environments |

Run 2, `db318da7`, started 18:11:37Z, finished 18:29:59Z, read the same way before this file
was closed at 18:55Z: `variant phases-v1.0`, `agentHash sha256:b3450564b6f32d6193e8580db766210e`,
30 model calls, 27 tool calls, cost 0.197241, 22 `events.jsonl` lines, passed 7 of 7,
`init-schema` `match`. **8 of 8 across three environments.**

Run 3 was in flight at 18:52Z. **It is not audited here.** The next pass reads all three, the
filed raw `init` records, and the README's table once Opus files it.

---

## Decisions the author still owns

1. **Merge order.** obs#76 targets `obs/foreign-agent-dir-guard`, not `main`, which is why it
   shows `CLEAN` where obs#75 shows `BLOCKED`. Merge obs#75 first with `--admin`; GitHub then
   retargets obs#76 to `main` when the base branch is deleted, or it must be retargeted by hand.
   Merging obs#76 first would land the hash fix onto the guard branch and leave `main` without
   either.
2. **Refuse or default.** Three launch-flag omissions in two days, each caught by a validator
   from a field or a transcript, none by the runner. Opus's README correction and pass 21 both
   leave open whether `run-agent.sh` should refuse to run without an explicit OTLP endpoint the
   way it refuses to guess a version. This pass's view: the runner already knows the pattern
   (a placeholder version is refused, an overlay for the wrong runtime is refused); an endpoint
   it cannot reach with an empty POST before the model call is the same class, and would have
   turned defect 3 into an exit code. It is instrument work, and it is before stop 12's first
   batch, not during it.
3. **The BE-004 fixtures under `--isolate-user-settings`** now have seven green runs at 7 of 7.
   That is a preflight reading and not the arm; it says nothing about whether BE-004
   discriminates, which is benchmarks#29's own verifier's job and was re-run at 12 of 12 on
   `main` on 09-07.

## Not checked

- Run 3 of `BATCHENV`, and whether Opus files all three in the README's table with the same
  rigour as the first six. Next pass.
- `verify-agent-delivery.sh` on the real runner and on the stripped copy, by this pass's own
  hand. Batch in flight; the transcript readings above stand in.
- Whether obs CI runs `verify-agent-delivery.sh` at all — it needs the API and the benchmarks
  repo, and the four green jobs on obs#76 are the api, runner-statistics, hook and web jobs.
  Pass 18's finding that the guard's fixtures run only locally is unchanged and now covers N–P.
- The commit messages of `06b9dae` and `a768691` say the kept transcripts carry *"13 launches
  with the tunnel endpoints"*. This pass counted 225 `run-agent.sh` invocations across the
  project's transcripts and 3 with the literal `14317` in the command; batch manifests set the
  port through `OTLP_GRPC_PORT` rather than the literal, so the two counts are of different
  things. The figure is in no evidence file, so nothing needs striking; it is unreproduced.
- `skills_hash` against a worktree with a `SKILL.md` — case P covers the fixture; no real batch
  has yet carried a skill through the fixed runner.

## Corrections made in place

None.

## Resolution

1. When `BATCHENV` finishes: file runs 2 and 3 beside run 1 in `evidence/b05-preflight/README.md`
   — the raw `init` lines too, as with the first six — and write the row that the first six lack:
   which flags each set carried, so the table itself shows why there are three sets. Commit,
   push; lab#77 re-runs.
2. Author merges **obs#75, then obs#76** (retarget to `main` if GitHub does not), then lab#77,
   all `--admin`. Commit this file and any later pass unaltered on lab#77 before the merge, as
   the four before it.
3. Decide the OTLP refuse-or-default question before stop 12's first batch, as instrument work
   on the observatory, and record the decision in the brief's §4 either way.
4. Then open stop 12 at §4 step 1. `TRACK-B-STATE.md` files passes 18–22 in
   `validation_processed` on that write.

## The single finding most likely to overturn the track's result if pursued

The same as pass 21's, one step further along: the record can now tell a treated run from a
control **only on `claude` with `--agent`**. On codex and copilot `agentHash` is `null` by
construction, which the comment calls the true answer — and it is — but it means B5's second
runtime under B10/B12 will again have arm membership resting on `--variant`. Fine for stop 12,
which is claude-only. Worth a line in the state file before stop 21 (B10, the second runtime
adapter), so the next runtime does not inherit the fix's name without its property.
