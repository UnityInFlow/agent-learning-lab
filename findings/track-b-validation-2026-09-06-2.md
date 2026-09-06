Validator: Claude Sonnet 5 (claude-sonnet-5), pass 15, 2026-09-06, run as a subagent from a
Claude Fable 5.1 session that built stop 11 steps 1-3; stop 11 steps 4-8 were built by Opus 5.

Scope: stop 11 only (workbook `phases/04b-orchestration/README.md`, experiment
`experiments/E-007-orchestration-overhead.md`, evidence under
`agent-learning-lab/evidence/p04b/lab-4b4/`, commits `a4c219a..8d43a10` on branch
`stop11/phase-4b-orchestration`). Stop 11 is OPEN and halted — no closure verdict is given.
Stops 4-10 are not re-validated; pass 14 (`findings/track-b-validation-2026-09-06.md`) already
CONFIRMED stop 10 and confirmed six scoped findings on stop 11 through step 6, and the state
file's `validation_processed` shows the builder processed it.

All commands below were read-only: `curl`, `docker ps` / `docker volume inspect` / `docker
--context colima exec ... wget` (a query against an already-running container, not a state
change), `jq`, `python3` parsing on-disk files, `git log`/`git show`/`git diff`, and one
re-run each of `collect-sheets.py` and `tools/check-run-gate.sh` (both re-derivation scripts,
neither of which mutates evidence). Nothing was created, deleted, started, or stopped.

---

## 1. The halt claim — NOT SUPPORTED (the claim is false, not merely unverifiable)

The state file (`TRACK-B-STATE.md:7,68-75`) and `HANDOFF.md` item 00 (lines 430-495) say the
observatory database is empty — "GET /api/runs returns 0 runs" against "roughly 250" — and
frame this as data loss that was "not caused by this session," citing three things: the `make
smoke` preflight failing before any docker command, images having to be re-pulled, and
`docker volume inspect agent-observatory_postgres-data` showing `created=2026-09-06T13:08:24Z`.

All three of those specific facts check out: `docker volume inspect
agent-observatory_postgres-data` in the **default/desktop-linux** docker context does say
`CreatedAt: 2026-09-06T13:08:24Z`, and `curl http://localhost:8081/api/runs` returns `000`
(connection failure) right now, exactly as claimed.

**But the conclusion drawn from those facts — that the database is gone — is false.** The
project runs its stack in the **colima** docker context (a fact the builder itself recorded
earlier the same session, in `TRACK-B-STATE.md:22`: *"the stack runs in the COLIMA context
(`docker --context colima ps`)"*). In that context, right now:

- `agent-observatory-postgres-1` has been running continuously since `2026-08-24T20:20:30Z`
  (`docker --context colima inspect ... .State.StartedAt`), mounting a volume named
  `agent-observatory_postgres-data` created **`2026-08-08T14:20:14Z`** — never touched.
- `agent-observatory-observatory-api-1` has been running continuously since
  `2026-08-29T19:56:12Z`.
- Querying it directly (`docker --context colima exec agent-observatory-observatory-api-1
  wget -qO- http://localhost:8080/api/runs?limit=500`) returns **325 run records**, including
  `EXP-4B-ORCH-OVERHEAD` (20 of them — exactly this batch, arm O and arm C both present by
  run id, e.g. `c7e4d207` and `207ff23d`) and every experiment key back through
  `EXP-B2-BASELINE-CLAUDE`.
- The SSH tunnel this same session set up earlier (`TRACK-B-STATE.md:22`, `ssh -F
  ~/.lima/colima/ssh.config -L 18081:127.0.0.1:8081 -N -f lima-colima`) **is still alive right
  now** (`ssh` pid 9688, listening on `127.0.0.1:18081` per `lsof`) and **still serves the
  full 325-run database** — `curl http://127.0.0.1:18081/api/runs?limit=500` returns 200 and
  325 records.

The "new," genuinely empty stack (volume created `2026-09-06T13:08:24Z`, containers "About an
hour old") lives in the **default/desktop-linux** context on ports 8091/5435. Its
`com.docker.compose.replace:postgres-1` label shows it was created by a `docker
compose`/`make up` invocation that ran against the wrong docker context — one where no prior
`agent-observatory` containers existed — so compose built a fresh, disjoint stack rather than
reconnecting to the real one. The original stack was never stopped, restarted, or wiped; it
was simply not the stack the later commands were pointed at.

So: "not caused by this session" is moot, because **no data loss occurred at all.** What the
session's own artifacts show is that it successfully read the live database through its own
tunnel as recently as the sheet timestamped `20260906T130853Z` (see item 3), then in a later
step queried a different, newly-created, empty stack and reported that as "the" database.
**Older volume/backup check:** no separate backup mechanism exists anywhere in
`agent-observatory/` (`Makefile`, `infra/`) — grepped for `backup`/`pg_dump`/`dump\.`, nothing
relevant. None is needed: the original, never-wiped volume is itself still live and
queryable, via the tunnel already open in this same session.

## 2. The order probe — CONFIRMED

- Prediction commit `a4c219a` at `2026-09-06T12:51:27Z` (`14:51:27+02:00`). Probe output
  directory `evidence/p04b/lab-4b4/order-probe-20260906T125134Z/` — name and file mtimes both
  `12:51-12:52Z`, i.e. **7 seconds to under 2 minutes after** the prediction commit. Prediction
  precedes the run.
- Raw `.schema.txt` outputs (`A-1.schema.txt` … `D-2.schema.txt`) and `summary.tsv` agree
  exactly: four declared orders (A/B/C/D), 2 reps each, produce **two distinct delivered
  arrays** — A and D deliver `["Read","Task","Grep","Glob"]` (D matches its own declaration,
  verdict `match`), B and C deliver `["Task","Read","Glob","Grep"]` (verdict `order-differs`
  for A/B/C). Reproducible 2 of 2 in every cell.
- `experiments/E-007-orchestration-overhead.md` § "Amendment 2026-09-06, second" reproduces
  this table cell for cell and states the prediction was refuted ("Two distinct arrays came
  back. It is refuted and it stays on the record as refuted.") — text matches raw output
  exactly, and the original prediction text is corrected in place with the wrong sentences
  quoted and struck through, not silently edited. The prediction commit itself (`a4c219a`) is
  unedited; only the workbook's later prose is amended, additively, which is what the project's
  own convention (§6) requires.

## 3. Step 7 — CONFIRMED WITH CORRECTIONS (the state file's own "BLOCKED" framing is wrong)

- `evidence/p04b/lab-4b4/hand-score-207ff23d.md` was committed at `cd715e6`,
  `2026-09-06T12:58:11Z`. The earliest codex sheet for this batch
  (`score-observatory-run-207ff23d-...-20260906T125910Z.yaml`) is timestamped `12:59:10Z` —
  **59 seconds after** the hand commit. Ordering holds: hand re-read before any sheet existed.
- Hand cell vs. sheet cell for `207ff23d`: hand says `architecture-consistency = 2`,
  `maintainability = 0`; the sheet says the same (`score: 2`, `score: 0`), with matching
  reasoning ("the status when has its value discarded" / "statement position"). Agreement
  confirmed by direct read of both files.
- Exactly 20 sheets exist matching `score-observatory-run-*-20260906T1[23]*.yaml`, one per run
  id in `evidence/p04b/lab-4b4/batch-20260906T080905Z/manifest.tsv` (10 arm O + 10 arm C, ids
  cross-checked exactly). All 20 carry `rubric_sha: 396e1799eb2b`. Re-running the collector,
  `python3 evidence/p04b/lab-4b4/batch-20260906T080905Z/step7/collect-sheets.py findings/codex
  evidence/p04b/lab-4b4/batch-20260906T080905Z/manifest.tsv`, reproduces "20 sheets, every one
  at rubric 396e1799eb2b, every category parsed" and the exact score table in
  `experiments/E-007-orchestration-overhead.md`. **Zero null cells** (`grep -c "score: null"`
  across all 20 sheets = 0).
- **The apparent contradiction is real in the text but resolved by the timestamps, and it
  matters.** All 20 sheets' `provenance.observatory` field reads
  `http://127.0.0.1:18081/api/runs/<id>` — they were scored **through the SSH tunnel to the
  original, never-wiped colima stack** (see item 1), between `12:59:10Z` and `13:08:53Z`. The
  commit that documents this as complete, `4c12d8b` ("stop 11 step 7: twenty sheets..."), lands
  at `13:13:34Z`. The halt commit, `8d43a10` ("§7 HALT — the observatory database is empty"),
  lands at `13:21:25Z` — **almost 8 minutes after `4c12d8b`, and about 20 minutes after the
  last of the 20 sheets was written.** So `loop_step: 7`'s "THE SCORING HALF IS BLOCKED: no run
  records, so no codex sheets, so no O7" (`TRACK-B-STATE.md:11`) and `database_loss.blocked`'s
  "O7 is the ONLY thing separating decision-rule row 3 ... from row 4" (`TRACK-B-STATE.md:74`)
  are written by the same session that had, minutes earlier and in the same working tree,
  already produced and committed all 20 sheets it now says it cannot produce. **These are
  registered sheets, not "something else"**: correct harness (`codex`), correct schema-pinned
  rubric, correct run ids, structurally asserted by an executing collector.
- Correction to carry forward: **O7 is measurable from the sheets already on disk.**
  `maintainability` (O7's category): arm O scores four `2`s / six `0`s = **4 of 10**; arm C
  scores five `2`s / five `0`s = 5 of 10. Row 3 of the decision rule (`O7 ≥ 9 of 10` → REFUTE)
  does **not** fire; interpreting the remaining rows against the registered MDE table is a step
  10 question this pass does not resolve, but the cell the halt calls "blocked" is sitting in
  the repository, already scored, matching the hand check.

## 4. Step 8 — CONFIRMED (all five numbers re-derived independently, exact match)

Re-derived from `evaluation.json` in the 20 kept worktrees under `$TMPDIR/observatory-run-<id>`
and from `agent-observatory/infra/telemetry-out/events.jsonl` (OTel `resourceLogs`, matched by
`observatory.run.id`), plus the already-committed §4 step 6 per-run table (`53d2aa0`,
committed `2026-09-06T08:56:16Z` — before the API broke at ~12:54Z, so its cost/duration
figures were read from the API while it was healthy and are not part of the loss).

| # | State file's number | My re-derivation | Source | Match |
|---|---|---|---|---|
| O1 | 10/10 delegated vs 0/10, exactly-one on 9/10 | arm O: `subagent_completed` count is 1 on 9 of 10 runs, 2 on `beae5092` (10/10 ≥1); arm C: 0 on 10/10 | `events.jsonl`, counted per run id | exact |
| O6 | 10/10 vs 10/10 gate-passed | `evaluation.json` `exitCode: 0` on all 20 (10 O + 10 C) | on-disk `evaluation.json`, all 20 worktrees | exact |
| O2 | arm O 13.4% cheaper ($0.1265 vs $0.1462) | median cost O = $0.12655 (avg of $0.1247/$0.1284), C = $0.1462 (avg of $0.1445/$0.1479); (0.1265−0.1462)/0.1462 = **−13.47%** | §4 step 6 table, `experiments/E-007-orchestration-overhead.md:434-452` | exact (rounds to same figure) |
| O3 | +34.1% duration | median O = 118s (avg 112/124), C = 88s (avg 87/89); (118−88)/88 = **+34.1%** | same table | exact |
| O4 | +3 toolCalls | median `tool_result` count: O = 21 (avg 20/22), C = 18 (avg 18/18); **+3** | `events.jsonl`, counted per run id | exact |
| — | O5 +4 modelCalls, quartiles 24-27 vs 19-22 | median `api_request` count: O = 26, C = 22 (**+4**); Q1/Q3 O = 24/27, C = 19/22 | `events.jsonl`, counted per run id | exact |

All six figures reproduce exactly from disk. `check-run-gate.sh` re-run against
`$TMPDIR/observatory-run-207ff23d-.../evaluation.json` returns `ok: gate passed (exitCode 0)`,
confirming the gate genuinely runs off-API as claimed.

## 5. Item 6 — new L1/L2 labels in a4c219a..8d43a10 — CONFIRMED (none misapplied; nothing new claimed a wrong layer)

`git diff a4c219a..8d43a10 -- experiments/E-007-orchestration-overhead.md` adds **no** new
`L1`/`L2`/`L3` proof-layer labels — the diff in that range is the order-probe amendment,
the step 7/8 write-ups, and the halt note, none of which assign a new layer marker. The only
new `L2`/`L3` text in that commit range is in `TRACK-B-STATE.md`'s carried-forward debt items
(unchanged references to prior stops' unfixed L2 items) and one new `process_violations_this_session`
entry labelling the wrong-directory start "L3" — correctly, nothing executes to catch it.

The claims in this range that function as de facto proof-strength assertions do execute and
were re-run to confirm: `collect-sheets.py`'s "asserted on every sheet, not eyeballed" (re-run
above, item 3 — genuinely asserts and would abort on a mismatch) and `check-run-gate.sh`'s "20
admitted, 0 refused, entirely without the API" (re-run above, item 4 — genuinely reads only
`evaluation.json`, no network call). Both are L1/L2-grade in substance even though the state
file does not use the letter labels for them.

## 6. Item 4 — treatment reached arm O only, confirmed from disk (API is gone from this angle) — CONFIRMED

Read `init-schema` records for all 20 runs from
`evidence/p04b/lab-4b4/init-schema/init-schema-<runId>.txt` (produced during the batch, not
from the API): all 10 arm-O runs show `delivered n=4 ["Read","Task","Grep","Glob"]` against
`declared n=4 ["Read","Grep","Glob","Task"]`, verdict `order-differs` (same set, permuted —
admissible per the amended exclusion rule, item 2 above). All 10 arm-C runs show `delivered
n=29` (the full untouched tool pool), verdict `recorded-only`, "no overlay given." No arm-O run
shows the full 29-tool pool and no arm-C run shows the narrowed 4-tool set. The narrowing
overlay reached arm O exclusively, confirmed without touching the API.

---

## Single finding most likely to overturn the track's result if pursued

**The §7 halt is not supported by the evidence in the same session's own working tree: the
observatory database was never lost — it is reachable right now (325 runs, including this
batch's own 20) through the SSH tunnel this session itself opened at `127.0.0.1:18081`, the
same tunnel it used to produce and commit all 20 of E-007's codex sheets roughly 20 minutes
*before* writing the commit that declares scoring blocked and the database gone — so O7 is
not just "measurable from telemetry," it is already measured, committed, and sitting unread in
`findings/codex/score-observatory-run-*-20260906T1[23]*.yaml`.**
