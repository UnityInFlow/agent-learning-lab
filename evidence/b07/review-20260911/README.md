# Stop 15 · §4a — the review round, and what was done with each finding

Two invocations on **2026-09-11**, on the **codex panel** (`-P codex`), because `ollama-cloud` is
at its weekly usage limit again and the default panel returns a 904-byte header-only stall at
exit 1. Second-reader breadth at this stop is therefore **one family**, which is a limitation of
this review and is stated rather than hidden.

| invocation | subject(s) | findings file | bytes | exit | findings |
|---|---|---|---|---|---|
| 1 | `E-015`, `E-016`, the b07 workbook, `protected-paths.yaml` | `findings/opencode/review-E-015-verification-policies-BE003-20260911T085300Z.md` | 24 206 | 0 | 40 |
| 2 | `policy-gate.sh` | `findings/opencode/review-policy-gate-20260911T085939Z.md` | 2 813 | 0 | 1 |

`protected-paths.yaml` and `policy-gate.sh` were reviewed as **byte-identical copies** outside the
repository — shas `76c4c34c…` and `f432abbc…`, checked before and after. `rtk` hides dotfile paths
from the harness, so submitting them at their real `.ai/` path reviews nothing and exits 0. That is
a documented trap in `agent-learning-lab/CLAUDE.md`, not a workaround invented here.

**The acceptance gate did not run.** Both invocations report *"acceptance pass failed to run,
opencode exit 1"* — the gate is an `opencode`-only route (*Which harness does what*), and opencode
is the thing that is down. Per §4a step 3 the gate verdict is recorded as **UNDECIDED, which is not
a pass.** The line-level findings below are real results (exit 0); only the gate is missing.

---

## The one finding CONFIRMED by execution, and it is a real defect in the registered artefact

**`policy-gate.sh` does not canonicalise the path before matching, so a `..` segment walks around
every prefix-anchored deny pattern.**

Reproduced by `path-traversal-probe.sh` in this directory, which invokes the **registered** gate in
place and edits nothing:

```
PATH                                       EXIT     MEANING
.github/workflows/ci.yml                   2        DENIED
sub/../.github/workflows/ci.yml            0        ALLOWED
infra/main.tf                              2        DENIED
src/x/../../infra/main.tf                  0        ALLOWED
pom.xml                                    2        DENIED
sub/../pom.xml                             2        DENIED
```

**Mechanism**, at `policy-gate.sh:68-88`: `REL="${RAW#"$ROOT"/}"` is a prefix strip with no
`realpath`, and the matcher then has two branches. The `**/name` branch compares
`basename "$REL"`, which a `..` cannot disturb — so `sub/../pom.xml` is still denied. The
prefix-anchored branch does `case "$REL" in .github/*)`, which a leading `sub/../` defeats. **So
five of the seventeen deny patterns — `.github/**`, `infra/**`, `deploy/**`, `charts/**`, `k8s/**`
— are bypassable by a path string, and the twelve `**/`-anchored ones are not.**

**It is NOT fixed at this stop, and that is not a dispute.** `policy-gate.sh` is a registered
variable of a batch that is already run and scored; §6 says *"a version that has been measured is
never edited; a change is a new version"*, and §7 makes moving one mid-experiment a halt. **This is
v1.1's first concrete requirement and it is handed to B8 with its reproduction.**

**What it does to this stop's numbers: nothing, and that is checkable.** All 91 edit-family calls
across both treated arms were `Edit` to source and test paths, and none carries a `..` segment —
`grep -c '\.\.' ` over the 17 treated policy logs returns 0. The measured false-positive rate
(0 / 91) and the measured true-positive population (0 in 325 corpus runs) are untouched.

**What it does to the exit gate's wording: it sharpens it.** The gate does *execute and refuse* —
DF1 proves that. Its **coverage is narrower than the policy file reads**, and a reader who takes
`infra/**` at face value is being told the truth about intent and not about behaviour. That
sentence is now in the workbook.

---

## The one finding REFUTED by going to the record

**Claim (twice, once per task): *"run order was block-sequential — 10 treated then 10 control —
during a load shift; the 'interleaved' claim is not satisfied."***

**Wrong, and the run records say so.** Ordered by `startedAt` from `GET /api/runs`, the batch
alternates strictly, pair by pair, on both tasks:

```
18:37:32 BE-003 treated · 18:40:03 BE-003 control · 18:42:36 BE-003 treated · 18:45:00 BE-003 control …
19:24:27 BE-004 treated · 19:28:01 BE-004 control · 19:31:29 BE-004 treated · 19:34:54 BE-004 control …
```

all 34 runs, no two same-arm runs adjacent. The critic inferred an order from the manifest's
layout rather than reading the timestamps. This is §4 step 7's *"go to the diff and say which fact
was wrong"*, applied to a review instead of a sheet.

**One real thing fell out of chasing it, and it is kept.** The final BE-004 control, `2635dc3b`,
started at **20:47:24 — 37 minutes** after its treated pair at 20:10:28, where every other gap in
the batch is 2 to 5 minutes. That gap is the runtime-version guard firing (`2.1.267 → 2.1.268`),
which is why BE-004 is `n = 7` and not `n = 10`. It is already disclosed in E-016's amendment; it
is recorded here too because a wrong finding led to a right question.

---

## Fixed, with the sha that fixed it

| # | finding | what was done |
|---|---|---|
| 1 | *"§5 validation table's first row names the obsolete `c558f78a` hash while the artifact is `f432abbc`"* | **CORRECT, and it was a defect in text written this session.** The stale value came from `TRACK-B-STATE.md`'s `treatment:` block, which still carries the pre-amendment hash from before the event log moved outside the worktree. The §5 table now names `f432abbc…`, which is also the value the batch manifest header recorded at launch. The state file's stale copy is flagged in place rather than silently corrected |
| 2 | *"Extract lists syntax errors as fail-open, but DF2 shows fail-closed — contradicts the Extract"* | **CORRECT.** The Deliberate-failure section already said *"narrowed, not overturned"*, but Extract §2 itself still read as a general claim. A dated note now sits at Extract §2 pointing to DF2b |
| 3 | *"Exit gate is marked met by substituting policy-gate for the verification entry point"* | **Partly correct, and the wording is now explicit** about what was substituted for what, and that `verify.sh` runs from the harness rather than as something the agent can be refused by |
| 4 | *"`protected-paths.yaml` declares `NotebookEdit` in `applies_to` but the docs describe Edit/Write"* | **Not a contradiction — `settings.json`'s matcher is `Edit\|Write\|NotebookEdit`** — but the workbook's prose was loose. Corrected to name all three, and to record that **0 of 91 calls were `Write` or `NotebookEdit`**, so both branches are untested by the batch |

## Disputed, with the reason each failure scenario cannot occur here

- ***"An extra non-logging hook in the treated settings would pass the hash and log checks
  undetected"*** (three variants). The treated overlay is four files and `git status --porcelain
  build/customizations/verify-v1.0` is empty; `settings.json` is committed at
  `1dc38808bee86df9b1…` and contains exactly one `PreToolUse` entry. The scenario requires an
  unrecorded file in a tracked directory. **Recorded as a real instrument gap for B8** — there is
  no *executing* check that the delivered settings match the registered ones — but it is not a
  defect in this batch, and the finding's own framing (*"would pass"*) is conditional, not observed.
- ***"P3's denominator is ambiguous — 36 allowed edits vs 20 ticket-legitimate ones."*** P3 is
  registered as *"of all `Edit`/`Write` calls in the treated arm, the fraction denied"*. The
  denominator is every such call, by the registered text, and it is 36. Re-scoping it to
  "ticket-legitimate" calls after the run would be re-specifying a prediction once the values are
  known (§4 step 12).
- ***"No decision row for 'P1–P3 hold, P4–P6 hold, cost outside MDE in the worse direction'."***
  Row 5 is exactly that row. It did not fire because cost is **inside** its MDE on both tasks
  (+12.83 % against 30 %, +5.02 % against 13 %). The finding describes a state that did not occur.
- ***"Zero evaluator-vs-`verify-sh` disagreement is consistent with `verify-sh` missing every
  failure class."*** **Agreed, and it is already the workbook's own wording** — *"a 0 %
  disagreement rate over a population with no failures in it does not show that the two agree on
  failures."* Not a change; a finding that arrived at the text's own conclusion.
- ***"`P1`'s registered path was changed by amendment, so literal and amended scoring diverge."***
  Disclosed in E-015's Results before codex ran, with the reason (the log was itself being scored
  as an unrelated production file, evaluator exit 21) and the date, and the amendment predates the
  batch. Recorded, not repaired.
- ***"DF2's absent log makes it VOID under P1 row 0."*** Row 0 governs **runs in the registered
  population**. DF2b is off-observatory, carries no experiment key and enters no `n`. It cannot
  void an arm it is not in.
- ***"`maintainability` duplicates P7's binary median gate"*** and ***"at n = 7 a one-point median
  shift has no variance basis."*** **Agreed, and this is the stop's headline finding rather than a
  revision** — the median is the wrong summary for a two-level category, it is written into the
  exit gate, the learning block and `findings/track-b-2026-09-11.md`, and it is B8's inheritance.
- ***"Run `e0075ad9`: two competent readers assign 0 and 2 on the same rubric text."***
  **Agreed and already measured** — the hand re-read registered exactly this ambiguity in writing
  **before any sheet existed**, and the registered scorer then took the hand's side. The rubric is
  a registered variable at `6252778b8472` and §7 makes editing its categories a halt.
- ***"`message`'s 'Do not retry' is unenforced guidance."*** **Correct and already labelled** — it
  is L3 by the workspace rule, inside an L2 artefact. Recorded.
- The remaining findings are restatements of these in the second experiment file, or ask for an
  executable legitimacy classifier, a run-order rule and a treatment-identity check — three
  instruments that do not exist. They are **author notes and B8 inputs**, not defects in what was
  measured.

**Round 2 was not run.** §4a allows up to three rounds; the two changes made are a hash correction
and three wording corrections, none of which changes a measurement, and the acceptance gate is
unavailable while opencode is down — so a second round would re-read the same text with the same
single family and could not return a gate verdict either. Recorded as a choice, with its reason.
