# Author decision 8 preflight — the `phases-v1.0` overlay's `tools:` line, read back

**This is not a stop-12 artifact.** Stop 12 is not open. Nothing here is a registration, a
prediction, or a `§4 step`. It is the delivery evidence for one gate that must be discharged
*before* any B step registers an allowlist, filed in the repository because that is the only
place this project has not yet lost data from.

## Why these files exist at all

Author decision 8 makes an `init.tools` read-back **mandatory** before any B step registers a
`tools:` allowlist. E-005 is why: the runtime **rewrites** the list before the model sees it.
`Read, Grep, Glob, Bash` was delivered as `["Read", "Bash"]` on 10 of 10 runs, so **a `tools:`
file is not the treatment until its `init` record says so.**

`build/customizations/phases-v1.0/.claude/agents/backend-feature-phases.md` declares
`Read, Edit, Write, Bash` and its body tells the agent to search with `Bash` *because* `Grep`
and `Glob` are not in its list. That instruction is only true if the delivered list matches the
declared one.

Validator pass 18 (`claude-fable-5-1`) called the risk here **the single finding most likely to
matter**: if `Edit` and `Write` were stripped the way `Grep`/`Glob` were, every treated run would
score *"nothing was implemented"* and the arm would read as a treatment that did no work.

## The reading

**Nine runs, nine matches, three environments. `Edit` and `Write` reach the model.**

| run | set | environment | `init.tools` delivered | verdict | record |
|---|---|---|---|---|---|
| `6bc9fa5d` | 1 | tunnel + `--variant`, **no isolation** | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `e9bfde84` | 1 | same | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `cb3d4bd9` | 1 | same | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `a997bd30` | 2 | isolation, **default OTLP, no `--variant`** | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |
| `bb0d731d` | 2 | same | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |
| `aa548920` | 2 | same | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |
| `c6d44da9` | **3** | **the batch environment on every flag** | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7, `agentHash` recorded |
| `db318da7` | **3** | same | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7, `agentHash` recorded |
| `b8e31a61` | **3** | same | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7, `agentHash` recorded |

**Set 3 is the reading that stands on its own.** Sets 1 and 2 each missed the batch environment
on a different flag — pass 19 found the first, and the re-run that fixed it introduced the
second (passes 20 and 21). Set 3 carries `--isolate-user-settings`, `--variant phases-v1.0` and
the tunnel endpoints `14317`/`14318` together, on the corrected runner, so it is the batch
environment on every flag this project has since found itself getting wrong. Sets 1 and 2 are
kept: agreeing across three environments is stronger than set 3 alone, and deleting the two that
exposed the defects would delete the evidence for them.

**Set 3 also carries the overhead the other six do not** — `modelCalls` 27/30/32, `toolCalls`
25/27/30, cost $0.227/$0.197/$0.200 — because it is the only set whose OTLP endpoints were the
live ones. `events.jsonl` grew 21, 22 and 24 lines across the three runs, read inside the window
rather than trusted from an exit code.

**And set 3 is the first evidence in this project of a run recording the hash of its own
treatment**: all three carry `agentHash: sha256:b3450564b6f32d6193e8580db766210e`, the overlay's
agent file, against `null` on the six before them. See defect 2.

Declared and delivered are the **same set in the same order** — not `order-differs` as E-007 saw,
and not E-005's stripping, which is about a `Bash`-bearing list that *also* declares `Grep`/`Glob`.
This list declares neither, so there is nothing to strip.

All nine on `BE-004`, the `phases-v1.0` overlay, `claude-haiku-4-5-20251001`, Claude Code
`2.1.263`, benchmarks at `eea144ef`. Sets 1 and 2 under `EXP-P12-PREFLIGHT-INITTOOLS` and
`-ISO`; set 3 under `EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV`, all three preflight keys, none
joinable to an `n`.

## Why there are three environments and not one

The first three runs (2026-09-07) were **not** isolated. Validator pass 19 caught it from the
`init` record itself: **41 agents and two user-level plugins**, against **6 agents and none** on an
isolated run. Decision 8's wording is *through the runner with the runner's own flags*, and the
batch that will inherit this reading runs with `--isolate-user-settings`.

The three isolated runs (2026-09-08) are the answer to that, rather than a caveat about it. This
repository's own lesson is the reason: **"a flag is a promise; a field is a fact"**
(`phases/b02-plain-baseline/README.md`). The environment difference is now a measured field in
six `init` records, not an argument.

~~The environment difference is now a measured field in six `init` records, not an argument.~~
**True of user settings only** — corrected 2026-09-08 per pass 21. The re-run that fixed
isolation dropped the OTLP endpoints and `--variant`, so set 2 was two flags short of the batch,
not zero. **Set 3 is the one that is short of nothing**, and the telemetry path is now a field
too: it is the only set with `modelCalls` and cost in its record.

All three sets are kept. Sets 1 and 2 are not junk — they are the same reading in environments
that each differ from the batch on a *different* axis, and agreeing across all three is stronger
than set 3 alone. They are also the evidence for the three defects below, two of which they are
the only demonstration of.

## What is in here

```
init-schema/     lib/check-init-schema.sh's own output, verbatim, one per run
                 (the format evidence/b04/init-schema/ established)
init-records/    the raw `system`/`init` line from each run's kept transcript
```

The raw records are filed because the `init-schema` summary does **not** carry the agent list, the
plugin list, or the session id — and those are what made pass 19's isolation finding visible at
all. A summary that cannot show you the thing you did not think to summarise is why the raw line
is here too.

`INIT_SCHEMA_DIR` exists for exactly this: *"TMPDIR is the default and macOS reaps it, so a batch
that wants durable evidence points this somewhere that survives."* The three isolated runs wrote
here directly. The first three were copied out of `TMPDIR` before it swept them.

---

## Three defects found while filing this, none of which changes the reading above

**Status after set 3, added 2026-09-08:** defect 1 and defect 3 are **retired** — set 3 is the
same reading with the flags they were about, so what was going to be disclosed is now measured.
Defect 2 is **fixed** in `agent-observatory` (obs#76), and set 3 ran on the corrected runner,
which is why its three records carry a real `agentHash`.

The original text of all three is kept below, unstruck, because each is the record of a defect
that was real when written and because the runs that exposed them are still in the table. What
changed is stated in each. The reading stands on the `init` records, which none of them touch.

### 1. Three of these runs are recorded in the observatory as `variant=baseline`

**Mine, and disclosed rather than corrected.** `--variant` defaults to `baseline` and I omitted it
on the isolated three. So `a997bd30`, `bb0d731d` and `aa548920` sit in the database labelled
`baseline` while having run the `phases-v1.0` overlay with `--agent backend-feature-phases`.

The database row is wrong; the run is not. The `init` record for each names
`backend-feature-phases` in its agent list, which is the delivery proof, and all three are under
the preflight experiment key `EXP-P12-PREFLIGHT-INITTOOLS-ISO` — never joinable to an `n`.

**Not silently rewritten.** A corrected row with no trace is a worse record than a wrong row with
a disclosure, and revising evidence is the one thing this project does not do. Whether to re-run
the three with `--variant phases-v1.0` is the author's call.

> **RETIRED 2026-09-08 by set 3, not by editing these rows.** `c6d44da9`, `db318da7` and
> `b8e31a61` carry `variant: phases-v1.0`. The three mislabelled rows stay exactly as they are,
> under their own preflight key, as the record of the defect. The author's call was to re-run,
> and mine was that a disclosure saying no probe ever matched the batch environment is a worse
> artifact than three runs that do.
> *Claude Opus 5 (`claude-opus-5`), 2026-09-08.*

### 2. `agentHash` and `skillsHash` hash files that do not exist for these treatments

`run-agent.sh` computes:

```sh
--argjson skills "$(hash_of .github/skills.md)"
--argjson agent  "$(hash_of .github/copilot-instructions.md)"
```

`.github/copilot-instructions.md` is not an agent file, and `.github/skills.md` is not where
Claude Code skills live. Neither path exists in the benchmarks repo. **So every one of these six
runs records `agentHash: null` for a run whose treatment *is* an agent file** — including the
three that named their variant correctly.

The comment directly above that block is about this exact mistake:

> *Hash the file this runtime actually reads, not a fixed filename. […] A hash of the wrong file
> is worse than no hash: it is a provenance claim about something that had no effect.*

The fix was applied to `instructionsHash`, which branches per runtime, and **not** to the two
beside it. The consequence is narrow but sharp: **the run record cannot distinguish a run that
received an agent overlay from one that did not.** Arm membership rests on `variant` — a string an
operator types, and which defect 1 is a live demonstration of getting wrong.

For the record, since the runner did not: the overlay's agent file is
`sha256:b3450564b6f32d6193e8580db766210e`.

> **FIXED 2026-09-08, `agent-observatory` obs#76.** `agentHash` now hashes
> `.claude/agents/<--agent>.md` on claude and is `null` elsewhere *meaningfully* — only claude
> has a named-agent flag and a native agent directory, so on codex and copilot there is nothing
> an agent file could be read by. `skillsHash` hashes every `SKILL.md` in the worktree as one
> digest over sorted `(path, content)` pairs.
>
> **The larger half of that fix is that the hash block moved above the `--check-customization`
> exit.** It used to be computed below it, so reading a hash cost a real benchmark run and a
> real model call — which is how two of three could name files that do not exist for as long as
> they did. A provenance field that costs a run to read is not a field anyone checks. Three
> fixtures now hold it (`verify-agent-delivery.sh` 13 → 16), and against a copy of the runner
> with only the two hash targets reverted, **N and P go red and the other fourteen pass**.
>
> **Set 3 ran on the corrected runner**, which is why `c6d44da9`, `db318da7` and `b8e31a61`
> carry `agentHash: sha256:b3450564b6f32d6193e8580db766210e` — the line above, which I had to
> compute by hand *because the runner would not*, is now the run record's own answer.
> The six earlier runs still read `null` and are left that way.
> *Claude Opus 5 (`claude-opus-5`), 2026-09-08.*

### 3. The isolated three carry null behaviour and efficiency metrics — and it is not isolation

> **CORRECTED 2026-09-08 by Claude Opus 5 (`claude-opus-5`), the model that wrote the error.**
> Attribution: validator pass 20 (`findings/track-b-validation-2026-09-08-2.md`), which reversed
> it, and pass 21 (`-3.md`), a fresh session that re-derived the reversal and closed the hole
> pass 20 left open. **The original is struck below, not deleted** — the diagnosis was wrong and
> the remedy it produced was worse than wrong, and neither is checkable once removed.
>
> **What is still true:** the metrics are null on the isolated three and populated on the first
> three; isolation is not the cause; and the colima forward on `4317`/`4318` accepts a connection
> and delivers nothing.
>
> **What is false: that a forward "died", and that anything here was using it.** Two listeners
> exist for each OTLP port on this host, and every batch since stop 11 uses the second:
>
> | port | listener | empty POST to `/v1/logs` |
> |---|---|---|
> | `4317` / `4318` | `limactl` — colima's own forward | **HTTP 000** |
> | `14317` / `14318` | `ssh` — the tunnel the batch manifests set | **HTTP 200** |
>
> The 2026-09-07 probe exported `OTLP_GRPC_ENDPOINT=http://localhost:14317` and
> `OTLP_HTTP_ENDPOINT=http://localhost:14318`. **My 2026-09-08 isolated script exported no OTLP
> variable at all**, so `lib/telemetry-env.sh:15-16` defaulted to `localhost:4317/4318`. So the
> forward's state on 09-07 is not evidenced by those runs at all, and `events.jsonl` stopped
> growing because nothing was sent through the tunnel after `cb3d4bd9` — not because a path broke.
>
> **The nulls are a launch-flag omission of mine, the same class as `variant=baseline` above.**
> That is three launch-flag omissions in two days — `--isolate-user-settings`, `--variant`, and
> the OTLP endpoints — which is an argument about the runner, not about me: pass 21 leaves open
> whether it should export the tunnel endpoints itself or **refuse to run without an explicit
> endpoint, the way it already refuses to guess a version.**
>
> **The instruction that follows from the evidence** is not the struck one below. It is: export
> `OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318` on every run as the manifests do, and read
> `events.jsonl` growth inside the batch window. Pass 21's word for the struck instruction is the
> right one — *dangerous rather than merely wrong*: a preflight that confirms the host can reach
> `4317` would pass or fail on a port no batch uses.
>
> **RETIRED 2026-09-08 by set 3**, which exported `OTLP_GRPC_ENDPOINT=http://localhost:14317`
> and `OTLP_HTTP_ENDPOINT=http://localhost:14318` and carries the overhead the six before it do
> not: `modelCalls` 27/30/32, `toolCalls` 25/27/30, cost $0.227/$0.197/$0.200, with
> `events.jsonl` growing 21, 22 and 24 lines — read inside the window, as the corrected
> instruction says, rather than inferred from an exit code. The struck text stays as the record
> of the diagnosis error.
>
> **What this costs the reading above:** nothing for `init.tools`, which is read from the
> transcript and not from telemetry, so 6 of 6 stands. But the isolated three are **two** flags
> short of the batch environment, not one — pass 19 found the first, and the re-run that fixed it
> introduced the second. *"The environment is now a measured field in six `init` records"* is true
> of **user settings only**; the telemetry path is a field in no record at all, which is the gap
> this defect should have named. **The reading of overhead was never made.**

~~`modelCalls`, `toolCalls`, `inputTokens`, `estimatedCost`: all `null` on the isolated three, all
populated on the first three. The obvious reading is that isolation kills telemetry. **It is not.**~~

~~Claude Code telemetry is enabled by environment variables `lib/telemetry-env.sh` exports on both
arms (`CLAUDE_CODE_ENABLE_TELEMETRY=1`, OTLP to `localhost:4317`), not by any user setting that
`--setting-sources project` could drop. The actual cause is **§4 trap 2**:~~

```
collector inside colima:   4317/tcp -> 0.0.0.0:4317   4318/tcp -> 0.0.0.0:4318
from the host:             port 4317 CLOSED    port 4318 CLOSED
```

~~The container has been up 13 days and reports healthy. **The colima host port-forward is dead**,
so no events reach the collector, so the adapter finds none. It died some time after
2026-09-07T22:53Z — `infra/telemetry-out/events.jsonl` has not been written since, and the last
records in it belong to `cb3d4bd9`.~~

**The runner behaved correctly** and this is worth stating plainly, because it is the opposite of
the failure this project keeps finding — it holds under the correction too:

```
claude-telemetry: no events found for run a997bd30-… in …/events.jsonl
    no telemetry found — behaviour metrics stay empty rather than guessed
```

It refused to guess. The run still exits 0, still evaluates, still passes 7/7 — **and records
nothing about cost, tokens or tool calls.**

~~**This is load-bearing for stop 12.** B5's gate is *"phase markers observable in the transcript, no
code written before DESIGN, overhead measured not assumed."* A batch run against a dead forward
discharges the first two and silently cannot discharge the third: every run comes back green with
the overhead fields empty. Nothing in the harness fails, and a reader who checks exit codes rather
than fields would not notice. **Confirm the host can reach 4317 before the first B5 batch, not
after it.**~~

---

*Filed 2026-09-08 by Claude Opus 5 (`claude-opus-5`) at the author's direction, following validator
pass 19 (`claude-fable-5-1`), `findings/track-b-validation-2026-09-08.md`, which found this
evidence existing only in `TMPDIR` and the observatory database. Extended the same day with set 3
and the defect resolutions, following passes 20 and 21 (`-2.md`, `-3.md`).*

*Three sets, three environments, and the honest summary is that it took three attempts to run a
preflight in the environment the batch will use — `--isolate-user-settings` missed on the first,
`--variant` and the OTLP endpoints missed on the second. Each was caught by a validator reading
a field rather than by the run that made it. That is an argument about the runner, not about
care: pass 21 leaves open whether it should refuse to start without an explicit endpoint the way
it already refuses to guess a version, and on three-for-three that is the better question.*
