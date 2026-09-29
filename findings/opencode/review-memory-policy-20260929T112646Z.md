# opencode review — memory-policy

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
reviewed_utc:    20260929T112646Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: governance/memory-policy.md
    sha:  16deb4edf343
    dirty: false
lab_head:        2f0044b
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: governance/memory-policy.md
  verdict: REJECT
  summary: Two internal contradictions make the artifact's governance answers unreliable as written: §2's "code only" for memtrace confidentiality contradicts §1's scope that includes agent-written decisions, and §3's bold "no" to "has anything ever removed a stale fact?" is contradicted by the next sentence's manual removal on the same date the paragraph names.
  blocking:
    - reason: §2's memtrace column answers "code only" for confidential-data eligibility, but §1 explicitly includes "decisions" in memtrace's scope — Cortex decision memory holds free-text agent-written rationale, the same risk vector the Claude auto memory column flags as "yes, and nothing prevents it." The artifact's own §1 contradicts its own §2.
      wrong_action: A reader trusting §2 over §1 writes confidential rationale into Cortex decision memory believing memtrace is "code only" and therefore safe; the artifact's own scope says the decision layer is part of memtrace, so the safety claim doesn't extend there. Symmetrically, an auditor using §2 to scope a memtrace redaction sweep excludes the decision layer, which is the actual exposure.
      anchor: "memtrace              → code. Symbols, call graphs, 'why is this here', decisions."
      evidence: governance/memory-policy.md:21; governance/memory-policy.md:41
    - reason: §3's bold answer to "Has anything ever *removed* a stale fact?" is "no" with the qualifier "Not once in the 52 days the corpus has existed," but the very next sentence states "The seven false claims were corrected on 2026-09-29 after the audit file was frozen, and that is the first removal this corpus has had." Today is 2026-09-29 per the artifact's preamble, so the correction falls inside the 52-day window the paragraph itself names.
      wrong_action: A reader recording the headline answer as a fact about the corpus writes "0 removals ever" when the truth is "0 automated removals, 1 manual removal triggered by this lab." The intended reading is recoverable only from the trailing qualifier "triggered by a lab, not by anything that runs" — but the bold "no" and the "not once in 52 days" qualifier do not carry that qualifier upstream, and policy headlines are read as written.
      anchor: "**\"Has anything ever *removed* a stale fact?\"** — **no.** Not once in the **52 days** the corpus has existed"
      evidence: governance/memory-policy.md:63
  non_blocking:
    - reason: §2 memtrace staleness row answers "re-index overwrites," which is a remedy after detection, not detection itself. The honest answer (matching the Claude column's "it is not") would be that memtrace has no staleness detection either — only a stale-entry cure that runs on re-index. Off-topic answer makes the memtrace/Claude comparison fuzzy.
      evidence: governance/memory-policy.md:42
    - reason: §3 partition arithmetic is ambiguous. "11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided by running anything" sums to 26 if disjoint, 25 if "true but obsolete" is nested inside the 11. Counts themselves (7 false) are unambiguous; only rate computation (7/25 = 28% vs 7/24 ≈ 29.2%) diverges between readings.
      evidence: governance/memory-policy.md:51
    - reason: §4 cites "§6 forbids" for the audit's L1-as-record classification, but the artifact has five sections; §6 does not exist here. A reader without external context (run prompt, phase README) cannot verify the L1 claim. The classification is interpretive — no prescription hangs on it — so the dangling reference weakens the artifact's central example without breaking its argument.
      evidence: governance/memory-policy.md:72
    - reason: §1's Postgres row bundles "(not yet built) learned knowledge" with the existing 742 run records under one column header, and §2's column answers "forever" and "cannot go stale" without scoping to the existing records. A reader cannot tell which properties are measured (current) vs prescribed (future). The "(not yet built)" parenthetical is a visible flag, but the table does not carry it through.
      evidence: governance/memory-policy.md:23; governance/memory-policy.md:39
  disputed:
    - finding: First critic's §3 finding quotes "the 21 days the corpus has existed" as the window inside which the manual removal contradicts the bold "no."
      why: governance/memory-policy.md:63 actually says "the **52 days** the corpus has existed (oldest memory file born 2026-08-08, newest 2026-09-25)." The "21" number is the critic's misquote. The substantive contradiction (the correction on 2026-09-29 falls inside the window the paragraph names) still holds; only the window length is wrong in the finding's quote.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 46s |
| ollama-cloud/glm-5.2 | ok | 91s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| ## 1. Ownership — who owns what, and what "owns" means | 1/1 | L3 |
| ## 2. The governance questions, answered | 1/1 | L3 |
| ## 3. Lab 9.4's three questions | 1/1 | L3 |
| ## 4. Layers — applied in order, stopping at the first yes | 1/1 | L3 |
| 2. The governance questions, answered | 1/1 | L3 |
| 3. Lab 9.4's three questions | 1/1 | L3 |
| 4. Layers — applied in order, stopping at the first yes | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### ## 1. Ownership — who owns what, and what "owns" means
**Verdict:** finding
**Failure:** The Postgres row says "runs, evaluations, and (not yet built) learned knowledge," bundling an existing system (run records) with one that does not exist yet. Section 2's governance table then answers "how long: forever" and "how is staleness detected: run records are immutable" under a single "Observatory Postgres" column. A reviewer reading that column cannot tell whether "forever" and "cannot go stale" apply to the learning store too — which is unbuilt and whose properties are therefore unmeasured. One reviewer scopes the answers to run records only; another reads the column header at face value and takes "cannot go stale" as a claim about the future learning store. The audit verified 742 run records; it cannot have verified a store that does not exist.
**Layer of the implied fix:** L3
**Anchor:** `Observatory Postgres  → runs, evaluations, and (not yet built) learned knowledge.`

### ## 2. The governance questions, answered
**Verdict:** finding
**Failure:** The memtrace row answers "how is staleness detected" with "re-index overwrites." Overwriting is a remedy, not a detection mechanism. If a symbol is deleted from git and memtrace is not re-indexed, nothing in memtrace flags the stale entry — re-indexing replaces it blindly when invoked, but nothing *detects* it in the interim. The Claude auto-memory column in the same row says "it is not" (no detection), which is the honest answer for an un-checked corpus. Two reviewers reading the memtrace row diverge: one accepts "re-index overwrites" as answering the question, the other says memtrace has no staleness *detection* either — only a staleness *cure* — and the row should say so. The distinction is load-bearing because the rest of the document's argument turns on the absence of detection being the defect.
**Layer of the implied fix:** L3
**Anchor:** `re-index overwrites`

### ## 3. Lab 9.4's three questions
**Verdict:** finding
**Failure:** Two defects in the same section.

First, the headline count. "11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided by running anything" reads as four disjoint categories summing to 26, but the declared n is 25. The total only works if "1 is true but obsolete" is a subset of the 11, not a fourth bucket. A reviewer who reads the comma list as a partition concludes the arithmetic is wrong (26 ≠ 25); a reviewer who nests the obsolete-one-inside-the-true concludes it is correct. The sentence does not disambiguate.

Second, the third question's answer contradicts itself. "Has anything ever removed a stale fact? — no. Not once in the 21 days the corpus has existed." The next sentence: "The seven false claims were corrected on 2026-09-29 after the audit file was frozen, and that is the first removal this corpus has had." Today is 2026-09-29 and the corpus has existed 21 days, so the correction falls inside the window "the 21 days the corpus has existed." The bold answer "no" and the qualifier "not once in 21 days" are both literally false under the paragraph's own timeline. One reviewer reads "no" as "no automated mechanism" (the intended reading); another reads the question literally — "has anything ever removed" — and finds the answer is "yes, once, today, by this lab." The paragraph resolves the intent but the headline answer does not match it.
**Layer of the implied fix:** L3
**Anchor:** `11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided by running anything.`

### ## 4. Layers — applied in order, stopping at the first yes
**Verdict:** finding
**Failure:** The "frozen audit" row justifies its L1-as-record claim with "no later session can make it say otherwise without rewriting a committed file — which §6 forbids." There is no §6 in this artifact. The document has five sections. A reader holding only this document cannot verify the claim that something forbids rewriting the audit, because the thing that forbids it is referenced by a section number that does not exist here. One reviewer assumes §6 lives in an external document (the run prompt) and accepts the L1 claim; another reads the artifact as self-contained, finds a dangling reference, and cannot confirm the L1 classification — which drops the audit row back to L3, since the only thing making it L1 is the external prohibition the reader cannot see.
**Layer of the implied fix:** L3
**Anchor:** `no later session can make it say otherwise without rewriting a committed file — which §6 forbids.`

### ## 5. What is not built, and the reason
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Preamble (unkeyed, lines 1–11)
**Verdict:** skipped
**Failure:** The preamble carries provenance claims ("every number here is frozen in [audit file]", "The author did not review this before it was written") that I cannot verify without reading the referenced audit file, which is not attached. I am skipping rather than guessing.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? This is not a rubric; it has no scoring categories. The ownership table's "authoritative vs Git" row restates what §4 classifies as L3, but that is a redundancy within the same document, not a category duplicating an external gate.
- The section two reviewers would diverge on most is §3, and by a wide margin — the arithmetic ambiguity (26 vs 25) and the self-contradicting "no" answer each independently produce divergent readings, and a reviewer who catches one is not guaranteed to catch the other.
- What the artifact did not say that it needed to say: where §6 lives. The L1 classification of the audit record — the one structural claim in the document — rests entirely on a reference the document does not resolve.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### 1. Ownership — who owns what, and what "owns" means
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 2. The governance questions, answered
**Verdict:** finding
**Failure:** The "can it hold confidential data" row answers `code only` for memtrace. But §1's own ownership table scopes memtrace to "code. Symbols, call graphs, 'why is this here', **decisions**." Cortex decision memory (`recall_decision`, `fleet_record_episode`, `fleet_ydoc_append`) stores free-text rationale written by an agent that has read the repo — the same risk vector the Claude column flags as "yes, and nothing prevents it." Two reviewers scoring this row against §1 would diverge: one reads "code only" as covering only the parsed AST graph and marks the row false for the decision layer; the other reads it as "memtrace holds code-derived facts, not session chatter" and marks it true. The artifact's own §1 created the ambiguity by bundling decisions into memtrace's scope while §2's confidentiality row excludes them.
**Layer of the implied fix:** L3
**Anchor:** `| **can it hold confidential data** | **yes, and nothing prevents it** — it is free text written by an agent that has read the repo | code only | run records only |`

### 3. Lab 9.4's three questions
**Verdict:** finding
**Failure:** The advertised total is 25 assertions, broken into "11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided." Read as four disjoint buckets these sum to 26. Read as "1 true-but-obsolete is a subset of the 11 true" they sum to 25. The sentence structure — a comma-separated list with "and" before the final item — presents them as parallel categories, which is the 26 reading. A reviewer who needs the exact false-rate or undecided-rate (both reported as fractions of 25 downstream) would compute different denominators depending on which reading they take. The artifact never disambiguates whether "true but obsolete" is inside or outside the 11.
**Layer of the implied fix:** L3
**Anchor:** `of the **25** assertions the memory index advertises, **11 are true, 1 is true but obsolete, 7 are false, and 7 cannot be decided by running anything.**`

### 4. Layers — applied in order, stopping at the first yes
**Verdict:** finding
**Failure:** The frozen-audit row claims "L1 as a record" on the grounds that "no later session can make it say otherwise without rewriting a committed file — which §6 forbids." Applied in order, the layer model's first test is: *can the bad value still be written down after the fix?* A rewritten audit file can be written, committed, and force-pushed — the §6 forbiddance is a rule a human reads, which is L3, not a structural impossibility. So by the model's own test this is L3, not L1. Two reviewers applying the lab's layer rules would diverge: one stops at step 1 and says "the file is editable, so not L1"; the other accepts "committed + append-only" as structural enough. The row also references "§6" — there is no §6 in this artifact (sections run 1–5). A reader without external context cannot resolve whether §6 lives in the phase README, the run prompt, or nowhere.
**Layer of the implied fix:** L3
**Anchor:** `| The frozen audit | **L3 as a control, L1 as a record** | It stops nothing from being written down. But it is append-only evidence of a past state, and no later session can make it say otherwise without rewriting a committed file — which §6 forbids. |`

### 5. What is not built, and the reason
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No scoring categories exist in this artifact; it is a policy, not a rubric. The layer table in §4 is descriptive, not scored.
- Which single section would you expect two reviewers to diverge on most, and by how much? §4 — the "L1 as a record" claim is the one place the artifact applies the lab's own layer model and gets the test result backwards (the bad value is writable, so step 1 says "not L1"). A reviewer who reads "L1 as a record" charitably (committed evidence is structurally hard to alter without trace) vs. one who applies the test literally (editable → not L1) would land one full layer apart.
- What did the artifact not say that it needed to say? It never states whether "true but obsolete" is a subset of the 11 true or a fifth disjoint bucket — and the sum hangs on it. It also never resolves where §6 lives, leaving a dangling internal reference in the one section that argues about structural impossibility.
