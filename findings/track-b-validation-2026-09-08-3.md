# Track B validation — 2026-09-08 (pass 21)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 21, 2026-09-08T14:25Z, a FRESH session
after /clear, started by the author with "verify opus work and provide resolution" — the same
sentence that produced pass 20 in the previous session. Scope: does Opus's work since pass 19
hold, and does pass 20 — which sits untracked on disk with a placeholder timestamp and no final
message on record — hold when a session that did not write it re-derives its one reversal?`

Under review: `agent-learning-lab` `stop12/phase-contract-instrument` at `03c1cbf` (PR lab#77,
open), `agent-observatory` `obs/foreign-agent-dir-guard` at `a7fc212` (PR obs#75, open), the
brief `workbench.local/VERIFY-BRIEF-stop12-instruments.md` as corrected 2026-09-08 11:45, the
discharge document `workbench-halt-discharge-stop12.md` at the workspace root, and
`findings/track-b-validation-2026-09-08-2.md` (pass 20, untracked). Author of the work under
review: Claude Opus 5 (claude-opus-5), 2026-09-07 evening and 2026-09-08 morning. Nothing new
from Opus since `03c1cbf` (10:25Z); both trees clean apart from pass 20's file.

Read-only against the repositories, the observatory and the kept logs, except for this file.
No model call. No record written anywhere: the two OTLP checks below POST an empty body, which
the collector accepts on one port and drops on the other without writing a line either way
(`events.jsonl` is 14 M and its last record is still pass 20's probe). `TRACK-B-STATE.md` and
`HANDOFF.md` not edited (last commits `08d22ab` and `f1f7c34`, 2026-09-07).

---

## Verdict

**Opus's processing of pass 19 is complete and honest, as pass 20 said.** Every item pass 19
asked for maps to a thing on disk or in the API, and the six `init` records say what the README
says they say. `Edit` and `Write` reach the model under both environments, so pass 18's
*single finding most likely to matter* stays off the table.

**Pass 20's reversal of defect 3 is CONFIRMED, and this pass closes the hole pass 20 left
open.** Pass 20 showed the SSH tunnel delivers and the colima forward does not, but listed as
*not checked* whether the three runs that *did* get metrics went through the tunnel. They did.
The launch commands are in the kept session transcripts: the 2026-09-07 probe set
`OTLP_GRPC_ENDPOINT=http://localhost:14317` and `OTLP_HTTP_ENDPOINT=http://localhost:14318`;
the 2026-09-08 isolated probe set neither. So the forward did not "die some time after
2026-09-07T22:53Z" — nothing this project has run since at least the morning of 09-07 has used
it. The null metrics are a launch-flag omission, the same class as `variant=baseline`
(defect 1), and the README's defect 3 attributes them to an outage that is not on record.

**One thing pass 20 did not mention, and this pass does not soften:** the isolated three are
therefore *two* flags short of the batch environment, not one. Pass 19 found the first
(`--isolate-user-settings`); the re-run fixed that and introduced the second (tunnel ports).
The `init.tools` reading does not depend on either — `tools` is read from the transcript, not
from telemetry — so the reading stands at 6 of 6. But *"the environment is now a measured
field in six init records"* (README, commit `03c1cbf`) is true of user settings only. The
telemetry path is not a field in any record, which is the gap defect 3 should name.

Per-stop verdict, since §9 wants one: no stop closed in this window. Stop 12 is still not
opened, and this pass found nothing of it created — the overlay under
`build/customizations/phases-v1.0/` is the tension pass 18 recorded under 3.3, unchanged.

---

## What was checked, and how

| # | claim | source | checked against | result |
|---|---|---|---|---|
| 1 | pass 19 committed unaltered | `123ba8d` | `git show --stat`, 218 insertions, file 218 lines | **holds** |
| 2 | `NODE_OPTIONS` trap in the brief's §4 | pass 19 resolution | brief lines 261–276: cause, symptom, fix, open question | **holds**; one unverifiable cosmetic, below |
| 3 | six `init` records filed | `03c1cbf` | `jq` on all six raw records: `tools` = `["Read","Edit","Write","Bash"]` ×6; agents 41/41/41/6/6/6; model `claude-haiku-4-5-20251001`; version `2.1.263` | **holds** |
| 4 | six `init-schema` outputs | same | all six read `delivered n=4 … declared n=4 … verdict=match` | **holds** |
| 5 | all six runs exist, BE-004, correct keys | README table | `GET /api/runs/<id>` through the tunnel (`127.0.0.1:18081`): 3 × `EXP-P12-PREFLIGHT-INITTOOLS` `variant=phases-v1.0` (20:25–20:53Z 09-07), 3 × `EXP-P12-PREFLIGHT-INITTOOLS-ISO` `variant=baseline` (09:44–10:19Z 09-08); all `passed: true`, 7/7 criteria | **holds** |
| 6 | defect 1, `variant=baseline` on the isolated three | README | API rows above; runner line 28 `VARIANT="${VARIANT:-baseline}"`; the isolated launch script passes no `--variant` | **holds** |
| 7 | defect 2, `agentHash` hashes the wrong file | README | `run-agent.sh:601-602`: `skills ← .github/skills.md`, `agent ← .github/copilot-instructions.md`; all six records `agentHash: null`, `skillsHash: null`; overlay file hashes to `b3450564b6f32d6193e8580db766210e` (32-char convention), which the README states | **holds** |
| 8 | defect 3, "the colima forward is dead" | README, discharge §2a, commit `03c1cbf` | `lsof`: `limactl` listens on 4317/4318, `ssh` on 14317/14318/18081. Empty POST to `/v1/logs`: **4318 → HTTP 000**, **14318 → HTTP 200**. `events.jsonl`: 22/23/22 lines for the 09-07 runs, **0** for each isolated run; pass 20's probe record present at the tail | **half holds**: the forward is dead, the path batches use is not |
| 9 | defect 3, "it died some time after 2026-09-07T22:53Z" | README | Opus session `c3898602…` 2026-09-07T20:25:34Z: the probe script exports `OTLP_HTTP_ENDPOINT=http://localhost:14318` and `OTLP_GRPC_ENDPOINT=http://localhost:14317`. Opus session `d851a2c1…` 2026-09-08T09:44:39Z: the isolated script exports `API`, `BENCHMARKS_REPO`, `INIT_SCHEMA_DIR` and **no OTLP variable**; `lib/telemetry-env.sh:15-16` then defaults to `localhost:4317/4318` | **refuted**: the runs with metrics never touched the forward |
| 10 | §6 condition 2 struck with attribution; §3.2 body amended | pass 19's "two stale crumbs" | brief §6 reads struck-through + *"this condition fired"* + count 13, attributed to Opus 2026-09-08 | **holds** |
| 11 | both PRs open, mergeable, blocked on review | pass 20 | `gh pr view`: lab#77 `MERGEABLE`/`BLOCKED`, head `03c1cbf`; obs#75 `MERGEABLE`/`BLOCKED`, head `a7fc212` | **holds** |
| 12 | CI green including the new job | pass 20 | lab#77: 9 of 9 pass, `a narrated phase is not a phase` 12 s; obs#75: 4 of 4 pass | **holds** |
| 13 | the checker's verifier still rejects | brief §2.2 | `./tools/verify-phase-contract-checker.sh` re-run locally: `15 passed, 0 failed, of 15 registered cases`, both `NEG` lines present, no file written to the tree | **holds** |
| 14 | state and handoff untouched | pass 20 | `git log -1 -- TRACK-B-STATE.md` → `08d22ab` 2026-09-07 16:13; `HANDOFF.md` → `f1f7c34` 16:05 | **holds** |

**Cosmetic, unverifiable.** The brief says the `NODE_OPTIONS` guard *"now also fires on
`UserPromptSubmit`, not only `PreToolUse`"*; pass 20 says the original event was `SessionStart`.
Today `~/.claude/settings.json` fires it on eight events including all three, and nothing on
disk records which one was first. Neither reading changes the fix line. Left as is.

---

## Defect 3, re-derived from the launch commands

The README's defect 3 says three true things and one false one:

- true: `modelCalls`, `toolCalls`, `inputTokens`, `estimatedCost` are null on the isolated three
  and populated on the first three (API, this pass)
- true: isolation is not the cause — telemetry is enabled by `lib/telemetry-env.sh`, not by a
  user setting
- true: the colima forward on 4317/4318 accepts a connection and delivers nothing (HTTP 000 on
  an empty POST; pass 20's real export also failed)
- **false:** *"It died some time after 2026-09-07T22:53Z — `events.jsonl` has not been written
  since, and the last records in it belong to `cb3d4bd9`."* The first three runs were launched
  with the tunnel endpoints, so the forward's state on 09-07 is not evidenced by them at all. The
  file stopped growing because the next thing sent through the tunnel was pass 20's probe. The
  brief's own §4 trap 2 — *"every colima host port-forward on this machine can be dead while
  reporting healthy"* — was written on 09-07 before the first probe ran, and every batch
  manifest since stop 11 (`run-e008.sh:154-157`) sets the tunnel ports for that reason.

The consequence Opus drew — *"Confirm the host can reach 4317 before the first B5 batch"* — is
therefore the wrong instruction, as pass 20 said, and this pass adds why it is dangerous rather
than merely wrong: a host that *can* reach 4317 is the one thing no run here has needed, and a
preflight that checks it would pass or fail on a port the batch does not use. The instruction
that follows from the evidence is pass 20's: **export the tunnel endpoints on every run as the
manifests do (`run-e008.sh:156-157`), and read `events.jsonl` growth in the batch window.**

Two corrections belong on record, originals struck, attributed:

1. `evidence/b05-preflight/README.md` defect 3 — the "died after 22:53Z" sentence and the closing
   "confirm the host can reach 4317" instruction; and the paragraph's opening claim that the
   environment variables point at `localhost:4317` *"on both arms"* is true of the defaults and
   false of every batch manifest.
2. `workbench-halt-discharge-stop12.md` §2a, the added paragraph's last defect, same wording.

And one addition, which is this pass's own: the isolated three are annotated as **not the batch
environment on the telemetry path** — the reading of `init.tools` is unaffected, the reading of
overhead was never made. Whether to re-run three probes with `--variant phases-v1.0` *and* the
tunnel ports, so that one set of three is the batch environment on every flag, is the author's
call. It is cheap (the isolated three took 35 minutes of Haiku, 09:44–10:19Z) and it would
retire defects 1 and 3 together instead of disclosing them.

---

## Not checked

- Whether the runner should export the tunnel endpoints itself, or refuse to run without an
  explicit endpoint the way it refuses to guess a version. Same class as the `NODE_OPTIONS`
  question in the brief's §4; the author's call, and the third launch-flag omission in two days
  (`--isolate-user-settings`, `--variant`, OTLP) argues for making the runner refuse.
- The PR bodies of lab#77 and obs#75 beyond title, head sha, mergeability and checks.
- `verify-agent-delivery.sh` cases A–M on the stripped runner; pass 19 reproduced 13/13 and this
  pass did not repeat it.
- The observatory guard's four `+` blocks in `run-agent.sh` were read for shape (native versus
  foreign agent globs per runtime, `die` with a remedy naming the runtime's own directory,
  `note:` for inert foreign files) and not re-executed.
- Pass 20's header still reads `2026-09-08T1x:xxZ`. Its file mtime is 13:00 local (11:00Z). Not
  my file; not edited. It should be committed as written, placeholder included, with the mtime
  in the commit message.

## Corrections made in place

None. Both trees are as Opus left them plus pass 20's file and this one, both untracked.

## Resolution

1. **Commit pass 20 and pass 21 unaltered**, the way passes 18 and 19 were (`69f0bfd`, `123ba8d`).
2. **Correct defect 3** in `evidence/b05-preflight/README.md` and the discharge document as
   above — originals struck, not deleted, attributed to the model that corrects them — and add
   the tunnel endpoints to the brief's §4 beside the API trap. Then push; lab#77 re-runs its
   nine jobs.
3. **Merge obs#75 and lab#77** (author, `--admin`). Nothing in either is a stop-12 artifact.
4. **Decide defect 2** before the first B5 batch: a two-line change to `run-agent.sh:601-602` so
   `agentHash` hashes the agent file the runtime reads, per the comment above it. Without it the
   run record cannot tell a treated run from a control, and stop 12 has two tasks and two arms.
5. **Decide the re-run**: three isolated probes with `--variant phases-v1.0` and the tunnel
   endpoints, or a disclosure that no probe run matched the batch environment on every flag.
6. Then open stop 12 at §4 step 1. `TRACK-B-STATE.md` files passes 18–21 in
   `validation_processed` when the autonomous run next writes it.

## The single finding most likely to overturn the track's result if pursued

Not defect 3 — it is a diagnosis error with the right remedy already written. **Defect 2.**
Every run record in this project carries `agentHash: null`, so from stop 12 onward arm
membership rests on `--variant`, a string typed at launch, and 2026-09-08 is a live demonstration
of three runs typed wrong on the same day the overlay was proven delivered. If a batch mislabels
even one control as treated, the phase-contract checker will score it *no phases observed* under
the treatment arm and the effect shrinks toward null with no field in the record to catch it.
Fix the hash before the first batch, not after.
