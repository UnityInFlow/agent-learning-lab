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
reviewed_utc:    20260925T155022Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: ../agent-observatory/runner/verify-agents-hash.sh
    sha:  f30200a2c43f
    dirty: false
  - path: ../agent-observatory/runner/ci-exempt.tsv
    sha:  0553b30fa73d
    dirty: false
lab_head:        41ff94d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Off-contract output — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: runner/verify-agents-hash.sh
  verdict: REJECT
  summary: Case F's comment attributes the backstop role for "content-only digest" to the wrong test case, and a future editor who follows that guidance could remove Case D as redundant — at which point the registered clause ("tells a renamed file from a changed one") becomes silently unenforced.
  blocking:
    - reason: Case F's comment claims a content-only digest "would pass D and E separately and fail here." Under a content-only digest, H_REN and H_ONE both hash "Body A." and are equal — so D is the case that fails, not F. F passes under content-only because H_REN hashes "Body A." and H_CHG hashes "Body A, edited." (different content). The comment's attribution is backwards: D is the actual guard that catches a content-only digest; F is not.
      wrong_action: A future editor reads F as the registered backstop and the source of the "rename vs change" guarantee, concludes D is redundant (since the comment says F is what catches the defect), and deletes Case D. After deletion, a content-only digest passes every remaining case and the registered clause from decision 11 item 9 is silently unenforced.
      anchor: "# F — THE REGISTERED CLAUSE. D and E must not be the same value. A digest over content alone\n#     would pass D and E separately and fail here, and that is exactly the defect being\n#     excluded: \"tells a renamed file from a changed one\" (decision 11 item 9)."
      evidence: runner/verify-agents-hash.sh:119-126
  non_blocking:
    - reason: The script does not test deletion from a multi-file overlay (removing `beta.md` from TWO). The header scopes the work to decision 11 item 9 ("tells a renamed file from a changed one"), so deletion may be intentionally out of scope — but the header also generalizes to "the SET of `.claude/agents/*.md`," and a set-digest contract that is not exercised against a removed member is not fully proven.
      evidence: runner/verify-agents-hash.sh:5-9
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | OFF CONTRACT | 342s |
| ollama-cloud/glm-5.2 | ok | 115s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| verify-agents-hash.sh | 1/1 | L3 |


---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### verify-agents-hash.sh
**Verdict:** finding
**Failure:** Case F's comment (lines 119-121) states: "A digest over content alone would pass D and E separately and fail here." This is factually wrong. With a content-only digest, H_REN and H_ONE both hash "Body A." and are equal, so **D fails** — D is the actual guard against content-only digests. F passes under content-only because H_REN hashes "Body A." and H_CHG hashes "Body A, edited." — different content, different hash. The concrete failure: a future editor reads F's comment, concludes F is the backstop for content-only digests and D is redundant, removes case D. A content-only digest now passes F undetected, and the "tells a renamed file from a changed one" clause — the script's stated purpose — is silently unenforced. The diff is deleting lines 104-110; before it, a content-only digest is caught at D; after it, the same defect passes every remaining case.
**Layer of the implied fix:** L3
**Anchor:** `# F — THE REGISTERED CLAUSE. D and E must not be the same value. A digest over content alone
#     would pass D and E separately and fail here, and that is exactly the defect being
#     excluded: "tells a renamed file from a changed one" (decision 11 item 9).`

### ci-exempt.tsv
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not applicable — these are test fixtures and a CI-exemption registry, not a scoring rubric. No category/gate overlap.
- **Which single section would you expect two reviewers to diverge on most, and by how much?** The F comment. A reviewer who traces the content-only-digest scenario through D and E will catch the misattribution; one who reads the comment at face value will not. I'd expect roughly 1 in 2 to miss it — the comment is confident, specific, and wrong, which is the hardest combination to catch by reading.
- **What did the artifact not say that it needed to say?** The script does not test deletion from a multi-file overlay (removing `beta.md` from the TWO fixture). That is a third mutation alongside rename and edit, and the set-digest contract covers it, but nothing proves it does. The clause scope ("tells a renamed file from a changed one") may exclude it by intent — but the script's header generalizes to "the SET of `.claude/agents/*.md`," and a set that cannot detect a removed member is not fully tested.
