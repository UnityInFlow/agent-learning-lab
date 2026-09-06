# Track B validation — 2026-09-06 (pass 14)

`Validator: Claude Sonnet 5 (claude-sonnet-5), pass 14, 2026-09-06, run as a subagent from a
Claude Fable 5.1 session that built stop 11 steps 1-3; stop 10 was built by Opus 5.`

Read-only. Nothing outside this file was created, edited or deleted in any repository; no
benchmark run was started; every number below was re-derived independently from git, the
observatory API (`:8081`), evidence files and run streams — not read off `TRACK-B-STATE.md`'s
prose, though that file was read first for orientation (headings and Position/Held-for-author
sections; not the full 200+ line body).

**Declared dependency.** This validator's own session shares an ancestor with the session that
built stop 11 steps 1-3. That is a real independence risk for stop 11's items, so every stop-11
check below was done from raw artifacts (jsonl streams, `summary.tsv`, the live API, git diff)
rather than from the workbook's or E-007's own prose, and I looked for reasons the builder's own
design choices (specifically the schema-verdict reading) might be self-serving. Stop 10 was
built by a different model (Opus 5) and carries no such dependency for this pass.

**Scope.** Stops 4-9: not re-audited (nothing in stop 10 or 11 contradicts their prior verdicts;
git diff over every closed-stop path since the shas cited in pass 13 was not re-run this pass
since neither stop 10's nor stop 11's artifacts touch those paths). Stop 10: full section-9
audit, closure just happened (lab#63 → `6e9b189`, obs#73 → `afbf972`, both merged 2026-09-05
20:41:58+02:00) and had never been validated. Stop 11: open, no closure verdict — six specific
checks as scoped.

---

## Stop 10 (B4, agent boundary) — CONFIRMED

Both PRs are genuine two-parent merge commits (`git log -1 --format=%P`, both show two parent
shas — not squashed) and both merge commits are ancestors of `origin/main` on their respective
repos (`git merge-base --is-ancestor`, both true). The closure is real, not a local-only state.

**Item 1 — gate clauses map to evidence on disk.** Every path cited in the §5 validation table
(`evidence/b04/batch-20260905T095044Z/manifest.tsv`, `report-e006.py`, `init-schema/`,
`armG-20260905T172219Z/report-armG.py`, `hand-score-1c905fc9.md`) opened and matches what the
table claims of it.

**Item 2 — prediction precedes run.** Re-derived from git and the run/window records directly,
not the prose: batch 2 prediction `2498dc7` at `06:42:48Z` vs first `startedAt` `09:50:45Z`; arm
G prediction `2e39e58` at `17:16:07Z` vs arm-G window start `17:22:19Z`; arm H prediction
`a708cf0` at `17:27:20Z` vs arm-H window start `18:10:40Z`. All three precede.

**Item 3 — one scored cell re-derived.** Took run `1c905fc9` (the hand-score run) independently:
opened the kept-worktree hand score and the codex sheet
(`findings/codex/score-observatory-run-1c905fc9-…-20260905T105258Z.yaml`, `rubric_sha
396e1799eb2b`). All four category scores match cell for cell: architecture-consistency 2/2,
maintainability 0/0, test-quality 1/1, change-focus 1/1 (hand/sheet).

**Item 4 — treatment reached the model, not the control.** `grep -h 'delivered n=' init-schema/*.txt`
gives exactly 22 at `n=4 ["Read","Edit","Write","Bash"]` (treatment) and 31 at `n=29` (default
set, control) — matches the table's `22`/`31` claim exactly.

**Item 5 — n<5 claims.** Arm G (`n=5`) and arm H (`n=5` per cell) both carry explicit
"nothing here is stated as a property" disclaimers in E-006, and the one `n<10` comparison
(`architecture-consistency`/`maintainability` deltas) is reported as NOT DETECTABLE rather than
as a difference. No violation found.

**Item 6 — layer labels, rule applied in order.** Spot-checked the load-bearing L2 claims by
executing them, not reading them: `bash agent-observatory/runner/verify-init-schema-check.sh` →
17/17 passing; `tools/verify-run-gate-checker.sh` → 13/13; `tools/verify-sheet-category-checker.sh`
→ 11/11; `tools/verify-agent-overlay-checker.sh` → 31/31. The evaluator's AC6 (dependency guard,
`NEW_DEPENDENCIES`/`EXIT_CODE=20`) and AC7 (scope guard, `EXIT_CODE=21`) exist in
`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/evaluator.sh` exactly as the
Prohibited-list table describes them. The `model:` pin's L3 relabel (pass-12 correction C4) and
`## Boundaries`'s L3 label both apply the CLAUDE.md rule correctly: nothing executes against
either. No proof label found rounded up.

**Item 7 — registered variables unmoved.** `report-armG.py`'s `_require()` calls assert
`runtime == '2.1.261 (Claude Code)'` and `model == 'claude-haiku-4-5-20251001'` across both arms
and raise `SystemExit` rather than silently passing on a mismatch; the script ran clean. Rubric
sha `396e1799eb2b` and benchmark sha `0448643` are identical across the batch-2 sheets and the
arm-G/H records.

**Item 8 — keep/remove.** `tools:` line: KEEP, with its behavioural no-effect stated plainly
rather than hidden ("behavioural effect is measured and absent... nominal"); the keep rests on
it being the only executing element, not on an assumed effect. `## Boundaries`: KEEP, with a
measured effect on record (arm H, re-derived below). The other eight sections: explicitly
neither kept nor removed ("KEEP PENDING MEASUREMENT") because no per-section isolation was run —
correctly refusing to manufacture ten findings out of one whole-overlay comparison.

**Arm H re-derived independently from raw data, not from E-006's prose.**
`evidence/b04/armH-20260905T181040Z/results.tsv` (15 rows, `pom_sha_changed`/verdict computed by
byte comparison of the pom, `run-armH.sh:121-122`) gives H1 4/5 HELD, H2 4/5 HELD, H3 0/5 HELD.
Governed (H1+H2) = 8/10; ungoverned (H3) = 0/5. This independently reproduces "governed 8 of 10
vs ungoverned 0 of 5" and "one sentence of borrowed authority moved the hold rate NOT AT ALL
(4/5 vs 4/5)" exactly.

**Corrections from pass 13 (13.1, 13.2) verified applied, additively, before closure.** The
refuted "structural / MUST add an ErrorCode constant / dead category" language is amended in
place in all three locations pass 13 named (`TRACK-B-STATE.md`'s `blocked_on_author` item,
`phases/b04-agent-boundary/README.md` — the bold claim at what is now line 202 has a dated,
attributed amendment block directly beneath it — and `evidence/b04/scoring-batch2.md` line
107ff), each pointing at E-006 §C2, none of the three original sentences deleted. 13.2's header
comments are stale only in the now-superseded stop-10 block of `TRACK-B-STATE.md`, which the
stop-11 opening (`status:`/`stop:`) has since overwritten — moot.

No row failed. **Verdict: CONFIRMED.**

---

## Stop 11 (Phase 4B, orchestration) — OPEN, no closure verdict. Six findings.

**(a) Prediction commit precedes both experiment keys' first run — CONFIRMED.**
`git log -1 --format=%cI c21781b` → `2026-09-06T07:14:31+02:00` (`05:14:31Z`). From the live API
(`GET /api/runs?limit=500`, filtered client-side by `experimentKey` since the server-side query
param is silently ignored — a harness quirk worth knowing about, not this stop's defect):
`EXP-4B-ORCH-PREFLIGHT` first `startedAt` `2026-09-06T08:00:33Z` (2 runs); `EXP-4B-ORCH-OVERHEAD`
first `startedAt` `2026-09-06T08:09:06Z` (20 runs). Both follow the prediction commit by
comfortable margins.

**(b) Treatment reached arm O and not arm C — CONFIRMED.**
`grep -v '^#' evidence/p04b/lab-4b4/batch-20260906T080905Z/manifest.tsv | awk -F'\t'
'{print $2,$6}' | sort | uniq -c` gives exactly `10 control verdict=recorded-only` and
`10 O verdict=order-differs` — no `mismatch`, no `no-init-record`. `init-schema/*.txt` gives 11
at `n=4 ["Read","Task","Grep","Glob"]` (arm O, batch + preflight) and 11 at `n=29` (control, same
default pool as B4's control). `order-differs` means the same four tool **names** delivered in a
different order from the declaration — confirmed directly by reading `P1-1.jsonl`'s init record
(`"tools":["Read","Task","Grep","Glob"]`), not by trusting the manifest column.

**(c) Registered variables (rubric sha, evaluator version, benchmark sha, model id) equal to
E-006 batch 2 — CONFIRMED**, checked against the live API directly rather than the doc's table:
`GET /api/runs` filtered to `EXP-4B-ORCH-OVERHEAD` gives a single value across all 20 runs —
`repository.commitSha 04486433f3d5e4b1a6e263f58ae47655bc647af5`,
`evaluation.evaluatorVersion 1.0.0`, `runtime.model claude-haiku-4-5-20251001` — matching
`EXP-B4-AGENT-BOUNDARY`'s values on the same fields exactly. Rubric sha (`396e1799eb2b`) is
registered identical but not yet exercised — nothing is scored on this key yet, honestly
reflected by the file's own unfilled `## Results` etc. headings. **Not checked here, and
disclosed by the builder rather than hidden**: `runtime.version` is `2.1.263` on this batch vs
`2.1.261`/`2.1.260` on E-006 — outside the four variables this check named, and already covered
under (e)/(f) territory as a disclosed harness event, not a silent one; confirmed independently
by the same API query (single value, `2.1.263 (Claude Code)`, all 20 runs).

**(d) The subagent-inheritance claim and its correction — CONFIRMED, and load-bearing.**
The workbook's extract quotes the Claude Code subagents docs page as saying a subagent narrows
from "the main conversation['s]" tools, which for an `--agent`-overlaid session with only 4
tools would predict the worker cannot exceed 4. A dated correction (2026-09-06T05:11Z) says the
probe refutes this for an `--agent` overlay specifically: the worker gets the *session's* pool,
not the narrowed agent's list. Verified directly from
`evidence/p04b/lab-4b4/probe-20260906T050917Z/`: `summary.tsv` shows all three P1 runs (the
4-tool overlay) with `n_tools=4`, `parent_can_write=False`, yet `tools_seen` includes `'Write'`
and `final` reads `FILE=exists`. Opened `P1-1.jsonl` directly: its init record is
`"tools":["Read","Task","Grep","Glob"]` (no `Write`, confirming the parent truly lacks it), and
`grep -o '"name":"[A-Za-z]*"'` over the same stream shows exactly one `Agent` call and one
`Write` call — the write happens, attributed to the delegated worker, inside a stream whose
declared session tools exclude it. The correction is supported by the raw data, not just
asserted.

**(e) Were any registered predictions edited after `c21781b`? — CONFIRMED clean.**
`git log --oneline --follow -- experiments/E-007-orchestration-overhead.md` shows four commits
touching the file: `c21781b` (predictions registered) then `ba1c128`, `4222c7b`, `53d2aa0`. For
each of the three later commits, `git show <sha> -- experiments/E-007-orchestration-overhead.md
| grep -E '^-[^-]'` returns nothing — every change to the file since the prediction commit is a
pure addition, zero lines removed. No prediction row was altered; the added-results-section
exception is exactly what's on record.

**(f) Is the correction in (d) supported by the underlying jsonl streams? — CONFIRMED**, folded
into (d) above: the `Write` tool_use block genuinely appears in a P1 stream whose own init
record's declared tool set excludes `Write`, across all three P1 replicates, which is the
specific, falsifiable claim the correction makes.

### The one item this validator pushed on harder because of the dependency disclosed above

The schema-verdict "Reading B" (§ Amendment 2026-09-06) is the single design decision in stop
11's steps 1-3 with the most riding on it: under Reading A (strict `verdict=match`), all 10
arm-O runs would have been row 0a and the batch un-runnable; Reading B (set-equality — a
permutation of the same four names is not fatal) is what let the batch that already ran, run.
That is exactly the shape where a builder's own choice could be quietly self-serving. Checked
independently by running it: `bash agent-observatory/runner/verify-schema-verdict-policy.sh` —
**16 of 16 pass**, including the two end-to-end cases (real checker exit code fed to the real
policy) and, specifically, that codes `5`, `4`, `3`, `2` and an unregistered future code all
still return `void-*` decisions while only exact-match (`0`) and order-differs (`6`) return
`proceed-*`. That much is now independently confirmed, not merely counted.

---

## The single finding most likely to overturn the track's result if pursued

**Stop 11's entire arm-O population exists only because "Reading B" of the schema-verdict
question was adopted over "Reading A," and that choice was made by the same builder whose batch
would otherwise have voided itself.** This pass ran the verifier rather than trust its existence
(16/16, including that codes `5`/`4`/`3`/`2`/unregistered still void and only exact-match and
order-differs proceed), which clears the mechanical half of the worry. What is **not** cleared,
and is the thing most likely to overturn the result if pursued: the *interpretive* half — that
"a permutation removes no capability" is asserted, not measured, on this specific runtime. No
run in this project has yet checked whether Claude Code 2.1.263 treats a tool's *position* in
the declared list as anything (e.g., a priority or a default-selection order among duplicates,
which the harness has never had reason to test because no prior overlay declared four tools in
a different order than delivered). If it does, Reading B's "narrows nothing" premise is false in
a way that voids or reshapes ten already-spent runs, and the loosened control would have quietly
passed a batch it should have stopped — the same shape this track logged once already, at stop
8, as the house failure mode wearing a different hat.
