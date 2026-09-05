# Track B validation — 2026-09-05, second pass (pass 12)

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-05T10:40–11:05Z.` Read-only. Nothing outside this file was created, edited or deleted in
any repository. The only commands run that write anywhere were the two observatory verifiers,
which write to their own temp fixtures.

**Independence.** Builder `claude-opus-5`; validator `claude-fable-5-1`. This validator wrote
passes 9, 10 and 11. Every number below was recomputed from the raw artifacts, not carried.

**The builder was live during this pass.** Codex sheets for batch-2 runs appeared in
`findings/codex/` from `20260905T105258Z` onward while this pass was running (13 by 11:01Z), and
the lab branch advanced from `b3886b2` to `d375cdc` (*Hand score for run 1c905fc9*, committed
10:52:04Z, i.e. before the first sheet at 10:52:58Z — §4 step 7's ordering honoured, by
timestamp). Everything here about scoring is therefore a snapshot at step 7 in progress. No
`track-b-sessions.log` exists at the workspace root, so the builder sessions were launched by
hand rather than through `run-track-b.sh`; not a defect, but the prompt and memory say to read
that log first and there is none.

**Inputs.** Prompt at sha `952c64e4fc35` (unchanged); `TRACK-B-STATE.md` on
`stop10/b4-agent-boundary` at `b3886b2`; `E-006`; `phases/b04-agent-boundary/README.md`;
`evidence/b04/` in full (both batch manifests, 43 init-schema records, 20 diffs, 21 probe
transcripts, the killed run); `evidence/p04a/e005/` (52 transcripts); the API on `:8081`
(**292 runs** = 249 at pass 11 + 40 `EXP-B4-AGENT-BOUNDARY` + 2 `EXP-B4-PREFLIGHT` + 1
`EXP-B4-PREFLIGHT-2161`); `pmset -g log`; `agent-observatory` at `968b498` on
`stop10/b4-agent-delivery`; the rubric at sha `396e1799eb2b`; GitHub lab#29.

**Repository state.** `origin/main` is still `b86401c`. Both stop-10 branches are pushed and
unmerged, no PR. Observatory tree clean. `git diff --stat 5393704 HEAD` over every closed-stop
path (E-001…E-005, phases 01/02/03/04a/b02/b03, `tools/`, `LEARNING-PATH.md`) is **empty**.

**Scope.** Closed stops are **4, 5, 6, 7, 8 and 9**. Stop 10 is **open at §4 step 7** and is
not claimed closed; §9 covers closed stops only, so it gets no verdict. But the user asked for
the builder's work to be verified, so §9's eight checks are applied to what stop 10 has put on
disk so far, as a pre-closure audit. The pass that validates stop 10 when it closes should not
carry these; it should re-derive them.

---

## Stops 4, 5, 6, 7, 8, 9 — CONFIRMED, unchanged

Pass 11's verdicts stand. The proof that nothing moved is structural rather than a re-read:
no file under any closed stop's paths differs from the tree pass 11 was processed on, and
`main` is the same commit. One re-derivation was repeated anyway because stop 10 cites it: the
E-005 `system/init` records over all 52 transcripts give control 13 × 29 tools, description
12 × 29, toollist `[Read, Grep, Glob]` × 17, and the deliberate-failure arm `[Read, Bash]` × 10
— identical to pass 11 and to E-005's amended table.

---

## Stop 10 (B4) — OPEN at step 7, pre-closure audit

### 1. Does every cited artifact exist? — yes, with one self-correction

| Cited | Found |
|---|---|
| `evidence/b04/batch-20260905T095044Z/manifest.tsv`, `window.txt` | 20 rows, 10 `verdict=match` + 10 `verdict=recorded-only`; window 09:50:44Z–10:36:48Z |
| `evidence/b04/batch-20260905T083311Z/manifest.tsv` | 20 rows, exits 0 × 5 and 2 × 15, same verdict split |
| `evidence/b04/init-schema/init-schema-<id>.txt` | 43 files: 40 batch runs + 3 preflight runs |
| `evidence/b04/batch-20260905T095044Z/diffs/` | 20 diffs, all non-empty; `diff --git` count 3 on 10 treatment, 3 on 9 control, 2 on 1 control |
| 20 worktrees under `$TMPDIR/observatory-run-<id>` | **20 of 20 present.** My first count said 19; that was my own `awk NR>7` skipping the first data row, caught on the recount and recorded here rather than reported |
| `~/agent-observatory-worktrees/b04-batch2/` | 20 files, 1.3M |
| 21 off-observatory probe transcripts | 21 `.jsonl` present, every one carries a `system/init` record with `tools` |
| `evidence/b04/preflight-20260905/killed-treatment-561cf44b.jsonl` | present, init tools `[Read, Edit, Write, Bash]` |
| observatory `968b498` | present, 5 files / 660 insertions, committed 08:22:55Z, **before batch 1 (08:33:12Z)**; tree clean |
| overlay hash `59c2b5db71f4c01e22a51589a1febdf9` | `shasum -a 256 … \| cut -c1-32` reproduces it. (`md5` does not, and the file says which — recorded because the first thing I tried was md5) |
| runner in-run check | `init-schema: verdict=` printed by the runner in **all 20** batch-2 logs; not only in the driver's manifest |

### 2. Prediction precedes run — yes

- `2498dc7` at **2026-09-05T06:42:48Z** contains five `### P` headers, `## Minimum detectable
  effect`, `## Exclusions`, `## Decision rule`. Batch 1's first `startedAt` is 08:33:12Z, batch 2's
  is 09:50:45Z.
- `git diff 2498dc7 HEAD -- E-006` deletes exactly **two lines**: the sentence *"Currently
  `2.1.260`; a move mid-batch voids the batch"* (replaced by the disclosed-move version) and the
  bare `## Runs` header. No prediction, threshold, exclusion or decision-rule row was rewritten.
- **P6 and the MDE amendment were added in `2db1a66` at 08:33:06Z — six seconds before batch 1's
  first run and 77 minutes before batch 2's.** Batch 2 is the batch, so the guarantee holds with
  margin; for batch 1 it held by six seconds, which is worth knowing when reading *"registered
  before the first batch run"*.
- The runner commit precedes both batches (above).

### 3. One scored cell re-derived by hand, before reading any sheet

Run `1c905fc9` (treatment 01), from `diffs/01-treatment-1c905fc9-….diff` and the rubric at
`396e1799eb2b`, scored by this validator **before** opening any sheet:

| category | validator | codex sheet `20260905T105258Z` | opencode sheet `20260905T105400Z` | builder's hand score `d375cdc` |
|---|---|---|---|---|
| architecture-consistency | **2** — both refusals throw `ResourceNotFoundException` / `ConflictException` from the baseline; no `ApiError` literal | 2 | 2 | 2 |
| maintainability | **0** — the status decision is an `if` chain | 0 | 0 | 0 |
| test-quality | **1** — the second `confirm` asserts the body, refusals assert the envelope, but persisted state is never re-read through a separate `get` | 1 | 1 | 1 |
| change-focus | **1** — `ErrorCode` gains `SHIPMENT_ALREADY_CANCELLED`, a change outside `confirm`; no second unnamed method differs | 1 | 1 | 1 |

Four of four agree, across the validator, both harnesses and the builder. The builder's hand
score was read only after this table's first column was written.

### 4. Did the treatment reach the model, and not the control? — yes, by the init record; the run record cannot say

- `customization.{instructions,skills,agent,hooks,mcp}Hash` is **null on all 40 runs of both
  arms**, and — re-derived over all 292 runs — **no run in the API has ever carried a non-null
  `agentHash` or `skillsHash`.** E-006 threat 3 and the README's layer table disclose this;
  the disclosure is correct. Two wording faults in the same rows, corrected below (C3).
- Delivery is proved where E-006 says it is: the runner's own `check-init-schema.sh` ran inside
  every batch-2 run, `[Read, Edit, Write, Bash]` on 10 of 10 treatment runs against the overlay's
  `tools:` line, and the 29-tool full set on 10 of 10 controls with nothing asserted.
- `runtime.model` = `claude-haiku-4-5-20251001` on 40 of 40; `runtime.version` = `2.1.261` on all
  20 of batch 2 and `2.1.260` on all 20 of batch 1; `repository.commitSha` = `0448643` on 40 of
  40; `evaluatorVersion` = `1.0.0` on 40 of 40.
- Both observatory verifiers re-run this pass: `verify-init-schema-check.sh` **17 passed, 0
  failed, of 17**; `verify-agent-delivery.sh` **9 passed, 0 failed, of 9**. The *"goes red with
  the guard deleted"* claim was not reproduced here; the verifier was run as shipped.
- Batch 2 from the API: 20 of 20 `evaluation.exitCode 0`, `acceptanceCriteriaPassed` 7 of 7 on
  every run, `permissionDenials` 0, `forbiddenActionAttempts` 0, `startedAt` 09:50:45Z–10:34:39Z,
  inside `window.txt`. `pmset -g log`: no `Entering Sleep` between 09:38:18Z and 10:47:13Z, so
  **none inside the batch-2 window** — the caffeinate claim holds.
- Batch 1 from the API: 3 treatment + 2 control at exit 0; 15 runs `failureClass F13`,
  `infrastructureFailure true`, `taskAttempted false`, first at 09:00:16Z. Three sleeps at
  08:41:58Z, 08:55:03Z (maintenance) and 09:04:11Z — as recorded. One count is wrong (C5).
- `changedFiles` re-derived from the API agrees with the diff count: treatment 10 at 3, control 9
  at 3 and 1 at 2.

### 5. Any property claimed from n < 5? — quoted

- *"3 of 3 confirmation runs against the shipped file"* — labelled n = 3, aggregated into the
  rule below; fine as written.
- *"the claude session limit that aborted batch 1 CLEARED at 09:45:51Z"* (state file, `status:`
  line) — asserted with no evidence path; nothing under `evidence/b04/` carries that timestamp.
  A process fact, not a result, but it is the reason §7's halt was judged not to apply.

### 6. Layer labels — one to relabel

- init-schema check **L2** holds: `run-agent.sh` exits 9 on a mismatch, `Makefile`
  `baseline-runs` stops the batch on 9, and the check executed on every run.
- `--agent` guard **L2** holds on 9 of 9 fixtures.
- **`model:` pin labelled L2 citing `check-overlay-parity.sh` — relabel L3 (C4).** That tool
  compares two overlays; B4's control has no overlay, so there is nothing for it to compare and
  it is not cited as having run for this stop. What exists is the runner's `--model` and the
  recorded `runtime.model`, haiku on 40 of 40 — an observation, not something that rejects a
  wrong pin.

### 7. Registered variables between B2 and this step

Rubric sha, evaluator version, benchmark sha and model id are unmoved (above). The runtime moved
`2.1.260 → 2.1.261` **between** batches, disclosed as the fifth harness move and re-probed on
`fee79c79` (`verdict=match`, exit 0) before batch 2. The launch moved (`--agent` on the treatment
arm; `--output-format stream-json --verbose` on both) — disclosed with the reason the format
change had to land on both arms. The two batches share one experiment key — disclosed as a
process violation; I confirmed the two separations are clean: versions are disjoint and the time
windows do not overlap.

### 8. Keep / remove — not reached (step 12)

---

## Corrections for the builder to apply additively at the next phase boundary

**C1. The "36 observations, 16 of 16 / 20 of 20" figure does not add up to its own table.**
E-006's row-0a table sums to **45** rows (3+3+3+3+3+3+10+17), or 42 without the no-key control.
Re-derived from all 21 probe transcripts and the 27 E-005 tool-list transcripts:

| declared list | delivered | n |
|---|---|---|
| contains `Bash` **and** at least one of `Grep`/`Glob` (candidate 3, greponly 3, globonly 3, E-005 F 10) | exactly those dropped | **19 of 19** |
| contains `Bash`, neither `Grep` nor `Glob` (verbatim cell 3) | verbatim | 3 of 3 |
| no `Bash` (nobash 3, E-005 T 17) | verbatim | **20 of 20** |
| no `tools:` key (control 3) | full 29-tool set | 3 of 3 |

The rule holds with no exception; the headline numbers are wrong. "16 of 16" appears in **five
places**: `E-006`, `TRACK-B-STATE.md`, `agent-observatory/runner/run-agent.sh`,
`runner/lib/check-init-schema.sh`, and **the overlay file itself**, which is the treatment at
sha `59c2b5db…` and must not be edited until the stop closes. Correct the other four
additively and record in E-006 that the overlay's own sentence carries the arithmetic error.

**C2. "Every 2-file passing run is a run that wrote no test file" is false, and the "the agent
MUST add an `ErrorCode` constant" mechanism under P1, P2, the README and the `blocked_on_author`
"biggest one" item is refuted by data already on disk.** *"11 of 88 passing BE-003 runs changed
2 files"* re-derives exactly at the pre-batch-1 cutoff. But of those 11, only **5** are haiku
runs that skipped the test (4 `EXP-B3-INSTRUCTIONS-CLAUDE`, plus step-5 control `15c14398`).
The other **6 are codex runs that wrote `ShipmentControllerTest.kt` and never touched
`ApiError.kt`**: `def66388`, `b576dd0d`, `34a01f57`, `77c7d1c3` (`EXP-B2-BASELINE-CODEX`),
`38e6a3df` (`EXP-CODEX-TOKENS`), `514b094e` (`EXP-B2-REHEARSAL-CODEX`) — each at
`acceptanceCriteriaPassed` **7 of 7**, criterion 4 and the 409 included. The task does not
mandate a new constant; the haiku population chooses to add one. And **one of the six was
scored: `514b094e`, codex sheet `20260830T195150Z`, `change-focus: 2`**, reason *"create,
getById, and list match the baseline; only confirm was added."* **Anchor 2 has been reached on
BE-003.** Consequences, none of which touch a registered prediction: (a) P2's *mechanism* is
wrong while its magnitude — 1 on 10 of 10 haiku runs — will very likely still hold; (b) the
`blocked_on_author` item hands the author the wrong question: not *"the anchor is unreachable by
construction"* but *"the anchor discriminates on a behaviour the model under test does not
show"*; (c) the MDE amendment's *"the gap between them is a test, not focus"* is true of 5 of 11
and the opposite of true for the other 6, where the gap is `ApiError.kt` — which is focus. Same
query the builder ran, one more column (`runtime.product`).

**C3. Two wording faults in the delivery rows.** *"`run-agent.sh:431` hashes
`.github/copilot-instructions.md`"* — the hash is at `:524–526`; `:431` is the `SKILL.md` find.
*"the first 32 hex characters of the digest, which is what the runner stores"* — the runner
stores nothing for a Claude agent overlay (the same row says so two lines later); the 32 hex
characters are what the reader computes with `shasum`.

**C4.** `model:` pin `L2 → L3`, with the observation (haiku on 40 of 40) kept as the evidence.

**C5.** *"machine idle sleep … 2 of the 5 gate-passing runs span one"* — by the run records
**one** does: `32ad6715` (08:54:34–08:59:49Z) spans the 08:55:03Z sleep and 08:57:24Z wake.
`500ba451` finished at 08:41:48Z, ten seconds before the first sleep. Immaterial to the verdict
(batch 1 is aborted) and wrong as a count.

---

## Data re-derived from the API, for the builder to check step 8–11 against

Not results. Not scored. Concurrent arms of batch 2 only, `n = 10` each. Quartiles are medians
of the lower and upper halves.

| outcome | treatment (min / Q1 / med / Q3 / max) | control | registered MDE | reading |
|---|---|---|---|---|
| `behavior.toolCalls` | 22 / 23 / **27** / 31 / 35 | 14 / 17 / **19.5** / 22 / 22 | ≥ +5 on the median, non-overlapping quartiles | **+7.5, Q1(T) 23 > Q3(C) 22** — clears the MDE against the concurrent control; +10 against B2's stored 17. P5, registered most likely to be wrong, points the right way |
| `efficiency.estimatedCost` | 0.125 / 0.130 / **0.144** / 0.164 / 0.203 | 0.115 / 0.139 / **0.153** / 0.175 / 0.192 | ≥ +25 % | −6 %, inside the MDE and opposite to P4's direction: NOT DETECTABLE |
| `efficiency.durationMs` | 86 / 117 / **124** / 143 / 152 s | 68 / 85 / **95.5** / 102 / 116 s | ≥ +40 % and no sleep | +30 %, inside the MDE; no sleep in the window |
| wrote a test file (P6) | 10 of 10 | 9 of 10 | ≥ 5/10 vs 0/10 | NOT DETECTABLE, as P6 said it would be |
| 4th file (row 1) | 0 of 10 | 0 of 10 | ≥ 5 of 10 | does not fire |
| pass rate (row 3) | 10 of 10 | 10 of 10 | lower in treatment | does not fire |

If these survive the builder's own derivation, the decision rule lands on row 5 as registered,
with one outcome — tool calls — outside its MDE in the predicted direction.

---

## The single finding most likely to overturn the track's result if pursued

**C2.** The item this stop hands the author with the largest consequence — *fifteen rubric
points are a constant by construction on BE-003* — rests on a mechanism that six passing runs
and one scored sheet on disk contradict. The anchor is reachable; the model under test does not
reach it. Pursued, that turns a rubric-repair question into a behavioural finding about
`claude-haiku-4-5-20251001` on this task, which is a different author decision and a cheaper
one. Pass 11's standing item — B3's instruction file has never been *observed* reaching the
runtime — is unchanged and still owed; the builder correctly routed it to `blocked_on_author`
rather than into stop 10's batch.
