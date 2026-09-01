# opencode review — backend-quality

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
opencode:        1.18.21
reviewed_utc:    20260827T182829Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  06fb70ec9354
lab_head:        5189b25
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: benchmark/rubrics/backend-quality.yaml
  verdict: REJECT
  summary: Two authoring defects the artifact's own commentary almost catches. (1) The rubric's gate-passing precondition — "the single most important rule" — is enforced only by prose (L3), not by the scorer; `opencode-score.sh` will compute a score on a known-bad directory, producing the meaningless number the artifact itself warns about. (2) The test-quality ladder routes a zero-assertion test file to score 1 (residual) while a status-code-only file scores 0 (anchor 0 holds), inverting the ranking of badness; the comment block at line 153 acknowledges the vacuity concern but the fix routes zero-assertions to 1 rather than to null as the comment implies, because the precondition only covers "no file under src/test/" and not "file with zero assertions."
  blocking:
    - reason: The rubric's "single most important rule" — gate-failing runs must not be scored — is enforced only by prose (E-001's Exclusions document, L3), not by the scorer; `opencode-score.sh` will compute a score on a `known-bad-*` directory. The rubric names the missing L2 closure itself: "The L2 version is the scorer refusing a target that is not a registered gate-passing `run_case`; it does not exist."
      wrong_action: A reader runs `opencode-score.sh` against a known-bad directory, gets a number, and ranks it against gate-passing runs. The artifact names this exact outcome: "A score computed on a gate-failing submission is not a weaker result, it is a different measurement wearing this one's units."
      anchor: "AND NOTHING HERE ENFORCES IT. This file assumes its input has already cleared the gates — every \"the gates own that\" above depends on it — but `opencode-score.sh` will score any directory it is handed, `known-bad-*` included. The filter lives in E-001's Exclusions, which is a document. **L3.** The L2 version is the scorer refusing a target that is not a registered gate-passing `run_case`; it does not exist. A score computed on a gate-failing submission is not a weaker result, it is a different measurement wearing this one's units."
      evidence: benchmark/rubrics/backend-quality.yaml:96-101
    - reason: The test-quality ladder inverts the ranking of two bad submission types: a zero-assertion test file scores 1 (residual), while a status-code-only file scores 0 (anchor 0 holds). The comment block at line 153 acknowledges the vacuity concern and adds the "at least one assertion exists" clause to prevent anchor 0 from being vacuously true of zero assertions. With the clause, zero assertions fails anchor 0 (the "at least one assertion exists" conjunct fails) and is routed by the ladder to score 1, not to null as the comment implies — the precondition at line 151 only triggers on "No file under src/test/" and never fires for a present-but-empty test file.
      wrong_action: Two submissions scored under this rubric rank in the wrong order: a zero-assertion file (scores 1) outranks a status-code-only file (scores 0), despite the latter testing at least the response status while the former tests nothing. Worse, the artifact's own commentary says zero assertions "would return 0 where the precondition says `null`" — the comment is reasoning about a precondition stronger than the one the file declares, and the reader who trusts the comment over the ladder will be misled about which score a scorer will actually emit.
      anchor: "At least one assertion exists, AND every assertion is a status code: none reads a response body, none re-reads state through a second request. The opening clause is not decoration — without it this anchor is vacuously true of a file with no assertions at all, and a scorer entering the ladder without the precondition would return 0 where the precondition says `null`. Cite the assertion list."
      evidence: benchmark/rubrics/backend-quality.yaml:153
  non_blocking:
    - reason: Anchor 2 of architecture-consistency uses "existing ApiException subclass" without disambiguating pre-existing vs. post-existing; a new subclass declared in `com.unityinflow.sample.api` and thrown in the same submission could be read either way. The gap analysis at line 48 implicitly treats "existing" as pre-existing, but the anchor text itself is silent.
      evidence: benchmark/rubrics/backend-quality.yaml:119
    - reason: Anchor 0 of change-focus excludes trailing-whitespace differences ("beyond trailing whitespace") but anchor 2 requires "character-identical," which a strict reading would not exclude; a method differing from the baseline only in trailing whitespace routes to score 1 instead of 2. Anchor 2 should be qualified with the same trailing-whitespace exclusion anchor 0 carries.
      evidence: benchmark/rubrics/backend-quality.yaml:164-166
    - reason: The gap analysis (line 48) mischaracterizes anchor 1 of architecture-consistency: it claims "Anchor 1 wants a type 'not imported from' api," but the anchor text at line 118 says "a new exception type, whether or not it lives in `com.unityinflow.sample.api`." A scorer reading the anchor directly gets the correct shape; a scorer reasoning from the gap analysis would misread.
      evidence: benchmark/rubrics/backend-quality.yaml:48, 118
    - reason: Cross-submission ranking across different null sets is acknowledged as an open question (the test-quality null rate is 3/5) but not resolved; this is properly handed forward in the comment block rather than hidden, so a reader who reads the rubric knows totals over different null sets are not comparable.
      evidence: benchmark/rubrics/backend-quality.yaml:84-89
  disputed:
    - finding: Null definition asymmetry — the rubric only licenses null for the 0 condition's uncertainty, not the 2 condition's, so a scorer unable to decide 2 while able to decide 0 as false would be left without a defined score.
      why: The ladder handles the contested case. If 0 is decidable as false and 2 is undecidable, the ladder gives 1 (because "EVERY clause of 2 holds" cannot be confirmed, so 2 doesn't hold), not null. The null definition is narrow but the ladder is the operative logic and produces a defined score in every contested case; a scorer following the ladder cannot reach a state where they must choose between null and a defined score. The artifact's "Never as a shrug" line locks this down.
    - finding: test-quality's "at least one assertion exists" clause is correctly identified by the comment as preventing vacuous truth of anchor 0, so the ladder is sound.
      why: The clause does prevent vacuous truth of anchor 0 — that part of the comment is correct. But the comment's follow-on claim, "would return 0 where the precondition says `null`," is wrong about the current artifact: the precondition at line 151 only triggers on "No file under src/test/," and a present-but-empty file reaches the ladder, which gives 1, not null. The clause is necessary; the comment overstates what it achieves.
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Comment block | 1/1 | L2 |
| categories | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### Comment block
**Verdict:** finding
**Failure:** Two distinct failures, both concrete.

(1) The artifact's "single most important rule in the business case" — a gate-failing run is unsuccessful and must not be scored — is unenforced. The artifact says so itself: "AND NOTHING HERE ENFORCES IT." The concrete failure: `opencode-score.sh` is handed a `known-bad-*` directory, computes a score, and that number is ranked alongside gate-passing runs. The artifact identifies the L2 closure (scorer refusing a non-gate-passing `run_case`) and states it does not exist. The filter lives in "E-001's Exclusions, which is a document." A document is L3. The bad value — a score on a gate-failing submission — can still be produced; nothing executes to reject it.

(2) The null definition is asymmetric: "`null` keeps exactly two jobs: a precondition failed … or the evidence does not let you decide whether the 0 condition holds." It names only the 0 condition. A submission where the 0 condition is clearly false but the 2 condition is undecidable (e.g., architecture-consistency where no error body is constructed but whether a thrown subclass is "existing" cannot be resolved from the attachments) falls through the ladder to 1, because "EVERY clause of 2 holds" cannot be confirmed. The artifact never says this is the intended behaviour for the 2 condition — a scorer who cannot decide 2 may reasonably emit `null` instead, since the artifact's null definition only licenses null for the 0 condition. Two scorers diverge: one follows the ladder to 1, the other reads the null definition literally and nulls.

**Layer of the implied fix:** L2 (the scorer refusing non-gate-passing targets) for failure 1; L3 (disambiguating the null definition to cover the 2 condition) for failure 2.
**Anchor:** "AND NOTHING HERE ENFORCES IT. This file assumes its input has already cleared the gates … but `opencode-score.sh` will score any directory it is handed, `known-bad-*` included." / "`null` keeps exactly two jobs: a precondition failed (no test file, no baseline), or the evidence does not let you decide whether the 0 condition holds."

### version
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### scale
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### categories
**Verdict:** finding
**Failure:** Three findings across three categories; the most serious is the score inversion in test-quality.

(1) **test-quality — score inversion for zero-assertion files.** A test file with zero assertions scores 1 (the residual), while a test file with only `assertThat(response.statusCode).isEqualTo(200)` scores 0. The worse submission scores higher. The ladder: 0 requires "at least one assertion exists" (false for zero assertions → 0 doesn't hold); 2 requires all three clauses (none hold → 2 doesn't hold); score 1. For the status-code-only file, 0 holds (at least one assertion, all are status codes). The artifact's own comment (line 153) acknowledges the zero-assertions case and adds the opening clause to prevent vacuous truth of anchor 0 — but the fix only prevents 0 from being vacuously true; it does not prevent the inversion, because the ladder routes zero-assertions to 1, which is above 0. Two reviewers diverge: one follows the ladder (1), the other says zero assertions is worse than only-status-codes and the ranking is wrong.

(2) **architecture-consistency — "existing" in anchor 2 is ambiguous.** Anchor 2 awards the top score when "Every refusal throws an existing `ApiException` subclass imported from `com.unityinflow.sample.api`." A submission that declares a NEW `ApiException` subclass in `com.unityinflow.sample.api` and throws it: a scorer reading "existing" as "present in the codebase after the change" scores 2; a scorer reading "existing" as "pre-existing" (the gap analysis's reading, line 48) scores 1. The gap analysis disambiguates, but it mischaracterizes anchor 1 in doing so — it says anchor 1 "wants a type 'not imported from' api" when anchor 1's actual text says "a new exception type, whether or not it lives in `com.unityinflow.sample.api`" (line 118). A scorer who notices this inconsistency may distrust the gap analysis and read "existing" loosely, scoring 2. The ladder gives 1 either way (since "existing" as pre-existing fails), but a scorer who reads "existing" as "present in the codebase" and confirms all other clauses of 2 will score 2.

(3) **change-focus — trailing-whitespace asymmetry between anchor 0 and anchor 2.** Anchor 0 counts a method as differing only if it differs "beyond trailing whitespace." Anchor 2 requires every unnamed method to be "character-identical" to the baseline. A submission where one unnamed method differs only in trailing whitespace: 0 doesn't hold (the difference is not "beyond trailing whitespace," and only one method differs anyway); 2 doesn't hold (the method is not character-identical). Score 1. A careful human scores 2 — trailing whitespace is not a meaningful change, and anchor 0's own exclusion of trailing whitespace signals the artifact agrees. But anchor 2's "character-identical" does not exclude it, creating a gap the ladder fills with 1.

**Layer of the implied fix:** L3 for all three — each is an anchor-wording ambiguity or ladder gap that a model reads and resolves differently, not something that executes.
**Anchor:** "At least one assertion exists, AND every assertion is a status code" (line 153) / "an existing `ApiException` subclass" (line 119) / "character-identical to the baseline" (line 166) vs. "differ from the baseline in anything beyond trailing whitespace" (line 164).

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The artifact explicitly dropped `functional-correctness` and `requirement-completeness` for this reason. The four remaining categories score quality among gate-passing submissions, not correctness. `test-quality`'s precondition (no test file → null) partially overlaps with a gate that requires tests to exist and pass, but for gate-passing submissions the precondition never triggers, so the overlap is inert.

- **Which section would two reviewers diverge on most, and by how much?** `categories` → `test-quality`, by one full point (0 vs 1). The zero-assertions inversion is the sharpest: the ladder mechanically produces 1 for a file with no assertions and 0 for a file with only status-code assertions, and a reviewer who notices the inversion will refuse to follow the ladder. The architecture "existing" ambiguity is a close second, also one full point (1 vs 2), but it requires a scorer to read "existing" loosely against the gap analysis, which is a softer disagreement.

- **What did the artifact not say that it needed to say?** The artifact says "a total over three categories is NOT COMPARABLE to a total over four" and instructs: "Report the categories that nulled beside every total, or do not report the total." But the purpose of the rubric is to rank submissions against each other. When some submissions null on `test-quality` (3 of 5 variants) and others do not, the artifact provides no procedure for ranking across different null sets. "Do not report the total" is guidance for presentation, not a resolution for comparison. Two submissions — one scored 90/100 on three categories (test-quality null), one scored 70/100 on four — cannot be ranked by the formula, and the artifact does not say how to rank them. The non-comparability is acknowledged; the resolution is absent.
