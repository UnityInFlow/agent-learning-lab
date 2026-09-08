# Track B validation — 2026-09-08 (pass 20)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 20, 2026-09-08T1x:xxZ, the same session as
passes 18 and 19, continued by the author with "verify opus work and provide resolution". Scope:
was pass 19 processed honestly, and does what Opus filed since hold?`

Under review: `agent-learning-lab` `stop12/phase-contract-instrument` at `03c1cbf` (three commits
on the pass-19 state: `123ba8d` the pass-19 file, `03c1cbf` evidence), `agent-observatory`
`obs/foreign-agent-dir-guard` at `a7fc212` (unchanged), both **pushed**, PRs **lab#77** and
**obs#75** open; the brief's §4/§6 corrections; the discharge document's added probe section;
`evidence/b05-preflight/`. Author of the work: Claude Opus 5 (claude-opus-5), 2026-09-08.

Read-only against the repositories except for this file. No model call. **Two synthetic records
were written to the observatory to settle one claim** — a trace to Tempo and one OTLP log line to
`infra/telemetry-out/events.jsonl` (468 bytes, run id `00000000-0000-4000-8000-000000014318`,
service `pass20-probe`). Neither matches any run and neither is removed, since editing that file
is editing evidence. Disclosed here.

---

## Verdict

**Pass 19 was processed completely and honestly.** Every item in the message the author handed
Opus is done, each checked against the thing rather than the sentence. The evidence Opus filed
matches the kept logs and the API exactly, and its three extra probe runs answer the isolation
question the right way — by measuring, not annotating.

**One of Opus's three new defect claims is wrong in scope, and it is the load-bearing one.** The
README and the discharge document say the colima OTLP forward is dead and that *"a B5 batch run
today would … silently fail to measure overhead."* The forward the batches use is alive. The
isolated probes got null metrics because they were sent to the default ports, not the tunnel — the
§4 trap-1 mistake applied to telemetry. Evidence and correction below. Nothing else reopens.

---

## The six items, each checked

| # | asked | done? | checked how |
|---|---|---|---|
| 1 | commit pass 19 unaltered | **yes** | `123ba8d`, 218 insertions, file is 218 lines, no added text |
| 2 | add the `NODE_OPTIONS` trap to §4 | **yes** | brief lines 261–276: cause, symptom (`got exit 1`, version message), fix, and the open question of whether the runner should strip it. One error: it says the guard *"now also fires on `UserPromptSubmit`, not only `PreToolUse`"* — it was `SessionStart`, not `PreToolUse`. Cosmetic; the fix line is right |
| 3 | file the probe init records | **yes, and more** | `evidence/b05-preflight/`: six `init-schema` outputs plus six raw `system`/`init` lines, README of 165 lines. The six raw records read `tools` = `["Read","Edit","Write","Bash"]` and `agents` = 41, 41, 41, 6, 6, 6 — byte-consistent with the kept logs in `TMPDIR` |
| 4 | annotate or re-run isolated | **re-run** | three runs under `EXP-P12-PREFLIGHT-INITTOOLS-ISO` (`a997bd30`, `bb0d731d`, `aa548920`), all in the API, all `init.tools` verbatim, all 6 agents with the overlay's `backend-feature-phases` first. 6 of 6 across two environments. The discharge document gained the table and the attribution |
| 5 | two stale crumbs | **yes** | §6 condition 2 struck with the correction and attribution; §3.2 body gained *"It was a real defect, and this section is the one that halted the pass"* |
| 6 | push and open PRs | **yes** | obs#75 (+133 −1), lab#77 (+1519). Both `MERGEABLE`, both `BLOCKED` on `REVIEW_REQUIRED` — branch protection, the author merges with `--admin` as before |

**§3.7 and §3.8 of the original brief are now observed, not assumed.** On lab#77 all nine jobs
are green, including `shell tools` with `check-phase-contract.py` and `naive-phase-checker.py`
in `tools/` — the ShellCheck action skipped them as pass 18 read from its source — and
`a narrated phase is not a phase` fired and passed on its first push. Pass 18's finding that only
two of the nine are required checks is unchanged.

**`TRACK-B-STATE.md` and `HANDOFF.md`** are untouched (last commits 16:13 and 16:05 on 09-07),
which is correct under the brief; the autonomous run will file passes 18–20 in
`validation_processed` when it next runs. Neither yet names `b05-preflight/`.

---

## The three defects Opus found while filing, re-checked

**1. `variant=baseline` on the isolated three.** Confirmed in the API: all three carry
`variant: baseline` under `EXP-P12-PREFLIGHT-INITTOOLS-ISO`. Disclosed, not rewritten. Correct
handling.

**2. `agentHash` hashes `.github/copilot-instructions.md`.** Confirmed in `run-agent.sh` (the
`jq -n` block after the `--check-customization` exit): `skillsHash` ← `.github/skills.md`,
`agentHash` ← `.github/copilot-instructions.md`, neither present in the benchmarks repo, so every
agent-overlay run records `null` for the hash of its own treatment. Real, and the sharpest of the
three: arm membership in the database rests on a typed `variant` string, which defect 1 got wrong
on the same day. The author's call, as Opus said.

**3. "The colima 4317 forward is dead … a B5 batch run today would silently fail to measure
overhead."** Half right, and the wrong half is the one that matters.

Two listeners exist for each OTLP port on this host:

| port | listener | trace to Tempo | log record to `events.jsonl` |
|---|---|---|---|
| `4317` / `4318` | `limactl` — colima's own forward | **HTTP 000**, export failed | **HTTP 000**, nothing written |
| `14317` / `14318` | `ssh` — the tunnel every batch manifest sets (`OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318`) | **`Tempo returned the trace`** | **HTTP 200, file grew 468 bytes, record present** |

So: the colima forward is dead while accepting connections, exactly as §4 trap 2 says. **The
tunnel is not**, and the tunnel is what E-008, E-009 and every fourth-cell batch used. The
isolated probes have null metrics because they were run with `telemetry-env.sh`'s defaults
(`localhost:4317`) rather than the manifests' `14317` — the same mistake §4 trap 1 warns about
for the API, one port over. The runner still behaved correctly (refused to guess), and Opus was
right to say so.

**What that changes.** The sentence *"a B5 batch run today would discharge two thirds of the
gate and silently fail to measure overhead"* is false for a batch run the way batches are run
here, and true for one started with the default ports. The load-bearing instruction therefore
moves: not *confirm the host can reach 4317*, but **pass `OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318`
on every run, as the manifests do, and read `events.jsonl` growth in the batch window, as
`run-e008.sh` already does.** The dead colima forward is a standing hazard, not a new outage;
`events.jsonl` last grew at 22:53 on 09-07 because nothing was sent through the tunnel after
`cb3d4bd9`, not because the path broke.

This belongs in `evidence/b05-preflight/README.md` defect 3 and the discharge document's added
paragraph, original struck. Not edited here (§5).

---

## Not checked

- Whether `cb3d4bd9`, the last run with metrics, went through the tunnel or the default forward
  at 22:53 on 09-07. The run record does not carry the endpoint. It does not change the finding.
- The PR bodies of obs#75 and lab#77 beyond title, size and checks.
- `~/.claude/settings.json` gained the `NODE_OPTIONS` guard on `PreToolUse`, `PostToolUse`,
  `SubagentStop` and `Stop` as well since pass 19. Harmless and idempotent; note that hooks in one
  event run in parallel, so on `PreToolUse` it does not reliably run *before* the node hooks in
  the same batch. `UserPromptSubmit` is the one that orders. Outside the brief.

## Corrections made in place

None.

## Resolution

Pass 19 is processed. **Merge obs#75 and lab#77** (author, `--admin`). Before the first B5 batch,
three things, all cheap: correct defect 3 in `b05-preflight/README.md` and the discharge document
as above, original struck; put the tunnel ports in the brief's §4 next to the API one; and decide
defect 2 (`agentHash`) — a one-line change in `run-agent.sh` that makes the run record able to
tell a treated run from a control, which stop 12 will want. Then open stop 12 at §4 step 1.
