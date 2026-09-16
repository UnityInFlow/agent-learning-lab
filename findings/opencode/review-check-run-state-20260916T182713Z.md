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
reviewed_utc:    20260916T182713Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-run-state.sh
    sha:  495bc140e443
    dirty: false
  - path: tools/check-completion-contract.sh
    sha:  edbb494d8860
    dirty: false
  - path: tools/verify-run-state-checker.sh
    sha:  a1e64f8e8530
    dirty: false
  - path: tools/verify-completion-contract-checker.sh
    sha:  0eee588ff234
    dirty: false
lab_head:        5d23904
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/tools/check-completion-contract.sh
  verdict: REJECT
  summary: The completion-contract checker prints `PASS 6 ... 0 deny pattern(s) read; no changed path matches` on stdout for any policy the `sed` extractor parses to zero patterns, then the same script's `ZERO_PATTERNS` branch writes `clause 6 read no rules` to stderr and `exit 2` fires — the body contradicts its own comment ("ZERO PATTERNS IS UNDECIDABLE, NOT PASS") on the one clause the script calls authoritative, and the verify suite pins the exit code but never asserts what the per-clause stdout line says.
  blocking:
    - reason: check-completion-contract.sh emits `PASS 6` to stdout when HITS=0 AND NPAT=0, then immediately afterwards the `ZERO_PATTERNS` branch fires `exit 2`. The same script's comment at lines 123–124 says "ZERO PATTERNS IS UNDECIDABLE, NOT PASS", but stdout disagrees with the exit code on the very clause the script calls itself authoritative on (line 115–116).
      wrong_action: A downstream parser reading the per-clause lines (the shape `verify-completion-contract-checker.sh`'s own `line()` helper relies on at line 36) sees `PASS` for clause 6 and counts it as decided; the same parser reading the exit code sees `UNDECIDABLE`; the two surfaces return opposite verdicts on the authoritative clause, so a CI gate that consumes the line-by-line output trusts a clause the script itself says it could not decide.
      anchor: pass 6 "no forbidden files changed" "$NPAT deny pattern(s) read; no changed path matches"
      evidence: check-completion-contract.sh:150
  non_blocking:
    - reason: check-run-state.sh only type-checks `.worktree`, `.startedAt`, `.updatedAt`, `.phase` (lines 38–41); empty strings pass `want_type string`. The validator's "valid against schema b8-v1.1" line therefore admits a run-state whose identity fields are empty. Improvement is to add non-empty checks; the current check does what it claims (type) and does not falsely assert anything stronger.
      evidence: check-run-state.sh:38-41
    - reason: check-completion-contract.sh derives clauses 2 and 3 from the single `--evaluator-exit` value (lines 80–92), so a build-success / test-failure run (exit 21) is reported as FAIL/FAIL rather than PASS/FAIL. The script's own output note at line 175 (`clauses 2 and 3 are TWO LINES FROM ONE INSTRUMENT`) names this — a documented limitation, not a hidden defect.
      evidence: check-completion-contract.sh:175
    - reason: check-run-state.sh pins `REG_PER=3` / `REG_TOTAL=7` (lines 94–95) as a second copy of constants also living in `repair-limit.sh` and `build/README.md#b8`; a tuning pass that raises the limit in the hook and README will cause the checker to reject valid output. The comment at lines 86–93 acknowledges this trade-off explicitly — the prior design read from the file and was worse (the file graded its own homework), so the duplication is deliberate, not a hidden coupling.
      evidence: check-run-state.sh:86-101
    - reason: check-completion-contract.sh's exit precedence at lines 176–187 lets `ZERO_PATTERNS` (exit 2) override a real clause failure (exit 1): a run with an added TODO and a zero-pattern policy exits 2, not 1. This is a documented design choice (lines 32–33 treat zero-pattern policy as "nothing could be decided"), not a hidden ordering.
      evidence: check-completion-contract.sh:176-187
    - reason: verify-run-state-checker.sh's fixture set (lines 66–79) does not probe empty-string values for `.worktree`, `.startedAt`, `.updatedAt`, or `.phase`. If check-run-state.sh is strengthened to require non-empty identity strings, this suite needs a matching fixture for the strengthened check.
      evidence: verify-run-state-checker.sh:66-79
    - reason: verify-completion-contract-checker.sh asserts `exit 2` for a zero-pattern policy (lines 129, 133) but never asserts what stdout says for clause 6 in the same scenario. The suite is the reason the stdout `PASS` line for clause 6 ships unverified; deepseek's own note at line 71 of the line-level pass names this. A strengthening should also assert the per-clause stdout line is `UNDECIDABLE` (or, at minimum, not `PASS`) when the policy parses to zero.
      evidence: verify-completion-contract-checker.sh:127-135
  disputed:
    - finding: "codex finding 1 (check-run-state.sh) — empty strings for `.worktree`, `.startedAt`, `.updatedAt`, `.phase` cause the validator to admit a run-state that cannot identify a produced run."
      why: "I can substantiate the gap from the artifact (lines 38–41 are the only checks on those fields, and `want_type` admits empty strings), but the artifact's claim is type validity, not content validity. The defect is a missing check, not a wrong check — the validator does what it claims and does not falsely assert non-emptiness. A diligent reader who reads the source can see the limit. Borderline; rated non-blocking on the test 'name what a reader would do wrong because of it' — they would trust an exit-0 with empty identity strings, but the type check is the only thing on offer here."
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 40s |
| ollama-cloud/deepseek-v4-pro | ok | 237s |

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
| tools/check-run-state.sh | 1/2 | L2 |
| tools/check-completion-contract.sh | 1/2 | L2 |
| tools/verify-run-state-checker.sh | 1/2 | L2 |
| tools/verify-completion-contract-checker.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| check-run-state.sh | 1/2 | L1 |
| check-completion-contract.sh | 1/2 | L1 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/check-run-state.sh
**Verdict:** finding
**Failure:** Starting from the known-good fixture, set `.worktree`, `.startedAt`, `.updatedAt`, and `.phase` to empty strings. The checker exits 0 because it verifies only that they are strings. One reviewer can therefore call the file valid against `b8-v1.1`, while another rejects it because an empty worktree, phase, or timestamp cannot identify a produced run. The executable validator gives the wrong authoritative answer.
**Layer of the implied fix:** L2
**Anchor:** want_type '.worktree'                   string
want_type '.startedAt'                  string
want_type '.updatedAt'                  string
want_type '.phase'                      string

### tools/check-completion-contract.sh
**Verdict:** finding
**Failure:** Run an evaluator whose compilation/build stage succeeds but whose test stage fails and exits 21, then invoke the checker with `--evaluator-exit 21`. The script reports both clause 2 (`build passed`) and clause 3 (`required tests passed`) as FAIL. A reviewer using the evaluator’s stage results marks clause 2 PASS and clause 3 FAIL; a reviewer trusting this checker marks both FAIL. A single aggregate exit code cannot decide the two clauses independently.
**Layer of the implied fix:** L2
**Anchor:** else
    fail 2 "build passed"          "evaluator exit $EVAL_EXIT (shared source, see note)"
    fail 3 "required tests passed" "evaluator exit $EVAL_EXIT (shared source, see note)"

### tools/verify-run-state-checker.sh
**Verdict:** finding
**Failure:** Mutate the known-good file to `.worktree = "" | .startedAt = "" | .updatedAt = "" | .phase = ""` and run this fixture suite. The defective checker still exits 0 for that file, and the suite itself also exits 0 because it has no fixture for empty required scalars. One reviewer treats the passing suite as evidence that required scalar semantics are enforced; another observes that only JSON types were tested.
**Layer of the implied fix:** L2
**Anchor:** echo "REFUSES a field of the wrong type — a schema that only checks presence is not a schema:"
expect "totalRepairAttempts as a string"   1 "$(mutate '.totalRepairAttempts = "3"')"
expect "affectedFiles as an object"        1 "$(mutate '.affectedFiles = {}')"

### tools/verify-completion-contract-checker.sh
**Verdict:** finding
**Failure:** Use an evaluator run in which the build succeeds and required tests fail with exit 21. This suite requires clause 2 to be FAIL, so it passes only when the completion checker misclassifies the successful build. A reviewer using stage-specific evidence expects clause 2 PASS; this executable fixture enforces FAIL.
**Layer of the implied fix:** L2
**Anchor:** [[ "$(line 2)" == FAIL ]] && ok "clause 2 (build) FAILS on evaluator exit 21" "FAIL" || bad "clause 2" "FAIL" "$(line 2)"

### Cross-cutting
**Verdict:** finding
**Failure:** Clauses 2 (`build passed`) and 3 (`required tests passed`) duplicate the single `--evaluator-exit` pass/fail gate rather than representing independent decisions. Reviewers would diverge most on `tools/check-completion-contract.sh`: for a build-success/test-failure run, one produces PASS/FAIL while the artifact produces FAIL/FAIL, a one-clause difference. The evidence set does not define the evaluator exit code’s stage semantics, non-empty/format constraints for required run-state strings, or an executable condition under which the seven-clause completion contract as a whole is satisfied.
**Layer of the implied fix:** L2
**Anchor:** NOTE: clauses 2 and 3 are TWO LINES FROM ONE INSTRUMENT (the evaluator's exit code). They are not two independent decisions.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

→ Read build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh
→ Read build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml
### check-run-state.sh
**Verdict:** finding
**Failure:** The registered ceilings are hardcoded here (`REG_PER=3`, `REG_TOTAL=7`) as a second copy of constants that also live in `repair-limit.sh` (`MAX_PER_FINGERPRINT=3`, `MAX_TOTAL=7`) and in `build/README.md#b8`. A later stop that raises the limit — e.g. a tuning pass sets `MAX_PER_FINGERPRINT=5` in the hook and updates the README — leaves this file pinning `3`. Every run-state file the real hook then writes (`limits.maxRepairAttemptsPerFailure: 5`) is rejected as `expected the registered 3, found 5`. One reviewer reading this file concludes "3 is the registered value"; another reading `repair-limit.sh` concludes "5 is the registered value." Nothing executes a cross-check between the two copies, so the disagreement is silent until the checker rejects valid output.
**Layer of the implied fix:** L1
**Anchor:** `REG_PER=3` / `REG_TOTAL=7` (lines 94–95), defended at lines 86–93 as "they are written here and the file's own `.limits` block is now CHECKED AGAINST them" — the defense removes the file-grades-its-own-homework vector but introduces a checker-vs-hook drift vector in the same stroke.

---

### check-completion-contract.sh
**Verdict:** finding
**Failure:** Clause 6 prints `PASS` while the script exits 2, contradicting its own stated policy. Give it a policy the `sed` extractor cannot parse (4-space indentation, or unquoted scalars — exactly the shapes in the fixture). `NPAT` comes out 0, the match loop runs zero times, `HITS` is trivially 0, and line 150 emits `PASS 6. no forbidden files changed ... 0 deny pattern(s) read; no changed path matches`. Then lines 176–179 write "the policy file parsed to ZERO deny patterns — clause 6 read no rules" to stderr and `exit 2`. A reviewer who reads the stdout line concludes clause 6 passed; a reviewer who reads the exit code concludes it was undecidable. Same run, opposite verdicts on the one clause the script calls itself authoritative on. `verify-completion-contract-checker.sh` (lines 126–135) asserts only `exit 2` and never asserts what the clause-6 line says, so the contradiction ships unverified.
**Layer of the implied fix:** L1
**Anchor:** `pass 6 "no forbidden files changed" "$NPAT deny pattern(s) read; no changed path matches"` (line 150), against the script's own claim at lines 123–124: "ZERO PATTERNS IS UNDECIDABLE, NOT PASS."

Secondary, same block: the exit precedence at lines 176–187 lets a zero-pattern policy override a genuine clause failure — if clause 5 fails *and* the policy parses to zero, the script exits 2 (undecidable) rather than 1 (a decidable clause failed), because the `ZERO_PATTERNS` branch is reached before the `FAILED` branch. Two reviewers disagree on which exit is correct for a run that has both a real failure and an unparseable policy.

---

### verify-run-state-checker.sh
**Verdict:** no finding
**Failure:** n/a — traced the known-good production path (runs the real `repair-limit.sh` hook rather than hand-writing the schema), the per-field removal/type-mutation cases, the invariant violations, and the negative controls (on-both-limits valid, null-handoff valid, populated-handoff valid); expected exit codes all line up with the checker's logic.
**Layer of the implied fix:** n/a
**Anchor:** n/a

---

### verify-completion-contract-checker.sh
**Verdict:** no finding
**Failure:** n/a — traced the git state across all twelve commits/reverts/rebases in the fixture; the fresh-baseline handling at lines 139–144 is correct (reusing `$BASE` there would have caused a spurious clause-6 failure unrelated to the test's intent), the zero-pattern and unresolvable-baseline cases assert the right exit codes, and the negative controls (pre-existing TODO, registered policy still parsing) are sound. Note: this file is the reason the clause-6 contradiction in the checker goes uncaught — it checks the exit code, never the PASS line — but that is a gap in the checker it exercises, not a defect in the fixture itself.
**Layer of the implied fix:** n/a
**Anchor:** n/a

---

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both. Within `check-completion-contract.sh`, clauses 2 ("build passed") and 3 ("required tests passed") are both derived from the single `--evaluator-exit` value — the script itself flags this with "TWO LINES FROM ONE INSTRUMENT," so they are one gate rendered as two clauses that can never disagree. That is a duplication of a gate, stated but not restructured.
- Which single section would you expect two reviewers to diverge on most, and by how much? `check-completion-contract.sh` clause 6 — a full PASS-vs-UNDECIDABLE disagreement on the clause the script claims to be authoritative on, depending on whether the reviewer trusts the printed line or the exit code. That is the widest divergence in the set.
- What did the artifact not say that it needed to say? Two things. `check-run-state.sh` documents the *values* of `REG_PER`/`REG_TOTAL` but not where the single source of truth is or how the hook's `MAX_PER_FINGERPRINT`/`MAX_TOTAL` are kept in sync with it — the coupling is the thing that needed stating, not the numbers. And `check-completion-contract.sh` says "ZERO PATTERNS IS UNDECIDABLE, NOT PASS" in a comment while the code emits `PASS`; the artifact asserts one behaviour and implements another, and no fixture closes that gap.
