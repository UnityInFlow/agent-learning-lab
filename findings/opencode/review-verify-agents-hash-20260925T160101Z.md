# opencode review — verify-agents-hash

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
reviewed_utc:    20260925T160101Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: ../agent-observatory/runner/verify-agents-hash.sh
    sha:  20ab61bc2ad3
    dirty: false
lab_head:        955e05c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory/runner/verify-agents-hash.sh
  verdict: ACCEPT
  summary: The fixture script is correct: nine well-distinguished cases (A–I) drive the real runner via --check-customization, the EXPECTED_CASES guard catches scope drift, and the comment on F correctly pins rename-vs-edit as a pair. Two wording overclaims in comments are worth fixing but do not mislead any reader into a wrong action.
  blocking: []
  non_blocking:
    - reason: The F-case comment (lines 132–136) claims the values are "DEMONSTRATED, not argued, on the ONE and RENAMED fixtures of this file", but the shown hashes are 32 hex chars (MD5-shaped) while every assertion below uses sha256:*. A reader debugging a case D failure would compare the demonstrated values against the runner's real 64-char SHA-256 output and conclude the runner is wrong. The teaching's conclusion (content-only collides on rename, path-including does not) is sound; the word "DEMONSTRATED" overclaims the provenance of the specific values.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory/runner/verify-agents-hash.sh:132-136
    - reason: The RENAMED fixture builds gamma.md with frontmatter name: alpha but dispatches --agent gamma (lines 65, 76). If run-agent.sh validates --agent against frontmatter name before computing customization hashes, D fails with "a rename was invisible" instead of a validation error — a real failure, but the message would misdirect debugging. The artifact does not document which resolution rule --check-customization assumes.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory/runner/verify-agents-hash.sh:65,76
    - reason: The header's "cases D, E and F below are that clause and nothing else" reads as "all three test the same thing", while F's own comment (lines 119–141) explicitly divides the labour — D catches a content-only digest, E catches a path-only digest, F pins the two apart as a pair. A reader who stops at the header would form a slightly wrong mental model, but the inline F comment corrects it on the same page; no wrong action follows.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory/runner/verify-agents-hash.sh:9,119-141
  disputed:
    - finding: First-pass cross-cutting note that the artifact does not specify whether agentsHash covers only top-level .claude/agents/*.md or recursively includes subdirectories, leaving a coverage gap.
      why: The header at line 6 states the glob explicitly as "the SET of .claude/agents/*.md"; recursive inclusion is a different feature, not a gap in the stated scope. The fixtures test the stated glob, and changing the glob would be a deliberate contract change, not a silent regression the script is hiding.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 96s |
| ollama-cloud/glm-5.2 | ok | 87s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| # --- fixtures --- | 1/1 | L3 |
| # F — | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### WHAT IS BEING PROVED
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header claims `agentHash` covers one file and `agentsHash` covers the set, attributes the clause to "decision 11 item 9," and asserts cases D, E, and F are "that clause and nothing else." F's own comment (lines 119–141) refines this: D detects a content-only digest, E detects a path-only digest, and F pins the two apart as a pair against a lossy fold. The header groups them; F's comment divides the labour. A reader who trusts only the header might read "that clause and nothing else" as "all three test the same thing," but F's comment is co-located and explicit. No wrong answer results.

### WHY IT DRIVES THE REAL RUNNER
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The claim that every case drives the real runner via `--check-customization` and that "no model call is made and no money is spent" is structurally sound: the `run()` helper (line 49–50) appends `--check-customization` to every invocation, and the runner is expected to exit before launching an agent. The script does not verify that no model call was made — it assumes the runner's `--check-customization` flag works as advertised. If that flag regressed, the test would still pass (it extracts hashes from whatever output appears) while money was spent silently. But the test's job is the hash behaviour, not the runner's cost behaviour; verifying the absence of a model call would require a different instrument.

### EXPECTED_CASES=9
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`EXPECTED_CASES=9` matches cases A through I. The final count check (lines 181–185) catches a case added without registration (`ran > EXPECTED_CASES`) and a case silently skipped (`ran < EXPECTED_CASES`). It does not protect against deletion — a removed case with a decremented `EXPECTED_CASES` passes the count check while losing the guarantee. This is a known limitation of count-based guards, not a defect; each case's comment explains its rationale, which is L3 protection against deletion.

The API health check (lines 25–28) gates the entire suite on a running observatory API. The comment at line 27 explains why: the real runner refuses to start without it. Mocking the API would test a copy of the control, which the header explicitly rejects (lines 12–14). The dependency is correct for the stated design.

`set -uo pipefail` without `-e` is deliberate: the script uses explicit `rc` checks in `agents_hash_of`, case A, and case H, and a failed `agent_file` write would produce a wrong hash caught by the case checks. Adding `-e` would cause premature exits on expected non-zero return codes (e.g., `agents_hash_of`'s error path).

### agents_hash_of
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `ERROR:$rc` sentinel (line 56) ensures two broken runs never compare equal — a content-only digest that also fails would produce `ERROR:1` for both REN and CHG, and case F's `sha256:*` check would reject them. The grep pattern `"agentsHash":[^,}]*` is specific enough: SHA256 hex strings contain no commas or braces, and `"agentHash":` (singular, used in case H) does not match inside `"agentsHash":` (plural) because the `s` breaks the pattern at position 7. If the runner succeeds but omits `"agentsHash":` from its output, the function returns an empty string, which fails every `sha256:*` and `== "$H_ONE"` check downstream — caught, not silently passed.

### # --- fixtures
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The RENAMED fixture (line 65) writes `gamma.md` with frontmatter `name: alpha` and dispatches `--agent gamma`. This is intentional: the test is about the file path in the digest, not the frontmatter name. If the runner resolves agents by frontmatter name rather than filename stem, `--agent gamma` would fail to find `name: alpha`, `agents_hash_of` would return `ERROR:$rc`, and case D would fail — surfacing the runner behaviour, not producing a wrong answer. The COPY fixture (line 69) is built independently from ONE with byte-identical content, correctly testing determinism through a separate construction path. The PLAIN fixture (line 70) has no `.claude/agents/` directory, correctly testing the null case.

### == agents_hash: the SET of .claude/agents/*.md ==
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Cases A through I are exhaustive against the digest failure modes the header claims to cover:

- A: null on empty set — without this, a hash that is non-null on everything satisfies every other case.
- B: non-null on non-empty — confirms A is not vacuously satisfied.
- C: adding a member moves the hash — proves the set, not just the dispatched file.
- D: rename (same content, different path) moves the hash — catches a content-only digest. F's comment (lines 122–136) demonstrates this with computed values.
- E: edit (same path, different content) moves the hash — catches a path-only digest.
- F: rename hash ≠ edit hash — catches a lossy fold that moves on both but collides. Not redundant with D and E: both can differ from H_ONE while being equal to each other.
- G: byte-identical independent construction hashes the same — catches a digest that includes non-content metadata (e.g., directory path, mtime).
- H: `agentHash` ≠ `agentsHash` on a two-file overlay — proves the two columns measure different things.
- I: removing a member returns the hash to the one-file value — complement to C; catches a digest that folds new members in without re-deriving from the current file list.

Case H compares `agentHash` from a fresh run against `agentsHash` cached in `$H_TWO` from an earlier run, rather than extracting both from the same output. If the runner were non-deterministic, this comparison would be invalid — but case G pins determinism, so the dependency is explicit. Case H's grep for `"agentHash":` does not match `"agentsHash":` because the `s` in `agentsHash` breaks the pattern.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. This is a fixture script, not a rubric. The cases test hash behaviour, not gate compliance.
- Which single section would you expect two reviewers to diverge on most, and by how much? The header's "cases D, E and F below are that clause and nothing else" vs F's comment placing F as "the second line of the guarantee, not the first." A reviewer skimming the header might question F's necessity; a reviewer reading F's comment would not. The divergence is small — both would keep F once they read its comment — but it is the only place where the artifact's framing and its own inline reasoning are in tension.
- What did the artifact not say that it needed to say? The artifact does not specify whether `agentsHash` covers only top-level `.claude/agents/*.md` or recursively includes subdirectories. The fixtures create only top-level files, so a runner that changed its glob from `*.md` to `**/*.md` would not be caught. This is a coverage gap, not a defect — the test covers what it claims to cover.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### WHAT IS BEING PROVED
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header correctly states the scope: `agentHash` covers one file, `agentsHash` covers the set, and cases D/E/F are the registered clause (decision 11 item 9). The claim is accurate against the cases that follow.

### WHY IT DRIVES THE REAL RUNNER
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Every case invokes `run-agent.sh --check-customization` on the real code path. The rationale — a fixture that re-implemented the digest would test a copy of the control — is the correct argument against a mock-based test here.

### Setup and helpers
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`set -uo pipefail` without `-e` is correct for this structure: every case uses explicit `ok`/`bad` calls, so `-e` would add nothing. The `ERROR:$rc` sentinel in `agents_hash_of` prevents two broken runs from comparing equal — a real trap that is correctly guarded. The API health check before any case runs is appropriate given the design constraint.

### # --- fixtures ---
**Verdict:** finding
**Failure:** The RENAMED fixture (`REN`) creates `gamma.md` with `name: alpha` in the frontmatter and passes `--agent gamma` on line 76. If `run-agent.sh` validates the `--agent` flag against the frontmatter `name` field *before* computing customization hashes (a plausible ordering, since `--check-customization` still needs to resolve which agent is dispatched), the runner rejects the invocation and `agents_hash_of` returns `ERROR:$rc`. Case D then fails with the message "a rename was invisible" — misattributing a fixture-construction mismatch to the hash computation. Two reviewers would diverge on the fix: one changes the frontmatter to `name: gamma` (which alters the file content and makes D pass for the wrong reason — content changed, not just path), the other changes `--agent` to `alpha` (which may not match the filename `gamma.md` if the runner resolves by filename). The fixture is caught between two constraints — identical content to ONE, and a `--agent` flag that matches the new filename — and the artifact does not say which way the runner resolves the agent identity during `--check-customization`.
**Layer of the implied fix:** L3
**Anchor:** `agent_file "$REN/.claude/agents/gamma.md"  alpha  "Body A."`

### # A —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The null baseline is correctly constructed: PLAIN has a CLAUDE.md but no `.claude/agents/` directory. Without this case, a hash that is non-null on everything would satisfy every case below. The grep for `"agentsHash":null` is consistent with the runner's compact JSON output format used by the other cases.

### # B —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### # C —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### # D —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The case itself is structurally correct: it tests that a renamed file (same content, different path) produces a different hash. The fixture-construction concern is reported above under the fixtures section, not here, because the issue is in how `REN` is built, not in what D asserts.

### # E —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### # F —
**Verdict:** finding
**Failure:** The comment on lines 132–136 claims "DEMONSTRATED, not argued, on the ONE and RENAMED fixtures of this file" and shows hash values `one = 7256986d2a4de9aa4a7d0b1012091c2a` and `ren = ea5fba4f3f610e938a6c2da36208c063`. These are 32-hex-character MD5 digests. The runner produces `sha256:`-prefixed 64-hex-character digests (as every case assertion confirms with `== sha256:*`). A reviewer debugging a case D failure who reads this comment and compares the runner's actual output (`sha256:b035…`, 64 chars) against the demonstrated values (`b035a37b…`, 32 chars) would conclude the runner is producing wrong values, when in fact the comment shows digests computed with a different algorithm than the runner uses. The word "DEMONSTRATED" asserts these are the runner's outputs on the actual fixtures; they cannot be.
**Layer of the implied fix:** L3
**Anchor:** `DEMONSTRATED, not argued, on the ONE and RENAMED fixtures of this file:`

### # G —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### # H —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### # I —
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Final assertion
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `EXPECTED_CASES=9` guard against `ran != EXPECTED_CASES` is a correct structural control: it catches scope drift (a case added or removed without updating the constant) that would otherwise pass silently. The count matches the nine cases A–I.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a test script, not a scoring rubric. No case duplicates another: F (rename ≠ edit) is not entailed by D (rename ≠ original) and E (edit ≠ original) together, because both could differ from the original while colliding with each other. The comment at lines 119–130 correctly identifies this and warns against deleting D as redundant.
- Which single section would two reviewers diverge on most, and by how much? The F comment's demonstrated hash values. One reviewer reads "DEMONSTRATED on the fixtures" literally and flags the MD5/SHA-256 mismatch as a documentation defect; another reads it as an illustrative analogy with a different algorithm and dismisses it. The divergence is on whether "DEMONSTRATED" is a factual claim about the runner's output or a pedagogical device — a difference of interpretation that the wording does not resolve.
- What did the artifact not say that it needed to say? It does not specify how `run-agent.sh` resolves the `--agent` flag during `--check-customization` — by filename, by frontmatter `name`, or not at all before computing hashes. Case D's fixture (`gamma.md` with `name: alpha`, dispatched as `--agent gamma`) is correct only under the third assumption. If the runner validates before hashing, D fails for a reason the failure message does not name.
