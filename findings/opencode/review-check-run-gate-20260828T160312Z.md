# opencode review — check-run-gate

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T160312Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-run-gate.sh
    sha:  04e5a86185ee
    dirty: false
  - path: tools/check-sheet-categories.sh
    sha:  bbb0df46e8e3
    dirty: false
lab_head:        c017eb8
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/check-run-gate.sh + tools/check-sheet-categories.sh
  verdict: REJECT
  summary: check-sheet-categories.sh's line-oriented regex matches any `  - name:` line in the file, so a sheet with `categories: [A]` and `other: [B]` reports a match against a rubric of [A, B] — defeating exactly the silent-category-loss check the script was built to enforce.
  blocking:
    - reason: The `names()` function uses a line-oriented sed pattern that matches any `  - name:` line in the file, not specifically those under the `categories:` key. A category that is absent from `categories:` but present in some other list (or anywhere else with the same indent) is counted as present.
      wrong_action: A reader hand-writes a malformed sheet, or the sheet-writer has a bug, where category B is filed under `other:` instead of `categories:` while A stays under `categories:`. The script returns exit 0 saying "ok, exactly the rubric's categories," the scoring pipeline proceeds on a sheet that is actually missing category B from its `categories:` list, and E-001's null-rate denominator — the cell count — is wrong because the missing category is silently treated as present rather than as a null measurement.
      anchor: names() { sed -n 's/^  - name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$1" | sed 's/[[:space:]]*$//' | sort; }
      evidence: tools/check-sheet-categories.sh:31
  non_blocking:
    - reason: check-run-gate.sh accepts string-typed `passed` / `exitCode` because both are coerced via `|tostring` before the line-68 string comparison. The script's stated contract (lines 1–4) is "did the evaluator say it passed," not "with strict JSON types," and the gate decision is unchanged across `"true"`/`true` and `"0"`/`0`. A reader who feeds it a string-typed verdict gets the right answer to the question the script asks.
      evidence: tools/check-run-gate.sh:47-48,68
    - reason: check-run-gate.sh's `taskAttempted` guard only fires on the literal string `"false"`; a blocked run whose evaluation document omits the field yields `attempt=""` (line 50) and exits 0 at line 68. The author backs this with a test (verify-run-gate-checker.sh:23 asserts the bare shape passes) and a comment claiming the case is unreachable (lines 58–61); the line-2 reviewer–author disagreement is over the contract, not over an output, and the fix the reviewer identifies is upstream in the evaluator.
      evidence: tools/check-run-gate.sh:50,58-66
  disputed:
    - finding: "no finding" verdict on check-sheet-categories.sh from pass 2 (deepseek-v4-pro)
      why: Pass 2 verified that the regex handles quoted vs unquoted names and that the fail-closed checks turn shape drift into exit 1, but did not notice that the pattern is line-oriented and does not anchor to the `categories:` block. Constructing the input `categories:\n  - name: A\nother:\n  - name: B` against a rubric of [A, B] makes `names()` emit `A\nB` from both sides and the script exits 0 — which is the silent category loss the header comment (lines 11–17) names as the failure mode this script exists to catch.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 39s |
| ollama-cloud/deepseek-v4-pro | ok | 188s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| tools/check-run-gate.sh | 1/2 | L2 |
| tools/check-sheet-categories.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| check-run-gate.sh | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/check-run-gate.sh
**Verdict:** finding
**Failure:** Input `{"passed":"true","exitCode":"0"}` exits 0 even though both verdict fields are strings rather than the evaluator’s boolean and numeric values. One reviewer can treat this as a valid passing evaluation while another rejects it as malformed, so the gate does not establish that the recorded verdict has the intended types.
**Layer of the implied fix:** L2
**Anchor:** passed=$( xf 'if has("passed")   then (.passed|tostring)   else "" end')

### tools/check-sheet-categories.sh
**Verdict:** finding
**Failure:** With rubric categories `A` and `B`, a sheet containing `categories:\n  - name: A\nother:\n  - name: B` exits 0. Category `B` is absent from `categories`, but the line-oriented scan collects it from the unrelated `other` list and incorrectly reports an exact match.
**Layer of the implied fix:** L2
**Anchor:** names() { sed -n 's/^  - name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$1" | sed 's/[[:space:]]*$//' | sort; }

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so none duplicates a pass/fail gate. Reviewers would diverge most on `tools/check-run-gate.sh`: the string-valued example can produce a one-verdict difference—accepted versus malformed. The evidence set does not define the required JSON field types or require category names to be read specifically from the YAML `categories` sequence; consequently both executables can accept documents that do not carry the claimed measurement structure.
**Layer of the implied fix:** L2
**Anchor:** “Does a scorer's sheet carry EXACTLY the rubric's categories — no more, no fewer, no others?”


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro


[memtrace] Update available: 1.1.4 → 1.1.5
           Run: memtrace install   (upgrades + can chain commands, e.g. `memtrace install start`)


[memtrace] Update available: 1.1.4 → 1.1.5
           Run: memtrace install   (upgrades + can chain commands, e.g. `memtrace install start`)


[memtrace] Update available: 1.1.4 → 1.1.5
           Run: memtrace install   (upgrades + can chain commands, e.g. `memtrace install start`)


[memtrace] Update available: 1.1.4 → 1.1.5
           Run: memtrace install   (upgrades + can chain commands, e.g. `memtrace install start`)

✱ Grep "correctness" 82 matches
✱ Grep "taskAttempted" 4 matches
→ Read tools/verify-sheet-category-checker.sh
→ Read tools/verify-run-gate-checker.sh
→ Read benchmark/rubrics/backend-quality.yaml
### check-run-gate.sh
**Verdict:** finding
**Failure:** The `taskAttempted` guard fires only on the literal string `"false"`. A blocked run (agent refused to attempt the task) whose evaluation document *omits* the field — or omits the `correctness` block entirely, which is exactly the bare shape the runner writes per the script's own test at `verify-run-gate-checker.sh:23` (`{"passed":true,"exitCode":0}`) — yields `attempt=""`, skips the line-62 guard, and exits 0 at line 68. The blocked run is scored. The author already defends against the `passed:true` + `taskAttempted:false` combination (test at line 30), so the "blocked run with passed=true" state is one they consider reachable; the absent-field variant of the same defect is unguarded. Two reviewers diverge: one reads the bare shape as a legitimate pass, the other reads it as the hole through which a blocked run sails. The script's own test suite bakes the hole in by asserting the bare shape passes.
**Layer of the implied fix:** L2 — the script is the executing control and the fix is in its logic, but note the deeper problem: the bare shape is *ambiguous* between "legitimate pass" and "blocked run with omitted field," and no L2 logic in this file can resolve that without the evaluator always writing `taskAttempted`. The real fix is upstream (evaluator always emits the field), which is L1/L2 in the evaluator, not here.
**Anchor:** `if [ "$attempt" = "false" ]; then` (line 62), with the extraction at line 50: `attempt=$(xf '(.correctness // {}) | if has("taskAttempted") then (.taskAttempted|tostring) else "" end')`

Secondary, same block: `passed: null` (or `exitCode: null`) is conflated with a false verdict. `has("passed")` is true for a null value, so `{"evaluation":{"passed":null,"exitCode":0}}` yields `passed="null"` (non-empty), skips the line-52 fail-closed check, and exits 2 at line 73 with "the evaluator failed this run." A null verdict is *no* verdict, which the script's own comment (lines 29–33) says must be exit 1 — the missing-vs-false distinction is enforced for the key but not for the value.

### check-sheet-categories.sh
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `names()` regex (`^  - name: *"\{0,1\}\([^"]*\)"\{0,1\} *$`) correctly handles both the rubric's unquoted names and the sheet's quoted names, and the fail-closed checks (lines 38–41) turn any shape drift into exit 1 rather than a silent empty-vs-empty match. Order-independence is intended and tested. The script's scope is names-and-count only; it does not check weights or scores, but the sheet does not carry weights (the scorer applies the rubric's), so that is not a gap in this file.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? These are gate/checker scripts, not scoring rubrics, so no categories exist to duplicate. The nearest analogue is `check-run-gate.sh`'s exit-code semantics: exit 2 is documented (lines 20–21) as "the evaluator says it failed," but the `taskAttempted` guard also exits 2 for "not attempted" — a blocked run is not a failed run, so the exit code is overloaded and the documentation does not name the third case.
- Which single section would you expect two reviewers to diverge on most, and by how much? `check-run-gate.sh`'s `taskAttempted` guard — by a full verdict (finding vs. no finding), because the divergence turns on whether "blocked run with `passed:true`" is a state the script must defend against, and the author's own test suite argues both sides at once (line 30 guards it, line 23 asserts the unguarded bare shape passes).
- What did the artifact not say that it needed to say? `check-run-gate.sh` never states what a *blocked* run's evaluation document looks like when `taskAttempted` is absent rather than false, and never states whether the bare shape `{"passed":true,"exitCode":0}` is a legitimate pass or an unguarded blocked run. That ambiguity is the finding; the file's comments (lines 58–61) assert "it cannot reach here with passed=true" while the test at line 30 constructs exactly that, and the file does not reconcile the two.
