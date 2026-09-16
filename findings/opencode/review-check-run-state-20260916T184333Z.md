# opencode review — check-run-state

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
opencode:        1.18.27
reviewed_utc:    20260916T184333Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-run-state.sh
    sha:  b3fe5190864e
    dirty: false
  - path: tools/check-completion-contract.sh
    sha:  c53fdce885d7
    dirty: false
  - path: tools/verify-run-state-checker.sh
    sha:  abfbd99bcd8c
    dirty: false
  - path: tools/verify-completion-contract-checker.sh
    sha:  0d34d8e216c0
    dirty: false
lab_head:        a55240a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/check-run-state.sh + tools/check-completion-contract.sh + tools/verify-run-state-checker.sh + tools/verify-completion-contract-checker.sh
  verdict: REJECT
  summary: Four blocking defects survive the line-level pass: a substring test on the `reserved` field where the contract is "reserved for B8a", a diff-header false positive that flags filenames like `TODO.md`, an exit-code precedence that downgrades a real clause failure to inconclusive, and a clause-6 scope narrower than the contract name (untracked forbidden files).
  blocking:
    - reason: The `reserved` field check uses `test("B8a")` (a regex substring match) where the contract is "must say the block is reserved for B8a, so a later reader cannot mistake data for a control". The same defect class — exact-vs-substring — is the one the file's own comments (lines 138–145) fix for `.decision`, so the inconsistency is in-file.
      wrong_action: A run-state whose `handoff.reserved` says "this block is NOT reserved for B8a" passes the check, and a reader records the handoff as reserved for B8a when the field says the opposite.
      anchor: 'jq -e ''(.handoff.reserved // "") | test("B8a")'' "$FILE" >/dev/null 2>&1'
      evidence: tools/check-run-state.sh:70
    - reason: The clause-5 grep matches the `+++ b/<path>` diff header. Pattern `'^+.*\(TODO\|FIXME\|XXX\|not implemented\|NotImplemented\)'` matches any line starting with `+` followed by anything containing the listed tokens; a `git diff` for an added file emits `+++ b/FIXME.md` (three `+` signs and the path), which contains `FIXME`. The verifier's only clause-5 case puts `TODO` inside a file body (verify-completion-contract-checker.sh:108), never in a filename, so the fixture does not exercise the failure mode.
      wrong_action: A submission that legitimately adds a ticket note named `TODO.md` or `FIXME.md` is reported `FAIL 5 … N added line(s) hold TODO/FIXME/not-implemented` when no added content line contains any of those tokens.
      anchor: "ADDED=\"$(git -C \"$WORKTREE\" diff \"$BASELINE\" -- . 2>/dev/null | grep -c '^+.*\\(TODO\\|FIXME\\|XXX\\|not implemented\\|NotImplemented\\)' || true)\""
      evidence: tools/check-completion-contract.sh:122
    - reason: Exit-code precedence at lines 203–214: the `ZERO_PATTERNS` branch exits 2 before `[[ "$FAILED" -eq 0 ]] || exit 1`, so a submission that FAILs a decidable clause AND trips the zero-pattern policy exits 2 (the "nothing authoritative was decided" code) rather than 1. Downstream automation keying on the exit code sees a failure as inconclusive.
      wrong_action: A genuinely failing submission is downgraded to "inconclusive" in the exit code, and a downstream retry/alert loop either re-runs a failed run or treats it as undecided rather than failed.
      anchor: "if [[ \"$ZERO_PATTERNS\" -eq 1 ]]; then ... exit 2 ... fi ... [[ \"$FAILED\" -eq 0 ]] || exit 1"
      evidence: tools/check-completion-contract.sh:203-214
    - reason: Clause 6 reads only `git diff --name-only "$BASELINE" -- .` (line 150), which lists committed changes between two refs and omits untracked files. The artifact calls this clause "the one this script is genuinely authoritative on" (lines 132–135) while delivering a scope narrower than the contract name "no forbidden files changed".
      wrong_action: A finished worktree that contains a newly created, never-`git add`'d forbidden path (e.g. `pom.xml`) passes clause 6 even though the worktree "changed" in the wider sense the contract reads as.
      anchor: "CHANGED=\"$(git -C \"$WORKTREE\" diff --name-only \"$BASELINE\" -- .)\""
      evidence: tools/check-completion-contract.sh:150
  non_blocking:
    - reason: Deny-list matcher double-counts a single-level match — `service/pom.xml` is added to `HITS` once by the `**/` basename branch and again by the shell-glob fallback at line 162, because `**` in bash (without globstar) is treated as `*`. The printed `HITS` count is wrong; the verdict is unaffected.
      evidence: tools/check-completion-contract.sh:156-164
    - reason: The `verify-run-state-checker.sh` fixture set does not include a case for `.blocks = ["opaque"]` or `.hookExecutions = [42]`. The underlying checker catches non-objects (see disputed), so the gap is real but does not hide a defect today.
      evidence: tools/verify-run-state-checker.sh:66-79
    - reason: The completion-contract verifier commits the forbidden `pom.xml` before checking (line 102), mirroring the checker's committed-changes-only scope rather than the broader "no forbidden files changed" claim. The fixture passes by construction; the artifact-level defect is the one above.
      evidence: tools/verify-completion-contract-checker.sh:101-105 - reason: Clause 5 ("no critical findings") is acknowledged in the artifact as "none of the mechanical kind added (not proof of none)" and is explicitly described as only partially decidable. An acknowledged partial is a different thing from a hidden one.
      evidence: tools/check-completion-contract.sh:126
 - reason: Clauses 2 and 3 are flagged in the artifact's own output as "TWO LINES FROM ONE INSTRUMENT" (line 201). The duplication is named; the verifier testing them as separable does not change the contract.
 evidence: tools/check-completion-contract.sh:201
  disputed:
    - finding: check-run-state.sh accepts `.blocks = ["opaque"]` and `.hookExecutions = [42]` because `.field` on a scalar raises a jq error that the `if jq -e ...` predicate swallows, so no problem is recorded.
      why: jq does not raise on field access of a missing key — `.reason` on a string returns null, not an error, and `.reason // ""` then yields "". The select at lines 135–137 matches, length > 0 is true, and the `if jq -e ...; then` branch DOES fire and record a problem. The same reasoning applies to the enum check at lines 143–145: `.decision // ""` is "" on a non-object, `index("")` is null, `null == null` is true, the select matches, the problem is recorded. The line-level finding misstates jq semantics; the checker handles these inputs correctly. The verifier gap is real but the alleged defect is not.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |
| ollama-cloud/deepseek-v4-pro | ok | 175s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

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
| tools/check-run-state.sh | 1/2 | L2 |
| tools/check-completion-contract.sh | 1/2 | L2 |
| tools/verify-run-state-checker.sh | 1/2 | L2 |
| tools/verify-completion-contract-checker.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| check-run-state.sh | 1/2 | L2 |
| check-completion-contract.sh | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/check-run-state.sh
**Verdict:** finding
**Failure:** A run-state with `.blocks = ["opaque"]` or `.hookExecutions = [42]` can exit 0. In each jq predicate, indexing the scalar as `.reason`, `.fingerprint`, or `.decision` raises a jq error; because the query is used as an `if jq -e ...` condition, that error is treated like a false predicate and no problem is recorded. One reviewer would regard the enclosing array type check as sufficient, while another would require every entry to have the object shape the later checks assume.
**Layer of the implied fix:** L2
**Anchor:** if jq -e '[.blocks[] | select((.reason // "") == "" or (.fingerprint // "") == "")] | length > 0' "$FILE" >/dev/null 2>&1; then

### tools/check-completion-contract.sh
**Verdict:** finding
**Failure:** Starting from a baseline without `service/pom.xml`, create an untracked `service/pom.xml` and run the checker with that baseline and the registered policy. `git diff --name-only "$BASELINE" -- .` omits untracked files, so clause 6 prints PASS even though the finished worktree contains a newly added forbidden path. A reviewer interpreting “changed” as Git diff output accepts this; a reviewer evaluating the complete finished worktree rejects it.
**Layer of the implied fix:** L2
**Anchor:** CHANGED="$(git -C "$WORKTREE" diff --name-only "$BASELINE" -- .)"

### tools/verify-run-state-checker.sh
**Verdict:** finding
**Failure:** Mutate the known-good fixture to `.blocks = ["opaque"]` or `.hookExecutions = [42]`. The checker can accept either malformed entry, but this verification script still exits 0 because it tests only missing fields, wrong top-level collection types, and object entries with selected invalid values. Two reviewers can therefore disagree on whether “wrong type” coverage includes collection member types while the executable suite supplies no resolution.
**Layer of the implied fix:** L2
**Anchor:** echo "REFUSES a field of the wrong type — a schema that only checks presence is not a schema:"

### tools/verify-completion-contract-checker.sh
**Verdict:** finding
**Failure:** After recording a clean baseline, create an untracked `service/pom.xml` without adding or committing it, then invoke the checker. Clause 6 incorrectly reports PASS, yet this fixture suite remains green because its forbidden-path case commits the file before checking. One reviewer can treat the committed-file fixture as coverage of additions; another can point out that it never exercises untracked additions in the finished worktree.
**Layer of the implied fix:** L2
**Anchor:** git -C "$WT" add -A; git -C "$WT" commit -qm "touch a forbidden file"

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category “no critical findings” duplicates a partial pass/fail gate: added TODO/FIXME/XXX/not-implemented lines cause clause 5 to fail, while the artifact also says the category is generally a judgement. The greatest reviewer divergence is in `tools/check-completion-contract.sh`, clause 5: for a clean diff it prints PASS although its own text says this is not proof of the clause; reviewers can score that as either one passed clause or one still-undecidable clause, a one-clause difference. The evidence set also never states whether newly created untracked files belong to the baseline-to-finished-worktree change set; concretely, an untracked forbidden `pom.xml` is omitted and produces the wrong PASS.
**Layer of the implied fix:** L2
**Anchor:** pass 5 "no critical findings" "none of the mechanical kind added (not proof of none)"


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### check-run-state.sh
**Verdict:** finding
**Failure:** The `reserved` field check uses a regex substring test, which is the exact defect class this same file documents and fixes for `.decision` (lines 138–145). A run-state whose handoff block says `"reserved": "data, not reserved for B8a"` — or any string that merely *contains* `B8a` — passes line 70, even though the field's own contract (line 71) is that it "must say the block is reserved for B8a." Two competent reviewers of the schema would read the contract as "identifies B8a as the owner"; the checker reads it as "mentions B8a anywhere." A later reader is exactly what the comment says the field protects against, and the protection fails on the one input that matters — a string that names B8a while denying it.
**Layer of the implied fix:** L2 (the check executes; making the match exact keeps it a running check)
**Anchor:** `jq -e '(.handoff.reserved // "") | test("B8a")' "$FILE" >/dev/null 2>&1`

### check-completion-contract.sh
**Verdict:** finding
**Failure:** Clause 5's mechanical critical-finding grep counts diff *header* lines as content. The pattern `^+.*\(TODO\|FIXME\|XXX\|…\)` matches a newly added file whose path contains one of those tokens, because `git diff` emits `+++ b/<path>` with a leading `+`. Concrete run: the agent adds `FIXME.md` (a ticket note) or `TODO.md`; the diff header `+++ b/FIXME.md` matches, so clause 5 reports `FAIL 5 … 1 added line(s) hold TODO/FIXME/not-implemented` when no added content line contains any of those tokens. The submission is falsely failed, and the fixture set does not catch it — its only clause-5 case (verify-completion-contract-checker.sh:108) puts the `TODO` inside the file body, never in a filename.
**Layer of the implied fix:** L2 (the check runs; excluding `+++`/`---` header lines keeps it running and correct)

Two further defects in the same file, lesser than the above: (a) the deny-list matcher double-counts a single-level match — a changed `service/pom.xml` matches both the basename case (line 158) and the glob case (line 162), so line 174 prints "2 path(s) match" for one file; the verdict is unaffected but the count is wrong. (b) Exit-code precedence at lines 203–214: a run that FAILs clause 5 *and* reads a zero-pattern policy exits 2, not 1, because the `ZERO_PATTERNS` branch returns before `[[ "$FAILED" -eq 0 ]] || exit 1`. A decidable failure is downgraded to "inconclusive" in the exit code, visible only in the text — downstream automation keying on the code will retry a genuinely failing submission.

### verify-run-state-checker.sh
**Verdict:** no finding
The fixture set exercises presence, type, emptiness, integrality, the registered-ceiling invariants, the handoff field set (including the null-is-valid negative control), and the enum exactness. The known-good case is generated by running the real hook rather than hand-writing the schema, which is the right provenance. The `reserved` substring defect above lives in the checker, not here; the fixture correctly tests only that `reserved: "tbd"` (which lacks `B8a`) fails, and never tests a value that *contains* `B8a` while denying it — the gap that lets the defect through, but that is a consequence of the checker's bug, not a defect in this file's logic.

### verify-completion-contract-checker.sh
**Verdict:** no finding
The negative controls are the valuable part and they hold up under inspection: a pre-existing `TODO` in the baseline is not blamed on the run (lines 126–133), the empty-summary case fails rather than passing on existence (117–120), and the zero-pattern policy is asserted to print `UNDECIDABLE` and not `PASS` (152–160). The guard-vs-functional mapping for evaluator exits 20/21 vs 12/13 is tested both directions.

### Cross-cutting
- **Duplicate pass/fail gate:** clause 2 ("build passed") and clause 3 ("required tests passed") in `check-completion-contract.sh` are two `pass`/`fail` lines emitted from a single instrument — the evaluator's exit code. The script itself flags this (`TWO LINES FROM ONE INSTRUMENT`, line 201), but the fixture set still treats them as separable assertions (lines 78–83 assert `FAIL` on each independently). Two decidable clauses, one observation; a reader counting "5 of 7 decidable" is counting the same fact twice.
- **Greatest divergence risk:** the exit-code precedence in `check-completion-contract.sh` — a FAILed clause 5 combined with a zero-pattern policy. Two reviewers will disagree on whether the process should report 1 (a clause failed) or 2 (nothing authoritative was decided), and the script's own comments claim both meanings for 2 without stating precedence when both conditions hold. I'd expect divergence of roughly one verdict in two on a submission that trips both.
- **What it did not say:** the artifact never states that the deny-list matcher and the `reserved` substring test are inconsistent with the exact-match discipline the comments advertise, nor does the fixture set contain a case that would catch the diff-header false positive (a file named `TODO`/`FIXME`/`XXX`) or a `reserved` value that contains `B8a` while contradicting it. Both defects survive the entire fixture set because no fixture targets the failure mode — which is the precise failure the set exists to prevent.
