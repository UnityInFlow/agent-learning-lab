# Track B validation — 2026-09-06 (pass 16)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 16, 2026-09-06, fresh session started by
the author with the one-word sentence "verify". Section 9 only.`

**Declared dependency.** §9 says to run the validator on a different model from the builder.
Stop 11's provenance lines name **two** builders: steps 1–3 (extract, design, the E-007
predictions at `c21781b`) are signed `Claude Fable 5.1` and steps 4–14 are signed
`Claude Opus 5` (E-007 lines 176, 353, 796, 896, 948, 954, 1282; workbook line 414). This
validator is Fable, so it shares a model with the session that wrote the registration it is
checking. Compensation, as passes 14 and 15 did: every number below is re-derived from raw
artifacts — the API records, `events.jsonl`, the batch logs, the sheets, the kept worktrees, git
— with parsers written in this session, never read off the workbook's or E-007's prose; and the
stop's own verifiers were executed rather than trusted to exist. Where a check could not be made
independent of the registration's own choices, that is said in the row.

**Read-only.** Nothing outside this file was created, edited, deleted, started or stopped.
Commands run: `git fetch` / `log` / `show` / `diff` / `merge-base`; `curl` against the SSH tunnel
at `127.0.0.1:18081`; `gh pr view`, `gh issue view`, `gh api …/timeline`, `gh project item-list`;
`jq`, `python3` over on-disk files; and one run each of `verify-run-e007.sh`,
`verify-run-e007-p2.sh`, `verify-schema-verdict-policy.sh`, `verify-init-schema-check.sh`,
`crossvalidate-f1.py`, `read-p2.py`, `collect-sheets.py`, `check-run-gate.sh` (×20),
`check-board-freshness.sh` and `check-links.sh`. All are re-derivation or fixture scripts; the two
`verify-run-*.sh` files build a throwaway tree and assert afterwards that the registered overlay's
hashes are unchanged (`4f2af4ba7f740c33 / 6096f5ea35383112` and `1b259ccc09066cad /
6096f5ea35383112`, both printed `ok overlay unchanged`).

**Scope.** Stop 11 closed at `21:08:45+02:00` today (lab#64 → `c085508`, then lab#65 →
`58154f7`). Passes 14 and 15 audited it while it was OPEN, through step 8; **this is the first
§9 pass over the closure** — steps 9 to 14, the P2 deliberate failure, the `test-quality` claim,
the §5 table, the §4a round and the merge. Stops 4–10: not re-audited row by row;
`git diff --stat 6e9b189 origin/main` (the stop 10 merge to today's main) over every closed-stop
path — `experiments/E-001…E-006`, `phases/0[0-3]*`, `phases/04a*`, `phases/b0[1-4]*`,
`evidence/b0*`, `evidence/p03*`, `evidence/p04a*` — is **empty**, so nothing stop 11 merged
touched a closed stop and their verdicts stand structurally.

**What §9 says to read first does not exist.** `findings/track-b-<date>.md` for today was not
written: the newest is `track-b-2026-09-05.md`, last committed `aa55c23` on 2026-09-05, one row
(stop 10), no stop 11 row. The stop 11 row lives in the closing comment on lab#14
(`2026-09-06T19:09:14Z`) and in `TRACK-B-STATE.md`'s position table (line 251). See correction 2.

---

## Stop 11 (Phase 4B, orchestration) — the closure, checked from git and GitHub

| Check | Command | Result |
|---|---|---|
| lab#64 is a merge commit and on main | `git log -1 --format=%p c085508`; `git merge-base --is-ancestor c085508 origin/main` | parents `6e9b189 35eee6e` — two-parent merge, not squash; ancestor **true** |
| lab#65 likewise | same on `58154f7` | parents `c085508 58e13a7`; ancestor **true**; `origin/main` **is** `58154f7` |
| the three prediction commits reachable from main | `merge-base --is-ancestor` on `c21781b`, `a4c219a`, `eab540e` | all three **true** |
| PR states | `gh pr view 64/65 --json state,mergedAt,mergeCommit` | both `MERGED`, `19:08:46Z` / `19:12:11Z`, merge commits `c085508` / `58154f7` |
| CI on lab#64 | `gh pr view 64 --json statusCheckRollup` | **8 of 8 `SUCCESS`**, including *a published board does not outlive its source* |
| boards | `./tools/check-board-freshness.sh` | `2 board(s) current at 0bc526aa09d3`, both built from `a57fd9b`, exit 0 |
| project card | `gh project item-list 2 --owner UnityInFlow` | `Done \| Phase 4B — Agent orchestration and multi-layer design` |
| **lab#14** | `gh issue view 14 --json state,closedAt`; `gh api …/issues/14/timeline` | **`CLOSED` at `2026-09-06T19:09:31Z`**, by hand (no commit on the close event), 17 s after the closing comment. **See correction 1** |

## §9 items, stop 11

### 1. Every gate clause maps to evidence that opens — CONFIRMED

Every path, sha and run id cited in the workbook's §5 table (lines 696–716) was opened:
`experiments/E-007-orchestration-overhead.md`; `phases/04b-orchestration/README.md`;
`build/customizations/orchestration-4b4-P{1,2}/.claude/agents/{orchestrator,implementer}.md`
(hashes re-derived: `4f2af4ba7f740c33`, `6096f5ea35383112`, `1b259ccc09066cad`,
`6096f5ea35383112`; `diff` between the two orchestrators is exactly the one line
`tools: Read, Grep, Glob, Task`); `evidence/p04b/lab-4b4/batch-20260906T080905Z/{manifest.tsv,
window.txt, step7/collect-sheets.py, step7/scores.txt, step8/per-arm.py, step8/per-arm.txt}`;
`p2-batch-20260906T181047Z/{manifest.tsv, window.txt, analysis/read-p2.py,
analysis/crossvalidate-f1.py}`; `batch-20260906T080032Z/manifest.tsv` (the preflight pair);
`probe-20260906T050917Z/`; `order-probe-20260906T125134Z/`; `init-schema/` (32 files: 20 + 2 + 10);
`hand-score-207ff23d.md`; `run-e007.sh`, `verify-run-e007.sh`, `run-e007-p2.sh`,
`verify-run-e007-p2.sh`, `init-schema-probe.sh`, `order-probe.sh`; the 20 codex sheets
`findings/codex/score-observatory-run-<id>-20260906T1[23]*.yaml`; the opencode stall sheet
`…207ff23d…-20260906T130110Z.yaml` (1.3 kB, header only, as described); the §4a review file
`findings/opencode/review-E-007-orchestration-overhead-20260906T184803Z.md` (38 170 bytes); all
**30** kept worktrees `$TMPDIR/observatory-run-<id>` (20 main + 10 P2); `SOURCES.md` carries all
six source URLs; `./tools/check-links.sh phases/04b-orchestration/README.md` → `ok=8 moved=0
blocked=0 unverified=0 broken=0`. **No cited path failed to open.**

The API rows resolve where the table says and nowhere else: `curl 127.0.0.1:18081/api/runs?limit=500`
→ HTTP 200, **335** records (325 at pass 15 plus this stop's 10 P2 runs), 20 on
`EXP-4B-ORCH-OVERHEAD`, 10 on `EXP-4B-ORCH-DELIB`, 2 on `EXP-4B-ORCH-PREFLIGHT`. The tunnel is
`ssh` pid 9688, still `LISTEN` on `127.0.0.1:18081`.

### 2. Prediction commits precede the first run — CONFIRMED, all three, from git and the records

| Prediction | committed (UTC) | first `startedAt` on its key (API) | margin |
|---|---|---|---|
| `c21781b` (E-007 O1–O7) | `2026-09-06T05:14:31Z` | `EXP-4B-ORCH-PREFLIGHT` `075857fe` **08:00:33Z**; `EXP-4B-ORCH-OVERHEAD` `207ff23d` **08:09:06Z** | 2 h 46 m / 2 h 54 m 35 s |
| `a4c219a` (order probe) | `12:51:27Z` | probe directory `order-probe-20260906T125134Z` | 7 s (pass 15 checked the file mtimes; not repeated) |
| `eab540e` (F1–F4, P2) | `18:08:51Z` | `EXP-4B-ORCH-DELIB` `eac5b2b1` **18:10:49Z** | **1 m 58 s** — and the driver itself was committed at `7df35f9` `18:10:42Z`, 7 s before the first run |

E-007 says 1 m 57 s against the window file's `18:10:48Z`; the record's `startedAt` is one second
later. Immaterial. **The registered text was not edited after registration:** extracting
`## Predictions` through `## Deliberate failure` from `c21781b` and from `origin/main` and
dropping the two appended `> ` quote blocks leaves the two extracts **identical** apart from the
blank lines those blocks introduced. Every later change to E-007 is either an addition or the
removal of an `*(after the run)*` placeholder (`git diff 53d2aa0 origin/main` deleted lines: the
`Status:` line, seven placeholder lines, the empty `## Decision` heading — nothing else).

### 3. One scored cell per step re-derived from the kept worktree and the rubric — CONFIRMED

The rubric is `benchmark/rubrics/backend-quality.yaml`, `shasum -a 256 | cut -c1-12` =
**`396e1799eb2b`**, unchanged since `0be66e7` (2026-09-01). All 20 sheets carry that sha (my
parser: `{'396e1799eb2b': 20}`), zero `null` cells, earliest `20260906T125910Z`, latest
`130853Z`; `hand-score-207ff23d.md` committed `cd715e6` at `12:58:11Z` — **59 s** before the
first sheet, as claimed.

Pass 15 re-derived `207ff23d`'s `maintainability` and `architecture-consistency`. I took the
**contested** dimension instead — `test-quality`, the one the §4a round found had moved — and
re-read one cell per arm off the worktree's test-file diff against the rubric's three anchor-2
clauses (`anchors.2`: second call's **body** asserted; state **re-read through a separate
`get(...)`**; a refusal asserting **`$.error.code`**):

| run | arm | second-call body | separate `get` re-read | `$.error.code` | **hand** | sheet |
|---|---|---|---|---|---|---|
| `1f806f3d` | O | `confirming an already confirmed shipment…` asserts `shipmentId` and `status` on the 2nd call; `repeated confirm calls…` on the 2nd and 3rd | `persists the confirmed status…` does `get("/shipments/S-5")` and asserts `status` | `SHIPMENT_CANCELLED` (409), `SHIPMENT_NOT_FOUND` (404) | **2** | 2 ✓ |
| `a2a7cdb1` | C | `confirms an already confirmed shipment…` asserts `status` on the 2nd call | **no `get(` anywhere in the diff** | both codes asserted | **1** (residual: one clause absent) | 1 ✓, reason *"persisted state is never re-read"* |

Both hand readings agree with the sheets, for the sheet's stated reason. **And the reason is the
same on every anchor-1 sheet in the batch:** all 15 `test-quality = 1` sheets (5 arm O, 10 arm C)
name *persisted state never re-read* as the missing clause and nothing else; all 5 anchor-2
sheets are arm O. **The entire `test-quality` difference is one rubric clause — whether a test
re-reads state through a separate GET.** Fisher two-sided on 5/10 vs 0/10, computed here:
**`p = 0.0325`**, matching E-007's `0.0325`. `maintainability` 4/10 vs 5/10: `p = 1.0`.

### 4. Treatment reached arm O and not arm C; P2 and not its control — CONFIRMED from three sources

- **`init` read-back, joined to the manifest** (the corrected command from the §5 table, run
  here): main batch **`10 O order-differs delivered n=4`** / **`10 control recorded-only n=29`**;
  P2 batch **5 / 5 both `recorded-only n=29`** (F4 by design). The control's 29 includes `Task`
  (checked on `a2a7cdb1`'s record), so arm C's zero delegations are behaviour, not capability.
- **The kept worktrees**: all 10 arm-O worktrees carry `.claude/agents/orchestrator.md` at
  `4f2af4ba7f740c33` and `implementer.md` at `6096f5ea35383112`; all 10 controls have no
  `.claude/agents` and a single `initial commit`. All 5 P2 worktrees carry the orchestrator at
  **`1b259ccc09066cad`** with setup commit *install customization for variant
  'orchestration-4b4-P2'*; all 5 P2 controls have none. **This is the only thing that separates
  the two P2 arms** — their `init` records are identical by design — and the §5 table does not
  cite it. Worktrees are reaped by macOS; the batch logs (`0N-O.log`, which carry the
  `--customization` path and the stream) are the durable copy. Observation, not a failing row.
- **`customization.*Hash`** is `{instructionsHash, skillsHash, agentHash, hooksHash, mcpHash}` all
  `null` on **20 of 20** main-batch records, arm O included — exactly as E-007 registered.
  `instructionsHash` is `null` on both arms, so it discriminates nothing here, and no row claims
  it does.
- **Telemetry** (my own parser over `events.jsonl`, 1 113 lines, joined by
  `observatory.run.id` to the 30 manifest ids): `tool_result` with `tool_name ∈ {Task, Agent}` —
  arm O **1 on 9 runs, 2 on `beae5092`**; arm C **0 on 10**; `subagent_completed` gives the same
  counts. The 10 P2-batch ids have **zero events of any kind** — the gRPC loss E-007 discloses,
  scoped exactly as it says. Arm O's stream carries `Edit` ×35 and `Bash` ×50 under run ids
  whose parent pool has neither, which is the worker counted under the parent (threat 3, answered).

### 5. Claims from `n < 5` stated as properties — two to quote, neither a failing row

- Workbook line 190–193: *"on **3 of 3** the worker subagent made a `Write` call … **The worker
  inherited the conversation's pool, not the main agent's narrowed list** … So a structural split
  *is* available."* — a runtime property from `n = 3`. It is **also true at `n = 10`** (the 35
  `Edit` events above, under parents delivered `n=4` without `Edit`), and the sentence should say
  so rather than rest on the probe.
- E-007 line 369–370: *"the split is not random — it reproduced 2 of 2 in every cell."* — *not a
  constant* is an existence proof and stands on any `n`; *not random* is a claim about
  reproducibility drawn from `n = 2` per cell and should carry that `n`.
- Everything about the P2 batch (`n = 5`) is written with its `n`, including the one-sentence
  version at E-007 line 1129 and the decision-table row that keeps the procedure body. F2's
  *"0 of 5 refutes nothing"* was written before the run and is quoted, not composed, afterwards.

### 6. Proof-layer labels — one row rounded up; the rest apply the rule in order

- **§5 row *"One scored cell re-read by hand"*: `L2 for the ordering (two independent recorded
  timestamps)` is L3.** Git writes a commit time, `codex-score.sh` writes a filename timestamp,
  and a **human compares them**; nothing executes to reject a sheet that predates the hand commit.
  The row directly above it (*"The prediction preceded the first run"*) applies the rule correctly
  and says L3 for the same shape. This is the correction pass 3 made at stop 8 (its item c),
  which pass 3 noted had already recurred from the first pass's B2 correction. **Third recurrence.**
  Correction 4.
- Executed, not read: `verify-run-e007.sh` **12 of 12**; `verify-run-e007-p2.sh` **12 of 12**;
  `verify-schema-verdict-policy.sh` **16 of 16**; `verify-init-schema-check.sh` **17 of 17**;
  `check-run-gate.sh` on all 20 main worktrees → **20 ok, 0 refused, 0 missing**;
  `crossvalidate-f1.py` → *agree on 20 of 20, count for count*, exit 0; `read-p2.py` → F1 `5 of 5`
  (exactly one `Agent` each), F2 `0 of 5`, controls `Edit` 4/5/3/3/3 with F1 0/5; `collect-sheets.py`
  reproduces the score rows exactly. Every L2 claim in the §5 table that names one of these was
  confirmed by running it.
- The `1,000 agents per run` cap (workbook line 594–599): the §4a round corrected L1 → L2 by the
  rule in order. Correct: a 1 001st spawn can still be written down; something executes and
  rejects it.
- `model:` pins L3 — correct, nothing rejects a wrong one. Scope note: the decision table
  (E-007 line 1257) says *"on 30 of 30 runs across both batches"*; the run record witnesses only
  the **main session's** model. The worker's pin is observed in the stream logs instead — every
  `"model"` value in all ten `0N-O.log` files is `claude-haiku-4-5-20251001` (45–64 occurrences
  per log, one value) — so the claim holds, from a source the row does not name.

### 7. Registered variables unmoved from E-006 batch 2 — CONFIRMED, with the one disclosed exception

From the API, one value each across all 20 `EXP-4B-ORCH-OVERHEAD` records **and** all 10
`EXP-4B-ORCH-DELIB` records: `runtime.model` `claude-haiku-4-5-20251001`; `runtime.version`
`2.1.263 (Claude Code)`; `repository.commitSha` `04486433f3d5…`; `evaluation.evaluatorVersion`
`1.0.0`; `evaluation.exitCode` 0 with `acceptanceCriteriaPassed 7/7` on 30 of 30. Rubric
`396e1799eb2b` on 20 of 20 sheets. E-006 batch 2 ran on **2.1.261** (pass 14 confirmed);
E-007's `§ Controlled variables` registered the version as held equal and it was not — disclosed
before the batch (E-007 § *Second finding*) and again in § Sanity checks after the §4a round. The
within-batch O-vs-C comparison is on one binary; see correction 7 for where the §5 table still
states the false clause.

Numbers, re-derived from the records rather than the tables (`n = 10` per arm):

| metric | arm O median (q1–q3) | arm C median (q1–q3) | Δ | E-007 says |
|---|---|---|---|---|
| `estimatedCost` | 0.12658 (0.1159–0.1321) | 0.14619 (0.1307–0.1489) | **−13.4 %** | −13.4 % ✓ |
| `durationMs` | 118 000 (102–130 k) | 88 000 (71–99 k) | **+34.1 %** | +34.1 % ✓ |
| `behavior.toolCalls` | 21 (19–23) | 18 (16–18) | **+3** | +3, quartiles 19–23 vs 16–18 ✓ |
| `behavior.modelCalls` | 26 (24–27) | 22 (19–22) | **+4** | +4, 24–27 vs 19–22 ✓ |
| telemetry `tool_result` / `api_request` per run | identical to `toolCalls` / `modelCalls` on 20 of 20 | | | ✓ |
| `result.addedLines` | **90** (68–106) | **64** (56–72) | **+26** | **not reported** — correction 6 |
| `changedFiles` | 3 on 10 of 10 | 3 on 10 of 10 | | not reported — correction 6 |

P2 batch: `estimatedCost`, `inputTokens`, `cachedTokens`, `toolCalls`, `modelCalls`, `traceId`
**`null` on 10 of 10**; `durationMs` present (P2 99–153 s, control 81–130 s). Exactly the loss
E-007 scopes.

### 8. Keep / remove — every keep has a measured effect on record or is flagged as a judgement

- Procedure body (L3): KEEP on **5/5 vs 0/5, `p = 0.0079`** — measured (re-derived: `read-p2.py`
  F1 column and my Fisher). ✓
- `tools:` line (L2): KEEP **against the default rule**, with the no-effect on record (**5/5
  without vs 10/10 with, `p = 1.0`**, re-derived) and the departure flagged as the author's to
  reverse. The reasoning — a boundary's value lives in the tail and five clean runs sample no
  tail — is the same reasoning stop 9 used to keep the description arm at L3. Consistent. ✓
- Nothing promoted; the overlay unedited since `c21781b` (`git log -- build/customizations/orchestration-4b4-P*`
  shows one commit). ✓
- Not removed and not measured: the implementer's four-line body — disclosed as *not separable in
  this design*, which is threat 1 of the registration. ✓ (and see the closing finding.)

---

## Verdict — stop 11: **CONFIRMED WITH CORRECTIONS**

No gate row fails. Every cited artifact opens; the three predictions precede their runs by
timestamps read from git and the records; every registered number reproduces from the API, the
telemetry, the sheets and the worktrees; the treatment's delivery is separated by the `init`
record, the worktrees and the telemetry, as the registration said it would have to be; the
registered text at `c21781b` is unedited on `main`; the closure is a two-parent merge on
`origin/main` with 8 of 8 checks green. The corrections are to the record around the result, and
two of them are process rules this run has already been corrected on once.

1. **lab#14 was closed on GitHub and every document of this stop says it stays open.** Issue 14
   is `CLOSED` at `2026-09-06T19:09:31Z`, by hand, 17 s after the closing comment. §4 step 14:
   *"A Phase issue stays open if any of its labs is deferred, and the comment names which."* Labs
   4B.1, 4B.2 and 4B.3 are deferred, and *"lab#14 stays OPEN"* is written in the PR body (line
   73), `HANDOFF.md` (line 23), `TRACK-B-STATE.md` (line 11), E-007 (line 1293) and the workbook
   (line 523). **Pass 10 raised exactly this for lab#5 and lab#6 and both were reopened**; the
   same failure recurred two stops later. **Reopen lab#14 with a comment naming the three unrun
   labs.** Applying the convention, not changing one — §0 says fix it.
2. **The halt's paperwork is missing.** `status: blocked` is a §7 halt (stop 12 waits on
   benchmarks#29, still `OPEN`). §5: *"At the end of the track, or at a halt, write
   `findings/track-b-<date>.md` … That file is what the validator in §9 reads first."* There is no
   `track-b-2026-09-06.md`, and `HANDOFF.md`'s *What is BLOCKED ON YOU* has no item for the
   benchmarks#29 halt — it is named only in § Position (line 21). Write the file with the stop 11
   row (it already exists verbatim in the lab#14 comment and the state file's position table) and
   add the halt item.
3. **Three stale summary headers on closed artifacts** — the shape of pass 13's correction 13.2,
   *the summary a reader hits first claiming less than the detail beneath it*:
   - E-007 lines 5–7, `**Status:**`, still reads *"O7 BLOCKED and the exit gate with it — the
     observatory database was destroyed before scoring"* on a file whose § Results says
     `NOT DETECTABLE`, O7 = 4 of 10, and whose § *The database loss* is retracted in full.
   - Workbook line 4, `**Status:** 🟨 open — spine stop 11, §4 step 1`, on the workbook of a
     closed stop.
   - Workspace `ai-learning/CLAUDE.md` line 37: *"Currently at **position 10 (B4 — agent
     boundary), OPEN**"* — two stops stale; pass 10's item 9.5a corrected the same line when it
     read *position 8*.
4. **§5 row *"One scored cell re-read by hand"*: relabel the ordering `L2` → `L3`** (item 6
   above). Third recurrence of the timestamp-comparison correction.
5. **The refuted *"`change-focus` = 1 on 70 of 70 scored runs — a dead category"* wording
   re-entered two registered documents** at `c21781b` — E-007 line 45 (the report-only row of the
   prediction table) and workbook line 359 — on 2026-09-06, the day after pass 13's 13.1 amended
   it in three places. Both the count and the word are wrong: E-006 §C2 has **73 of 73** on this
   model and one `change-focus = 2` (`514b094e`, a codex arm), so the category is dead *on this
   model*, not in itself. E-007's own failure analysis (line 1204) already carries *73 runs*, so
   the file disagrees with itself between its registered row and its results. The registered
   text cannot be edited; **an additive note beside each, pointing at E-006 §C2**, is the fix.
6. **The report-only items were registered and not reported.** E-007 line 45 makes
   `changedFiles`, `addedLines` and `change-focus` *"report only"*; `change-focus` is reported
   (1 on 20 of 20), the other two appear nowhere for the main batch. From the records:
   `addedLines` arm O **median 90 (68–106)** vs arm C **64 (56–72)**, `changedFiles` **3 on 20 of
   20**. Worth reporting for its own sake and because the extra lines are test code — `1f806f3d`
   adds 78 test lines where `a2a7cdb1` adds 43 — which is where `test-quality` moved. *True of
   these runs.*
7. **§5 row *"No registered variable moved between E-006 batch 2 and this batch"* still states the
   clause the §4a round found false** (finding 3, 2/2: Claude Code `2.1.261 → 2.1.263`). The
   round's table says it was *"corrected in E-007's sanity checks and the §5 table"*; the sanity
   check carries the correction, the §5 row's clause and layer cell do not — the evidence cell
   lists `2.1.263` without saying it moved. Add the exception to the row.
8. **E-007 line 1156: *"Four of seven held"*** counts O7 as held while the table two lines below
   says O7 *"missed its band by one"*. On the letter, 3 of 7 held (O1, O5, O6), one refuted (O2),
   two below threshold (O3, O4), one missed its band inside its MDE (O7). The table is right; the
   sentence rounds up.

**Processing of passes 14 and 15, verified applied and additive.** Pass 15 item 1 → E-007 §
*The database loss* opens with a `RETRACTED IN FULL` block, false text kept beneath; HANDOFF item
00 retracted in place, item 00b added. Pass 15 item 3 → § *O7, measured*, reading written before
the number, rule completed. Pass 14's closing finding → order probe registered at `a4c219a`,
run, prediction refuted and kept refuted, two sentences of the first amendment corrected in
place with the originals quoted. Pass 14 (e) extended: no registered line altered through
`origin/main`. All present.

---

## The single finding most likely to overturn the track's result if pursued

**The only return this stop detected sits on one rubric clause and may belong to the element the
design could not isolate.** `test-quality` anchor 2 on **5 of 10 vs 0 of 10 (`p = 0.033`)**
reduces, on every one of the 20 sheets, to a single question — *did a test re-read the persisted
state through a separate `get(...)`* — and arm O added a median **26 more lines**, mostly tests.
E-007's registered threat 1 says the treatment is *"the split including"* the implementer's
four-line body, which tells the worker to write *"tests for every case it names"* and is *"prose
the control does not have"*; P2 kept that body and P1's `tools:` line was shown to move nothing.
So the one thing that moved may be **the worker's prose, not the decomposition** — which is
E-003's result (a prose instruction) wearing E-007's treatment. If a fourth cell (plain baseline
**plus** the implementer's four lines as its own instruction, no split, `n = 10`) reproduces 5 of
10, then stop 11's *"decomposition returned nothing the gate can see"* is true and its one
detected effect is not about orchestration at all; if it does not, `test-quality` is a real return
from the split and the verdict under reading B — *no row fires* — is the honest one, which would
make E-007 the first experiment in the track to have measured a benefit and registered no way to
say so. Either way the answer decides what stop 12 registers on BE-004, and it is a new arm, so
it is the author's under §7.
