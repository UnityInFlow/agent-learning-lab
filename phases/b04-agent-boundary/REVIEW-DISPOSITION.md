# Stop 10 (B4) — §4a review, round 1: every finding, fixed or disputed

`Round 1 of at most three. Panel `-P codex -A -n 2` (author decision 3 — the ollama critic families
have failed three consecutive rounds and are additionally out of weekly quota tonight). Acceptance
gate SKIPPED via `-A`, so **no round here returns `ACCEPT`**; that is recorded as a limitation of
this round, not as a pass. Disposition by Opus 5 (claude-opus-5), autonomously, 2026-09-05.`

**Recurrence note.** The harness computes recurrence per *family* and `families: 1` here, so its own
table reads `1/1` throughout. The recurrence below is across the **two runs within that family**.
§4a: *a finding at 1/2 is still a finding; recurrence is a detection threshold, not a truth value.*

| artifact | findings file | exit | n |
|---|---|---|---|
| `experiments/E-006-agent-boundary-v1.0.md` | `findings/opencode/review-E-006-agent-boundary-v1.0-20260905T181824Z.md` | 0 | 16 |
| `phases/b04-agent-boundary/README.md` | `findings/opencode/review-README-20260905T182126Z.md` | 0 | 13 |
| `evidence/b04/run-armH.sh` | `findings/opencode/review-run-armH-20260905T182437Z.md` | 0 | 2 |
| `evidence/b04/armG-20260905T172219Z/report-armG.py` | `findings/opencode/review-report-armG-20260905T182536Z.md` | 0 | 7 |

**A process error of mine, recorded because it is the exact trap §4a warns about.** I opened
`review-report-armG-…182536Z.md` while it was still being written, saw 20 lines with nothing under
the provenance block, and called it a **header-only stall**. It was not: the file is now 155 lines
with seven findings. I had checked for a live `opencode` process and found none — the process had
exited between the write of the header and the write of the body. **A stall check that samples once
cannot distinguish "stalled" from "mid-write".** No decision rested on the misjudgment, because I
re-read the file before acting.

## FIXED

| # | artifact | rec. | finding | what changed | sha |
|---|---|---|---|---|---|
| 1 | `report-armG.py` | 1/2 | `exitCode == 0` checked, `evaluation.passed` not | added `_require(all(r['passed'] …))` | this commit |
| 2 | `report-armG.py` | 1/2 | `python3 -O` strips every `assert`, so the registered-variable guard can be switched off | all four `assert`s converted to `_require()` raising `SystemExit` | this commit |
| 3 | `report-armG.py` | 2/2 | arm membership and `n = 5` never enforced; adding or losing a record still prints a comparison | `_require` on the variant set and on `n == 5` per arm | this commit |
| 4 | `report-armG.py` | 2/2 | printed acceptance ratio taken from `g[0]` only, unrepresentative if records disagree | denominator computed across the whole group, and a mixed group prints `(MIXED)` | this commit |
| 5 | `E-006` §Arm G results | 2/2 | **"the two arms differ in the overlay's prose alone" is false** — arm G also differs in `--agent` launch mode | claim withdrawn in place, in a dated correction block; what remains is the negative claim (*the rise is not the tool list*) and the un-run arm that would separate prose from launch mode | this commit |
| 6 | `E-006` §treatment delivery | 2/2 | the identity hash covers the agent `.md`, not the overlay directory | scope stated; verified `find … -type f` = **1 file** in each overlay directory, so the two coincide *today*; directory-manifest assertion recorded as owed | this commit |
| 7 | workbook §Build | 2/2 | the build spec's *"only the tool list constrains"* is contradicted by arm H | new subsection: the trap's **layer** claim survives, its **effect** claim does not | this commit |
| 8 | workbook §Deliberate failure | 2/2 | arm H's effect attributed to `## Boundaries` alone without the discriminating cell | attribution narrowed to *"the overlay's prose"* in the workbook, matching what E-006 already registered before the data | this commit |
| 9 | workbook §Exit gate | 1/2 | all six checklist items still `[ ]` while the prose says each is answered | all six ticked | this commit |
| 10 | workbook + `E-006` + learning block | 2/2 (×3 findings) | *"change-focus 1 on 70 runs"* contradicted by run `514b094e` scoring 2 | **already fixed before this review was read**, in `aa55c23`: corrected to **73 of 73** with the population scoped, and the `514b094e` exception disclosed as a **codex-arm** run | `aa55c23` |
| 11 | `run-armH.sh` | 2/2 | a failed `claude` invocation leaving `pom.xml` unchanged is still recorded `HELD` | **upheld, not disputed.** Recorded in `E-006` with the five checks showing it did not bite in this batch (exit 0 on 15/15, `.err` 0 B on 15/15, transcripts 10 KB–96 KB, escalation prose read on two, `pom-diffs/` matching row for row from another source). The **L2** fix — `one()` refusing `HELD` when `rc != 0` — is **owed**, not applied: §6 forbids editing a tool whose runs are a closing stop's evidence | this commit |

## DISPUTED, with the reason its failure scenario cannot occur

| # | artifact | rec. | finding | dispute |
|---|---|---|---|---|
| 12 | `E-006` | 2/2 | P1/P2 and Threat 4 are "contradicted by six cited two-file passing runs" | **The document says so itself, in a section titled `C2 — the mechanism under P1 and P2 is REFUTED`, written and committed before the batch.** The critic has found a disclosed refutation and reported it as an undisclosed contradiction. Nothing to fix: removing the tension would mean deleting the refutation |
| 13 | `E-006` | 2/2 | the ordered decision rule "can yield KEEP from row 2 before row 3 would REJECT" | An ordered rule stopping at the first match is the registered design, fixed before the data precisely so the order cannot be chosen afterwards. It is also **moot here**: row 2 needs `maintainability` anchor 2 on 9 of 10 and got **3 of 10**, so it did not fire |
| 14 | `E-006` | 2/2 | Reading A is a "post-batch narrowed reading" applied instead of the literal preregistered row 5 | **Both readings, and both verdicts, were written and committed *before* arm G returned a number** — that is what the section's own title says and what its commit timestamp shows. Reading B's `REJECT` is preserved verbatim beside Reading A's `INCONCLUSIVE`. The critic's objection is that I chose; the answer is that I chose in advance, in public, and published the alternative |
| 15 | `E-006` | 2/2 | MDE cutoffs have no stated statistical derivation | True and already disclosed: they are judgment-set, registered before the data, with the mechanism stated per prediction. A resampling derivation over `n = 10` on a task where two of three gate outcomes are constants would put a decimal point on a constant. Recorded as a known limit, not fixed |
| 16 | `E-006` | 2/2 | "Permission mode / `--allowedTools` — identical on both arms" is an unchecked item with no value asserted | **Already on record as a limitation, and as the author's**: `blocked_on_author` item C, *"FLAGS ARE NOT ON THE RUN RECORD, so 'the same flags were passed to every arm' is L3."* The runner passes one flag set per batch, but nothing persists it per run, so no value *can* be asserted per arm on this instrument. For arm H, which runs off the observatory, the exact flag line **is** captured — `armH-…/provenance.txt` |
| 17 | `E-006` | 1/2 | codex and opencode `maintainability` disagree (9 vs 8) and the artifact does not say whether disagreement blocks | Decision C settles it and is cited in the file: **codex is the registered scorer and produces the number; opencode is a second reader, not a vote.** §4 step 7 says where they disagree, go to the diff. Tonight the second reader could not run at all (ollama weekly limit), which is recorded separately |
| 18 | `E-006` | 2/2 | exclusion rule does not define whether a partially-completed excluded run counts in the pass-rate denominator | It does, by construction: the registered comparison is **batch 2 only**, all 20 of which are gate-passing, and batch 1 is excluded **whole** and named as aborted. There is no partial run in any denominator |
| 19 | `E-006`, workbook | 2/2 | `change-focus` duplicates the decision rule's diff-focus gate | Correct, and it is the finding this stop already carries to the author: `change-focus` is a dead category on BE-003 carrying 15 % of the rubric weight. It is in `blocked_on_author`. Not fixable here — the rubric sha is a **registered variable** and moving it mid-experiment is a §7 halt |
| 20 | workbook §Goal | 1/2 | "no runs yet" language conflicts with the presented results | The workbook is written in stop order and the Goal section is the state at §4 step 1. Rewriting it to match the ending would erase the record of what was believed at the start, which §4 step 12 exists to prevent |
| 21 | workbook §4 step 2 | 2/2 | the per-run init read-back "cannot exist before the prediction commit" — a temporal inconsistency | The critic has misread author decision 8. What must precede the prediction commit is the **probe** — a preflight run on its own experiment key, whose `init` record is read back before any batch run. That is `EXP-B4-PREFLIGHT-2161` / run `fee79c79`. The per-batch read-backs come later and are a different artifact |
| 22 | workbook §4 step 10 | 2/2 | keeping `tools:` despite no measured behavioural effect contradicts the stated remove-if-no-effect rule, using "it executes" as an unstated criterion | The criterion is **stated, in the table, in the same row**: it is the only element that executes, and its behavioural no-effect is written into the same cell. §4 step 10's rule is about *rules*; deleting the one L2 control on a step whose whole subject is L2-vs-L3 would remove the thing the stop measures. The disagreement is real and is left visible rather than resolved by wording |
| 23 | workbook §Prohibited list | 2/2 | AC6/AC7 permit gratuitous unrelated rewrites inside permitted files, so "scope discipline is constant by definition" does not hold | A fair criticism of the *evaluator*, not of this stop's claim. The claim made here is narrower and measured: `change-focus` scored 1 on 73 of 73 and `changedFiles` sat at 3 on 30 of 30 across both batches. Whether the evaluator *could* admit a sprawling diff is untested and is now named in `next_question` |
| 24 | workbook §Commit | 2/2 | the Commit section supplies no commit identifier | Not yet due — it is filled at §4 step 14, which is the PR this disposition accompanies. Filled there |
| 25 | `report-armG.py` | 1/2 | band thresholds labelled "registered before the run" but nothing executes to verify that registration | Correct, and unfixable inside the script: a script cannot prove its own constants predate a run. **The proof is external and is a machine record** — prediction commit `2e39e58` at `2026-09-05T19:16:07+02:00` against the first `startedAt` of `17:22:19Z`, re-derivable with `git log --format=%cI -1 2e39e58` |
| 26 | `E-006` §Runs batch 2 | 1/2 | the registered batch-2 comparison is never presented as a results block | It is, in `evidence/b04/report-e006.py`, which recomputes it from committed run records; the file references it rather than duplicating numbers that would then need to agree. §5's table cites the same path |
| 27 | `run-armH.sh` | 2/2 | no valid-trial criteria defined, so all-failing invocations could read as "HELD 5 of 5" | The same defect as #11 and upheld there. It is disputed only as to *this batch*, where the five checks in `E-006` show every trial valid |
| 28 | `E-006` §Hypothesis | 2/2 | H2's "change-focus constant by construction" conflicts with a cited `change-focus = 2` run | The `= 2` run is `514b094e`, a **codex** arm (`gpt-5.6-sol`, `changedFiles` 2). Every claim of constancy here is scoped to `BE-003`/`claude-code`/`claude-haiku-4-5-20251001`, where it is 1 on 73 of 73. That scoping was added in `aa55c23` before this review was read |

## What round 1 does not settle

- **The acceptance gate was skipped (`-A`) on all four artifacts**, so no artifact has an `ACCEPT`.
  §4a permits stopping when every remaining line-level finding is disputed in writing, which is the
  state reached here — but *"the gate's own objection is answered"* is **not** satisfied, because the
  gate did not run. Recorded as `UNDECIDED-BY-DESIGN`, not as a pass.
- **One family only.** §4a asks for `-P` across families on anything that will be a registered
  variable. The three non-codex families have failed three consecutive rounds and are out of weekly
  quota. A second family is owed on `report-armG.py` and on the rubric whenever quota returns.
- **Three L2 fixes are owed and none is applied**, all for the same reason — §6 forbids editing a
  tool whose runs are the evidence a stop is closing on: `run-armH.sh`'s `HELD`-on-failure, the
  manifest's missing third init-schema verdict, and the batch harness's PID lockfile.
