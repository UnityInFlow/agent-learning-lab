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

**Six runs, six matches, two environments. `Edit` and `Write` reach the model.**

| run | environment | `init.tools` delivered | verdict | eval |
|---|---|---|---|---|
| `6bc9fa5d` | user settings **live** | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `e9bfde84` | user settings **live** | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `cb3d4bd9` | user settings **live** | `["Read","Edit","Write","Bash"]` | match | exit 0 |
| `a997bd30` | `--isolate-user-settings` | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |
| `bb0d731d` | `--isolate-user-settings` | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |
| `aa548920` | `--isolate-user-settings` | `["Read","Edit","Write","Bash"]` | match | exit 0, 7/7 |

Declared and delivered are the **same set in the same order** — not `order-differs` as E-007 saw,
and not E-005's stripping, which is about a `Bash`-bearing list that *also* declares `Grep`/`Glob`.
This list declares neither, so there is nothing to strip.

All six on `BE-004`, `phases-v1.0`, `claude-haiku-4-5-20251001`, Claude Code `2.1.263`, benchmarks
at `eea144ef`.

## Why there are two environments and not one

The first three runs (2026-09-07) were **not** isolated. Validator pass 19 caught it from the
`init` record itself: **41 agents and two user-level plugins**, against **6 agents and none** on an
isolated run. Decision 8's wording is *through the runner with the runner's own flags*, and the
batch that will inherit this reading runs with `--isolate-user-settings`.

The three isolated runs (2026-09-08) are the answer to that, rather than a caveat about it. This
repository's own lesson is the reason: **"a flag is a promise; a field is a fact"**
(`phases/b02-plain-baseline/README.md`). The environment difference is now a measured field in
six `init` records, not an argument.

Both sets are kept. The non-isolated three are not junk — they are the same reading in a
*noisier* environment, and agreeing across both is stronger than either alone.

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

All three are recorded rather than fixed. The reading stands on the `init` records, which none of
them touch.

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

### 3. The isolated three carry null behaviour and efficiency metrics — and it is not isolation

`modelCalls`, `toolCalls`, `inputTokens`, `estimatedCost`: all `null` on the isolated three, all
populated on the first three. The obvious reading is that isolation kills telemetry. **It is not.**

Claude Code telemetry is enabled by environment variables `lib/telemetry-env.sh` exports on both
arms (`CLAUDE_CODE_ENABLE_TELEMETRY=1`, OTLP to `localhost:4317`), not by any user setting that
`--setting-sources project` could drop. The actual cause is **§4 trap 2**:

```
collector inside colima:   4317/tcp -> 0.0.0.0:4317   4318/tcp -> 0.0.0.0:4318
from the host:             port 4317 CLOSED    port 4318 CLOSED
```

The container has been up 13 days and reports healthy. **The colima host port-forward is dead**,
so no events reach the collector, so the adapter finds none. It died some time after
2026-09-07T22:53Z — `infra/telemetry-out/events.jsonl` has not been written since, and the last
records in it belong to `cb3d4bd9`.

**The runner behaved correctly** and this is worth stating plainly, because it is the opposite of
the failure this project keeps finding:

```
claude-telemetry: no events found for run a997bd30-… in …/events.jsonl
    no telemetry found — behaviour metrics stay empty rather than guessed
```

It refused to guess. The run still exits 0, still evaluates, still passes 7/7 — **and records
nothing about cost, tokens or tool calls.**

**This is load-bearing for stop 12.** B5's gate is *"phase markers observable in the transcript, no
code written before DESIGN, overhead measured not assumed."* A batch run against a dead forward
discharges the first two and silently cannot discharge the third: every run comes back green with
the overhead fields empty. Nothing in the harness fails, and a reader who checks exit codes rather
than fields would not notice. **Confirm the host can reach 4317 before the first B5 batch, not
after it.**

---

*Filed 2026-09-08 by Claude Opus 5 (`claude-opus-5`) at the author's direction, following validator
pass 19 (`claude-fable-5-1`), `findings/track-b-validation-2026-09-08.md`, which found this
evidence existing only in `TMPDIR` and the observatory database.*
