# opencode review — run-b11-deliberate-failure

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20261005T194122Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/b11/run-b11-deliberate-failure.sh
    sha:  5160f8cc6db8
    dirty: true
  - path: evidence/b11/verify-b11-deliberate-failure.sh
    sha:  bfde4dd8508a
    dirty: true
lab_head:        0ba15a7
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/b11/run-b11-deliberate-failure.sh
  verdict: REJECT
  summary: The probe and its verifier each claim behavior the code does not implement — the subject is not pinned to the registered batch's sha by default, the verifier never exercises the subject-sha gate, and the verifier's comment claims D5 is checked in case C when only D3 is — so a green run proves less than the artifact says it does.
  blocking:
    - reason: The subject-sha gate is documented as having a default that does not exist in the code.
      wrong_action: A reader who trusts the comment at lines 72-75 runs the probe without exporting DF_EXPECT_SUBJECT_SHA, assuming the subject is pinned to run 40af8ffb's recorded sha. If ShipmentController.kt has drifted in the worktree (rebase, teammate edit, watcher save), the copy-vs-source check at lines 76-79 passes, the gate at line 80 is skipped, and the probe reports all six clauses ok against content the registered batch never saw. RESULT.md records the drifted sha and the driver exits 0.
      anchor: "The default is the sha the registered batch's own run 40af8ffb recorded for this file; an override must say so explicitly."
      evidence: evidence/b11/run-b11-deliberate-failure.sh:72-83
    - reason: The verifier has no case that exercises the subject-sha gate it claims to verify, violating its own stated standard.
      wrong_action: A reader runs verify-b11-deliberate-failure.sh, sees all eight cases green, and concludes the subject-sha gate works. A regression that inverts the comparison at line 81 or drops the `-n` test would leave every existing case green, because no case sets DF_EXPECT_SUBJECT_SHA. The verifier's own header (line 11: "a control that has never been shown to reject anything is indistinguishable from one that rejects nothing") is self-contradictory — the subject-sha gate is exactly the kind of control the header warns about.
      anchor: "a control that has never been shown to reject anything is indistinguishable from one that rejects nothing."
      evidence: evidence/b11/verify-b11-deliberate-failure.sh:11,64-90
    - reason: The verifier's case C comment claims D3/D5 must still pass, but only D3 is grep-checked.
      wrong_action: A reader trusts the comment at line 94 ("D3/D5 must still pass") and assumes the verifier proves the break is minimal. If a future change to the driver drops the D5 check call (lines 185-188) or breaks the broken-copy's hash-match branch, case C's exit code is unaffected, D1 and D2 still fail (the mismatch branch is still removed), and the grep at line 101 still finds `ok D3`. The verifier reports all-green. The comment's claim is unenforced.
      anchor: "Case C must fail for the REGISTERED reason, not for any reason: D1 and D2 are the clauses the missing branch breaks, and D3/D5 must still pass."
      evidence: evidence/b11/verify-b11-deliberate-failure.sh:94-105
  non_blocking:
    - reason: BODY_LINE at line 85 includes `import` in its pattern, so the variable can hold a header line rather than a body line. The comment at line 84 says this is "used by D4 to prove no body leaked," but the actual check (line 153-156) only proves that one specific line did not appear. A hook regression that leaked a function body into the refusal would pass D4 if that body did not also include the matched import. The D4 clause description ("refusal leaked a source line") is honest; the comment is aspirational. The test is weak, not wrong.
      evidence: evidence/b11/run-b11-deliberate-failure.sh:84-85,153-156
    - reason: Case F (non-executable recorder) asserts exit 4 but does not verify the reason string, unlike cases G and H which check for specific prereq names. A future reordering of prereq checks in the driver could make case F pass for a different reason than the one its label claims.
      evidence: evidence/b11/verify-b11-deliberate-failure.sh:72-75,108-112
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 215s |
| ollama-cloud/glm-5.2 | ok | 211s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| run-b11-deliberate-failure.sh | 1/1 | L3 |
| verify-b11-deliberate-failure.sh | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### run-b11-deliberate-failure.sh
**Verdict:** finding
**Failure:** Lines 72-75 comment states: *"The default is the sha the registered batch's own run 40af8ffb recorded for this file; an override must say so explicitly."* Lines 80-83 implement the gate as `if [[ -n "${DF_EXPECT_SUBJECT_SHA:-}" && "$SRC_SHA" != "$DF_EXPECT_SUBJECT_SHA" ]]`. There is no default value for `DF_EXPECT_SUBJECT_SHA` anywhere in the script — the hook's `EXPECT_SHA` at line 40 has a hardcoded default, but the subject sha does not. When `DF_EXPECT_SUBJECT_SHA` is unset, the `-n` test is false and the entire gate is skipped. The subject is pinned only to its own copy (line 76, copy==source), not to the registered batch's subject. Concrete scenario: `ShipmentController.kt` in the worktree is edited between batch registration and probe run (rebase, teammate commit, watcher-triggered save). The driver copies the new content, copy==source passes, the probe runs against content the registered batch never saw, and RESULT.md records the new sha with exit 0. Two reviewers diverge: one reads the comment and believes the subject is pinned to the registered sha by default; the other reads the code and sees it is not. A secondary issue in the same section: line 84 calls `BODY_LINE` a "real source line … used by D4 to prove no body leaked," but line 85's pattern includes `import` (a header line, not body) and `-m1` takes only the first match. D4 proves that one specific line — likely an import — did not appear in the refusal, not that no body leaked. A hook regression that leaked a different function's body line into the refusal would pass D4.
**Layer of the implied fix:** L3
**Anchor:** `The default is the sha the registered batch's own run 40af8ffb recorded for this file; an override must say so explicitly.`

### verify-b11-deliberate-failure.sh
**Verdict:** finding
**Failure:** The driver's subject-sha gate (lines 80-83) can exit 3 when `DF_EXPECT_SUBJECT_SHA` is set and doesn't match. The verifier has no case that exercises this gate — no case sets `DF_EXPECT_SUBJECT_SHA` to a wrong value and asserts exit 3. The verifier's own header (lines 5-7) states the principle: *"a control that has never been shown to reject anything is indistinguishable from one that rejects nothing."* The subject-sha gate is exactly such a control. Concrete scenario: the comparison at line 81 is inverted (`!=` written as `==`), or the `-n` test is dropped. Every existing verifier case still passes (none sets `DF_EXPECT_SUBJECT_SHA`), the driver's exit-3-for-subject-mismatch path is dead, and the verifier reports all-green. Two reviewers diverge: one says "the gate is in the driver, it works"; the other applies the verifier's own standard and says "the verifier doesn't prove it works." A lesser issue in the same section: case F (non-executable recorder, lines 72-75) asserts exit 4 but does not verify the reason string, unlike cases G (line 108 checks for "jq") and H (line 83 checks for "D4"). If the driver exited 4 at case F for a different prereq (e.g., a future check reordered ahead of the recorder), case F would still pass.
**Layer of the implied fix:** L2
**Anchor:** `a control that has never been shown to reject anything is indistinguishable from one that rejects nothing.`

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a probe-and-fixture pair, not a scoring rubric. No category/gate overlap.
- Which single section would two reviewers diverge on most, and by how much? The subject-sha pinning comment in `run-b11-deliberate-failure.sh` lines 72-75. One reviewer reads the comment as describing implemented behavior; the other reads the code and sees no default. The divergence is not marginal — one concludes the subject is pinned by default, the other concludes it is not pinned at all unless an env var is explicitly set. That is a full grade of disagreement on whether the control exists.
- What did the artifact not say that it needed to say? Whether the absence of a default `DF_EXPECT_SUBJECT_SHA` is intentional (the subject is only pinned when an external caller opts in) or a gap (the comment describes a default that was never wired). The comment and the code cannot both be right, and the artifact does not acknowledge the discrepancy.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### run-b11-deliberate-failure.sh
**Verdict:** finding
**Failure:** A default run of the probe (no `DF_EXPECT_SUBJECT_SHA` exported) uses a subject file that has been modified in the worktree since the registered batch — say someone touched `ShipmentController.kt` to add a KDoc. The copy-vs-source check at lines 76–79 passes (copy matches source), but the source no longer matches the registered batch's version. The probe runs, all six clauses report `ok`, RESULT.md is written, and the driver exits 0. Two reviewers diverge: one reads the comment at lines 73–75 — *"The default is the sha the registered batch's own run 40af8ffb recorded for this file"* — and concludes the subject is pinned by default so this cannot happen; the other reads line 80 — `if [[ -n "${DF_EXPECT_SUBJECT_SHA:-}" && ...` — and sees the check is skipped when the variable is unset, concluding a drifted subject passes silently. The hook pin at line 40 hardcodes its default sha (`EXPECT_SHA="${DF_EXPECT_SHA:-e78e66…}"`); the subject pin has no equivalent default, so the two pins are not symmetric despite the comment claiming they are.
**Layer of the implied fix:** L2 — hardcoding the registered subject sha as the default value of `DF_EXPECT_SUBJECT_SHA` (mirroring line 40) would make the check execute and exit 3 on a drifted subject. As written, the comment is L3: it describes an intention that nothing enforces.
**Anchor:** `The default is the sha the registered batch's own run 40af8ffb recorded for this file; an override must say so explicitly.`

### verify-b11-deliberate-failure.sh
**Verdict:** finding
**Failure:** The driver is modified to delete the D4, D5, and D6 `check` calls from the loop body (lines 153–162, 178–188) while keeping D1–D3. Case A runs the real hook: D1–D3 pass, the driver exits 0, `run_case A 0` passes. Case C runs the broken hook: D1 and D2 fail (the mismatch branch is still removed), D3 passes, the driver exits 2; the grep at line 95 finds `FAIL D1` and `FAIL D2`, the grep at line 101 finds `ok D3`, and the case passes. Cases B, D–H test exit codes 3 and 4 and are unaffected. The verify script reports `all N cases behaved as specified`, but the driver no longer tests D4 (body-leak refusal), D5 (the break itself), or D6 (recorder). A regression where the hook started leaking source lines into its refusal, or where the recorder stopped storing entries, would go undetected. The comment at line 94 — *"D3/D5 must still pass"* — names D5 as a required pass in case C, but no grep checks for `ok D5` in `C.out`; the claim is unenforced.
**Layer of the implied fix:** L2 — grepping case A's output for `ok D4`, `ok D5`, `ok D6` (as line 101 already does for `ok D3` in case C) would execute and fail if the driver skipped those checks.
**Anchor:** `Case C must fail for the REGISTERED reason, not for any reason: D1 and D2 are the clauses the missing branch breaks, and D3/D5 must still pass.`

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. D1 (allow stale) and D2 (drop key) test behavior and side-effect of the same event but are not duplicative. D3 (refuse fresh) and D5 (break refuses changed) both test refusal but against different hooks. D4 and D6 are unique.
- Which single section would two reviewers diverge on most, and by how much? The `DF_EXPECT_SUBJECT_SHA` comment in `run-b11-deliberate-failure.sh`. One reads "the default is the sha" as a claim that the code pins by default; the other reads the `[[ -n "${DF_EXPECT_SUBJECT_SHA:-}" ]]` guard and sees it skips by default. The divergence is total — they disagree on whether a default run catches a drifted subject at all.
- What did the artifact not say that it needed to say? The verify script does not state which clauses case A verifies beyond exit 0. Its own comment at line 94 names D5 as a required pass in case C, but no check enforces that — so the artifact's stated contract is wider than its executed contract.
